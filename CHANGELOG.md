# Change Log for Release

# HPC Pack 2019

## [HPC Pack 2019 Update 3 Refreshed (6.3.8328) - 2/11/2025](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2019-update-3?view=hpc19-ps)
## [HPC Pack 2019 Update 3 (6.3.8310) - 11/23/2024]()

## Enhancements to Job Scheduler

* **Initial [support for Kubernetes workloads](https://github.com/Azure/hpcpack/blob/master/Scripts/Kubernetes-Integration.md) within HPC Pack**
* **Supported head node FQDN from clients** - To enable client connection with head node FQDN, please add registry value named **EnableClientFQDN** with DWORD value 1 under registry key  `HKLM\SOFTWARE\Microsoft\HPC`
* **Configurable job history auto-cleanup options** - Support the following configurations for job cleanup.
  * These configurations can be viewed or set by `Get-HpcClusterProperty` or `Set-HpcClusterProperty`. Please use the default values unless there is any specific issue or requirement for the job history auto-cleanup.
  ```CMD
  SchedulerDeleteOldJobsTotalTimeout // default 14400 seconds
  SchedulerDeleteOldJobsDefaultCommandTimeout // default 60 seconds
  SchedulerDeleteOldJobRetryInterval // default 15000 milliseconds
  SchedulerDeleteOldJobsMaxBatchSize // default 2048 jobs
  SchedulerDeleteOldJobsMaxTimeout // default 480 seconds
  ```

* **Supported Windows environment configurations for Windows registry settings** - To use this feature, just set the environment variable with `CCP_CONFIG_` prefix, e.g., `CCP_CONFIG_CertificateValidationType`.
  * The following set environment command would override the cluster registry `CertificateValidationType` and bypass the certificate validation.
  ```CMD
  set CCP_CONFIG_CertificateValidationType=0
  ```
* **Supported jobs packing and tasks spreading on nodes** - By default, jobs are spreading on nodes and tasks are packing on nodes.
  * To enable jobs packing on nodes, run the following PowerShell cmdlet and then restart HpcScheduler service on all head nodes.
  ```powershell
  Set-HpcClusterProperty -SchedulerEnvFeatureFlags 'JOB_PACKING_ON_NODE'
  ```

  * To enable tasks spreading on nodes, run the following PowerShell cmdlet and then restart HpcScheduler service on all head nodes.
  ```powershell
  Set-HpcClusterProperty -SchedulerEnvFeatureFlags 'TASK_SPREADING_ON_NODE'
  ```
* **Fixed job failure when the cluster property DisableResourceValidation is set to True and the nodes are removed from job's node group** - The job would be requeued instead.
* **Fixed runaway tasks under stress**
* **Fixed clusrun job stuck when running on Linux node with a leftover named pipe from a failed task**
* **Fixed cluster event dispatching issue which caused a scheduler memory leak, job slowness, broker timeouts, and client event loss**
* **Fixed task stuck in queued state due to incorrect required core computation when adding tasks after a job is submitted with task dependencies**
* **Fixed node allocation order for tasks in a job as default packing by node names**
* **Fixed divided by zero exception when viewing job cost due to zero core nodes**
* **Fixed the issue that GPU job finished immediately with all tasks in queued state**
* **Fixed job failure when all nodes are removed from their node groups when `DisableResourceValidation` is set to True**
* **Fixed a job project name cleanup bug where the `SP_DeleteOldJobs` stored procedure was not handling null entries in the `ProjectId` Column properly**
* **Replaced an index in the `AllocationHistory` table to increase deletion performance**
* **Linux node support updates for new Linux distro versions**
* **Fixed job stuck in cancelling state due to race condition**
* **Fixed node reservation in queue mode when MIN_MAX_ON_NODE feature is enabled**

## Improvements to Setup and Management

* **Fixes for bursting to Azure IaaS VMs**
* **Fixes for bursting to Azure Batch pools**
* **Fixed Entra ID service principal creation error**
* **Fixed an authentication issue when bursting to IaaS VMs in regional Azure Cloud**
* **Updated API versions in Azure node template**
* **Supported Node Cool Down Time for auto grow and shrink on Azure** - A new auto grow shrink parameter `NodeCoolDownTime` was added for Azure IaaS VM nodes that failed to grow.
* You may set it to 100 minutes using the following PowerShell cmdlet. By default it is set to 10 minutes.
  ```powershell
  Set-HpcClusterProperty -NodeCoolDownTime 100
  ```
* **Support for new Azure IaaS VM SKUs**
* [**Improved logging integration with Azure Monitor**](https://aka.ms/hpcpack_bicep_am)
* [**Enhanced Azure deployment using Bicep**](https://aka.ms/hpcpack_bicep_template)
* **Inclusion of a Log Viewer GUI tool for easier log analysis**
* **Improved logic for handling Service Fabric certificate keys during installation**
* **Fixed an issue where service versions in `ServiceManifest.xml` were not set properly, causing Service Fabric cluster installation failure**
* **Security updates for dependent libraries and applications**
* **Fixed node stuck in draining state due to divide by zero error when removing the node**
* **Fixed Azure shared image version validation**

## SOA Runtime and Excel
* **.NET 8 SOA service hosts available on Windows compute nodes** - To enable .Net 8 SOA service hosts follow the steps below.
  * Download and install the latest .Net 8 Runtime and Asp.Net Core 8 Runtime from [here](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
  * Copy the installed bits to the head node file share, e.g, `\\<HeadNode>\reminst`, and then run the following `clusrun` commands on the compute nodes.
  ```CMD
  clusrun /nodegroup:ComputeNodes \\<HeadNode>\reminst\dotnet-runtime-8.0.8-win-x64.exe /install /passive /quiet
  clusrun /nodegroup:ComputeNodes \\<HeadNode>\reminst\aspnetcore-runtime-8.0.10-win-x64.exe /install /passive /quiet
  ```
  * Add or update **architecture="NET64"** under the **service** section in the service registraion files to switch from .Net Framework service hosts to .Net service hosts.
  * To change the built-in Echo service for .Net 8 service hosts, just make the following changes in `CcpEchoSvc.config` file and run `EchoClient.exe` to try it out.
  ```xml
  <service assembly="%CCP_HOME%Net\NetEchoSvcLib.dll" architecture="NET64" ... >
  ```
* **Fixed SOA session stuck with slow progress for short echo requests**
* **Fixed OnExit handler exception caused by race conditions under stress**
* **Fixed the issue where the create session async call won't be called**
* **Fixed the exception thrown when Excel.exe couldn't be found**
* **Fixed the registration of the ExcelDriver Type Library (TLB)**
* **Support for Excel 2021 in Excel VBA offloading**

## UI & CMD & SDK

* **Added SDK support for .NET Standard 2.0** - Check the NuGet package [here](https://www.nuget.org/packages/Microsoft.HPC.SDK).
* **Added SDK support for Linux.** - See [here](https://github.com/Azure-Samples/hpcpack-samples) for more information.
* **Fixed the job modify API exception**
* **Fixed the connection leak in Store API**
* **Fixed the SOA client random crash due to `System.InvalidOperationException` using .Net SDK**
* **Fixed HPC Cluster Manager crashes**
* **Supported fast job commands when the previous job Id macro '!!' is not used** - To enable fast job commands, just set user environment variable `CCP_NO_JOB_ID` as True, e.g.,

  ```CMD
  setx CCP_NO_JOB_ID true
  ```
* **Fixed potential deadlocks when `Wait()` on `ConnectAsync(SchedulerConnectionContext context, CancellationToken token)`**


## [HPC Pack .Net SDK (6.3.8310) - 11/23/2024](https://www.nuget.org/packages/Microsoft.HPC.SDK/6.3.8310)
* Fixed potential deadlocks when `Wait()` on `ConnectAsync(SchedulerConnectionContext context, CancellationToken token)`


## [HPC Pack .Net SDK (6.3.8187-beta) - 6/30/2024](https://www.nuget.org/packages/Microsoft.HPC.SDK/6.3.8187-beta)
* Supported SDK Logging
   
To enable logging in new SDK, you need to create the `appsettings.json` in project and add the following settings in `csproj` file:  
   
```xml  
<ItemGroup>  
    <Content Include="appsettings.json">  
        <CopyToOutputDirectory>PreserveNewest</CopyToOutputDirectory>  
    </Content>  
</ItemGroup>  
```  
   
The new SDK uses Serilog as a logging tool. You can refer to the details in [serilog/serilog-settings-configuration](https://github.com/serilog/serilog-settings-configuration): A Serilog configuration provider that reads from Microsoft.Extensions.Configuration (github.com).  
   
Here's a simple `appsettings.json` configuration. (The project needs to install the corresponding package: `Serilog.Sinks.Console` and `Serilog.Sinks.File`)  
   
```json  
{  
    "Serilog": {  
        "Using": [ "Serilog.Sinks.Console", "Serilog.Sinks.File" ],  
        "MinimumLevel": "Debug",  
        "WriteTo": [  
            { "Name": "Console" },  
            {  
                "Name": "File",  
                "Args": { "path": "D:/Logs/log.txt" }  
            }  
        ]  
    }  
}  
```  
   
If you want to use other logging tools or customize your own logger, you can use `Microsoft.Hpc.Scheduler.Store.TraceHelper.Configure(Microsoft.Extensions.Logging.ILogger log)` Method, which will replace the default `ILogger` and output in the rules you defined.
  
* Supported Linux Clients  
   
You can now develop C# client applications on .NET 6/7/8 running on Linux machines that connect to HPC Pack clusters. Note that you need to specify the `CCP_USERNAME` and `CCP_PASSWORD` environment variables when submitting jobs. Additionally, there are optional configuration files (`/etc/hpcpack/config.json` for root configuration and `~/.hpcpack.json` for user configuration) that correspond to the registry settings on Windows machines, such as `ClusterConnectionString` and `CertificateValidationType`. These settings can also be specified in environment variables with the `CCP_CONFIG_` prefix, for example, `CCP_CONFIG_ClusterConnectionString` and `CCP_CONFIG_CertificateValidationType`. The environment variables will override the values in the user and root configuration files.  
   
* Supported WCF Certificate Subject Name and Certificate Name Checks  
   
On Windows machines, import the following registry to bypass the CN check, or set the value to `0` to bypass both CN and CA checks.  
   
```reg  
Windows Registry Editor Version 5.00  
   
[HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC]  
"CertificateValidationType"=dword:00000001  
```  
   
On Linux machines, set `CertificateValidationType` in the `/etc/hpcpack/config.json` or `~/.hpcpack.json` file, or set the environment variable `CCP_CONFIG_CertificateValidationType`.  
   
* Fixed the client crash caused by WCF AsyncCallBack duplicate completion.




## [HPC Pack .Net SDK (6.3.8025-beta) - 3/8/2024](https://www.nuget.org/packages/Microsoft.HPC.SDK/6.3.8025-beta)
* Fixed scheduler connection leak
* Fixed job modify exception

## [HPC Pack .Net SDK (6.3.8022-beta) - 12/27/2023](https://www.nuget.org/packages/Microsoft.HPC.SDK/6.3.8022-beta)
* This preview SDK release targets both .Net Standard 2.0 and .Net Framework 4.7.2.
* Note .Net Standard SDK does not have full feature partiy with .Net Framework SDK due to reduced platform API availability. Feature gaps include:
  - WCF certificate subject name and certificate name checks are skipped
  - No TLB support
  - SOA endpoints cannot be configured via XML files
  - .NET Remoting is unsupported
  - Excel feature isn't tested
  - Excel feature won't emit Windows Events logs
* Currently .Net Standard SDK works on Windows only. Linux support is coming soon.
* Additionally the new SDK supports Azure AD joined client machine connecting to domain joined clusters with Windows authentication.
* Please report any issues via [issues](https://github.com/Azure/hpcpack/issues).

## [HPC Pack 2019 Update 2 (6.2.7756) - 9/27/2023](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2019-update-2?view=hpc19-ps)

* Job Scheduler

	- Resolved long-running task failure during head node failover
	- Reduced recovery time for highly available head nodes
	- Fixed unreachable nodes issue due to heartbeat hang when head nodes fail over
	- Added support for HPC_CREATESESSION, allowing tasks to run in a user session without RDP to compute nodes beforehand - Users may specify job environment HPC_CREATESESSION equals True so the job will run under a user session if exists or it would create the user session and run job in it
	- Fixed utilization over 100% issue caused by null task allocation end time
	- Corrected cluster metric counters with highly available head nodes
	- Addressed an issue that job may get stuck when DB transaction timed out but actually succeeded
	- Fixed an issue that job may fail to shrink resource when it has task dependencies
	- Resolved regression preventing IP address usage as the scheduler name
	- Fixed an issue that node could be stuck in draining state due to a divide by zero error when removing the node
	- Introduced support for single node tasks - To enable this feature,
      - Set the scheduler feature flag and restart HpcScheduler service on all head nodes: 
        Set-HpcClusterProperty -SchedulerEnvFeatureFlags 'TASK_ON_SINGLE_NODE'
      - Set job environment. E.g. 
        job submit /numcores:5-5 /jobenv:CCP_TASK_ON_SINGLE_NODE=True hostname
	- Introduced support min and max cores for job and task on a node - To enable this feature,
      - Set the scheduler feature flag and restart HpcScheduler service on all head nodes
        Set-HpcClusterProperty -SchedulerEnvFeatureFlags 'MIN_MAX_ON_NODE'
      - Set job and task environment.	E.g.
        job new /numcores:8-8 /jobenv:CCP_JOB_MIN_MAX_ON_NODE=4-4
        job add !! /numcores:4-4 /env:CCP_TASK_MIN_MAX_ON_NODE=2-2 hostname
  - Extended job activation and submission filter timeouts from 3 to 10 minutes
  - Increased maximum project name length from 80 to 128 characters
  - Improved speed for job task dependency validation

* Setup and Management

	- Replaced ADAL with MSAL for Azure authentication
	- Migrated from Azure AD Graph to Microsoft Graph
	- Added configurable Azure VM Create/Start Timeout
	- Fixed BadRequest error when creating AAD service principal with HPC Cluster Manager
	- Resolved ModelUpdate object leaks
	- Addressed large IaaS VM deployment issue by partitioning Start/Stop operations into multiple changes
	- Set DB recovery mode to Simple for HPCHAWitness and HPCHAStorage databases to reduce DB size
	- Enabled integrated Windows authentication for SQL server in cases where domain user check failed
	- Added support for more recent Linux distributions

* SOA Runtime and Excel

	- Fixed slow Excel job execution due to leftover auto recovery files
	- Resolved SOA broker worker crash caused by unhandled exception in rare conditions

* UI & SDK

	- Fixed task environment variable cleanup issue when copying jobs from GUI
	- Resolved GUI hang issue caused by excessive project names
	- Fixed UI crash due to service-side NullReferenceException
	- Added waitState parameter for scheduler job/task submit API to enable fast submission

## [HPC Pack 2019 Update 1 (6.1.7531) - 1/22/2022](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2019-update-1?view=hpc19-ps)

* Job Scheduler

	- Fix task statistics issue in Linux node agent
	- Support HPC_SESSIONCONSOLE so tasks can run either in user session or console on compute nodes - Users may specify job environment HPC_SESSIONCONSOLE equals True so the job will run under user session if exists or it would create user console and run job in it.
	- Add job cost/corehours cache in scheduler to reduce SQL query - The cache refresh interval can be configured by 'cluscfg setparams JobCostCacheRefreshInterval=&lt;int&gt;'. The value is in seconds with a default 60. Value 0 means disabling the cache. Value -1 means disabling the job cost/corehours feature.
	- Fix an issue in job history reporting Get-HpcJobHistory : Value cannot be null.
	- Fix for the incorrect node group cache issue
	- Fix an error "Method EncryptCredentialForSpecifiedOwner is not supported" when using command "hpccred setcreds /owner"
	- Allow non-exclusive jobs of a same user run on a same node with HPC_CREATECONSOLE=Keep.
	- Add config EmailUseAsciiEncoding to solve mail body containing strange character problem in certain environment
      - By default EmailUseAsciiEncoding is set to False, run 'cluscfg setparams EmailUseAsciiEncoding=True' on the head node to set it to True.
	- Fix task failures when linux nodes just get started
	- Fix a compute node heartbeat lost issue
	- Fix the task dispatching timeout in 3 minutes
	- Fix a bug that rerunning failed parametric sweep sub task may lead to master task stuck in running due to failed task counter incorrect
	- Fix node release task failure
	- Fix the issue that task got killed for only one heartbeat loss
	- Support to specify port for SMTP server
	- Fix random SchedulerException: Could not register with the server. Try again later.
	- Fix unexpctedly canceled task and set proper error code and message
	- Fix a leak of SQLConnection Pool in scheduler

* Setup and Management

	- Support Windows Server 2022 as compute nodes
	- Support idle node pool for auto grow shrink - Users may keep a number of nodes in idle node pool in Azure auto grow shrink by running 'Set-HpcClusterProperty -IdleNodePool &lt;int&gt;'. The default value is 0 which means no idle node pool.
	- Give notification in cluster manager when the certificate on the head node is near expiry date
	- Support Hyper-V generation 2 images for Azure IaaS VM compute nodes
	- Support to specify SSH public key instead of password when creating Azure IaaS Linux compute nodes
	- Fix the issue that some firewall rules are incorrectly configured when creating Azure IaaS compute node with "Windows Server 2012 R2 Datacenter with Excel" or "Windows Server 2016 Datacenter with Excel" image
	- Support to specify preferred OS Disk type for IaaS VMs
	- Fix an installation failure due to HpcManagement service start timeout
	- Support more VM sizes for Azure IaaS compute nodes
	- Support more Linux distros
	- Fix duplicate UDP senders in HpcMonitoringClient
	- Fix handle leaks in HpcMonitoringClient on Win10/WS2016 zh-cn nodes
	- Fix an issue that sometimes the Diagnostics Pivot View cannot be shown in HPC Cluster Manager when Filters are applied
	- Fix the issue that Linux node agent cannot be installed when python 2.x is not installed
	- Fix an issue that network may breaks every several minutes in certain network configurations
	- Fix an issue that auto grow shrink service keeps failing when one head node is not available in a cluster with multiple head nodes
	- Support client connect from a different domain when FQDN of cluster node is required in that domain
	- Add a setup argument to allow the customer to specify certificate validation option when installing Client components in unattended mode
	- Fix an issue that sometimes some HPC stateless services cannot automatically recover  when losing connection with database
	- Fix an issue that HpcReporting service enters into stopped state and doesn’t automatically recover
	- Fix an issue that HpcManagement service fails to start in a rare condition
	- Fix an issue in for Handler.cmd in HpcComputeNode manifest when deploying Azure IaaS Nodes
	- Add new auto grow shrink option GrowOnlyFullySatisfied to grow only when the job is fully satisfied
	- Add a diagnostic test case for node communication certificate
	- Fix Cross-site Scripting (XSS) vulnerabilities
	- Fix linux node scale issue
	- Built-in HA module: fix a datetime conversion issue
	- Fix the node sid translation issue by adding ouPath for IaaS nodes
	- Fix a blocking issue in auto grow shrink caused by deleted node groups
	- Fix the issue that the diagnostic test case "Excel workbook configuration Test" always fails
	- Fix a potential issue that user may get HTTP status 500 without any message/log
	- Fix a bare metal deployment failure in some rare condition
	- Fix an issue that existing tags in the Azure resource group are removed when creating new Azure IaaS nodes

* SOA Runtime and Excel

	- Fix the issue that calling ExcelClient.Dispose would exit the Excel workbook and application
	- Fix the issue that two regular users cannot run non-interactively on a same node

* UI & SDK

	- Fix HpcClusterManager task list view in job property pane refresh too quick

## [HPC Pack 2019 (6.0.7205) - 6/9/2020](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2019?view=hpc19-ps)
* Built-in High Availability  
  - In HPC Pack 2019, we have a built-in high availability architecture for head nodes. Compared to the architecture in HPC Pack 2016 which leverages Microsoft Service Fabric, the new architecture requires less CPU and memory resources. In the new architecture, just two nodes are sufficient to create a highly available HPC Pack cluster. Using the built-in HA architecture provides additional flexibility as well. The new architecture allows additional head nodes to be added into a cluster at any time. See the Get started guide for Microsoft HPC Pack 2019 to create a highly available HPC Pack cluster on-premises. If you want to deploy a highly available HPC Pack cluster in Azure, see Deploy an HPC Pack 2019 cluster in Azure.

* New Admin Portal  
  - With the new HPC Pack 2019 release, we provide a new Admin Portal for a fresh cluster admin experience. The new Portal is enabled and available by default. It is accessible at the URL https://hostname/hpc/portal, where the hostname is the name or IP address of an HPC Head node. If you have multiple head nodes deployed in your cluster, you may use any head node's name or address. Note, Only the latest versions of Chrome and Firefox are supported.

* Job Scheduler  
  - Job cost and core hours – Now in the GUI and command line, you can view the job cost and core hours in real time. Job cost count the resource used by a job as the sum of cost of each core on which the job's tasks are running. Job core hours count the resource used by a job as the sum of hours of each core on which the job's tasks are running.

  - Job purge command line – A new ‘purge’ verb is added to the job command line for admin to purge the old jobs in the database if the scheduled cleanup is not yet doing so.

* Management
  - Support managed identity to manage Azure IaaS compute nodes – If the head nodes of your HPC Pack cluster are Azure VMs, you can now use Azure managed identity to manage the Azure IaaS compute nodes. For more details please refer to Enable Azure Managed Identity to manage Azure resources.

  - Support Azure Spot VMs (Experimental) - In HPC Pack 2019, you can now use an experimental feature to create Azure IaaS compute nodes with Azure Spot VMs. Using Azure Spot VMs allows you to take advantage of unused Azure compute capacity at a significant cost savings. For more details about this feature, please refer to Burst to Azure IaaS compute nodes.

  - Virtual file system for Azure Batch pool nodes – Azure Batch pool nodes can now mount virtual file systems like Azure Files by just providing the mount configuration when adding the nodes. Here is an example mount configuration string to mount Azure Files on Windows nodes, {"Type":"AzureFiles","AccountName":"","AccountKey":"","AzureFileUrl":"","Source":null,"ContainerName":null,"SasKey":null,"MountPath":"Y","MountOptions":"/persistent:Yes"}  
  The “Type” could be “AzureFiles”, /”AzureBlob”/, ”NFS” or /”CIFS”. Please refer to this doc (https://docs.microsoft.com/azure/batch/virtual-file-mount) for detailed mount configurations. You may specify multiple mount configurations by joining the configuration strings with semicolon (;).

  - Node start checker – In certain situations when a compute node restarts, it is preferred to check a certain condition, i.e. Infiniband network IP is ready, before reporting heartbeats for job allocation. To achieve this, just adding the following registry keys and changing the NodeChecker.cmd under %CCP_HOME%Bin folder on the compute nodes.  
  The node start checker would run NodeChecker.cmd with NodeCheckerTimeout (by default -1/infinite). If the exit code is non-zero or timeout occurs, it will rerun in NodeCheckerInterval (by default 10 seconds) for NodeCheckerCount (by default 3) in total. Note, no matter the final exit code is zero or not, the heartbeats will start for the node.

      Windows Registry Editor Version 5.00  
      [HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC]  
      "NodeCheckerCount"=dword:00000003  
      "NodeCheckerInterval"=dword:0000000a  
      "NodeCheckerTimeout"=dword:0000003c  

  - PowerShell module – In HPC Pack 2019, the HPC PowerShell cmdlets are loaded automatically in a module named Microsoft.Hpc when running the cmdlets. There is no need to add the snapin any more.

* Fixes and improvements  
  HPC Pack 2019 includes all the previous fixes for HPC Pack 2012 R2 Update 3 (latest 4.5.5202) and HPC Pack 2016 Update 3 (latest 5.3.6450). Besides, it also contains the following fixes,

  - Auto grow shrink  
  Fix a grow issue when the job has resource type for Node or Socket growing by auto calculated Min or Max.
Fix a shrink issue when the management service failed to connect to HpcMonitoringServer to update metric value.

  - Service reliability improvements - Fix a few exceptions e.g. ArgumentOutOfRangeException, NullReferenceException and InvalidCastException in HpcScheduler and HpcManagement services to impove the reliability.

  - Accessibility fixes - Fix a bunch of accessibility bugs in GUI.

  - Management Database size - Fix an issue that the size of HPC Management database grows fast when there are hundreds of compute nodes in the cluster.

* Fundamental updates
  - Window Server 2019/SQL Server 2019/Excel 2019
  - .Net Framework 4.7.2
  - Azure SDKs

* Additional fixes in refreshed build 6.0.7214 - 8/7/2020
  - A setup fix to support managed identify for Azure SQL databases
  - A Linux node agent fix for memory/CPU leaks

## [HPC Pack 2019 Preview (6.0.7121) - 11/15/2019](https://www.microsoft.com/en-us/download/details.aspx?id=100592)
* Built-in High Availability model for head nodes
* New admin and job portal
* Job core hours and costs by specified per node cost
* Fundamental supports: Windows Server 2019/SQL Server 2019/Excel 2019,.Net Framework 4.7.2, New Azure SDKs

# HPC Pack 2016

## [HPC Pack 2016 Update 3 QFE KB4537169 (5.3.6450) - 2/14/2020](https://www.microsoft.com/en-us/download/details.aspx?id=100918)
- Improve the SOA performance and reliability.
- Fix the issue that sometimes the cluster utilization rate is shown greater than 100% in the cluster utilization chart.
- Fix the issue that NAT is not working if the OS of the head node is Windows Server 2016 or above.
- Support UEFI boot for bare metal deployment.
- Fix an issue that in some situation HPCUsers cannot call service registration REST API.
- Fix an issue that in some rare condition, some compute nodes are in OK state, but cannot run tasks.
- Fix an issue that a parametric sweep job cannot finish when all its tasks finish.
- Fix an issue that old jobs are not cleaned up in time.
- Fix an issue that “SortByNodes” query parameter doesn’t work in HPC Web API.
- Support pagination in HPC Web API at endpoint “/hpc”: A “StartRow” query parameter can be used when getting list of jobs/tasks/nodes. The first row has index 0. When this parameter presents in request,  
  a) The server will returns the requested range of rows defined by “StartRow” and “RowsPerRead”(default to 10).  
  b) The total row count is returned in the response header “x-ms-row-count”.  
  c) The response headers "x-ms-continuation-QueryId" and "x-ms-continuation-CurrentObjectNumber" will not be returned.
- Support sorting order in HPC Web API at endpoint “/hpc”: A “Asc” query parameter can be used when getting list of jobs/tasks/nodes. The parameter has a default value “True”, to sort the list ascendingly. When given a value “False”, the return list is in descending order. The sort field is specified by “SortNodesBy”/”SortJobsBy”/”SortTasks” query parameters as before.
- Enforce authorization of SignalR Hubs for job & task events.
- Increase the life time of continuation token/rowset in web service to 60 min.
- Fix an issue that start/stop IaaS nodes may fail unexpectedly.
- Fix an error in auto grow shrink when the monitoring service is temporarily unavailable.
- Fix a possible job scheduler hang when the scheduler service restarts.
- Fix an issue that SOA message level trace cannot be viewed after system reboot.
- Fix Web Portal connection and port leak.
- Fix an issue that HpcMonitoring service may stop to persist minute counters.
- Sort nodes by node group and node name for auto grow and avoid to retry the same batch of failed nodes.
- Add change role button back to the context menu for Azure IaaS nodes.
- Fix a scheduler SQL insert NULL exception when adding job/task allocation history caused by node GUID changing.
- Fix an issue that Linux node with FQDN host name may not be recognized by scheduler.
- Improve Linux node GPU instance name readability in metric info.
- Fix an issue that Azure IaaS nodes are stuck at Provisioning state occasionally when auto grow shrink is enabled.
- Fix an issue that sometimes compute node cannot join the cluster with “node name already exists” error.
- Fix an issue that Cluster Manager cannot view reporting charts after moving HPCReporting database to another SQL server instance.
- Fix some issues in French OS.

## [HPC Pack 2016 Update 3 (5.3.6435) - 8/2/2019](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2016-update-3?view=hpc16-ps) 
* Performance and reliability improvements
  * Improve scheduler task dispatching rate.
  * Improve SOA request dispatching rate when some service hosts idle time out.
  * Improve service reliability by fixing service crash and leak issues under certain circumstances.
* Setup and Deployment
  * Support not to install rras/dhcp/wds components on head node slipstream installation with “-SkipComponent:rras,dhcp,wds” option.
  * Use new VM extension (instead of HPC compute node image) to deploy Azure IaaS Windows nodes with the following operating systems: Windows Server 2019, Windows Server 2016, Windows Server 2012 R2, Windows Server 2012, Windows Server 2008 R2 SP1.
  * Windows Server 2019 can now be specified as the operating system for Azure PaaS nodes.
  * User can specify one of the following .Net Framework version which will be installed in Azure PaaS nodes: NDP461(default value), NDP462, NDP47, NDP471, NDP472, NDP48.
* Management
  * Machine accounts can now be added in add user dialog in HPC Cluster Manager.
  * Enable environment variable value containing "=" in HPC Cluster Manager and HPC Job Manager.
  * Increase task command line length limit from 480 to 1024 in HPC Cluster Manager and HPC Job Manager.
* SOA Runtime
  * Support PowerShell Export-HPCSoaTrace cmdlet.
  * Support auto grow nodes for SOA jobs by the estimated time for the queued requests to complete.
  * A cluster property named SoaJobTimeToComplete (in minutes) besides current SoaJobGrowThreshold/SoaRequestsPerCore is introduced to help make the grow decision for SOA jobs. The growing number is the max value of the previous calculation by request number and the new calculation by job time to complete estimation. The new logic uses the simple formula to calculate the growing count: growingCount = CallDuration * OutstandingCalls / SoaJobTimeToComplete – RunningTasks. Note this estimation takes a few assumptions e.g. no prefetch, no concurrency, no faults, request time evenly distributed, and zero grow time. This implementation is expected to solve long running request issue in practice. Also note the default value of SoaJobTimeToComplete is 0, which means growing by request remaining time is not enabled.
* Scheduler
  * Change the way of translating AAD(email format) username to domain format username. (Remove hash and use completed AAD name as username for Linux node. Include domain name in hash for Windows node).
  * Custom scheduler node sorter.
  * To use the custom node sorter for node selection when scheduling jobs, first implement the Microsoft.Hpc.Scheduler.AddInFilter.HpcClient.INodeSorter interface defined in Microsoft.Hpc.Scheduler.dll as shown below, then rename the custom sorter dlls to 0.dll\~63.dll (max 64 custom sorters) and copy them under the folder %CCP_DATA%NodeSorters on the head node, finally use #0\~#63 for job’s orderby property when submitting the job.
  * Support gMSA (Group Managed Service Account). With this support, the cluster may have gMSA accounts setup for cluster users or admins. To setup gMSA accounts, please check the online docs. Basically it requires to add a KDS root key and create an ADServiceAccount, and install the ADServiceAccount on the nodes. To submit a job with gMSA account, just specify the pseudo password “GMSA”. E.g. job submit /user:hpc\hpcgmsa$ /password:GMSA hostname. Note job owner who is submitting the job must use the same gMSA account.
  * Support docker task on Windows.
  * Support job template environments.
  * Users can set environments in job templates now. The scope of job template environments is between cluster environments and job environments. They will override cluster environments and be overridden by job environments.
  * REST API Improvements.
    * REST API can finish a Job/Task.
    * REST API can "Call as another user" by setting HTTP header "x-ms-as-user".
    * Server pushes job/task events by SignalR to http clients.
    * REST API endpoint “/hpc/” now supports HTTP Basic Auth.
    * Add filter "NodeGroup=" to get jobs for Scheduler REST & Web APIs.
  * Avoid retrieving client version from the dll file when doing impersonation.
  * Allow Job Administrators to connect service as client.
  * Previously we only allow cluster Administrators to connect service as client, now we also allow cluster Job Administrators to do so.
  * (Preview) HpcData service scheduler integration. Users can setup and run HpcData service on compute nodes (both Linux and Windows) and specify inputFiles and outputFiles properties for tasks to download input files and upload output files from/to Azure Blobs, Azure Files or File Servers. Please check README.txt under %CCP_HOME%Core for more details. Note this is a preview feature and may be subject to future changes according to customer feedbacks.
  * Linux node manager improvement.
    * Add environment variable CCP_DISABLE_CGROUP to enable running a task without cgroup.
    * Change the default working directory to home.
    * Enable task statistics when task is running.
    * Add properties 'CcpVersion' and 'CustomProperties' in node registration info.
    * Support monitoring InfiniBand network usage.
    * Support monitoring multiple instances of network usage, which is set as default instead of monitoring total usage.

## [HPC Pack 2016 Update 2 QFE KB4481650 (5.2.6291) - 1/4/2019](https://www.microsoft.com/en-us/download/details.aspx?id=57703)
- Fix a task dependency issue
- Fix dependent assembly loading issue of activation/submission filter
- Fix an issue that HPC Web portal cannot be loaded
- Enable HPC REST API for non-domain-joined cluster
- Add Excel related diagnostics tests and "GPGPU configuration Report" back
- Fix the issue that the PowerShell command Set-HpcNode cannot set node role
- Enable Compute Node role of the headnode for non domain joined cluster
- Fix an issue that makes JobManager crash when switching between resource view and job view
- Fix assembly reference to enable in-process broker on client side
- Fix an issue causes Session.Close throwing NullReferenceException when using default binding
- Try to stop LogonUI and WinLogon when creating console times out
- Fix SOA broker backend to use UPN for Kerberos authentication
- Fix auto grow shrink service to use ComputedMax for job with max being set when there are fewer tasks than max in the job
- Fix an issue that SOA inprocess broker session could have the counter of total calls falsely doubled
- Fix a few accessibility issues in HPC Cluster/Job Manager GUI
- Fix an issue that an error dialog will pop up when closing Cluster/Job Manager GUI
- Add "-ConnectAsUser " for HPC powershell cmdlet. With this cluster admin can connect to the cluster and submit job on behalf of other users
- Add support Ubuntu1804
- Add environment variable CCP_SWITCH_USER=1 in job or task to run task command by switching user rather than by sudo, thus MPI task could run successfully on RDMA capable nodes with Ubuntu
- Fix affinity issue on Linux nodes
- Bring with MSMPI 10.0

## [HPC Pack 2016 Update 2 (5.2.6277) - 9/29/2018](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2016-update-2?view=hpc16-ps)
* Mesos integration.  
HPC Pack can now auto grow-shrink compute resources from a Mesos cluster with the help of open sourced HPC Pack Mesos framework.
* SOA common data for non-domain joined compute nodes.  
This enables SOA service running on non-domain joined Windows compute nodes to read SOA Common Data from Azure Blob Storage directly without accessing to HPC Runtime share which usually located on the head node. This enables your SOA workloads in a hybrid HPC Pack Cluster with compute resource provisioned in Azure.
* Burst to Azure IaaS VM improvements.  
In HPC Pack 2016 Update 1 we introduced new node template type in HPC Pack "Azure IaaS VM node template". Now we have below improvements:
  * In order to create a node template for Azure IaaS VM, cluster admin need to have multiple steps to configure Azure Service Principal, Azure key vault Secret and collect info from the Azure portal. Now we simplified all these steps into the step-by-step wizard.
  * You can now enable Azure Accelerated networking when you create Azure IaaS compute nodes.
  * Azure node information (such as node size, image name) is now automatically collected through metadata service on the node. After the node being provisioned, you will be able to check these information in the Cluster Manager GUI.
* View job/task history on node.  
  Added new parameters of command node view: “/jobhistory”, “/taskhistory”, “/lastrows” and “/when”. Use “/jobhistory” and(or) “/taskhistory” to get job and(or) task allocation history of the node. Use “/lastrows” to specify how many rows in DB to query for getting allocation history, default is 100 rows. Use “/when” to filter the allocation history and check which jobs/tasks were running on the node in the specified time. For example, below command will show latest job history that running on node IaaSCN001:  
  `node view IaaSCN001 /jobhistory`
* Fast Balanced Scheduling Mode.  
  Fast Balanced mode is a new mode in addition to Queued and Balanced mode. In this mode, cores are allocated to jobs according to their extended priority. Different from the Balanced mode which calculates balance quota among running jobs, the Fast Balanced mode calculate the balance quota among queued and running jobs together and the preemption in this mode happens in node group level and gracefully, so that it can achieve final balance state more efficiently. The Fast Balanced mode has some constraints on job settings. Non-compatible jobs will fail with validation error.
  To enable the fast balanced mode you need to run below powershell cmdlet: 
  ```
  set-hpcclusterproperty -schedulingmode FastBalanced
  ```
* Task to reboot compute node for Cluster admin.  
  Cluster admin now can create and submit job with task that will reboot a compute node when it is finishing. Cluster admin need to have task environment variable CCP_RESTART=True specified. When the task is completed on the compute node, the node will reboot itself and the task will still be "Running" state in the scheduler. When the service restarted from a reboot, the task will then be reported as completed.  
  This type of task should run on the compute node exclusively so that when it is rebooting the compute node, no other tasks will be impacted.
* Lizard updated
Lizard is a tool that runs and tunes Linpack benchmark on HPC Pack cluster. We now have an updated lizard tool that can be downloaded together with HPC Pack 2016 Update 2.
* Other improvements
  * Linux nodes now are enabled in HPC Pack built-in reports for resource utilization, availability.
  * Add a new value “KEEP” for job environment variable HPC_CREATECONSOLE, when this value specified, we will create a new logon console session if not exists or attach to the existing one and keep the console session after the job completes on the compute nodes;
  * We now generate hostfile or machinefile for Intel MPI, Open MPI, MPICH or other MPI applications on linux nodes. A host file or machine file containing nodes or cores allocation information for MPI applications will be generated when rank 0 task is starting. User could use job or task environment variable $CCP_MPI_HOSTFILE in task command to get the file name, and $CCP_MPI_HOSTFILE_FORMAT to specify the format of host file or machine file. Here is an example how you can use this in your MPI PINGPONG run: source /opt/intel/impi/\`ls /opt/intel/impi\`/bin64/mpivars.sh && mpirun -f $CCP_MPI_HOSTFILE IMB-MPI1 pingpong
  * By default, scheduler will use job’s runas user credential to do an “Interactive” logon on the compute node. And sometime the “Interactive” logon permission may be banned by your domain policy. We now introduced a new job environment variable "HPC_JOBLOGONTYPE" so that user could specify different logon type to mitigate the issue. The value of job environment variable could be set to 2,3,4,5,7,8,9.
  * DB connection string plugin improvement: In addition to scheduler service, DB connection string in monitoring service, reporting service, diagnostics service and SDM service will also be refreshed when connection fails so that user can use customized assembly as plugin to refresh DB connection strings in these services.

## [HPC Pack 2016 Update 1 QFE KB4342793 (5.1.6125) - 7/26/2018](https://www.microsoft.com/en-us/download/details.aspx?id=57174)
- Fix an issue caused local user can’t be created on non-domain joined compute nodes in a domain joined cluster.
- Add ability to read common data through Azure Blob Storage to non-domain joined compute node.
- Fix an Azure IaaS node deployment failure due to deployment template file not found in HA cluster.
- Support operating system with French for broker/compute/workstation node.
- Allow the node action “Maintain” for domain joined Azure IaaS nodes.
- Linux extension is updated, the “Linux not showing up in Azure” issue is resolved.
- Add option to disable the windows compute node from syncing hpc cluster admin to local administrator group, to do this, you need to add following value on the target node under registry HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC  
  Name: DisableSyncWithAdminGroup  
  Type: REG_DWORD  
  Data: 1

## [HPC Pack 2016 Update 1 QFE KB4135110 (5.1.6112) - 5/28/2018](https://www.microsoft.com/en-us/download/details.aspx?id=56964)
Scheduler Fixes
- Fix “task min unit” not specified error when submitting job after switching job's unit type.
- Add a new value “KEEP” for job environment variable HPC_CREATECONSOLE, when this value specified, we will create a new logon console session if not exists or attach to the existing one and keep the console session after the job completes on the compute nodes.
- Fix a regression for cross-domain user when running job on windows compute nodes.
- Fix an issue that if scheduler object is GCed, its connection will not be closed.
- Fix task failure issue when cgroup is not installed on linux nodes.
- We now generate hostfile or machinefile for Intel MPI, Open MPI, MPICH or other MPI applications on linux nodes. A host file or machine file containing nodes or cores allocation information for MPI applications will be generated when rank 0 task is starting. User could use job or task environment variable $CCP_MPI_HOSTFILE in task command to get the file name, and $CCP_MPI_HOSTFILE_FORMAT to specify the format of host file or machine file. Currently, we have 4 format as below (Suppose we allocate N nodes and each node with 4 cores).
       1. The default host file format:
             nodename1
             nodename2
             …
             nodenameN
       2. When $CCP_MPI_HOSTFILE_FORMAT=1, the format is:
             nodename1:4
             nodename2:4
             …
             nodenameN:4
       3. When $CCP_MPI_HOSTFILE_FORMAT=2, the format is like:
             nodename1 slots=4
             nodename2 slots=4
             …
             nodenameN slots=4
       4. When $CCP_MPI_HOSTFILE_FORMAT=3, the format is like:
             nodename1 4
             nodename2 4
             …
             nodenameN 4
  Here is an example how you can use this in your MPI PINGPONG run:
      source /opt/intel/impi/\`ls /opt/intel/impi\`/bin64/mpivars.sh && mpirun -f $CCP_MPI_HOSTFILE IMB-MPI1 pingpong
- Mutual trust for multi-node task (usually MPI task) on Linux nodes will be automatically set for all users including cluster admin. It is not required to set extendedData with the tool “HPCCred.exe”.
- By default, scheduler will use job’s runas user credential to do an “Interactive” logon on the compute node. And sometime the “Interactive” logon permission may be banned by your domain policy. We now introduced a new job environment variable "HPC_JOBLOGONTYPE" so that user could specify different logon type to mitigate the issue. The value of job environment variable could be set to 2,3,4,5,7,8,9 as below, more refer to [Doc](https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184(v=vs.85).aspx).  
  ```
      public enum LogonType
      {
             Interactive = 2,
             Network = 3,
             Batch = 4,
             Service = 5,
             Unlock = 7,
             NetworkClearText = 8,
             NewCredentials = 9,
      }
  ```
- Fix an issue that job would be stuck in queued state and block other jobs when it meets all the conditions: unit type is Node, run on a single node, node group assigned.
- Fix regression on Activation/Submission Filter.
- Enable HTML formated email notification.
- Fix the issue that HPC Pack 2012 R2 Update 3 scheduler API may not able to get node and group information from HPC Pack 2016 Update 1 Cluster (by adding back .net remoting for scheduler node service on port 6729).
- User mapping changes With this change, cluster admin will not be mapped to Linux “root” user by default any more. It will be mapped to an local Linux user with the same name(with or without domain prefix) in Linux compute node instead, which is a member of group “sudo” if the user is created by HPC Pack Linux nodemanager. Only Windows local system account “NT AUTHORITY\SYSTEM” will be mapped to Linux root user. When you use Clusrun, you can specify this local system account on the cluster manager Clusrun GUI or through Clusrun command “Clusrun /user:system <your command>”. Setting environment variable “CCP_MAP_ADMIN_USER” to “0” to map cluster admin to Linux root user as previous default behavior, but under this case mutual trust for root user between Linux compute nodes will not be set automatically.
- A checkbox named ‘Run as local system account "NT AUTHORITY\SYSTEM"’ is added to Clusrun dialog in HPC Cluster Manager. HPC administrators can run clusrun command in Linux compute nodes as root user by checking it.
- Hpccred.exe improvement. Command “hpccred listcreds” can be used to display the credentials owned by current user. HPC administrator can use “hpccred listcreds [/owner:username]” and “hpccred setcreds [/owner:username]” to display or to set credentials owned by other users. Extended data of each cluster user will be filled with RSA key for SSH automatically if user do not set it manually.
- Fix issue that our service won’t authenticate client machine in 3-headnode cluster mode with certification.
- Fix NullReferenceException if HPC registry key is absent on the client machine.

SOA Fixes
- Fix issue that exception in finding SOA service registration file shall not affect continuing finding in other paths.
- Fix an issue that SOA service registration folder cannot be on a network share other than the head node. When the share is on another machine, just make sure the share allow read access for <Domain>\<HeadNode>$ machine account.
- Fix issue that SOA service host may not able to access SOA service registration share in 3-headnode cluster mode.
- Fix an issue that causes SOA job failing if system.ServiceModel/bindings configuration settings is missing in the corresponding service configuration file.
- Removed authentication requirement for non-admin user get Service registration file via https endpoint.
- Fix issue that Non-domain joined SOA client cannot connect to Session Service using Net.Tcp binding.
- Fix Azure storage connection string loading issue in SOA data service.
- Fix two issues in v2 proxy client/operation contract mode: one is client/session does not idle time out; another is the total request counter is incorrectly deducte.

Management Fixes
- Fix issue that reporting service may not work in single headnode cluster.
- DB connection string plugin improvement: In addition to scheduler service, DB connection string in monitoring service, reporting service, diagnostics service and SDM service will also be refreshed when connection fails so that user can use customized assembly as plugin to refresh DB connection strings in these services.
- Fix deployment failure when auto scale is enabled for batch pool.
- Fix an issue that auto grow shrink service does not grow for jobs without auto calculated grow by min or max and a specified min for one core. In another word, the issue happens if GrowByMin is set to false (default) and the job is specified with 1-[N] or \*-[N] cores, or GrowByMin is set to true and the job with 1-[N] or 1-* cores. * means auto calc.
- Fix node selection performance issue in HPC Cluster Manager.
- Fix auto grow issue in a group of nodes with mixed number of cores while the resource type of jobs is node or socket.
- Fix case sensitive issue in node group name for auto grow shrink service.
- Fix the issue that busy online nodes will be selected for grow if the queued job has RequestedNodes specified without NodeGroups.
- Add the missing script files Import-HPCConfiguration.ps1/Export-HPCConfiguration.ps1 and fix the issue that Set-HpcClusterName.ps1/Move-HpcNode.ps1 may not work.
- Fix issue that compute nodes may enter into WinPE many times during bare metal deployment.
- Make availability set optional for Azure IaaS node deployment.
- Fix NullRefereceException in bare metal deployment if deployment certificate not specified.
- Fix issue that Azure IaaS node failed to deploy when Headnode name has less than 4 characters.
- Fix Linux nodes unavailable issue when there is NIC on headnode associated with "169.254.*" IP.
- Fix the issue that management service fails to start when there is invalid IP address in hosts file.
- Fix "Specified cast is not valid" issue when run Get-HPCMetricValueHistory cmdlet in powershell.
- Fix job property deserialize issue in REST API.

## [HPC Pack 2016 Update 1 (5.1.6086) - 12/18/2017](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2016-update-1?view=hpc16-ps)
* Removed dependency on Service Fabric for single head node installation. Service Fabric is not required for installing a cluster with a single head node. However, it is still required for setting up a cluser with 3 head nodes.
* Azure Active Directory integration for SOA jobs.
In HPC Pack 2016 RTM, we added Azure Active Directory support for HPC Batch jobs. Now we add support for HPC SOA jobs.
* Burst to Azure Batch improvements.
In this version, we improve bursting to Azure Batch pools including support for low priority VMs and Linux VM pools.
* Use Docker in HPC Pack.
HPC Pack is now integrated with Docker. Job users can submit a job requesting a Docker image, and the HPC Job Scheduler will start the task within Docker. NVIDIA Docker GPU jobs and cross-Docker MPI jobs are both supported.
* Manage Azure Resource Manager VMs in HPC Pack
One of the advantages of HPC Pack is that you can manage Azure compute resources for upir cluster through node templates, in the same way that you manage on-premises resources. In addition to the Azure node template (for PaaS nodes) and Azure Batch pool template, we introduce a new type of template: Azure Resource Manager (RM) VM template. It enables you to add, deploy, remove, and manage RM VMs from a central place.
* Support for Excel 2016.
If you’re using Excel Workbook offloading in HPC Pack 2016 Update 1, Excel 2016 is supported by default. The way you use Excel Workbook offloading hasn’t been changed from earlier versions of HPC Pack. If you use Office 365, you need to manually activate Excel on all compute nodes.
* Improved autogrow/shrink operation log.
Previously you had to review management logs to check what was happening to the autogrow/shrink operations for compute resources, which is not very convenient. Now you canm read the logs within the HPC Cluster Manager GUI (Resource Management > Operations > AzureOperations). If autogrow/shrink is enabled, you see one active “Autogrow/shrink report” operation every 30 minutes. This operation logs is never archived and instead is purged after 48 hours. This behavior differs from other operations.
Note that this feature already exists in HPC Pack 2012 R2 Update 3 with QFE4032368.
* Improved Linux mutual trust configuration for cross-node MPI jobs
Previously when a cluster user submitted a cross-node MPI job, they had to provide a key pair XML file generated through hpccred.exe setcreds /extendeddata:<xml>. Now this is not required, because HPC Pack 2016 Update 1 generates a key pair for the user automatically
* Peek output for a running task.  
  Before HPC Pack 2016 Update 1, you were only able to see the last 5K of output from the task if the task did not specify output redirection. And if the task redirected to a file, you were not able to know the output of a running task. This situation was worse if your job and task were running in Azure nodes because your client could not access the Azure nodes directly.
  Now you can view the latest 4K of output and standard error by going to the View Job dialog box from HPC Job Manager. Select a running task and click Peek Output.  
  You can also use the HPC Pack command task view <jobId>.<TaskId> /peekoutput to get the latest 4K of output and standard error from the running task.  
  Considerations:  
  This feature does not work if your task is running on an Azure Batch pool node.
Peek output may fail if your task redirects the output to a share that the compute node account cannot access.
* Backward compatibility. In HPC Pack Update 1 we add compatibility with previous versions of HPC Pack. The following scenarios are supported: 
  * With the HPC Pack Update 1 SDK, you can connect to previous versions (HPC Pack 2012 and HPC Pack 2012 R2) of an HPC Pack Cluster and submit and manage your Batch jobs. Note that the HPC Pack Update 1 SDK does not work for HPC Pack 2016 RTM clusters.
  * You can connect to HPC Pack 2016 Update 1 from previous versions (HPC Pack 2012 and HPC Pack 2012 R2) of the HPC Pack SDK to submit and manage batch jobs. Please note that this only works if your HPC Pack 2016 Update 1 cluster nodes are domain joined.
  The latest HPC Pack SDK is available on NuGet.  
  The HPC Pack 2016 Update 1 SDK adds a new method in IScheduler as shown below to allow you to choose the endpoint you want to connect to: WCF or .NET remoting. Previously, the Connect method first tried to connect to a WCF endpoint (version later than HPC Pack 2016 RTM) and if that failed it tried a .NET remoting endpoint (version before HPC Pack 2016)  
    ```c#
    public void Connect(string cluster, ConnectMethod method)
    ```
* SqlConnectionStringProvider plugin.  
HPC Pack 2016 Update 1 supports a plugin to provide a customized SQL connection string. This is mainly for managing the SQL connection strings in a separate security system from HPC Pack 2016 Update 1. For example, use the plugin if the connection strings change frequently, or they contains secret information that it is improper to save in the Windows registry or the Service Fabric cluster property store.
* New HPC Pack Job Scheduler REST API.  
While we keep the original HPC Pack REST API for backward compatibility, we introduce a new set of REST APIs for Azure AD integration and have added JSON format support.
* SOA performance improvement.  
The performance of service-oriented architecture (SOA) jobs has been improved in this release.

## [HPC Pack 2016 RTM (5.0.5826) - 12/29/2016](https://docs.microsoft.com/en-us/powershell/high-performance-computing/what-s-new-in-hpc-pack-2016?view=hpc16-ps)
* High availablity  
In HPC Pack 2016, we have migrated our head node services from the Failover Clustering Service to the Service Fabric Service. You can now deploy a highly available HPC Pack cluster much more easily in Azure or on-premises. See the Get started guide for Microsoft HPC Pack 2016 to create a highly available HPC Pack cluster on-premises. If you want to deploy a highly available HPC Pack cluster in Azure, see Deploy an HPC Pack 2016 cluster in Azure.
* Azure Active Directory integration  
With previous versions of HPC Pack set up in Azure virtual machines, you needed to set up a domain controller for your HPC cluster. This is because HPC Pack requires Active Directory authentication for cluster administrators and cluster users. In HPC Pack 2016, the administrator can alternatively configure Azure Active Directory for cluster authentication. For more details, see Manage an HPC Pack cluster in Azure using Azure Active Directory.
* Enhanced GPU support  
Since HPC Pack 2012 R2 Update 3 we have supported GPUs for Windows compute nodes. HPC Pack extends the support to include Linux compute nodes. With the Azure N-Series VM size, you’re able to deploy an HPC Pack Cluster with GPU capabilities in Azure. For more details, see Get started with HPC Pack and Azure N-Series VMs.
* GUI improvements
  * Hold job - Now in the job management UI (HPC Job Manager), you can hold an active job with a hold-until date and time. The queued tasks within the active job are held from dispatching. And if there are any running tasks in the job, the job state is marked as Draining instead of Running.
  * Custom properties page - In the Job dialog, you can now view and edit a job’s custom properties. And if the value of the property is a link, the link is displayed on the page and can be clicked by the user. If you would like a file location to be clickable as well, use the format file:///\<location\>, for example, file:///c:/users.
  * Substitution of mount point - When a task is executed on a Linux node, the user usually can’t open the working directory. Now within the job management UI you can substitute the mount point by specifying the job custom properties linuxMountPoint and windowsMountPoint so that the user can access the folder as well. For example, you can create a job with the following settings:  
    ~~~
    Custom Property: linuxMountPoint = /gpfs/Production
    Custom Property: windowsMountPoint = Z:\Production
    Task Working Directory: /gpfs/Production/myjob
    ~~~
    Then when you view the job from GUI, the working directory value in the Job dialog > View Tasks page > Details tab will be z:\production\myjob. And if you previously mounted the /gpfs to your local Z: drive, you will be able to view the job output file.
  * Activity log - Job modification logs are now also logged in the job’s activity log.
  * Set subscribed information for node - The Administrator can set node subscribed cores or sockets from the GUI. Select offline nodes and perform the Edit Properties action.
  * No copy job – If you specify the job custom property noGUICopy as true, the Copy action on the GUI will be disabled.
* Scheduler improvements
  * Task execution filter - HPC Pack 2016 introduces a task execution filter for Linux compute nodes to enable calling administrator-customized scripts that each time a task is executed on Linux nodes. This helps to enable scenarios such as executing tasks with an Active Directory account on Linux nodes and mounting a user's home folder for task execution. For more information, see Get started with HPC Pack task execution filter.
  * Release task issue fix – HPC Pack 2016 fixes the issue that a job release task may not be executed for exclusive jobs.
  * Job stuck issue – HPC Pack 2016 fixes an issue that a job may be stuck in the Queued state.
* SOA improvements
  * 4 MB message limit removed - Now in SOA requests you can send requests that are larger than 4 MB in size. A large request will be split into smaller messages to persist into MSMQ, which has the 4MB message size restriction.
  * HoldUntil for SOA sessions - For a SOA session, users can now pause a running session by modifying a session job's HoldUntil property to a future time.
  * SOA session survival during head node failover.
  * SOA sessions can run on non-domain-joined compute nodes - For non-domain-joined compute nodes, the broker back-end binding configuration in the service registration file can be updated with None or Certificate security.
  * New nethttp transport scheme - The nethttp is based on WebSocket, which can greatly improve message throughput compared with basic HTTP connections.
  * Configurable broker dispatcher capacity - Users can specify the broker dispatcher capacity instead of the calculated cores. This achieves more accurate grow and shrink behavior if the resource type is node or socket.
  * Multiple SOA sessions in a shared session pool - To specify the pool size for a SOA service, add the optional configuration \<service maxSessionPoolSize="20"\> in the service registration file. When creating a shared SOA session with the session pool, specify both sessionStartInfo.ShareSession and sessionStartInfo.SessionPool as true. And after using this session, close it without purging to leave it in the pool.
  * Updated EchoClient.exe - Updates for random message size and time, flush per number of requests support, message operation (send/flush/EOM/get) timeout parameter, and new nethttp scheme support.
  * Extra optional parameters in ExcelClient.OpenSession method for Excel VBA - Extra parameters include jobname, projectName, anbd jobPriority.
  * Added GPU type support for SOA session API.
  * Miscellaneious stability and performance fixes in SOA services.
* Management
  * Autogrow/shrink service supports Linux nodes - When HPC Pack cluster is deployed in Azure virtual machines.
  * New property for autogrow/shrink service - The ExcludeNodeGroup property enables you to specify the node group or node groups to exclude from automatic node starts and stops.
  * Built-in REST API Service – Now the REST API Service is installed on every head node instance by default.
  * Non-domain-joined Windows compute nodes – The cluster administrator can set up a Windows compute node which is not domain-joined. A local account will be created and used when a job is executed on this type of node.

# HPC Pack 2012 R2

## [HPC Pack 2012 R2 Update 3 Accumulative QFE KB4505153 (4.5.5202) - 6/11/2019](https://www.microsoft.com/en-us/download/details.aspx?id=58380)
SOA fixes
- Fix possible object disposed fault message returned by SOA service hosts.
- Support PowerShell Export-HPCSoaTrace cmdlet.

Scheduler
- Add binary redirection in HpcScheduler.exe.config to better support HPC Pack 2016 client.
- Fix an issue that causes Azure Burst timeouts and Azure nodes end with Offline and Error state.

Management
- Add a way to force delete node with comment 'ForceRemoveNodeMode'.

MPI
- MPI version is updated to v10.0.

Setup
- Support not to install rras/dhcp/wds components on head node slipstream installation with “-SkipComponent:rras,dhcp,wds” option.

This QFE will supercede all HPC Pack 2012 R2 Update 3 QFEs released earlier.

Known issue:
Installation of this upgrade package does not support SQL Server 2008 R2 or earlier.

## [HPC Pack 2012 R2 Update 3 QFE KB4470565 (4.5.5197/5199) - 12/6/2018](https://www.microsoft.com/en-us/download/details.aspx?id=57602)

- Fix an issue that an error dialog will pop up when closing Cluster/Job Manager GUI.
- In Cluster/Job Manager GUI, make "Failed Tasks" column in job list view and "State" column in task list view to be sortable.
- Add column "Free Disk Space (MB)" in the node list view of Cluster Manager GUI.
- Support Kerberos authentication in HPC SOA; Support none secure backend binding for HPC SOA Broker.
- Fix issue that auto grow shrink service may under grow azure resource if the azure nodes have configured under subscribed cores.
- Improve auto grow shrink service to use job's ComputedMax instead of using job's max resource setting.
- Fix scheduling issue when compute node name contains lower case characters.

**Note: this QFE has been regerated (from build 4.5.5197 to 4.5.5199) to address a regression: You may fail to stop an Azure IaaS node in build 4.5.5197.**

## [HPC Pack 2012 R2 Update 3 QFE KB4344029 (4.5.5194) - 7/19/2018](https://www.microsoft.com/en-us/download/details.aspx?id=57161)

- Fix a bug that job will be stuck in queued state if its unit type is Node, has Single Node property and NodeGroup assigned.
- Fix a bug that activity Log may not refresh in UI.
- Support operating system with French for compute/workstation/broker node.
- Add a new value “KEEP” for job environment variable HPC_CREATECONSOLE, when this value specified, we will create a new logon console session if not exists or attach to the existing one and keep the console session after the job completes on the compute nodes.
- By default, scheduler will use job’s runas user credential to do an “Interactive” logon on the compute node. And sometime the “Interactive” logon permission may be banned by your domain policy. We now introduced a new job environment variable "HPC_JOBLOGONTYPE" so that user could specify different logon type to mitigate the issue. The value of job environment variable could be set to 2,3,4,5,7,8,9 as below, more refer to [Doc](https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184(v=vs.85).aspx)  
  ```c#
      public enum LogonType
      {
            Interactive = 2,
            Network = 3,
            Batch = 4,
            Service = 5,
            Unlock = 7,
            NetworkClearText = 8,
            NewCredentials = 9,
      }
  ```
## [HPC Pack 2012 R2 Update 3 QFE KB4039431 (4.5.5187) - 2/27/2018](https://www.microsoft.com/en-us/download/details.aspx?id=56614)
Fast Balanced Scheduling Mode  

Fast Balanced mode is a new mode in addition to Queued and Balanced mode. In this mode, cores are allocated to jobs according to their extended priority. Different from the Balanced mode which calculates balance quota among running jobs, the Fast Balanced mode calculate the balance quota among queued and running jobs together and the preemption in this mode happens in node group level and gracefully, so that it can achieve final balance state more efficiently. The Fast Balanced mode has some constraints on job settings. Non-compatible jobs will fail with validation error. . To enable the fast balanced mode you need to run below powershell cmdlet:
       set-hpcclusterproperty -schedulingmode FastBalanced

This update fixes some known issue of HPC Pack 2012 R2 Update 3 as described as below

HPC Pack fixes
- Fix an issue which causes folder C:\programdata\Microsoft\Crypto\RSA\MachineKeys being filled up with temporary files
- In a rare case, HPCSync may fail with Access Denied error when moving the extracted temp folder to the target. We handle it a bit nicer this time.
- Make the hard coded 4 hour and 15 minute auto grow timeout into a configurable parameter GrowTimeout. The default value is 60 minutes. You can change it through below cmdlet:
       set-hpcclusterproperty -growtimeout <your_own_timeout>
- Fix the issue that cluster manager keeps crashing after clicking “Node Templates” if there is un-approved node.
- Fix the wrong display name issue in script ConfigARMAutoGrowShrinkCert.ps1.
- The speed of selecting a node in the node list in HPC Cluster Manager is improved, especially when there are a large number of nodes in the cluster.
- Now you can modify task commandline within job submission filter which is not possible before this fix.
- Add command “hpccred listcreds” for listing credentials. Add parameter “owner” for command “hpccred setcreds” so that cluster admin could set credentials for other users.
- Automatically recover the scheduler service in case the https server is faulted
- Fix a memory leak in HpcBrokerWorker which happens when there are lots of requests.
- Auto grow would count the online/OK nodes in the excluded node groups for the capacity check. E.g. if there are 2 online/OK nodes in the excluded node group and the queued jobs/tasks require 3 nodes, it would be possible to grow only 1 node for the workload.

## [HPC Pack 2012 R2 Update 3 QFE KB4035415 (4.5.5170) - 8/7/2017](https://www.microsoft.com/en-us/download/details.aspx?id=55714)
This update fixes some known issue of HPC Pack 2012 R2 Update 3: Before this fix, the deployment will not wait for the completion of the startup script specified in the node template and admin has no way to change this behavior. Thus job/task may fail as the environment hasn't been ready by the startup script. With this fix we expose below two registry keys so that admin can overwrite the default behavior. For example if admin set registry key "Microsoft.Hpc.Azure.AzureStartupTaskFailureEnable" to 1, the deployment will wait until the startup script finishes execution before setting the node reachable for jobs

Management fixes
- Supporting below registry keys in headnode:
      HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC Name:Microsoft.Hpc.Azure.AzureStartupTaskFailureEnable Type:REG_DWORD; (default is 0)
      HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC Name:Microsoft.Hpc.Azure.AzureStartupTaskTimeoutSec Type:REG_DWORD; (default is 1800)

## [HPC Pack 2012 R2 Update 3 QFE KB4032368 (4.5.5168) - 7/17/2017](https://www.microsoft.com/en-us/download/details.aspx?id=55650)

Management fixes
- Fix GUI freeze issue when there are lots of azure nodes, node templates in the system
- Fix perf counters may not collected issue when there are lots of azure nodes (serveral thousand)
- Bring the support on ARM deployed Azure IaaS nodes in auto grow shrink service
- Add "AzureOperations" in the Operations View so that admin can check the auto grow shrink script easily; The auto grow shrink logs will be purged after 48 hours
- Improved AzureAutoGrowShrink.ps1 script as below:  
      1. Able to handle parametric task with millions of sub-tasks;  
      2. Multiple azure batch operations on grow and shrink instead of one operation to prevent azure side throttling and blocked by one azure operation;  
      3. Bring node online after successful azure deployment instead of bringing node online before node provisioning;

## [HPC Pack 2012 R2 Update 3 Accumulative QFE KB3189996 (4.5.5161) - 6/3/2017](https://www.microsoft.com/en-us/download/details.aspx?id=54772)
SOA fixes
- Removed 4 MB message size limit - Now in SOA requests you can send requests that are larger than 4 MB in size. A large request will be split into smaller messages when persisting in MSMQ, where there is 4MB message size restriction.
- Configurable broker dispatcher capacity - Users can specify the broker dispatcher capacity instead of the calculated cores. This achieves more accurate grow and shrink behavior if the resource type is node or socket. Please refer the sample below:  
  ```xml
      <loadBalancing dispatcherCapacityInGrowShrink="0"/>
  ```
   If value is 0 – dispatcher capacity is auto calculated by the number of cores. If value is an positive integer, dispatcher capacity will be the value specified.
   Dispatcher Capacity is defined as the number of requests that a service host can handle at a time, by default it is the number of cores a service host occupies. This value can also be specified by sessionStartInfo.BrokerSettings.DispatcherCapacityInGrowShrink per session
- An optional parameter ‘jobPriority’ is added in ExcelClient.OpenSession method for Excel VBA.
- Added GPU Unit type in SOA session API so that you can specify GPU resource in the SOA job.
- Fixed an issue that HA broker nodes may not be found by the system due to AccessViolationException in session service.
- Fixed an issue that SOA job may be stuck in queued state.
- Reduced the SOA job queue time in Balance/Graceful Preemption mode.
- Fixed an issue that durable session job may runaway when the client sends requests without flush and then disconnects.
- Fixed broker worker crash issue in some rare situation.
- Fixed an issue that a session job may stall when azure worker role nodes get re-deployed in a large deployment.
- Fixed an issue that SOA request may fail in some rare condition with large azure burst deployment.
- Added ParentJobIds in SessionStartInfo for SOA Session API so that parent jobs can be specified during session creation.
- Added ServiceHostIdleTimeout for SOA service, and the default value is 60 minutes.

Scheduler and API fixes
- Fix overflow in AllocationHistory table; This requires SQL Server 2012 or later version.
- Add cluster property JobCleanUpDayOfWeek to specify on which day of week should HPC Pack clean up Scheduler DB. For example, to let the service do job clean up on every Saturday, admin need to set:
      Set-HPCClusterProperty -JobCleanUpDayOfWeek “Saturday”
- Fix an issue that task may failed with “The parameter is incorrect” message for both on-premise and azure HPC IaaS cluster.
- Fix a scheduler crash issue during startup.
- Enabled GPU related metrics.
- Improved of error handling for linux node manager.
- Fix a deadlock issue when finishing a job or a task to avoid queuing the whole cluster.
- Fix an issue that a job stuck in canceling and won’t release resource for other jobs resulting the whole cluster being blocked.
- Improve performance (added a few SQL index) when there is huge historical data.
- Added cluster configuration “DisableResourceValidation”. Now admin can set this value to true to skip validation on job resource requirement whether can be met by the current available resource. This allows user to submit jobs to a cluster without resource added or provisioned. To change the setting:
      Set-HPCClusterProperty -DisableResourceValidation $newValue
- Included job modification in job audit events. To see all job modification and activities, please try view the “Activity Log” in the job management UI or the output of command “job view \<jobid\> /history".
- Added new job action "Hold" in job GUI; Now you can hold a running job so that no new resources will be allocated to this job. And the job will be in “Draining” state if there is still active tasks running.
- Fix an issue that release task may be skipped to run in exclusive job.
- Fix an issue that clusrun may fail to get output from azure compute nodes due to compute node IP changes under auto grow shrink situation.
- Task execution filter - Task execution filter for Linux compute nodes to enable calling administrator-customized scripts that each time a task is executed on Linux nodes. This helps to enable scenarios such as executing tasks with an Active Directory account on Linux nodes and mounting a user's home folder for task execution. For more information, check "Get started with HPC Pack task execution filter".
- Set maximum memory for your task to be allowed during execution. User can add environment variable ‘CCP_MAXIMUMMEMORY’ in task, then the task will be marked as failed if the task tries to exceed the memory limitation set by this value on windows compute node. This setting currently isn't appliable on linux compute node.
- Task Level Node Group: We added initial support for specifying node group information for your tasks instead of specifying this information at the job level. A few things you need to be aware when using this feature:  
    1. You’d better using this feature in Queued Scheduling Mode
    2. You can only assign one requested node group for your task and meanwhile, you shall not specify node groups for your job
    3. It is better you specify node groups without overlapping for your tasks within a job
    4. Currently you can specify the task requested node group in the scheduler API, job GUI or CLI

Management fixes
- Fix a socket exhaustion issue when AzureStorageConnectionString isn’t correctly configured.
- Fix an issue that SDM service can consume 100% of CPU time on the headnode some time.
- Add ‘Networks’ in return object in ‘Get-HpcNode’ powershell cmdlet;.
- Support new Azure role size in azure bursting including Av2 and H series.
- Fix an issue that admin may fail to remove an HPC user whose account is already removed from AD.
- Support GPU on workstation node as well as Linux nodes.
- Fix one issue for selecting OS version when add Azure batch pool in HPC Pack.
- Fix one issue that the heatmap sometime showing empty.
- Improve Auto grow shrink script, make the node online first before growing instead of waiting all nodes in OK state. Now the node will be able to accept jobs once it is started.
- Auto grow shrink script supports to grow/shrink compute nodes created with VM scaleset.
- Fix the issue that sometimes auto grow shrink script doesn’t use certificate for Azure authentication even when the certificate is configured.
- Fix the issue that Export-HpcConfiguration.ps1 exports the built-in template “LinuxNode Template” which shall not be exported.
- Support excludeNodeGroups property in built-in auto grow shrink, user can specify the node group in which he want those nodes to be excluded from auto grow shrink logic.
- Add option to disable the node from syncing hpc cluster admin to local administrator group, to do this, you need to add following value on the target node under registry HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC  
  Name: DisableSyncWithAdminGroup  
  Type: REG_DWORD  
  Data: 1

GUI Improvements
- Show total core in use, running job, running tasks in heatmap view status bar when no node selected.
- Now you can copy “allocated nodes” in job/task detail page.
- Custom properties page - In the Job dialog, you can now view and edit a job’s custom properties. And if the value of the property is a link, the link is displayed on the page and can be clicked by the user. If you would like a file location to be clickable as well, use the format file:///\<location\>, for example, file:///c:/users
- Substitution of mount point - When a task is executed on a Linux node, the user usually can’t open the working directory. Now within the job management UI you can substitute the mount point by specifying the job custom properties linuxMountPoint and windowsMountPoint so that the user can access the folder as well. For example, you can create a job with the following settings:  
  Custom Property: linuxMountPoint = /gpfs/Production  
  Custom Property: windowsMountPoint = Z:\Production  
  Task Working Directory: /gpfs/Production/myjob  
  Then when you view the job from GUI, the working directory value in the Job dialog > View Tasks page > Details tab will be z:\production\myjob. And if you previously mounted the /gpfs to your local Z: drive, you will be able to view the job output file.
- Set subscribed information for node - The Administrator can set node subscribed cores or sockets from the GUI. Select offline nodes and perform the Edit Properties action.
- No copy job – If you specify the job custom property noGUICopy as true, the Copy action on the GUI will be disabled.
- Improve HPC job manager heatmap performance issue when there are more than 1000 nodes.
- Support to copy multiple SOA jobs on SOA job view with the correct format.

REST API and WebComponent fix
- Add new REST API Info/DateTimeFormat to query DataTime format info on HPC Pack REST server so that the client side can do DataTime parsing with the correct format.
- Improved job searching in HPC Web Portal; Now if you want to get all jobs with name contains “MyJobName” you need to specify “%MyJobName” in search box.
- Add new odata filter parameters “TaskStates”, “TaskIds”, and “TaskInstanceIds” to the REST API GetTaskList.

**Note: This QFE had been refreshed in early June 2017 to address patching issues when your existing cluster is using remote DB with customized scheduler DB name;**

This QFE will supercede QFE 3134307, QFE 3147178 and QFE 3161422 released earlier.

## [HPC Pack 2012 R2 Update 3 QFE Accumulative KB3161422 (4.5.5111) - 6/22/2016](https://www.microsoft.com/en-us/download/details.aspx?id=52983)

SOA fixes
- Added SOA HoldUntil Support. For a SOA session, users can now pause a running session by modifying session job's HoldUntil property to a future time.
- Fixed the possibly broker unload when the connection timeout happens between the broker and the client which may cause calculating requests discarded.
- Updated EchoClient for random message size and time; add flush per number of requests support; add message operation (send/flush/EOM/get) timeout parameter.
- Added two optional parameters jobName and projectName in ExcelClient.OpenSession method for Excel VBA.
- Other bug fixes around stability and logging for SOA.
- Fix node exclusion too long for SOA jobs: Finish task when exit call failed.

Scheduler fixes
- Carry hresult on node manager exception for better troubleshooting of node manager exceptions.
- Linux node manager execution filter support.
- Fix the task dependency issue that a job could be stuck in running state if a task is added and its dependent parametric sweep task is in running state with some finished sub-tasks.
- Improve the performance of scheduler by decreasing the validating time of a job which contains a large number of tasks with task dependency.
- Fix the issue that node release task may fail if the job resource type is “Socket” or “GPU”.

Management fixes
- Add JobId in HpcTask object for powershell, so user can get JobId in cmdlet Get-HpcTask.
- Enhance HpcSync.exe command, if no package to sync from Azure storage, exit with 0 instead of -1.
- Fix one issue to let user set SubscribedCore and SubscribedSocket for GPU compute node.
- Support running SOA job for Azure PaaS deployment using internal load balancer.
- Fix one UI bug, when select “By Node Template” in node view, if click “Add Node”, it will be failed and popup error dialog.

This QFE will supercede QFE 3134307 and QFE 3147178 released earlier

## [HPC Pack 2012 R2 Update 3 QFE KB3147178 (4.5.5102) - 4/1/2016](https://www.microsoft.com/en-us/download/details.aspx?id=51662)
SOA improvements
- Fixed the error "Authentication failed. Make sure you have the permission to the SOA diagnostics service." when SOA message level logs are viewed by administrators from a trusted domain other than the domain of the job owner.
- Fixed the issue when setting serviceOperationTimeout to a small value for a SOA service, that the timeout exception for each request from the service cannot be passed through to the client.
- Fixed the issue that jobs could be stuck in the queued state due to a SOA job cannot be preempted because of a syncing issue between scheduler and the broker when there are a lot of responses waiting to be flushed into MSMQ and only a few processing requests.
- Increased the session creation throughput when using a shared session pool.
- Provided the binding parameter to override the default binding when creating SOA sessions. To use the new Session API, please download the QFE version of the SDK.

Management and Azure burst improvements
- Fixed the issue in HPC Cluster Manager, in Job view, when user selects one “Admin Jobs”, then clicks “Job Details” property tab, it is unable to show job details.
- Fixed a backward compatibility issue for the GUI when connecting to HPC Pack 2012 R2 Update 2 (and previous version) clusters.
- Provided two new configurations by registry keys to alter the node state and the default 60 minute operation timeout for Azure burst deployments.  
  1. HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC Name:Microsoft.Hpc.Azure.HpcSyncFailureEnable Type:REG_DWORD Data:1
By default, HpcSync results don't affect the final Azure node deployment state. After configuring this registry key with DWORD value 1, when HpcSync fails to sync all the packages on a node, the node will be marked in the Error state and this won't block completion of the whole deployment operation. The HpcSync will continue to retry downloading the packages on the nodes with a default 5 minute interval and once this succeeds, the Azure node will automatically reach the OK state. The deployment operation logs will show the related message for any Error nodes because of the HpcSync failure. This registry key shouldn't be set if there is no user package being uploaded through hpcpack.exe otherwise the provision will fail as hpcsync does not find any packages
  2. HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\HPC Name:Microsoft.Hpc.Azure.DeploymentOperationTimeoutInMinutes Type:REG_DWORD Data:60
By default, the Azure burst deployment operation has a timeout of 60 minutes. With this registry key, the deployment timeout can be customized according to the requirement. For example, change it to 30 minutes if a shorter operation timeout is preferred.

Scheduler fixes
- fix issue that task may incorrectly created with dependency while the job is already running.
- fix performance issue for jobs with large number of tasks with dependencies.

## [HPC Pack 2012 R2 Update 3 QFE KB3134307 (4.5.5094) - 2/2/2016](https://www.microsoft.com/en-us/download/details.aspx?id=50809)
Auto grow shrink improvements
- Supports jobs with task dependencies.
- Supports Linux IaaS nodes.

SOA improvements
- Added support for multiple SOA sessions in a shared session pool.  
  To specify the pool size for a SOA service, add the optional configuration \<service maxSessionPoolSize="20"\> in the service registration file. When creating a shared SOA session with the session pool, specify both sessionStartInfo.ShareSession and sessionStartInfo.SessionPool as true. And after using this session, close it without purging to leave it in the pool.
- Added GPU type for SOA session API.
- Fixed an issue that SOA service host start failure may make the SOA job unable to release core resources to other jobs.
- Added SOA multi-emit feature: you can specify the following optional configuration in your service registration file: \<loadBalancing multiEmissionDelayTime="10000"\>. Then, if a SOA request fails to return from the service host within 10,000 milliseconds, the broker will resend the request until a response is successfully returned within the timeout for the request or the messageResendLimit of the request is reached. Specify the value -1 or remove the multiEmissionDelayTime attribute from loadBalancing to disable this feature.  
  **Note: Please choose a value which is large enough to be considered as a bad request calculation for your service; otherwise, many requests will be re-calculated unnecessarily, which will waste the cluster resources.**
- Improved the functionality of EchoClient.exe for the built-in SOA echo service. It is a handy tool for evaluating the functionality and the performance of the SOA system.

Linux node agent fixes
- Removed some sensitive information from the logs.
- Fixed an issue that when node manager restarts, the nodemanager.json configuration file’s content are cleared occasionally, causing the node to be in an error state.
- Fixed an issue when cgroup subsystems with different hierarchy as installation are specified.

Support for Azure Internal Load Balancer
- Now when you are using ExpressRoute you can specify Azure Internal Load Balancer for your azure PaaS compute nodes in the node template. Together with forced tunneling you can have all your burst traffic within ExpressRoute.

Deprecated the environment variable %CCP_NEW_JOB_ID%
- In Update 3 we introduced CCP_NEW_JOB_ID to store the job id generated or used in a previous job command, but it doesn’t work appropriately. Now with this QFE, we use the symbol "!!" to indicate the job id when it is required as a parameter in a job command.
e.g. job new; job add !! hostname; job view !!; job submit /id:!!

Fixed task failure issue
- In some cases, your task will fail during task creation with an error similar to: Error from node: server:Exception 'The job identifier xxx is invalid.' This update fixes the issue when the following server stack trace is generated:  
  ```c#
  at Microsoft.Hpc.NodeManager.RemotingExecutor.RemotingNMExecImpl.StartTask(Int32 jobId, Int32 taskId, ProcessStartInfo startInfo)
  at Microsoft.Hpc.NodeManager.RemotingExecutor.RemotingNMExecImpl.StartJobAndTask(Int32 jobId, String userAccount, Byte[] cipherText, Byte[] iv, Byte[] certificate, Int32 taskId, ProcessStartInfo startInfo)
  at Microsoft.Hpc.NodeManager.RemotingExecutor.RemotingNMExecImpl.StartJobAndTask(Int32 jobId, String userAccount, Byte[] cipherText, Byte[] iv, Int32 taskId, ProcessStartInfo startInfo)
  at Microsoft.Hpc.NodeManager.RemotingCommunicator.RemotingNMCommImpl.StartJobAndTask(Int32 jobId, String userAccount, Byte[] cipherText, Byte[] iv, Int32 taskId, ProcessStartInfo startInfo
  ```
Other fixes
- in HPC HA cluster, there might be two nodes with same name in cluster, one is unapproved and the other is offline.


## [HPC Pack 2012 R2 Update 3 (4.5.5079) - 11/14/2015 ](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/hpc-server-2012-R2-and-2012/mt595796(v=ws.11))

* Support for Linux nodes on-premises
  In Update 2, we introduced Azure Linux VM support for HPC Pack. With this update, HPC Pack supports Linux for on-premises compute nodes. Customers running HPC clusters on Linux can now use HPC Pack deployment, management, and scheduling capabilities, and the user experience is very similar to the Windows nodes.
  * Deployment – In Update 3, we include the Linux agent binaries with HPC Pack. After the head node installation, you can install these binaries from the head node share with the provided setup script. In this release, we support CentOS (versions 6.6 and 7.0), Red Hat Enterprise Linux (versions 6.6 and 7.1) and Ubuntu (Version 14.04.2).
  * Management and scheduling – The management and scheduling experience of Linux nodes in HPC Cluster Manager is similar to the Windows nodes we already support. You can see the Linux nodes' heat maps, create jobs with Linux node specific cmdlets, monitor job, task, and node status, etc. Additionally, the handy tool clusrun is supported with Linux nodes.
  * Support for MPI and SOA workloads – Please note that Microsoft (MS-MPI) is only available on Windows computes nodes. Thus you need to install an MPI version by yourself on the Linux nodes. We provide guidance on how to submit Linux MPI jobs in HPC Pack. To run SOA workloads on Linux nodes ,you need our Java Service Host, which is released as an open source project on GitHub. We will publish more details on this later.
  For more information about Linux support in Update 3, see Get Started with Linux compute nodes with HPC Pack.
* GPU support
  GPUs are becoming more popular in technical computing. With this update, we offer the initial support of GPUs with HPC Pack. In this update, we support NVidia GPUs with CUDA capability only (for example, Tesla K40).
  * Management and monitoring – Our management service detects whether a Windows compute node has a GPU installed and configured. If so, we collect GPU metrics so that it can be monitored on the heat map..
  * Scheduling – In this release, you can specify unit type as GPU in addition to Core/Socket/Node for your job or task. Additionally, the job scheduler will provide the assigned GPU index information as an environment variable for your task to use exclusively.
  For more information about this GPU support in Update 3, see Get started with HPC Pack GPU support.  
* Burst to Azure Batch
  The Azure Batch service is a cloud platform service that provides highly scalable job scheduling and compute management. Starting with this update, HPC Pack is able to deploy an Azure Batch pool from the head node and treat the pool nodes as a “fat” node in the system. Batch jobs and tasks can be scheduled on the pool nodes.
  For more information, see Burst to Azure Batch from Microsoft HPC Pack.
* Scheduler improvements
  * Azure auto grow shrink with SOA workloads – Now the auto grow shrink service can grow nodes based on the outstanding calls in a SOA job instead of only task numbers. And you can set the new SoaJobGrowThreshold and SoaRequestsPerCore properties for auto grow shrink:.
  * Customizable idle detection logic – Until this release the workstation nodes and unmanaged server nodes have been treated as idle based on keyboard or mouse detection or CPU usage for processes other than those for HPC Pack. Now we add these capabilities:
    * You can whitelist processes you want to exclude from calculating the node CPU usage by adding below registry key values (Type: REG_MULTI_SZ) HKLM\Software\Microsoft\HPC\CpuUsageProcessWhiteList.
    * When you don’t specify keyboard or mouse detection or a CPU usage threshold, you can provide your own node idleness logic by creating a file with the name IdleDetector.notidle in the %CCP_HOME%Bin folder. HPC Pack checks whether this file exists and reports to the scheduler every 5 seconds.
  * Previous task exit code – We provide the environment variable CCP_TASK_PREV_EXITCODE to record the previous exit code of the task if it is retried.
  * Scheduler REST API improvements.
    * Added the new task properties ExecutionFailureRetryCount and AutoRequeueCount
    * Added OData filter and sort-by ability on GetNodeList, GetJobList, and GetTaskList. For example, for GetJobList:
      Specify OData filters to use for this request in the format "$filter=<filter1>%20and%20<filter2>…". To filter the jobs by a valid job state, use the filter "JobState%20eq%20<JobState>". To retrieve jobs whose state changed after certain date time, use the filter "ChangeTimeFrom%20eq%20<DataTime>". A null value is ignored. The minimum version that supports this URI parameter is Microsoft HPC Pack 2012. To use this parameter, also specify the Render URI parameter set to RestPropRender and a minimum api-version value of 2012-11-01. Example: "$filter=JobState%20eq%20queued%20and%20 ChangeTimeFrom%20eq%202015-10-16&Render=RestPropRender&api-version=2012-11-01".
  * Unlimited number of parametric sweep tasks in a job – Before this release the limit was 100.
  * CCP_NEW_JOB_ID environment variable for the job new command. – With this variable you no longer need to parse the command output in your batch scripts.
* SOA improvements
  * Better mapping for broker worker logs with sessions - To enable the per session broker logs, add the attribute PerSessionLogging="1" for the shared listener “SoaListener” in HpcBrokerWorker.exe.config on the broker nodes.
  * SessionStartInfo supports %CCP_Scheduler% as the head node name if it is not specified – It also accepts any predefined environment variable, such as %HPC_IaaSHN%.
  * Support for Excel running under console session by default - If you have many cores on a compute node and you want to start many instances of Excel, run Excel under a console session to prevent possible issues. From HPC Cluster Manager, click Node Management. In the node list, choose all the compute nodes for Excel, right-click, and choose Remote Desktop from the context menu. RDP to all the nodes using the user credentials under which the Excel workbook will run. This creates an active interactive session for the Excel work to launch and it can be observed when the Excel job runs on the nodes.
  * SOA job view in web portal - The HPC web portal now shows additional list views for SOA jobs and My SOA jobs with default columns for request counters including total and outstanding requests. In the job details view, progress bars are added to show the progress of the tasks and requests.
  * EchoClient.exe for the built-in Echo service - The EchoClient.exe is located in the %CCP_HOME%Bin folder. It can be used as a simple SOA client for the built-in Echo service named CcpEchoSvc. For example, EchoClient.exe –h <headnode> -n 100 creates an interactive SOA session with 100 echo requests. Type EchoClient.exe -? for more help info.
* Other improvements
  * HPC version tool - We introduce a Windows PowerShell tool to list the HPC Pack version and installed updates. Run Get-Help Get-HPCPatchStatus.ps1 –Full on any computer where HPC Pack is installed to get detailed help and examples..
  * Per instance heat map - Until this release HPC Pack has only provided an aggregated instance heat map, but now you can view an individual heat map of each instance through the overlay view.
  * MS-MPI v7 - We integrate with the latest Microsoft MPI version, MS-MPI v7 (download here).

## [HPC Pack 2012 R2 Update 2 (4.4.4864) - 7/7/2015](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/hpc-server-2012-R2-and-2012/mt269417(v=ws.11))
* Support for Linux nodes on Azure  
  With this update, HPC Pack now supports Linux VMs for compute nodes running on Azure. Customers running high-performance computing clusters on Linux can now use HPC Pack deployment, management, and scheduling capabilities. The user experience is very similar to the one for Windows nodes.
  * Deployment – In HPC Pack 2012 R2 Update 1 we released an IaaS deployment script tool to help create an HPC Pack VM cluster on Azure. Now in Update 2 (starting from version 4.4.0), we extend the support scope to Linux nodes as well. By following the latest documentation for this tool, the entire deployment experience is easy and fast, with multiple options from which you can choose.
    We plan to provide Azure Resource Manager (ARM) template-based deployment solutions for Linux nodes at a later time.
  * Management and scheduling – The management and scheduling experience of Linux nodes in the HPC cluster manager is quite the similar to the experience for Windows nodes we already support. You can see the Linux nodes heat maps, create jobs with specific Linux cmdlets, and monitor job, task, and node status. Additionally, the useful Clusrun tool is also supported on Linux nodes.
  * Support for RDMA – Azure now provides RDMA network support for Linux VMs as well as Windows Server instances created in the A8 or A9 size. Size A8 or A9 Linux nodes in an HPC Pack cluster will automatically connect to the RDMA network as long as you choose a supported Linux RDMA images from the Azure Marketplace.
  For more information about Linux support in Update 2, see Getting Started with HPC Pack and Linux in Azure.
* Run Excel workbooks on HPC clusters on Azure
  * Deployment – Using the recently released Azure Resource Manager and Azure quickstart templates, we released a template to create an HPC Pack cluster with Excel pre-installed on compute nodes. See this article for instructions to deploy a working HPC cluster shortly.
  * Excel workbook – With a few simple changes you make on your existing Excel workbook, you can directly point your computation workloads to the cluster on Azure.
  * Excel UDF – By changing only the head node name to the IaaS cluster name and deploying the XLL files on the IaaS cluster, the UDF offloading works just as in on-premises HPC Pack clusters.
  * Transparent data movement – You don't need to worry about the how to move the Excel workbooks from your local workstation to Azure; all these details are handled by HPC Pack. You can see the work done just as in a local on premises cluster.
* Built-in auto grow/shrink service  
  In HPC Pack 2012 R2 Update 1, we introduced and released the first version of support for automatically growing or shrinking the Azure VM resources in an HPC Pack cluster via a Windows PowerShell script. Now in Update 2, we improved this feature to be a built-in service. You can now enable or disable this feature on demand without keeping a Windows PowerShell script running. This features still targets Azure nodes (PaaS) and Azure IaaS VM compute nodes in an HPC Pack cluster. Additional improvements include:
  * Improved efficiency of nodes growing and shrinking.
  * Grow or shrink the HPC Azure nodes by checking the job’s node group or required nodes, and grow them accordingly.
  * Configure the auto grow/shrink service during HPC Pack cluster deployment by the IaaS deployment tool through the AutoGrowShrink option.
  If you don’t use the HPC Pack IaaS cluster deployment tool, you can enable this feature through the following steps:  
    ~~~
    1. Start HPC PowerShell as an administrator.
    2. View the current configuration of the AutoGrowShrink property by running the following command: Get-HpcClusterProperty –AutoGrowShrink
    3. Enable or disable “AutoGrowShrink” by running the following command:
    Set-HpcClusterProperty –EnableGrowShrink <1 | 0>
    4. Change the grow interval (in minutes) by running the following command:
    Set-HpcClusterProperty –GrowInterval <interval>
    5. Change the shrink interval (in munites) by running the following command:
    Set-HpcClusterProperty –ShrinkInterval <interval>
    ~~~
* Cluster deployment with Azure quickstart templates  
  The HPC Pack team has contributed several Azure quickstart templates to help customers with specifc needs deploy HPC clusters in Azure Resource Manager. The templates include:
  * Generic HPC Pack cluster with a clean installation of Windows Server on compute nodes.
  * HPC Pack cluster with customized compute node images.
  For more details and instructions, go to Azure Quickstart Templates, and search for the keyword “HPC” to find the one you need.
* SOA improvements
  * Support for basicHttpBinding as a transport scheme for creating SOA sessions, sending requests and getting responses. Besides the basicHttpBinding, the Azure Storage queue is also utilized as a transport medium to improve performance and scalability.
  * Support for running SOA clients on a machine outside of the cluster domain either with NetTcp or Https binding. For example, an on-premises SOA client can now communicate with an HPC Pack cluster in Azure IaaS.
  * Support for Azure data movement for SOA sessions. After setting the Azure storage connection string on the cluster, using SessionStartInfo.DependFiles will help move the files on the client machine to the %HPC_SOADATAJOBDIR% folder on an IaaS head node via Azure storage blobs. The same data file for a given user will only be uploaded and downloaded to the data cache on the head node once, and then copied to %HPC_SOADATAJOBDIR% folder for each session to consume.
  * SOA message UniqueId can be explicitly specified when sending messages using broker clients.
  * SOA service versioning is expanded from major.minor to the full version format major.minor.build.revision.
  * SOA jobs can be viewed from HPC Job Manager.
  * SOA message level tracing now supports HTTP binding.
  * Common Data blob download timeout is changed as a configurable parameter in the service dll configuration file.
  * Other performance and scalability improvements.
* Other improvements
  * Support for reserved public IP address for bursting to Azure - In Update 2, we introduce support for a reserved public IP address for each Azure cloud service endpoint used in Azure “burst” deployments. This is to help customers who have a strong requirement for a firewall rule that all the traffic has to bind to a reserved IP address. So to configure Azure “burst” nodes, the endpoint Azure deployment has to bind to a static IP address. Otherwise, all the traffic will be blocked by the firewall.
  * More views in HPC Job Manager – Update 2 adds a SOA jobs view, heat map view, and a monitoring chart view.
  * Suspend a running job - Starting in Update 2 you can suspend a running job. Previously, if you wanted to empty the cluster for some important jobs, you had to cancel the running jobs, and jobs entered the Canceled state. In Update 2, you can set the holduntil property on a running job; the job will stop dispatching new tasks to nodes, and becomes Queued after the all the running tasks finish. It won’t be scheduled until the time set on the holduntil property. You can set the holduntil property on a running job inthe following ways:  
    ```
    HPC command: job modify {jobid} /holduntil:{holduntiltime}

    HPC PowerShell: Set-HpcJob {jobid} –Holduntil {holduntiltime}

    Job management GUI: Select a running Job, perform Modify Action, and change the HoldUntil setting on the Advanced page to a later time.
    ```
  * Azure SDK 2.5 – For Azure “burst” deployments we upgraded our Azure SDK version from 2.2 to 2.5 to improve reliability and to stop using the to-be-deprecated REST API in the Azure Storage service (details here). We recommend our users to migrate to this version as soon as possible if you deploy Azure “burst” nodes.
  * Kerberos constrained delegation support - For this to work, your software needs to obtain the User Principal Name (UPN) of the user requesting the job. Then it impersonates this user, connects to the HPC scheduler, and submits the job, using the HPC Class Library. A prerequisite is to set up account delegation.
  * MS-MPI v6 - We integrate with the latest Microsoft MPI version, MS-MPI v6 (download here).

## [HPC Pack 2012 R2 Update 1 (4.3.4652) - 11/17/2014 ](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/hpc-server-2012-R2-and-2012/dn864736(v=ws.11))
* Azure IaaS deployment and management
  * HPC Pack image now available in the Azure Marketplace on both the Azure global and Azure China services  
    For this release, we added a new HPC Pack virtual machine image to the Azure Marketplace. This Azure VM image is based on Windows Server 2012 R2 Datacenter Edition with HPC Pack 2012 R2 Update 1 pre-installed. Microsoft SQL Server 2014 Express is also pre-installed. You can use this image to create the head node of a Windows HPC cluster in Azure. We recommend using a VM size of at least A4. Before creating a VM, you must configure a valid virtual network for it if the head node is not planned as a single-machine scenario. Additionally, while or after creating the VM, you will need to join the virtual machine to an Active Directory domain. You can optionally promote the head node as the domain controller. For more information, see Create a Head Node from the Microsoft HPC Pack Azure VM Image.
  * HPC Pack IaaS deployment script to deploy an HPC cluster on Azure VMs  
    The HPC Pack IaaS deployment script provides an easy and fast way to deploy HPC clusters in Azure infrastructure services (IaaS) on either the Azure Global or the Azure China service operated by 21Vianet. It utilizes the HPC Pack VM image in the Azure Marketplace for fast deployment and provides a comprehensive set of configuration parameters to make the deployment easy and flexible. The HPC Pack IaaS cluster can be set up from a client computer by using only the Azure subscription ID and the management certificate or publish setttings file; the script can then create all the cluster infrastructure, including the virtual network, affinity groups, storage accounts, cloud services, domain controller, remote or local SQL databases, head node, broker nodes, compute nodes, and Azure PaaS (“burst”) nodes. The script can also use pre-existing Azure infrastructure and then create the HPC cluster head node, broker nodes, compute nodes and Azure PaaS nodes. The HPC Pack web portal and REST API can also be enabled by the script. For details, see Create an HPC cluster with the HPC Pack IaaS Deployment Script.  
    **Note: Before running this script, you must configure an Azure publish settings file or an Azure management certificate on the client.**
  * HPC Pack IaaS management scripts to add, remove, start, or stop Azure VM nodes in an HPC Pack IaaS cluster  
    Besides the easy and fast deployment script, we provide a set of management scripts on the IaaS head node to help customers easily manage the Azure VM compute nodes in an HPC Pack IaaS cluster. With Add-HpcIaaSNode.ps1 and Remove-HpcIaaSNode.ps1, users can easily expand or shrink the number of IaaS VMs with different customized compute node images and different VM sizes in multiple cloud services and storage accounts. With Start-HpCIaaSNode.ps1 and Stop-HpcIaaSNode.ps1, you can grow and shrink the number of Azure VM compute nodes according to the workload. When the number of jobs or tasks increases, start the VMs to bring the compute nodes online to grow the compute resources. When the workload finishes, bring the compute nodes offline and stop the VMs into the Stopped (Deallocated) state to save costs. For details, see Manage the Compute Node VMs in an HPC Pack IaaS Cluster.
    **Note: Before running these scripts, you must configure an Azure publish settings file or an Azure management certificate on the client.**
* Azure PaaS (“burst”) deployment enhancements
  * Automatically detect and support new node sizes  
    In HPC Pack 2012 R2 and prior releases, the Azure node (worker role instance) sizes supported in burst deployments are fixed. HPC Pack 2012 R2 Update 1 allows newly added Azure worker role sizes that are supported by HPC Pack to be automatically refreshed and appear in the dropdown list in the Add Node Wizard when adding Azure burst nodes. The list of supported role sizes is maintained by Microsoft and is updated periodically as the platform supports new sizes. Depending on your Azure subscription, you may not be able to use all Azure role sizes.
  * Azure regional virtual networks supported  
    Azure regional virtual networks (“wide” VNets) were introduced in May 2014 and newly created VNets now span an entire Azure region instead of a hardware cluster in an Azure data center. Because of this, a regional VNet is bound to a location instead of an affinity group. In HPC Pack 2012 R2 and prior releases, when creating Azure nodes template, if the VNet is required, HPC Pack only detects and validates the VNets associated with the affinity group of the specified cloud service. Starting in HPC Pack 2012 R2 Update 1, HPC Pack fully supports regional VNets for Azure burst deployments, and continues to support the previous “narrow” VNet that is associated with an affinity group for backward compatibility.
  * Start selected Windows Azure nodes  
    HPC Pack 2012 R2 Update 1 allows you to start selected nodes from HPC Cluster Manager or the new Start-HpcAzureNode HPC PowerShell cmdlet. With this feature you can now add a set of Azure nodes once and then scale up the number of provisioned nodes to match the workloads in the job queue multiple times. Working with the stop selected Azure nodes feature introduced in HPC Pack 2012 R2, you can scale up and down the number of provisioned Azure nodes without adding and removing the nodes each time. In previous versions of HPC Pack, you can only start an entire set of nodes deployed with a particular node template.
  * Azure burst deployments supported in Azure China  
    HPC Pack 2012 R2 Update 1 now supports Azure burst deployments in the Azure China service and provides a simple PowerShell script to run on the head node(s) to switch between the Azure Global and Azure China services. To switch between the Azure Global and Azure China service, on each head node, open PowerShell as an administrator, go to $env:CCP_HOME\bin, and run .\Update-HpcAzureEndpoint.ps1 -AzureType Global or .\Update-HpcAzureEndpoint.ps1 -AzureType China. You don’t need to restart any HPC services after running the script. To view the current Azure service used for the deployment, run .\Update-HpcAzureEndpoint.ps1 –View. For more information about the Azure China service operated by 21ViaNet, please refer to [Doc](http://www.windowsazure.cn/zh-cn/support/faq/?l=zh-cn).  
    **Note: You should stop any Azure burst deployments before changing the service type, or you may not be able to use the previous deployments.**
* Installation
  * Support for Microsoft SQL Server 2014  
    The HPC Pack 2012 R2 Update 1 installation package and the HPC Pack Azure VM image contain SQL Server 2014 Express to host local HPC cluster databases. If SQL Server 2012 or 2008 R2 Express is not detected on the head node, the installation package installs SQL Server 2014 Express. (The upgrade installation does not upgrade an existing SQL Server 2012 Express or 2008 R2 Express installation to SQL Server 2014 Express.) For remote databases, SQL Server 2014 Standard and Enterprise are now also supported. The remote databases can be configured with a SQL Server AlwaysOn failover cluster instance or availability group for high availability. For more information about SQL Server HA solutions, see High Availability Solutions (SQL Server).
* Node management
  * Automatically grow or shrink the number of Azure nodes and Azure VMs according to workload.   
    HPC Pack 2012 R2 Update 1 provides the AzureAutoGrowShrink.ps1 PowerShell script to monitor the jobs or tasks in the queue to automatically grow or shrink the number of Azure PaaS (burst) nodes or the IaaS compute node VMs by starting or stopping the nodes. You can specify a set of parameters, e.g., the number of queued jobs or the number of active queued tasks required to grow per one node, the threshold of the number of queued jobs or the number of active queued tasks required to start grow, the grow/shrink check interval, the number of sequential idle confirmations for a node to shrink, and the node templates or job templates for the grow/shrink scope. This script can be found under %CCP_Home%bin folder on head nodes and clients. When running with compute node VMs in Azure, the script should run on the IaaS head node because it depends on Start-HPCIaaSNode.ps1 and Stop-HPCIaaSNode.ps1 to start and stop the IaaS VMs. For detailed usage, run Get-Help .\AzureAutoGrowShrink.ps1 –detailed in an elevated PowerShell window under $env:CCP_HOME\bin. For more information, see Grow and Shrink Azure Compute Resources in an HPC Pack Cluster.  
  * Configure management operation log archive and retention intervals  
    To avoid filling the HPC Management database with management operation logs, the previous fixed archive interval (7 days) and retention interval (180 days) are now configurable via the HPC PowerShell cmdlet Set-HpcClusterProperty with the –OperationArchive and –OperationRetention parameters. The current values can be viewed by Get-HpcClusterProperty.
  * Script support to move compute nodes, broker nodes, workstation nodes, and unmanaged server nodes to a different cluster or head node  
    HPC Pack 2012 R2 Update 1 provides the Move-HpcNode.ps1 PowerShell script to easily move cluster nodes to a different head node without reinstalling or reimaging the nodes. The scripts can run either with or without the previous head node, in case the previous head node is unavailable. For more information, see Move Cluster Nodes to a New Head Node.  
    **Note: Before moving WCF broker nodes, make sure there are no active SOA sessions on the nodes. After moving the broker nodes, the requests and responses for previous SOA sessions could be lost.**
* Job scheduling
  * Finish task operation added to finish active tasks directly to the Finished state  
    Similar to the existing job finish operation, a task finish operation is newly added to all users to finish a task. The task finish operation stops the task process immediately and marks the task as finished. HPC Pack 2012 R2 Update 1 supports this operation via the task finish command and the Stop-HpcTask HPC PowerShell cmdlet, and the HPC Job Scheduler API in the SDK.
    ```
    Command line example: task finish 1.1 /message: "Finish the task"
    HPC PowerShell example: Stop-Hpctask -JobID 5 -TaskId 1 -SubTaskId 5 -State Finished
    ```
    ```c#
    API example: 
    Scheduler s = new Scheduler();
    s.Connect("HeadNode");
    var job = s.CreateJob();
    job.Name = "EurekaTaskJob";
    var task = job.CreateTask();
    task.CommandLine = "ping localhost -n 60 && exit 1";
    job.AddTask(task);
    s.SubmitJob(job, "username", "password");
    job.FinishTask(task.TaskId, "Finish the task.")
    ```
  * Finish or cancel a running job gracefully to let running tasks complete  
    HPC Pack 2012 R2 Update 1 provides a new way to finish or cancel a running job gracefully, which lets the running tasks run until they are complete. You can do this via the job finish and job cancel commands, the Stop-HpcJob HPC PowerShell cmdlet, and the HPC Job Scheduler API in the SDK.
    ```
    Command line examples:
    job finish 2 /graceful /message: "Finish the job gracefully"
    job cancel 5 /graceful /message: "Cancel the job gracefully"
    HPC PowerShell examples:
    Stop-HpcJob -Id 2 –State finished -Graceful –Message "Finish the job gracefully"
    Stop-HpcJob -Id 2 -Graceful –Message "Cancel the job gracefully"
    ```
    ```c#
    API example:
    Scheduler s = new Scheduler();
    s.Connect("HeadNode");
    var job = s.CreateJob();
    job.Name = "EurekaTaskJob";
    var task = job.CreateTask();
    task.CommandLine = "ping localhost -n 60 && exit 1";
    job.AddTask(task);
    s.SubmitJob(job, "username", "password");

    //Finish method 1
    job.Finish(isForced: false, isGraceful: true);
    //Finish method 2
    s.FinishJob(jobId: job.Id, message: "Finish the job gracefully", isForced: false, isGraceful: true);

    //Cancel method 1
    job.Cancel(isForced: false, isGraceful: true);
    //Cancel method 2
    s.CancelJob(jobId: job.Id, message: "Cancel the job gracefully", isForced: false, isGraceful: true);
    ```
  * Job-level automatic task requeue after application execution failure  
    HPC Pack 2012 R2 Update 1 introduces an integer job property TaskExecutionFailureRetryLimit with default value 0. When set with a positive integer N, all the tasks in a job except node preparation and release tasks automatically requeue for a maximum of N times when an application execution failure happens (e.g., return code is not zero or not within the defined scope). This property is available in related job commands, HPC PowerShell cmdlets such as New-HpcJob, and the HPC Job Scheduler API. Previous versions of HPC Pack provide only cluster-wide automatic job or task requeue settings for a cluster scheduling or dispatching problem.
    ```c#
    API example:
    Scheduler s = new Scheduler();
    s.Connect("HeadNode");
    var job = s.CreateJob();
    job.Name = "TestFailRetry";
    job.TaskExecutionFailureRetryLimit = 3;
    var task = job.CreateTask();
    task.CommandLine = "ping localhost -n 5 && exit 1";
    job.AddTask(task);
    s.SubmitJob(job, "username", "password");
    ```
  * Scheduling jobs and tasks to unmanaged resources (Preview)  
    HPC Pack 2012 R2 Update 1 introduces a Preview feature that developers can leverage to write their own resource communicator for the Windows HPC scheduler to support new types of compute resources that are not supported by default in HPC Pack. Examples include Linux nodes and Azure Batch service resources. We will release code samples in the near future.
* Runtimes and development
  * Shortened SOA job rebalancing interval in Balanced scheduling mode  
    The lower limit of allocationAdjustInterval in the SOA service configuration file is changed from 15000 ms to 3000 ms. You can use a lower setting for allocationAdjustInterval along with statusUpdateInterval (e.g., 5000 ms and 3000 ms) to shorten the SOA job rebalancing interval in Balanced scheduling mode. The statusUpdateInterval limits are unchanged. The change to allocationAdjustInterval does not affect any of your existing service configuration files unless you modify them explicitly.
  * MS-MPI runtime  
    The v5 release of MS-MPI is included and installed in this release of HPC Pack. MS-MPI v5 includes the following features, improvements, and fixes:
    * Improved the affinity algorithms for mpiexec.exe (/affinity and /affinity_layout options)
    * Added support for MPI_Win_allocate_shared and MPI_Win_shared_query
    * Added support for MPI_Comm_split_type
    * Added support for MPI_Get_library_version
    * Added support for configuring the queue depths used for Network Direct connections using the MSMPI_ND_SENDQ_DEPTH and MSMPI_ND_RECVQ_DEPTH environment variables
    * Removed the dependency on the Visual Studio runtime
    * Fixed incompatibility with Visual Studio 2012 and 2013 when building mixed Fortran and C++ applications
    * Added SAL annotations to the APIs to better support static code analysis of MPI applications
    * Refactored debugging support to implement MQS debugging as defined by the MPI Forum  
    **Note: MS-MPI v5 can also be downloaded as a separate installation package, including the software development kit (SDK), from the Microsoft Download Center.**

## [HPC Pack 2012 R2 RTM (4.2.4400) - 1/14/2014](https://docs.microsoft.com/en-us/previous-versions/windows/it-pro/hpc-server-2012-R2-and-2012/dn582020(v=ws.11))

* Deployment  
  Operating system requirements are updated. HPC Pack 2012 R2 is supported to run on Windows Server® 2012 R2 and Windows® 8.1 for certain node roles, as shown in the following table. For more information, see System Requirements for Microsoft HPC Pack 2012 R2 and HPC Pack 2012.  
  ```
  Head node: Windows Server 2012 R2, Windows Server 2012  
  Compute node: Windows Server 2012 R2, Windows Server 2012, Windows Server 2008 R2  
  WCF broker node: Windows Server 2012 R2, Windows Server 2012  
  Workstation node: Windows 8.1, Windows® 8, Windows® 7  
  Unmanaged server node: Windows Server 2012 R2, Windows Server 2012, Windows Server 2008 R2  
  Windows Azure node: Windows Server 2012 R2, Windows Server 2012, Windows Server 2008 R2  
  Client (compute with only client utilities installed): Windows Server 2012 R2, Windows 8.1, Windows Server 2012, Windows 8, Windows Server 2008 R2, Windows 7, Windows Server® 2008, Windows Vista®  
  ```
* Windows Azure integration
  * Stop or remove selected Windows Azure nodes.  
    HPC Pack 2012 R2 allows you to stop or remove selected nodes from Windows Azure, giving you finer control over the size and cost of your Windows Azure node deployments. You can use HPC Cluster Manager or the new Stop-HpcAzureNode and Remove-HpcAzureNode Windows HPC PowerShell cmdlets. With this feature you can now scale down the number of deployed nodes to match the workloads in the job queue. You can also remove selected Windows Azure nodes in a deployment (or across deployments) that are idle for long periods, or in an error state. In previous versions of HPC Pack, you can only stop or remove an entire set of nodes deployed with a particular node template.
  * Additional compute instance sizes are supported in Windows Azure node deployments.  
    HPC Pack 2012 R2 introduces support for the A5 compute instance (virtual machine) size in Windows Azure node deployments.
    To run parallel MPI applications in Windows Azure, HPC Pack 2012 R2 will also support the A8 and A9 compute instances that will be released to general availability in selected geographic regions in early 2014. These compute instances provide high performance CPU and memory configurations and connect to a low-latency and high-throughput network in Windows Azure that uses remote direct memory access (RDMA) technology. For more information about running MPI jobs on the A8 and A9 instances in your Windows Azure burst deployments, see [Doc](http://go.microsoft.com/fwlink/?LinkID=389594).
    For details about the supported instance sizes, see Virtual Machine and Cloud Service Sizes for Windows Azure and Azure Feature Compatibility with Microsoft HPC Pack.
* Job scheduling
  * The performance of graceful preemption in Balanced scheduling mode is improved for HPC SOA jobs.  
    HPC Pack 2012 R2 has improved the “waiting-for-task-finishing” mechanism in Balanced job scheduling, which previously was not optimized for HPC service-oriented architecture (SOA) jobs. This change improves the performance of graceful preemption of tasks in Balanced job scheduling mode for HPC SOA jobs.
* Runtimes and development
  * MS-MPI adds mechanisms to start processes dynamically.  
    MS-MPI now supports a “connect-accept” scenario in which independent MPI processes establish communication channels without sharing a communicator. This functionality may be useful in MPI applications consisting of a master scheduler launching independent MPI worker processes, or a client-server model in which the server and clients are launched independently.
    Additionally, MS-MPI introduces interfaces that allow job schedulers other than the one in HPC Pack to start MS-MPI processes.
  * MS-MPI can be updated independently of HPC Pack.  
    Starting in HPC Pack 2012 R2, HPC Pack will allow future updates to Microsoft MPI (MS-MPI) without requiring you to update the HPC Pack services. This change will allow Windows HPC cluster administrators to update MS-MPI functionality simply by installing an updated MS-MPI redistributable package on the cluster.
    As in previous versions, MS-MPI is automatically installed when HPC Pack 2012 R2 is installed on the cluster nodes, and it is updated when you upgrade your existing HPC Pack 2012 with SP1 cluster to HPC Pack 2012 R2. However, HPC Pack 2012 R2 now installs MS-MPI files in different locations than in previous versions, as follows:
    * MS-MPI executable files are installed by default in the %PROGRAMFILES%\Microsoft MPI\Bin folder, not in the %CCP_HOME%\Bin folder. The new environment variable MSMPI_BIN is set to the new installation location.
    * MS-MPI setup files for cluster node deployment are organized separately from setup files for other HPC Pack components in the remote installation (REMINST) share on the head node.
    The new locations may affect existing compute node templates or existing MPI applications. For more information, see Release Notes for Microsoft HPC Pack 2012 R2.


