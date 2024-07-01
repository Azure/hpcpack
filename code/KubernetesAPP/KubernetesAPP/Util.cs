namespace KubernetesAPP
{
    public class Util
    {
        public static string[] SplitStringBySpaces(string input)
        {
            if (string.IsNullOrEmpty(input))
            {
                return []; // Return an empty array if the input is null or empty
            }

            // Split the input string by spaces and return the array of words
            return input.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
        }

        public static (string podName, string containerName, string imageName, string namespaceName, string[] command, string[] arguments) ProcessArgs(string[] args)
        {
            string podName = args[0];
            string containerName = args[1];
            string imageName = args[2];
            string namespaceName = args[3];
            string[] command = SplitStringBySpaces(args[4]);
            string[] arguments = new[] { args[5] };
            return (podName, containerName, imageName, namespaceName, command, arguments);
        }
    }
}
