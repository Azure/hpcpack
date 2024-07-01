using k8s;
using k8s.Models;

namespace KubernetesAPP
{
    internal class PodList
    {
        private static async Task Main(string[] args)
        {
            string? homeDirectory = Environment.GetEnvironmentVariable("HOME");
            homeDirectory = homeDirectory ?? "/home/hpcadmin";
            var config = KubernetesClientConfiguration.BuildConfigFromConfigFile($"{ homeDirectory }/.kube/config");
            IKubernetes client = new Kubernetes(config);

            var pod = new V1Pod
            {
                Metadata = new V1ObjectMeta
                {
                    Name = "busybox-sleep-forever",
                    NamespaceProperty = "default"
                },
                Spec = new V1PodSpec
                {
                    Containers =
                    [
                        new V1Container
                        {
                            Name = "busybox",
                            Image = "busybox",
                            Command = ["sh", "-c", "sleep 3600"]
                        }
                    ],
                    RestartPolicy = "Always"
                }
            };

            // Create the pod in the default namespace
            var createdPod = await client.CoreV1.CreateNamespacedPodAsync(pod, "default");

            //var podlistResp = client.CoreV1.ListNamespacedPodWithHttpMessagesAsync("default", watch: true);
            //await foreach (var (type, item) in podlistResp.WatchAsync<V1Pod, V1PodList>())
            //{
            //    Console.WriteLine("==on watch event==");
            //    Console.WriteLine(type);
            //    Console.WriteLine(item.Metadata.Name);
            //    Console.WriteLine(item.Status.Phase);
            //    Console.WriteLine("==on watch event==");
            //    if (item.Status.Phase == "Succeeded")
            //    {
            //        Console.WriteLine("Pod is done!");
            //        break;
            //    }
            //}
        }
    }
}
