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
            Console.WriteLine("Starting Request!");

            var job = new V1Job
            {
                ApiVersion = "batch/v1",
                Kind = "Job",
                Metadata = new V1ObjectMeta
                {
                    Name = "stress-job"
                },
                Spec = new V1JobSpec
                {
                    Template = new V1PodTemplateSpec
                    {
                        Metadata = new V1ObjectMeta
                        {
                            Name = "stress-job"
                        },
                        Spec = new V1PodSpec
                        {
                            Containers = new[]
                            {
                                new V1Container
                                {
                                    Name = "stress",
                                    Image = "progrium/stress",
                                    Command = new []
                                    {
                                        "stress"
                                    },
                                    Args = new []
                                    {
                                        "--cpu", "4", "--timeout", "60s"
                                    },
                                    Resources = new V1ResourceRequirements
                                    {
                                        Requests = new System.Collections.Generic.Dictionary<string, ResourceQuantity>
                                        {
                                            { "cpu", new ResourceQuantity("500m") }
                                        },
                                        Limits = new System.Collections.Generic.Dictionary<string, ResourceQuantity>
                                        {
                                            { "cpu", new ResourceQuantity("2") }
                                        }
                                    }
                                }
                            },
                            RestartPolicy = "Never"
                        }
                    },
                    BackoffLimit = 0,
                    TtlSecondsAfterFinished = 60
                }
            };

            var createdJob = await client.BatchV1.CreateNamespacedJobAsync(job, "default");

            //var podlistResp = client.CoreV1.ListNamespacedPodAsync("default", watch: true);
            var podlistResp = client.CoreV1.ListNamespacedPodWithHttpMessagesAsync("default", watch: true);
            // C# 8 required https://docs.microsoft.com/en-us/archive/msdn-magazine/2019/november/csharp-iterating-with-async-enumerables-in-csharp-8
            
            
            await foreach (var (type, item) in podlistResp.WatchAsync<V1Pod, V1PodList>())
            {
                Console.WriteLine("==on watch event==");
                Console.WriteLine(type);
                Console.WriteLine(item.Metadata.Name);
                Console.WriteLine(item.Status.Phase);
                Console.WriteLine("==on watch event==");
                if (item.Status.Phase == "Succeeded")
                {
                    Console.WriteLine("Pod is done!");
                    break;
                }
            }
        }

    }
}
