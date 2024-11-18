## How to Deploy a Kubernetes Cluster in HPC Pack

### Usage 
We have 2 scripts to deploy a Kubernetes cluster, `Deploy-Kubernetes-Kubespray.ps1` and `Deploy-Kubernetes-Manually.ps1`. You can run them on your headnode. The usage is the same. 
```powershell
.\Deploy-Kubernetes-Kubespray.ps1 -password {password} -servers {servers}
```
or
```powershell
.\Deploy-Kubernetes-Manually.ps1 -password {password} -servers {servers}
```
Replace `{password}` with your password and `{servers}` with your node names seperated by commas.

### Differences
|            | Deploy-Kubernetes-Kubespray.ps1 | Deploy-Kubernetes-Manually.ps1 |
|------------|---------------------------------|--------------------------------|
| **Deployment** | Uses [Kubespray](https://github.com/kubernetes-sigs/kubespray) to deploy a Kubernetes cluster, providing flexibility to modify the script and install plugins. | Uses [kubeadm](https://github.com/kubernetes/kubeadm) to deploy a Kubernetes cluster, which does not support customization. | 
| **Output** | Runs a shell within a `clusrun` command, so there will be no output until the whole shell script completes. | Provides output as soon as a single `clusrun` command finishes. | 
| **Master Node Selection** | Selects the control-plane nodes based on its own algorithm. To configure this selection manually, modify the `inventory/mycluster/hosts.yaml` file. | Selects the first server in `servers` as the control-plane node. | 
| **Time** | Takes more time to deploy a cluster of the same scale. | Takes less time to deploy a cluster of the same scale. |

## KubernetesWrapper

KubernetsWrapper is a C# application to monitor [Kubernetes Jobs](https://kubernetes.io/docs/concepts/workloads/controllers/job/). It will create a pod and a job, run the job, remove both the pod and the job, and then print logs from the pod. After running the PowerShell scipt in the previous part, KubernetsWrapper will be installed on each node in the cluster. 

### Usage
The path has been added to `~/.profile`, so you can run it directly. It's a good practice to submit a HPC Pack job that starts `KubernetesWrapper`, then pass the parameters to this application.
```powershell
job submit /nodegroup:{nodegroup_name} /numcores:{numcores} bash -lc 'KubernetesWrapper --job {job_name} --container {container_name} --image {image_name} --namespace {namespace} --ttl {ttl_for_job} --argument {argument_list}'
```

For example, the following command will create a Kubernetes Job that takes up CPU usage.
```powershell
job submit /nodegroup:Kubernetes /numcores:6 bash -lc 'KubernetesWrapper --job cpu-stress-job --container stress --image progrium/stress --namespace default --ttl 5 --argument --cpu 2 --timeout 5s'
```

## Limitations
1. These scripts only works for Ubuntu distributions. Other distributions are not supported at this time.
2. `KubernetsWrapper` only monitors `job`. Other resouce types are not supported at this time.
