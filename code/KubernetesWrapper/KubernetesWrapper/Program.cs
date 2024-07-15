using k8s;
using k8s.Models;

namespace KubernetesWrapper
{
    internal class PodList
    {
        private static async Task Main(string[] args)
        {
            var (jobName, containerName, imageName, namespaceName, ttlSecondsAfterFinished, command, arguments) = Util.ProcessArgs(args);

            Console.WriteLine($"Job Name: {jobName}");
            Console.WriteLine($"Container Name: {containerName}");
            Console.WriteLine($"Image Name: {imageName}");
            Console.WriteLine($"Namespace Name: {namespaceName}");
            Console.WriteLine("---------");

            Console.WriteLine("Command: ");
            Console.WriteLine($"length: {command.Count}");
            foreach (var item in command)
            {
                Console.WriteLine(item);
            }
            Console.WriteLine("---------");

            Console.WriteLine("Arguments: ");
            Console.WriteLine($"length: {arguments.Count}");
            foreach (var item in arguments)
            {
                Console.WriteLine(item);
            }
            Console.WriteLine("---------");

            string? homeDirectory = Environment.GetEnvironmentVariable("HOME");
            homeDirectory ??= "/home/hpcadmin";
            var config = KubernetesClientConfiguration.BuildConfigFromConfigFile($"{homeDirectory}/.kube/config");
            IKubernetes client = new Kubernetes(config);

            var nodes = Environment.GetEnvironmentVariable("CCP_NODES");
            var nodeList = Util.GetNodeList(nodes);
            Console.WriteLine("node list: ");
            foreach (var item in nodeList)
            {
                Console.WriteLine(item);
            }
            Console.WriteLine("---------");

            if (nodeList.Count == 0)
            {
                nodeList = ["iaascn177", "iaascn178"];
            }

            if (nodeList.Count == 0)
            {
                Console.WriteLine("Node list is empty. Exiting...");
                return;
            }

            CancellationTokenSource source = new();
            CancellationToken token = source.Token;

            Console.CancelKeyPress += async (sender, e) =>
            {
                e.Cancel = true; // Prevent the process from terminating immediately
                Console.WriteLine("interrupt!!");

                try
                {
                    var job = await client.BatchV1.ReadNamespacedJobAsync(jobName, namespaceName);
                    Console.WriteLine($"Job '{jobName}' found.");
                    
                    // Job exists, so delete it
                    await client.BatchV1.DeleteNamespacedJobAsync(name: jobName, namespaceParameter: namespaceName);
                    Console.WriteLine($"Job '{jobName}' deleted successfully.");

                }
                catch (k8s.Autorest.HttpOperationException ex) when (ex.Response.StatusCode == System.Net.HttpStatusCode.NotFound)
                {
                    Console.WriteLine($"Job '{jobName}' does not exist.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                }

                var podList = await client.CoreV1.ListNamespacedPodAsync(namespaceName, labelSelector: $"app={containerName}");
                Console.WriteLine($"Pod list count: {podList.Items.Count}");
                foreach (var pod in podList.Items)
                {
                    try
                    {
                        Console.WriteLine($"Pod: {pod.Metadata.Name}");
                        await client.CoreV1.DeleteNamespacedPodAsync(pod.Metadata.Name, namespaceName, new V1DeleteOptions());
                        Console.WriteLine($"Deleted pod: {pod.Metadata.Name}");
                    }
                    catch (k8s.Autorest.HttpOperationException ex) when (ex.Response.StatusCode == System.Net.HttpStatusCode.NotFound)
                    {
                        Console.WriteLine($"Pod '{pod.Metadata.Name}' does not exist.");
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"Error: {ex.Message}");
                    }
                }

                source.Cancel();
            };

            try
            {
                await CreateJob(client, jobName, containerName, imageName, namespaceName, 
                    ttlSecondsAfterFinished, command, arguments, nodeList, token);

                var jobWatcher = client.BatchV1.ListNamespacedJobWithHttpMessagesAsync(
                    namespaceName,
                    labelSelector: $"app={containerName}",
                    watch: true,
                    cancellationToken: token);

                await foreach (var (type, item) in jobWatcher.WatchAsync<V1Job, V1JobList>(
                    onError: e =>
                    {
                        Console.WriteLine($"Watcher error: {e.Message}");
                    },
                    cancellationToken: token))
                {
                    //Console.WriteLine($"Event Type: {type}");
                    //Console.WriteLine($"Job Name: {item.Metadata.Name}");
                    //Console.WriteLine($"Job Status Succeeded: {item.Status.Succeeded}");

                    if (item.Status.Succeeded == nodeList.Count)
                    {
                        Console.WriteLine($"All pods reach Success state. About to exit in {ttlSecondsAfterFinished} seconds.");

                        if (type == WatchEventType.Deleted)
                        {
                            Console.WriteLine("Job reaches Deleted state. Exit monitoring now.");
                            break;
                        }
                    }
                    //Console.WriteLine("---------");
                }
            }
            catch (TaskCanceledException ex)
            {
                Console.WriteLine($"Stop watching. Task was canceled: {ex.Message}");
            }
        }

        public static async Task<V1Job?> CreateJob(IKubernetes client, string jobName, string containerName, string imageName, 
            string namespaceName, int ttlSecondsAfterFinished, List<string> command, List<string> arguments, List<string> nodeList,
            CancellationToken token)
        {
            V1Container? container = new()
            {
                Name = containerName,
                Image = imageName,
            };

            if (command.Count != 0)
            {
                container.Command = command;
            }

            if (arguments.Count != 0)
            {
                container.Args = arguments;
            }

            var job = new V1Job
            {
                ApiVersion = "batch/v1",
                Kind = "Job",
                Metadata = new V1ObjectMeta
                {
                    Name = jobName,
                    Labels = new System.Collections.Generic.Dictionary<string, string>
                    {
                        { "app", containerName }
                    }
                },
                Spec = new V1JobSpec
                {
                    Completions = nodeList.Count,
                    Parallelism = nodeList.Count,
                    TtlSecondsAfterFinished = ttlSecondsAfterFinished,
                    Template = new V1PodTemplateSpec
                    {
                        Metadata = new V1ObjectMeta
                        {
                            Labels = new System.Collections.Generic.Dictionary<string, string>
                            {
                                { "app", containerName }
                            }
                        },
                        Spec = new V1PodSpec
                        {
                            Affinity = new V1Affinity
                            {
                                NodeAffinity = new V1NodeAffinity
                                {
                                    RequiredDuringSchedulingIgnoredDuringExecution = new V1NodeSelector
                                    {
                                        NodeSelectorTerms =
                                        [
                                            new V1NodeSelectorTerm
                                            {
                                                MatchExpressions =
                                                [
                                                    new()
                                                    {
                                                        Key = "kubernetes.io/hostname",
                                                        OperatorProperty = "In",
                                                        Values = nodeList
                                                    }
                                                ]
                                            }
                                        ]
                                    }
                                }
                            },
                            Containers =
                            [
                                container
                            ],
                            RestartPolicy = "Never"
                        }
                    }
                }
            };

            V1Job? result = null;
            try
            {
                result = await client.BatchV1.CreateNamespacedJobAsync(job, namespaceName, cancellationToken: token);
                Console.WriteLine($"Job '{jobName}' created successfully.");
            }
            catch (TaskCanceledException ex)
            {
                Console.WriteLine($"Job will not be created. Task was canceled: {ex.Message}");
            }
            catch (k8s.Autorest.HttpOperationException ex) when (ex.Response.StatusCode == System.Net.HttpStatusCode.Conflict)
            {
                Console.WriteLine($"Job '{jobName}' already exists. Error: {ex.Message}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating deployment: {ex.Message}");
            }

            return result;
        }
    }
}
