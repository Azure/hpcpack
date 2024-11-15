## How to deploy a Kubernetes cluster in HPC Pack

### Usage 
We have 2 scripts to deploy a Kubernetes cluster, Deploy-Kubernetes-Kubespray.ps1 and Deploy-Kubernetes-Manually.ps1. You can run them on your headnode. The usage is the same. 

`.\Deploy-Kubernetes-Kubespray.ps1 -password '{your_password}' -servers IaaSCN1,IaaSCN2,IaaSCN3,IaaSCN4,IaaSCN5`
or
`.\Deploy-Kubernetes-Manually.ps1 -password '{your_password}' -servers IaaSCN1,IaaSCN2,IaaSCN3,IaaSCN4,IaaSCN5`

### Difference
1. Deploy-Kubernetes-Kubespray.ps1 uses [Kubespray](https://github.com/kubernetes-sigs/kubespray). Deploy-Kubernetes-Manually.ps1 uses kubeadm. It's more flexible to use Deploy-Kubernetes-Manually.ps1 because you can change the script and install plugins if you'd like to.
2. Deploy-Kubernetes-Kubespray.ps1 runs a shell within a `clusrun` command, so there will be no output until the whole shell script is completed. Just wait for it. Deploy-Kubernetes-Manually.ps1 will output something as soon as a single `clusrun` command is done.
3. Deploy-Kubernetes-Kubespray.ps1 will decide the master node or etcl node based on its own algorithm (change inventory/mycluster/hosts.yaml if you want to config in your way). Deploy-Kubernetes-Manually.ps1 will take the first server in `servers` as the master node.
4. Deploy-Kubernetes-Kubespray.ps1 takes more time than Deploy-Kubernetes-Manually.ps1 to deploy a cluster of the same scale.

## KubernetesWrapper

KubernetsWrapper is a C# application to monitor the [Kubernetes Job](https://kubernetes.io/docs/concepts/workloads/controllers/job/). It will create pod & job, run job, remove pod & job and print logs from pod. After running the powershell scipt in the previous part, KubernetsWrapper will be installed on each node in the cluster. 

### Usage
The path bas been added to ~/.profile, so you can run it directly. It's a good practice to submit a HPC Pack job that starts `KubernetesWrapper`, then pass the parameters to this application.
`job submit /nodegroup:{nodegroup_name} /numcores:{numcores} bash -lc 'KubernetesWrapper --job {job_name} --container {container_name} --image {image_name} --namespace {namespace} --ttl {ttl_for_job} --argument {argument_list}'`

For example,
`job submit /nodegroup:Kubernetes /numcores:6 bash -lc 'KubernetesWrapper --job cpu-stress-job --container stress --image progrium/stress --namespace default --ttl 5 --argument --cpu 2 --timeout 5s'`
It will create a Kubernetes Job that takes up CPU usage.

## Limitations
1. The script only works for Ubuntu distro. The other distros are not supported.
2. `KubernetsWrapper` only monitors `job`. The other resouce type is not supported.
