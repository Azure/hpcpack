using k8s;

namespace KubernetesAPP
{
    internal class PodList
    {
        private static void Main(string[] args)
        {
            //var config = KubernetesClientConfiguration.BuildConfigFromConfigFile("~/.kube/config");
            //IKubernetes client = new Kubernetes(config);
            //Console.WriteLine("Starting Request!");

            //var list = client.CoreV1.ListNamespacedPod("default");
            //foreach (var item in list.Items)
            //{
            //    Console.WriteLine(item.Metadata.Name);
            //}

            //if (list.Items.Count == 0)
            //{
            //    Console.WriteLine("Empty!");
            //}
            var fi = new FileInfo("/home/hpcadmin/.kube/config");
            Console.WriteLine(fi.DirectoryName);
        }
    }
}
