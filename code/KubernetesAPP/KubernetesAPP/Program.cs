using k8s;
using k8s.Models;

namespace KubernetesAPP
{
    internal class PodList
    {
        private static void Main(string[] args)
        {
            string? homeDirectory = Environment.GetEnvironmentVariable("HOME");
            homeDirectory = homeDirectory ?? "/home/hpcadmin";
            var config = KubernetesClientConfiguration.BuildConfigFromConfigFile($"{ homeDirectory }/.kube/config");
            IKubernetes client = new Kubernetes(config);
            Console.WriteLine("Starting Request!");

            client.CoreV1.CreateNamespacedPod(new V1Pod
            {
                Metadata = new V1ObjectMeta
                {
                    Name = "test-pod"
                },
                Spec = new V1PodSpec
                {
                    Containers = new List<V1Container>
                    {
                        new V1Container
                        {
                            Name = "test-container",
                            Image = "busybox",
                            Command = new List<string> { "sleep", "5" }
                        }
                    }
                }
            }, "default");

        }
    }
}
