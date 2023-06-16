<#

.SYNOPSIS
Export Windows HPC Cluster Configuration Settings.

.DESCRIPTION
This script allows a user to export Windows HPC cluster configuration settings.

.PARAMETER Path
The export destination path.

.PARAMETER Configuration
The name of the configuration settings to export. Valid values: "Diagnostics","Management","Reporting","Scheduler","Soa" or none for all configurations.

.PARAMETER DontAppendTimeStampFolder
The flag to turn off creating a sub folder in the given path.

.EXAMPLE
Export-HpcConfiguration.ps1

.EXAMPLE
Export-HpcConfiguration.ps1 -Path:c:\export -Configuration:Scheduler

.EXAMPLE
Export-HpcConfiguration.ps1 -Path:c:\export -DontAppendTimeStampFolder

.EXAMPLE
Export-HpcConfiguration.ps1 -Path:c:\export -Configuration:Scheduler,Soa

.NOTES

.LINK

#>
Param(
    [switch] $DontAppendTimeStampFolder,

    # The export destination path.
    [ValidateNotNullOrEmpty()]
    [string] $Path, 

    # The names of the configuration settings to export. Valid values: "Diagnostics","Management","Reporting","Scheduler","Soa" or none for all configurations.
    [ValidateSet("Diagnostics","Management","Reporting","Scheduler","Soa")]
    [string[]] $Configuration
)

	function PreExportItem( [string] $Name, [string] $Target, [bool] $IsFolder) {
		WriteOutput ("Exporting $Name to $Target.");
		$Global:OldErrorCount = $Global:Error.Count;
		$Global:WarningForCmdlet = $null;
		$Global:Xml += '<ExportedConfiguration Name="' + $Name + '" Target="' + $Target + '" />';
		if ( !$IsFolder ) { $Target = [System.IO.Path]::GetDirectoryName($Target); }
		if( !(Test-Path $Target) ) { New-Item -Path $Target -ItemType directory | out-null; }
	}
	
	function PostExportItem {
		if( $Global:Error.Count -gt $Global:OldErrorCount ) { $Global:FailureCount++; } else { $Global:SuccessCount++; }
		$Global:WarningForCmdlet | ? { $_ -ne $null } | % {
			$Global:Warning += "WARNING: " + $_.Message + [environment]::NewLine + [environment]::NewLine;
			$Global:Verbose += "WARNING: " + $_.Message + [environment]::NewLine + [environment]::NewLine;
		}
	}
	
	function WriteWarning( [string] $warning) {
		Write-Warning $warning;
		$Global:Warning += "WARNING: $warning" + [environment]::NewLine + [environment]::NewLine;
		$Global:Verbose += "WARNING: $warning" + [environment]::NewLine + [environment]::NewLine;
	}
	
	function WriteOutput( [string] $output) {
		Write-Output $output;
		$Global:Verbose += $output + [environment]::NewLine + [environment]::NewLine;
	}

	$error.Clear();

	$errorMsgNonElevatedProcess = "This function needs to be run with elevated PowerShell.";
	$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent() );
	if(!$currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator )) { Write-Error $errorMsgNonElevatedProcess; return; }

	$errorMsgCannotOnlyRunOnHeadNode = "This function needs to be run on head node.";
	if( !(Test-Path HKLM:\Software\Microsoft\HPC) -or (Get-ItemProperty -Path:HKLM:\Software\Microsoft\HPC).InstalledRole -inotcontains "HN") { Write-Error $errorMsgCannotOnlyRunOnHeadNode; return; }

	if( !(Get-PsSnapIn Microsoft.HPC -EA:0) ) { Add-PsSnapIn Microsoft.HPC; }
	$error.Clear();

	if ([string]::IsNullOrEmpty($path)) {
		if ($DontAppendTimeStampFolder) {
			# The script will surely fail
			$errorMsgNeedPathParam = "-DontAppendTimeStampFolder switch is specified, while -Path parameter is missing. Please include the path information in the parameter list. The folder indicated by the path will be created by this script.";
			Write-Error $errorMsgNeedPathParam;
			return;
		}
        
		# Assign path as current folder.
		$Path = ".";
	}
       
	if (!$DontAppendTimeStampFolder) {
		$Path = [System.IO.Path]::Combine($Path, [System.DateTime]::Now.ToString("yyyyMMdd_HHmmss"));
	}
       
	$errorMsgCannotCreateTargetFolder = "Cannot create exporting target folder ""$Path"". The directory already exists or the given path is invalid.";
    
	# We only work with path which does not exist. This prevents data over-writing handling
	if ([System.IO.Directory]::Exists($Path)){
		Write-Error $errorMsgCannotCreateTargetFolder;
		return;
	}
    
	[System.IO.Directory]::CreateDirectory($path) | out-null;
    
	# We need to ensure the created path is a disk IO object and the CreateDirectory function completes successfully
	# CreateDirectory won't create folder in registry
	# CreateDirectory may fail for invalid path or bad permission.    
	if( (Get-ItemProperty $Path) -eq $null -or (Get-ItemProperty $Path).GetType().Name -ne "DirectoryInfo") {
		Write-Error $errorMsgCannotCreateTargetFolder;
		return;
	}

	$Path = [System.IO.Path]::GetFullPath($Path);

	WriteOutput("Setting exporting target folder to ""$Path"".");

	if($Configuration -eq $null) { $Configuration = "Diagnostics","Management","Reporting","Scheduler","Soa"; }
	$version = (Get-HpcClusterOverview).Version;

	if( $error ) { return; }

	$Global:SuccessCount = $Global:FailureCount = 0;
	$Global:Warning = $Global:Verbose = "";
	$Global:Xml = '<?xml version="1.0" encoding="utf-8"?><!-- Note:Changing ExportedConfiguration element in this file will not impact the behavior of Import-HpcConfiguration later. --><ExportedConfigurations HpcVersion="' + $version + '" ClusterName="' + $Env:CCP_SCHEDULER + '" Time="' + [System.DateTime]::Now.ToString() + '" CmdLine="' + $MyInvocation.Line + '" Operator="' + $Env:USERDOMAIN + '\' + $Env:USERNAME + '">';

	$redirectToExportFolderCfg = "ActivationFilterProgram", "SubmissionFilterProgram";
	$bypassCfg = "ActivationFilterProgram","AdFailurePercentageEntry","BackfillLoadPeriod","DisableCredentialReuse","EmailCredential","EventListenerClosePercentage","InstallCredential","RestoreMode","SchedulerOnAzure","SchedulerWebServicePort","SchedulerWebServiceEnabled","SchedulerWebServiceThumbprint","SchedulerWebServiceAuth","SpoolDir","SqlReadFailurePercentageEntry","SqlTransactionFailurePercentage","SubmissionFilterProgram","ReportingDbSize";
	$bypassSchdEnvVar = "CCP_CLUSTER_NAME","CCP_MPI_NETMASK","CCP_SERVICEREGISTRATION_PATH","WCF_NETWORKPREFIX";
	$diagCfgNames = "TtlCompletedRuns","RunCleanUpHour","ConcurrencyTestRunNumber";
	$mgmtCfgNames = "AzureCollectionInterval","CollectCounters","MinuteCounterRetention","NodeNamingSeries","WDSMode","InstallCredential","AzureStorageConnectionString", "AzureLogsToBlob", "AzureLogsToBlobThrottling", "AzureLogsToBlobInterval", "AzureMetricsCollectionEnabled","AzureMetricsJobStatisticsDelayMinutes","AzureIaaSMetricsCollectionEnabled","OperationArchive","OperationRetention";
	$rptCfgNames = "DataExtensibilityEnabled","DataExtensibilityTtl","AllocationHistoryTtl","ReportingDbSize";

	if($Configuration -icontains "Management") {
		PreExportItem -Name:"Cluster registry" -Target:"$Path\ClusterRegistry.xml" -IsFolder:$false;
		Get-HpcClusterRegistry | Export-CliXml -Path "$Path\ClusterRegistry.xml";
		PostExportItem;
	}

	if($Configuration -icontains "Diagnostics") {
		PreExportItem -Name:"diagnostics configurations" -Target:"$Path\Diagnostics" -IsFolder:$true;
		Get-HpcClusterProperty -Parameter -WA:SilentlyContinue | ? {$diagCfgNames -icontains $_.Name -and $bypassCfg -inotcontains $_.Name} | Export-CliXml -Path "$Path\Diagnostics\DiagnosticsCfg.xml";
		PostExportItem;
	}
	
	if($Configuration -icontains "Management") {
        $installShare = (Get-HpcClusterRegistry -PropertyName InstallShare).Value
		PreExportItem -Name:"drivers" -Target:"$Path\Management\HpcDriver" -IsFolder:$true;
		if( Test-Path "$installShare\Drivers" ) { Copy-Item "$installShare\Drivers\*" "$Path\Management\HpcDriver" -Recurse | out-null; }
		PostExportItem;

		PreExportItem -Name:"images" -Target:"$Path\Management\HpcImage" -IsFolder:$true;
		if ( Test-Path "$installShare\Images") { Copy-Item "$installShare\Images\*" "$Path\Management\HpcImage" -Recurse | out-null; }
		PostExportItem;

		PreExportItem -Name:"users" -Target:"$Path\Management\HpcUser.xml" -IsFolder:$false;
		Get-HpcMember -WV:+Global:WarningForCmdlet | ? { !($_.Name.EndsWith("$")) } | Export-Clixml -Path "$Path\Management\HpcUser.xml";
		WriteWarning "Machine accounts are not exported as HPC users for security reason.";
		PostExportItem;

		PreExportItem -Name:"node groups" -Target:"$Path\Management\HpcNodeGroup.xml" -IsFolder:$false;
		Get-HpcGroup -WV:+Global:WarningForCmdlet | Export-Clixml -Path "$Path\Management\HpcNodeGroup.xml";
		PostExportItem;

		PreExportItem -Name:"node templates" -Target:"$Path\Management\HpcNodeTemplate" -IsFolder:$true;
		Get-HpcNodeTemplate -WV:+Global:WarningForCmdlet | % { if( $_.Name -ne "HeadNode Template" –and $_.Name –ne "LinuxNode Template" –and $_.Name –ne "NonDomain ComputeNode Template" -and $_.Name -ne "Default ComputeNode Template") { Export-HpcNodeTemplate -Template $_ -Path "$Path\Management\HpcNodeTemplate\$($_.Name).xml" -WV:+Global:WarningForCmdlet; } };
		PostExportItem;

		PreExportItem -Name:"management configurations" -Target:"$Path\Management\ManagementCfg.xml" -IsFolder:$false;
		Get-HpcClusterProperty -WV:+Global:WarningForCmdlet | ? {$mgmtCfgNames -icontains $_.Name -and $bypassCfg -inotcontains $_.Name} | Export-CliXml -Path "$Path\Management\ManagementCfg.xml";
		PostExportItem;

		PreExportItem -Name:"hpc metrics" -Target:"$Path\Management\Metrics.xml" -IsFolder:$false;
		Export-HpcMetric -Path "$Path\Management\Metrics.xml";
		PostExportItem;

		PreExportItem -Name:"hpc nodes" -Target:"$Path\Management\HpcNode.xml" -IsFolder:$false;
		Export-HpcNodeXml -Path "$Path\Management\HpcNode.xml";
		PostExportItem;
	}

	if($Configuration -icontains "Reporting") {
		PreExportItem -Name:"reporting configurations" -Target:"$Path\Reporting" -IsFolder:$true;
		Get-HpcClusterProperty -Parameter -WA:SilentlyContinue | ? {$rptCfgNames -icontains $_.Name -and $bypassCfg -inotcontains $_.Name} | Export-CliXml -Path "$Path\Reporting\ReportingCfg.xml";
		PostExportItem;
	}

	if($Configuration -icontains "Scheduler") {
		PreExportItem -Name:"job templates" -Target:"$Path\Scheduler\HpcJobTemplate" -IsFolder:$true;
		Get-HpcJobTemplate -WV:+Global:WarningForCmdlet | % { Export-HpcJobTemplate -Template $_ -Path "$Path\Scheduler\HpcJobTemplate\$($_.Name).xml" -WV:+Global:WarningForCmdlet; }
		PostExportItem;

		PreExportItem -Name:"job template ACL" -Target:"$Path\Scheduler\HpcJobTemplate\HpcJobTemplateAcl.xml" -IsFolder:$false;
		Get-HpcJobTemplate | Get-HpcJobTemplateAcl -WV:+Global:WarningForCmdlet | Export-CliXml -Path "$Path\Scheduler\HpcJobTemplate\HpcJobTemplateAcl.xml";
		PostExportItem;
		
		PreExportItem -Name:"scheduler environment variables" -Target:"$Path\Scheduler\SchedulerEnvVar.xml" -IsFolder:$false;
		($envVars = Get-HpcClusterProperty -Environment) | ? { $bypassSchdEnvVar -inotcontains $_.Name } | Export-Clixml -Path "$Path\Scheduler\SchedulerEnvVar.xml";
		WriteWarning "Environment variables CCP_CLUSTER_NAME, CCP_MPI_NETMASK, CCP_SERVICEREGISTRATION_PATH and WCF_NETWORKPREFIX are not exported because it's very likely they don't work with another cluster when being imported later.";
		PostExportItem;

		PreExportItem -Name:"scheduler configurations" -Target:"$Path\Scheduler\SchedulerCfg.xml" -IsFolder:$false;
		$schdCfg = Get-HpcClusterProperty -WV:+Global:WarningForCmdlet | ? { ($envVars|%{$_.Name}) -inotcontains $_.Name -and $diagCfgNames -inotcontains $_.Name -and $mgmtCfgNames -inotcontains $_.Name -and $rptCfgNames -inotcontains $_.Name -and $bypassCfg -inotcontains $_.Name};
		$schdCfg | Export-Clixml -Path "$Path\Scheduler\SchedulerCfg.xml";
		if($Configuration -icontains "Management") { $Global:WarningForCmdlet = $null; }
		PostExportItem;

		$schdCfg | % {
			if( $redirectToExportFolderCfg -icontains $_.Name -and !([string]::IsNullOrEmpty($_.Value)) ) {
				$fileName = [System.IO.Path]::GetFileName($_.Value);
				PreExportItem -Name:$_.Name -Target:"$Path\Scheduler\$($_.Name)\$fileName" -IsFolder:$false;
				if (!(Test-Path "$Path\Scheduler\$($_.Name)")) { New-Item -Path "$Path\Scheduler\$($_.Name)" -ItemType directory | out-null; }
				Copy-Item $_.Value "$Path\Scheduler\$($_.Name)\$fileName";
				PostExportItem;
				WriteWarning "Only one assembly file is exported for $($_.Name) If it has dependencies on other assemblies, you need to export them manually.";
			}
		}
	}

	if($Configuration -icontains "SOA") {
		PreExportItem -Name:"SOA service registration files" -Target:"$Path\SOA\Registration" -IsFolder:$true;
		$svcRegFileSource = (Get-HpcClusterRegistry -PropertyName ServiceRegistrationShare).Value
		if( $svcRegFileSource.IndexOf(';') -ne -1) {
			WriteWarning "When the ServiceRegistrationShare cluster property value contains multiple paths seperated by ';', only the first path is exported.";
			$svcRegFileSource = $svcRegFileSource.SubString(0, $svcRegFileSource.IndexOf(';'));
		}

		Copy-Item "$svcRegFileSource\*" "$Path\SOA\Registration" -Recurse;
		WriteWarning "For SOA services, only registration files are exported. You need to export service assemblies manually.";
		PostExportItem;
	}
	
	WriteWarning ("Some configurations are not exported due to either security reason or it's not supported to import them later: "+ [string]::join(", ", $bypassCfg) + ".");
	WriteWarning "Some exported configurations may refer to the cluster name or UNC path. You need to review and change appropriately before importing them to another cluster later.";
	$Global:Xml += '</ExportedConfigurations>';
	$Global:Xml | Out-File "$Path\MetaData.xml" -Encoding:utf8;
	WriteOutput "Exporting is completed. $Global:SuccessCount configurations are exported successfully. $Global:FailureCount configurations fail to be exported.";
	if ( $error ) { $error >> "$Path\ExportError.log"; }
	if ( $Global:Warning ) { $Global:Warning > "$Path\ExportWarning.log"; }
	$Global:Verbose > "$Path\ExportVerbose.log";
