param (
    [string]$password,
    [string[]]$servers
)

function Install-Kubernetes {
    param (
        [string]$server
    )
    Write-Host "Installing Kubernetes on $server"
    clusrun /nodes:$server 'sudo apt-get update && sudo apt-get install -y apt-transport-https curl'
    clusrun /nodes:$server 'echo deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ / | sudo tee /etc/apt/sources.list.d/kubernetes.list'
    clusrun /nodes:$server 'sudo mkdir /etc/apt/keyrings'
    clusrun /nodes:$server 'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg'
    clusrun /nodes:$server 'sudo apt-get update && sudo apt-get install -y kubelet kubeadm kubectl docker.io'

    clusrun /nodes:$server "wget https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb"
    clusrun /nodes:$server "sudo dpkg -i packages-microsoft-prod.deb"
    clusrun /nodes:$server "rm packages-microsoft-prod.deb"

    clusrun /nodes:$server 'mkdir -p $HOME/.kube'
    clusrun /nodes:$server 'echo ''export PATH=$PATH:$HOME/KubernetesWrapper/net8.0'' >> ~/.profile'
}

function Init-Master-Node {
    param (
        [string]$server
    )
    clusrun /nodes:$server 'rm -f ~/.ssh/kube_key*'
    clusrun /nodes:$server 'ssh-keygen -t rsa -N """" -f ~/.ssh/kube_key'

    clusrun /nodes:$server 'sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0 && sudo apt install sshpass -y'
    clusrun /nodes:$server 'git clone https://github.com/Azure/hpcpack.git && cd hpcpack && git checkout tianyiliu/deploy-Kubernetes-script'
    clusrun /nodes:$server 'dotnet build ~/hpcpack/code/KubernetesWrapper/KubernetesWrapper.sln'
    clusrun /nodes:$server 'mkdir KubernetesWrapper && cp -r ~/hpcpack/code/KubernetesWrapper/KubernetesWrapper/bin/Debug/net8.0 ~/KubernetesWrapper'
    
    clusrun /nodes:$server 'sudo kubeadm init --pod-network-cidr=10.1.0.0/16'
    clusrun /nodes:$server 'sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config'
    clusrun /nodes:$server 'sudo chown $(id -u):$(id -g) $HOME/.kube/config'
    clusrun /nodes:$server 'kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml'
    clusrun /nodes:$server 'curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O'
    clusrun /nodes:$server 'sed -i ''s/cidr: 192\.168\.0\.0\/16/cidr: 10.1.0.0\/16/g'' custom-resources.yaml'
    clusrun /nodes:$server 'kubectl apply -f custom-resources.yaml'
    sleep 100
    clusrun /nodes:$server 'kubectl taint nodes --all node-role.kubernetes.io/control-plane-'
}

foreach ($server in $servers) {
    Install-Kubernetes -server $server
}

Init-Master-Node -server $servers[0]
$joinClusterCommand = clusrun /nodes:$($servers[0]) "sudo kubeadm token create --print-join-command"
$joinClusterCommand = "sudo " + $joinClusterCommand[1]
Write-Host joinClusterCommand
Write-Host $joinClusterCommand

for ($i = 1; $i -lt $servers.Length; $i++) {
    clusrun /nodes:$($servers[$i]) 'mkdir -p $HOME/.kube'
    clusrun /nodes:$($servers[0]) "sshpass -p $password ssh-copy-id -i ~/.ssh/kube_key.pub -o StrictHostKeyChecking=no $($servers[$i])"
    clusrun /nodes:$($servers[0]) "sshpass -p $password scp ~/.kube/config hpcadmin@$($servers[$i]):~/.kube"
    clusrun /nodes:$($servers[$i]) $joinClusterCommand
    
    clusrun /nodes:$($servers[$i]) "sudo apt-get update && sudo apt-get install -y dotnet-runtime-8.0"
    clusrun /nodes:$($servers[0]) "sshpass -p $password scp -r ~/KubernetesWrapper hpcadmin@$($servers[$i]):~/KubernetesWrapper"
}

# try {
#     New-HpcGroup -Name "Kubernetes"
# } catch {
#     write-host "Group Kubernetes already exists"
# }

Add-HpcGroup -Name "Kubernetes" -NodeName $servers
