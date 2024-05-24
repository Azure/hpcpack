#!/bin/bash

resolve_hostname() {
    hostname=$1
    ip=$(dig +short $hostname)
    echo $ip
}

# ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
sudo apt install sshpass -y

# Parse command line options
while getopts ":p:" opt; do
    case ${opt} in
        p)
            password=$OPTARG
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            usage
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Check if at least one IP address is provided
if [ $# -eq 0 ]; then
    echo "Please provide at least one IP address." >&2
    usage
fi

# Check if password is provided
if [ -z "$password" ]; then
    read -s -p "Enter password for SSH authentication: " password
    echo
fi

echo "password: $password"
IPS=()

# Loop through each IP address and copy SSH key
for hostname in "$@"; do
    # Resolve the hostname to IP address and append to the array
    ip=$(resolve_hostname $hostname)
    IPS+=($ip)
    sshpass -p $password ssh-copy-id -i ~/.ssh/id_rsa.pub -o StrictHostKeyChecking=no $ip
done
