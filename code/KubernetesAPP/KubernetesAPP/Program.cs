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
            if (args.Length < 5)
            {
                Console.WriteLine("Usage: <podName> <containerName> <imageName> <namespaceName> <command>");
                return;
            }

            var (podName, containerName, imageName, namespaceName, command) = Util.ProcessArgs(args);

            Console.WriteLine($"Pod Name: {podName}");
            Console.WriteLine($"command: {command}");
            Console.WriteLine(command.Length);
            foreach (var item in command)
            {
                Console.WriteLine($"command item: {item}");
            }
            string? homeDirectory = Environment.GetEnvironmentVariable("HOME");
            homeDirectory = homeDirectory ?? "/home/hpcadmin";
            var config = KubernetesClientConfiguration.BuildConfigFromConfigFile($"{homeDirectory}/.kube/config");
            IKubernetes client = new Kubernetes(config);

            Console.CancelKeyPress += (sender, e) =>
            {
                Console.WriteLine("Ctrl+C pressed, shutting down...");
                e.Cancel = true; // Prevent the process from terminating immediately
            };

            var pod = new V1Pod
            {
                Metadata = new V1ObjectMeta
                {
                    Name = podName,
                    NamespaceProperty = namespaceName
                },
                Spec = new V1PodSpec
                {
                    Containers =
                    [
                        new V1Container
                        {
                            Name = containerName,
                            Image = imageName,
                            Command = ["sh", "-c", "sleep", "3600"]
                        }
                    ],
                    RestartPolicy = "Always"
                }
            };

            V1Pod? createdPod = null;
            try
            {
                // Create the pod in the default namespace
                createdPod = await client.CoreV1.CreateNamespacedPodAsync(pod, "default");
            }
            catch (HttpOperationException e)
            {
                Console.WriteLine($"Exception in creating pod: {e.Message}");
                return;
            }
            catch (Exception e)
            {
                Console.WriteLine($"Unknown exception in creating pod: {e.Message}");
                return;
            }

            Console.WriteLine($"Pod {podName} created.");
            var podWatcher = client.CoreV1.ListNamespacedPodWithHttpMessagesAsync(
                "default",
                fieldSelector: $"metadata.name={podName}",
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
                Console.WriteLine($"Pod Conditions: {string.Join(", ", item.Status.Conditions.Select(c => $"{c.Type}={c.Status}"))}");
                Console.WriteLine(new string('-', 20));

                if (item.Status.Phase == RUNNINGSTATUS)
                {
                    Console.WriteLine($"Pod {podName} is running. Exit monitoring.");
                    break;
                }
            }
        }
    }
}
