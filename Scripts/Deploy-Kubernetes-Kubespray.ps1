param (
    [string]$password,
    [string[]]$servers
)

$joinedServers = $servers -join ' '

clusrun /nodes:$($servers[0]) "git clone https://github.com/Azure/hpcpack.git && cd hpcpack && git checkout tianyiliu/deploy-Kubernetes-script && chmod +x Scripts/Deploy-Kubernetes.sh"
clusrun /nodes:$($servers[0]) "hpcpack/Scripts/Deploy-Kubernetes.sh -p '$password' $joinedServers"

New-HpcGroup -Name "Kubernetes" -ErrorAction SilentlyContinue
Add-HpcGroup -Name "Kubernetes" -NodeName $servers
