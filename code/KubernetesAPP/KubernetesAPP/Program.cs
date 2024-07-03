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
            var deploymentName = "busybox-deployment";
            var containerName = "busybox";
            var imageName = "busybox";
            var namespaceName = "default";
            var command = new[] { "sleep", "3600" };
            var arguments = new[] { "" };
            var nodeList = new[] {"node3", "node4"};
            
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

            Console.CancelKeyPress += async (sender, e) =>
            {
                e.Cancel = true; // Prevent the process from terminating immediately
                Console.WriteLine("interrupt!!");
                
                try
                {
                    var deployment = await client.AppsV1.ReadNamespacedDeploymentAsync(deploymentName, namespaceName);
                    Console.WriteLine($"Deployment '{deploymentName}' found.");

                    // Deployment exists, so delete it
                    var deleteResult = await client.AppsV1.DeleteNamespacedDeploymentAsync(
                        name: deploymentName,
                        namespaceParameter: namespaceName
                    );
                    Console.WriteLine($"Deployment '{deploymentName}' deleted successfully.");

                }
                catch (k8s.Autorest.HttpOperationException ex) when (ex.Response.StatusCode == System.Net.HttpStatusCode.NotFound)
                {
                    Console.WriteLine($"Deployment '{deploymentName}' does not exist.");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"Error: {ex.Message}");
                }
            };

            var pod = await CreateDeployment(client, deploymentName, containerName, imageName, namespaceName, command, arguments, nodeList);

            var podWatcher = client.CoreV1.ListNamespacedPodWithHttpMessagesAsync(
                "default",
                labelSelector: $"app={containerName}",
                watch: true);

            await foreach (var (type, item) in podWatcher.WatchAsync<V1Pod, V1PodList>(
                onError: e =>
                {
                    Console.WriteLine($"Watcher error: {e.Message}");
                }))
            {
                Console.WriteLine($"Event Type: {type}");
                Console.WriteLine($"Pod Name: {item.Metadata.Name}");
                Console.WriteLine($"Pod Status: {item.Status.Phase}");
                Console.WriteLine(new string('-', 20));

                if (item.Status.Phase == RUNNINGSTATUS)
                {
                    Console.WriteLine($"Pod {deploymentName} is running. Exit monitoring.");
                    break;
                }
            }
        }

        public static async Task<V1Deployment?> CreateDeployment(IKubernetes client, string deploymentName, string containerName, string imageName, 
            string namespaceName, string[] command, string[] arguments, string[] nodeList)
        {
            var deployment = new V1Deployment
            {
                ApiVersion = "apps/v1",
                Kind = "Deployment",
                Metadata = new V1ObjectMeta
                {
                    Name = deploymentName
                },
                Spec = new V1DeploymentSpec
                {
                    Replicas = nodeList.Length,
                    Selector = new V1LabelSelector
                    {
                        MatchLabels = new System.Collections.Generic.Dictionary<string, string>
                        {
                            { "app", containerName }
                        }
                    },
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
                            Containers =
                            [
                                new()
                                {
                                    Name = containerName,
                                    Image = imageName,
                                    Command = command,
                                    //Args = arguments
                                }
                            ],
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
                            }
                        }
                    }
                }
            };

            V1Deployment? result = null;
            try
            {
                result = await client.AppsV1.CreateNamespacedDeploymentAsync(deployment, namespaceName);
                Console.WriteLine($"Deployment '{deploymentName}' created successfully.");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error creating deployment: {ex.Message}");
            }

            return result;
        }
    }
}
