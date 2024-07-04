using k8s;
using k8s.Autorest;
using k8s.Models;

namespace KubernetesAPP
{
    internal class PodList
    {
        static string RUNNINGSTATUS = "Running";
        private static async Task Main(string[] args)
        {
            //if (args.Length < 6)
            //{
            //    Console.WriteLine("Usage: <podName> <containerName> <imageName> <namespaceName> <command> <arguments>");
            //    return;
            //}
            //var (podName, containerName, imageName, namespaceName, command, arguments) = Util.ProcessArgs(args);
            var deploymentName = "busybox-job";
            var containerName = "busybox";
            var imageName = "busybox";
            var namespaceName = "default";
            var command = new[] { "sleep", "5" };
            var arguments = new[] { "" };
            var nodeList = new[] {"node3", "node4"};
            int ttlSecondsAfterFinished = 5;

            Console.WriteLine($"deployment Name: {deploymentName}");
            Console.WriteLine($"Container Name: {containerName}");
            Console.WriteLine($"Image Name: {imageName}");
            Console.WriteLine($"Namespace Name: {namespaceName}");
            Console.WriteLine("----");

            foreach (var item in command)
            {
                Console.WriteLine(item);
            }
            Console.WriteLine("----");

            foreach (var item in arguments)
            {
                Console.WriteLine(item);
            }
            Console.WriteLine("----");

            string? homeDirectory = Environment.GetEnvironmentVariable("HOME");
            homeDirectory ??= "/home/hpcadmin";
            var config = KubernetesClientConfiguration.BuildConfigFromConfigFile($"{homeDirectory}/.kube/config");
            IKubernetes client = new Kubernetes(config);

            var nodes = Environment.GetEnvironmentVariable("CCP_NODES");
            Console.WriteLine($"CCP_NODES: {nodes}");
            //Console.CancelKeyPress += async (sender, e) =>
            //{
            //    e.Cancel = true; // Prevent the process from terminating immediately
            //    Console.WriteLine("interrupt!!");

            //    try
            //    {
            //        var deployment = await client.AppsV1.ReadNamespacedDeploymentAsync(deploymentName, namespaceName);
            //        Console.WriteLine($"Deployment '{deploymentName}' found.");

            //        // Deployment exists, so delete it
            //        var deleteResult = await client.AppsV1.DeleteNamespacedDeploymentAsync(
            //            name: deploymentName,
            //            namespaceParameter: namespaceName
            //        );
            //        Console.WriteLine($"Deployment '{deploymentName}' deleted successfully.");

            //    }
            //    catch (k8s.Autorest.HttpOperationException ex) when (ex.Response.StatusCode == System.Net.HttpStatusCode.NotFound)
            //    {
            //        Console.WriteLine($"Deployment '{deploymentName}' does not exist.");
            //    }
            //    catch (Exception ex)
            //    {
            //        Console.WriteLine($"Error: {ex.Message}");
            //    }
            //};

            var job = await CreateJob(client, deploymentName, containerName, imageName, namespaceName, command, arguments, nodeList, ttlSecondsAfterFinished);

            var jobWatcher = client.BatchV1.ListNamespacedJobWithHttpMessagesAsync(
                namespaceName,
                labelSelector: $"app={containerName}",
                watch: true);

            await foreach (var (type, item) in jobWatcher.WatchAsync<V1Job, V1JobList>(
                onError: e =>
                {
                    Console.WriteLine($"Watcher error: {e.Message}");
                }))
            {
                Console.WriteLine($"Event Type: {type}");
                Console.WriteLine($"Job Name: {item.Metadata.Name}");
                Console.WriteLine($"Job Status Succeeded: {item.Status.Succeeded}");

                if (type == WatchEventType.Deleted)
                {
                    Console.WriteLine("Job reaches Deleted State. Exit monitoring now.");
                    break;
                } 
                else if (item.Status.Succeeded == nodeList.Length)
                {
                    Console.WriteLine($"All pods reach Success state. About to exit in {ttlSecondsAfterFinished} seconds.");
                }

                Console.WriteLine("----");
            }
        }

        public static async Task<V1Job?> CreateJob(IKubernetes client, string jobName, string containerName, string imageName, 
            string namespaceName, string[] command, string[] arguments, string[] nodeList, int ttlSecondsAfterFinished)
        {
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
                    Completions = nodeList.Length,
                    Parallelism = nodeList.Length,
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
                                                    new() {
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
                                new V1Container
                                {
                                    Name = containerName,
                                    Image = imageName,
                                    Command = command
                                }
                            ],
                            RestartPolicy = "Never"
                        }
                    }
                }
            };

            V1Job? result = null;
            try
            {
                result = await client.BatchV1.CreateNamespacedJobAsync(job, namespaceName);
                Console.WriteLine($"Job '{jobName}' created successfully.");
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
