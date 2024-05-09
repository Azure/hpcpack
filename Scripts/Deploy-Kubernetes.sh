#!/bin/bash

sudo apt update
echo "Installing Python 3.10 and Pip"
sudo apt install software-properties-common -y
sudo add-apt-repository ppa:deadsnakes/ppa -y
sudo apt update
sudo apt install python3.10 python3.10-venv python3.10-dev -y
sudo rm /usr/bin/python3
sudo ln -s python3.10 /usr/bin/python3
sudo ln -s /usr/lib/python3/dist-packages/apt_inst.cpython-38-x86_64-linux-gnu.so /usr/lib/python3/dist-packages/apt_inst.so
sudo ln -s /usr/lib/python3/dist-packages/apt_pkg.cpython-38-x86_64-linux-gnu.so /usr/lib/python3/dist-packages/apt_pkg.so
curl https://bootstrap.pypa.io/get-pip.py | sudo python3

echo "Testing python3 and pip3"
python3 -V
pip3 -V
echo "End of Installing Python 3.10 and Pip"
# end of Installing Python 3.10 and Pip

echo "Generating ssh key and copying to all nodes"
sudo apt install sshpass -y
# ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

# # Function to display usage information
# usage() {
#     echo "Usage: $0 [-p password] [ip1 ip2 ...]" 1>&2
#     exit 1
# }

# # Parse command line options
# while getopts ":p:" opt; do
#     case ${opt} in
#         p)
#             password=$OPTARG
#             ;;
#         \?)
#             echo "Invalid option: -$OPTARG" >&2
#             usage
#             ;;
#         :)
#             echo "Option -$OPTARG requires an argument." >&2
#             usage
#             ;;
#     esac
# done
# shift $((OPTIND -1))

# # Check if at least one IP address is provided
# if [ $# -eq 0 ]; then
#     echo "Please provide at least one IP address." >&2
#     usage
# fi

# # Check if password is provided
# if [ -z "$password" ]; then
#     read -s -p "Enter password for SSH authentication: " password
#     echo
# fi

# echo "password: $password"
# IPS=()

# # Loop through each IP address and copy SSH key
# for ip in "$@"; do
#     IPS+=($ip)
#     echo "Copying SSH key to $ip..."
#     sshpass -p "$password" ssh-copy-id -o StrictHostKeyChecking=no "$ip"
#     if [ $? -eq 0 ]; then
#         echo "SSH key copied successfully to $ip."
#     else
#         echo "Failed to copy SSH key to $ip. Please check the password or connectivity."
#     fi
# done

# for ip in "${IPS[@]}"; do
#     echo "IP: $ip"
# done

# echo "Installing and disabling firewalld"
# sudo apt install firewalld -y
# sudo systemctl disable --now firewalld


# echo "Installing and configuring Kubernetes via kubespray"
# git clone https://github.com/kubernetes-sigs/kubespray
# cd kubespray
# # We may customize the version of kubespray here
# git checkout release-2.24
# sudo pip3 install -r requirements.txt
# cp -rfp inventory/sample inventory/mycluster
# CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
# ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root reset.yml
# ansible-playbook -i inventory/mycluster/hosts.yaml  --become --become-user=root cluster.yml
# mkdir -p $HOME/.kube
# sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
# sudo chown $(id -u):$(id -g) $HOME/.kube/config

# kubectl version


