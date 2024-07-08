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

        public static (string jobName, string containerName, string imageName, string namespaceName, int ttl,
            List<string> command, List<string> argument) ProcessArgs(string[] args)
        {
            // Initialize variables to store the parsed arguments
            string jobName = string.Empty;
            string containerName = string.Empty;
            string imageName = string.Empty;
            string namespaceName = string.Empty;
            int ttl = 0;
            List<string> command = [];
            List<string> argument = [];

            // Parse the command-line arguments
            for (int i = 0; i < args.Length; i++)
            {
                switch (args[i])
                {
                    case "--job":
                        if (i + 1 < args.Length)
                        {
                            jobName = args[i + 1];
                            i++;
                        }
                        break;
                    case "--container":
                        if (i + 1 < args.Length)
                        {
                            containerName = args[i + 1];
                            i++;
                        }
                        break;
                    case "--image":
                        if (i + 1 < args.Length)
                        {
                            imageName = args[i + 1];
                            i++;
                        }
                        break;
                    case "--namespace":
                        if (i + 1 < args.Length)
                        {
                            namespaceName = args[i + 1];
                            i++;
                        }
                        break;
                    case "--ttl":
                        if (i + 1 < args.Length)
                        {
                            int.TryParse(args[i + 1], out ttl);
                            i++;
                        }
                        break;
                    case "--command":
                        while (i + 1 < args.Length && !args[i + 1].StartsWith('-'))
                        {
                            command.Add(args[i + 1]);
                            i++;
                        }
                        break;
                    case "--argument":
                        while (i + 1 < args.Length && !args[i + 1].StartsWith('-'))
                        {
                            argument.Add(args[i + 1]);
                            i++;
                        }
                        break;

                }
            }

            return (jobName, containerName, imageName, namespaceName, ttl, command, argument);
        }

        // input: 2 IAASCN114 4 IAASCN117 4
        public static List<string> GetNodeList(string? ccp_nodes)
        {
            string[] splitted = SplitStringBySpaces(ccp_nodes);
            int length = 0;
            if (splitted.Length != 0)
            {
                length = Int32.TryParse(splitted[0], out length) ? length : 0;
            }
            List<string> nodes = [];
            for (int i = 0; i < length; i++)
            {
                nodes.Add(splitted[2 * i + 1].ToLower());
            }
            return nodes;
        }
    }
}
