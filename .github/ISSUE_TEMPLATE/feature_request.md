---
name: Azure Node automatic resize on Allocation failure due to Azure region data centre capacity limit
about: It should be possible to specify a "failover" VM size to use when deployment of normal VM size allocation or deployment fails due to to Azure region data centre capacity limit and execute the resize of the deallocated VM node, then start the VM node.

---

#### Feature Request Description
- Currently if an auto-scaling Azure node fails to deploy or spin up because of the normal Azure VM size allocation or deployment fails. e.g.
- 5/16/2024 9:29:00 AM	The operation on the Azure node MyNode001 finished with status 'Failed', error details:
{"code":"AllocationFailed","message":"Allocation failed. We do not have sufficient capacity for the requested VM size in this region. Read more about improving 
	likelihood of allocation success at http://aka.ms/allocation-guidance"}

- Unfortunately, this error handling does not help users or applications that depend on the Azure VM node being seamlessly available.  


#### Describe Preferred Solution
A HPC Powershell command (and maybe to GUI) to add an optional parameter to specify a "failover" VM size for a Azure node, and to use the parameter to resize the VM node if you get an error about VM size allocation or deployment failure due to to Azure region data centre capacity limit.   

#### Describe Alternatives Considered
An other option is to specify a "failover" HPC group to use instead, if VMs won't start in the primary HPC group because of this error.

#### Additional Context
![image](https://github.com/Azure/hpcpack/assets/170510965/d2987031-706d-4365-ae46-30d9a23e3cc9)

