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

            //client.CoreV1.CreateNamespacedPod(new V1Pod
            //{
            //    Metadata = new V1ObjectMeta
            //    {
            //        Name = "test-pod"
            //    },
            //    Spec = new V1PodSpec
            //    {
            //        Containers = new List<V1Container>
            //        {
            //            new V1Container
            //            {
            //                Name = "test-container",
            //                Image = "busybox",
            //                Command = new [] { "sleep", "5" }
            //            }
            //        }
            //    }
            //}, "default");

            client.BatchV1.CreateNamespacedJob(new V1Job
            {
                ApiVersion = "batch/v1",
                Kind = "Job",
                Metadata = new V1ObjectMeta
                {
                    Name = "busybox-job"
                },
                Spec = new V1JobSpec
                {
                    TtlSecondsAfterFinished = 10,
                    Template = new V1PodTemplateSpec
                    {
                        Metadata = new V1ObjectMeta
                        {
                            Name = "busybox-pod"
                        },
                        Spec = new V1PodSpec
                        {
                            RestartPolicy = "Never",
                            Containers = new[]
                            {
                                new V1Container
                                {
                                    Name = "busybox-container",
                                    Image = "busybox",
                                    Command = new [] { "sleep", "5" }
                                }
                            }
                        }
                    }
                }
            }, "default");

            Console.WriteLine("Request Completed!");
        }
    }
}
