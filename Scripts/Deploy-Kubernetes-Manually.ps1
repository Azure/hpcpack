param (
    [string]$password,
    [string[]]$servers
)

function Install-Kubernetes {
    param (
        [string]$server
    )
    clusrun /nodes:$server sudo apt-get update; sudo apt-get install -y apt-transport-https curl
    clusrun /nodes:$server 'echo deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ / | sudo tee /etc/apt/sources.list.d/kubernetes.list'
    clusrun /nodes:$server sudo mkdir /etc/apt/keyrings
    clusrun /nodes:$server 'curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg'
    clusrun /nodes:$server sudo apt-get update; sudo apt-get install -y kubelet kubeadm kubectl docker.io
    clusrun /nodes:$server sudo kubeadm init --pod-network-cidr=10.1.0.0/16

    clusrun /nodes:$server mkdir -p $HOME/.kube
    clusrun /nodes:$server sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    clusrun /nodes:$server sudo chown $(id -u):$(id -g) $HOME/.kube/config

    clusrun /nodes:$server kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml
    clusrun /nodes:$server curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O
    clusrun /nodes:$server sed -i `'s/cidr: 192\.168\.0\.0\/16/cidr: 10.1.0.0\/16/g`' custom-resources.yaml
    clusrun /nodes:$server kubectl apply -f custom-resources.yaml
}


function Init-Master-Node {
    param (
        [string]$server
    )
    clusrun /nodes:$server sudo kubeadm init --pod-network-cidr=10.1.0.0/16
    clusrun /nodes:$server 'kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/tigera-operator.yaml'
    clusrun /nodes:$server 'curl https://raw.githubusercontent.com/projectcalico/calico/v3.26.1/manifests/custom-resources.yaml -O'
    clusrun /nodes:$server 'sed -i 's/cidr: 192\.168\.0\.0\/16/cidr: 10.1.0.0\/16/g' custom-resources.yaml'
    clusrun /nodes:$server 'kubectl apply -f custom-resources.yaml'
}


Install-Kubernetes -server $servers[0]


# $joinCommand = clusrun /nodes:$($servers[0]) "sudo kubeadm token create --print-join-command"
