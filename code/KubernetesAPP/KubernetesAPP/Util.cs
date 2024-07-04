namespace KubernetesAPP
{
    public class Util
    {
        public static string[] SplitStringBySpaces(string? input)
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

        // input: 2 IAASCN114 4 IAASCN117 4
        public static string[] GetNodeList(string? ccp_nodes)
        {
            string[] splitted = SplitStringBySpaces(ccp_nodes);
            int length = Int32.TryParse(splitted[0], out length) ? length : 0;
            string[] nodes = new string[length];
            for (int i = 0; i < length; i++)
            {
                nodes[i] = splitted[2 * i + 1];
            }
            return nodes;
        }
    }
}
