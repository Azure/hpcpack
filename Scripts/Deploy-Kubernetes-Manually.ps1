param (
    [string]$password,
    [string[]]$servers
)

clusrun /nodes:$($servers[0]) "sudo kubeadm token create --print-join-command"
