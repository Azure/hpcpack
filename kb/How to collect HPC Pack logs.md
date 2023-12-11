## Introduction
   This doc describes how to collect HPC Pack logs when there is an issue with the HPC Pack cluster.

   >Applies to: HPC Pack 2012 (v4.0-4.1), 2012 R2/Update 1/2/3 (v4.2-4.5), 2016 /Update 1/2/3 (v5.0-v5.3), 2019 (v6.0)

## Cause
   HPC Pack writes cosmos binary log files for different service components. Users may need to know where to find and collect the logs when an issue happens.

## Resolution

### 0. How to check HPC Pack version

  Open **HPC Cluster Manager** GUI -> Help -> About.

  Or, go to %CCP_HOME%Bin folder and check the file version of the HPC bits e.g. HpcSchedulerCore.dll.

### 1. Log file locations


All HPC service log files are under **%CCP_DATA%LogFiles** folder on the cluster nodes with the name pattern ***\<ServiceName>_\<Index>.bin***. The log configurations are in the service app.config file under %CCP_HOME%Bin folder.

  > [!Note]
  >
  > 1. HPC Pack logging module always pre-creates an empty log file for each running HPC service/client, so the log file with latest index number is always empty, the latest logs are stored in the log file with second latest index number. For example, if 123 is the latest index for HpcScheduler service log files, HpcScheduler_000123.bin is empty, HpcScheduler_000122.bin contains the latest service logs.
  > 2. The timestamps for all log messages are stored in UTC time.
  >


* Scheduler\HpcScheduler_*.bin -- HpcScheduler service logs

* Scheduler\HpcNodeManager_*.bin -- HpcNodeManager service logs

* Scheduler\HpcWebService_*.bin -- HpcWebService service logs

* Diagnostics\HpcDiagnostics_*.bin -- HpcDiagnostics service logs

* HpcFrontend\HpcFrontend_*.bin -- HpcFrontend service logs

* HpcNaming\HpcNaming_*.bin -- HpcNaming service logs

* Management\HpcManagement_*.bin -- HpcManagement service logs

* Management\HpcReporting_*.bin -- HpcReporting service logs

* Management\HpcSdm_*.bin -- HpcSdm service logs

* Monitoring\HpcMonitoringNode_*.bin -- HpcMonitoringClient service logs

* Monitoring\HpcMonitoringServer_*.bin -- HpcMonitoringServer service logs

* SOA\HpcBrokerWorker_*.bin -- HpcBrokerWorker process logs

* SOA\HpcBroker_*.bin -- HpcBroker service logs

* SOA\HpcSession_*.bin -- HpcSession service logs

* SOA\HpcSoaDiagMon_*.bin -- HpcSoaDiagMon service logs

  

All client logs are under at %CCP_LOGROOT_USR% on the client machine. In a default install this will resolve to C:\Users\\\<User Profile>\AppData\Local\Microsoft\Hpc\LogFiles

* ClusterManager\HpcClusterManager_*.bin -- HpcClusterManager GUI logs

* ClusterManager\ClusterRemoteConsole_*.bin

* HpcJobManager\HpcJobManager_*.bin -- HpcJobManager GUI logs

* MAPI\powershell.exe_*.bin -- Hpc PowerShell logs

* SOA\HpcServiceHost_*.bin -- SOA service host logs
  



### 2. How to open and search logs

  Use the following GUI tool

  * LogViewerUI – LogViewerUI is a graphical tool that can parse HPC Pack service logs. It is available here: https://hpconlineservice.blob.core.windows.net/logviewer/LogViewer.UI.application
  * LogViewerUI v2 - More powerful in parsing log files and filtering. It is available here:
    ClickOnce installation:
    https://hpconlineservice.blob.core.windows.net/logviewerv2/LogViewer.UI.application
    XCOPY Package:
    https://hpconlineservice.blob.core.windows.net/logviewerv2green/LogViewer_2.0.0.7.zip

  > [!Tips]
  >
  > You can use the above tool to view the content and check the timespan of a bin log file, so that you can collect the correct log files for issue troubleshooting. Note that the timestamps for all log messages are in **UTC time**. You may also use the FindStr feature to search the log files that contain a key word from all log files under a specific folder.

  * Search logs via FindStr:
    1. Locate the directory that stores the logs. For example: C:\code\logs.
    ![image info](./images/directory.png)

    2. Click `FindStr`. Fill in the `Filters`. Leave the `Skim` as default (-1). Browse the folder that stores the logs. Click `Find`, it will find the log files that contain any log that meets the filter. You can then open the logs by double-clicking the logs below. In this example, it will find log files that contain "job 231" (case insensitive).
    ![image info](./images/findstr.png)

    3. You can find more about filter in `Help`.
    ![image info](./images/help.png)



### 3. How to collect logs for Job scheduling issue

Normally we need the HpcScheduler service logs on the head node and the HpcNodeManager service logs on the compute nodes. Please indicate the job and task Ids and make sure the logs collected cover the timespan of the job and task. 



### 4. How to collect logs for Node management issue

Normally we need the HpcManagement, HpcSdm service logs on the head node and the HpcManagement service logs on the compute node. Please indicate the node name and make sure the logs collected cover the timespan of the node error.



### 5. How to collect logs for SOA jobs

Normally we need the HpcSession service logs on the head node, Hpcbroker service logs and HpcBrokerWorker process logs on the broker node, and HpcServiceHost process logs on the compute node.

  * By default, HpcBrokerWorker_\*.bin log files are not per session. To collect per session broker worker logs for each SOA session, on the broker node, set PerSessionLogging="1" for the shared listener “SoaListener” in HpcBrokerWorker.exe.config under %CCP_HOME%Bin on the broker nodes and then restart the HpcBroker service. After that, when a SOA session with id [SessionId] finishes, there would be a file named HpcBrokerWorker_[LogIdentifier]\_[SessionId] under %CCP_DATA%LogFiles\SOA folder on the broker node. All the broker log files for this SOA session are named like HpcBrokerWorker\_[LogIdentifier]_\*.bin for the same LogIdentifier, they are by default 1MB files. Note if you have multiple broker nodes, you need to do the search or enable the per session logging on each broker node.

  * To collect HpcServiceHost logs on the compute nodes, you need to enable it in the service registration file first. Check the built-in CcpEchoSvc.config file as an example,
  ```xml
    <system.diagnostics>
    <sources>
      <!--
      <source name="Microsoft.Hpc.HpcServiceHosting" switchValue="All">
        <listeners>
          <add name="Console" />
        </listeners>
      </source>
       -->
      <source name="HpcSoa" switchValue="All">
        <listeners>
          <remove name="Default" />
          <add name="SoaListener" />
        </listeners>
      </source>
    </sources>
    <sharedListeners>
      <add type="System.Diagnostics.ConsoleTraceListener, System, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
        name="Console" traceOutputOptions="DateTime">
        <filter type="" />
      </add>
      <!--
      Write hpc trace to specified log file. Log files are separated by subfolder named by job id,
      and log file is named by task instance id. Each file is 1MB, and upper limit for each task is 1000MB
      -->
      <add type="Microsoft.Hpc.Trace.HpcTraceListener, Microsoft.Hpc.Trace"
        name="SoaListener"
        initializeData="%CCP_LOGROOT_USR%SOA\HpcServiceHost\%CCP_JOBID%\%CCP_TASKINSTANCEID%\Host"
        FileSizeMB="1"
        MaxAllowedDiskUsageInMB="1000" />
    </sharedListeners>
    <trace autoflush="true" useGlobalLock="false">
      <listeners>
        <remove name="Default" />
        <add name="SoaListener" />
      </listeners>
    </trace>
    </system.diagnostics>
  ```

  * To colllect SOA client session api logs, please add the following in the client app.config file,
  ```xml
    <system.diagnostics>
    <trace autoflush="true" />
    <sharedListeners>  
    <add name="xml"
              type="System.Diagnostics.XmlWriterTraceListener"
              initializeData= "c:\TEMP\session.svclog" />
    </sharedListeners>
    <sources>
      <source name="SOA Session API" switchValue="All">
        <listeners>
          <remove name="Default" />
    <add name="xml"/>
        </listeners>
      </source>
    </sources>
    </system.diagnostics>

  ```

### 6. How to collect logs for client side issue

  Normally we may want to collect the HPC Cluster/Job Manager or HPC Powershell logs


### 7. How to collect logs for Linux nodes

   - The Linux node manager logs are under path `/opt/hpcnodemanager/logs/`, named `nodemanager(.*)`
   
   - The On-premise Linux node manager daemon log is under path `/opt/hpcnodemanager/logs/`, named `hpclinuxagent.log`
   
   - The Azure Linux node extension waagent log is under path `/var/log/azure/<name>/`, named `extension.log`

### 8. How to collect setup and patch logs

   The setup and patch logs are under path `%windir%\Temp\HPCSetuplogs` on the node.


## Status

  1/19/2020 - Init

## More Information
