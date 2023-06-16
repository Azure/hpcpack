<#

.SYNOPSIS
Import Windows HPC Cluster Configuration Settings.

.DESCRIPTION
This script allows a user to import Windows HPC cluster configuration settings.

.PARAMETER Path
The import source path.

.PARAMETER Configuration
The name of the configuration settings to import. Valid values: "Diagnostics","Management","Reporting","Scheduler","Soa" or none for all configurations.

.PARAMETER Force
Import the specified configuration settings without prompting for confirmation.

.EXAMPLE
Import-HpcConfiguration.ps1

.EXAMPLE
Import-HpcConfiguration.ps1 -Path:c:\export\20110520_132914 -Configuration:Scheduler

.EXAMPLE
Import-HpcConfiguration.ps1 -Path:c:\export\20110520_132914 -Configuration:Scheduler,Soa

.NOTES

.LINK

#>

Param(
    [ValidateNotNullOrEmpty()]
    [string] $Path,

    [ValidateSet("Diagnostics","Management","Reporting","Scheduler","Soa")]
    [string[]] $Configuration, 

    [switch] $Force
)

	function PreImportItem ([string] $Name, [string] $Target) {
		$Global:OldErrorCount = $Global:Error.Count;
		$Global:WarningForCmdlet = $null;
		WriteOutput ("Importing $Name from $Target.");
	}
	
	function PostImportItem {
		if( $Global:Error.Count -gt $Global:OldErrorCount ) { $Global:FailureCount++; } else { $Global:SuccessCount++; }
		$Global:WarningForCmdlet | ? { $_ -ne $null } | % {
			$Global:Warning += "WARNING: " + $_.Message + [environment]::NewLine + [environment]::NewLine;
			$Global:Verbose += "WARNING: " + $_.Message + [environment]::NewLine + [environment]::NewLine;
		}
	}

	function ImportClusterProperty ([string] $Name, [string] $Value) {
		if( $bypassCfg -icontains $Name -or ($bypassCfgIfEmpty -icontains $Name -and [string]::IsNullOrEmpty($Value)) ) { return; }
		if( ($Value -eq 'True') -or ($Value -eq 'False')) { "Set-HpcClusterProperty -$($Name):$"+ $Value | iex; } else { "Set-HpcClusterProperty -$($Name):'$($Value)' -WV:+Global:WarningForCmdlet" |iex; }
	}

	function ImportClusterRegistry ([string] $Name, [string] $Value) {
		if( $bypassRegistry -icontains $Name -or [string]::IsNullOrEmpty($Value) ) { return; }
		"Set-HpcClusterRegistry -PropertyName $Name -PropertyValue '$Value' -WV:+Global:WarningForCmdlet" | iex;
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

	$Path = [System.IO.Path]::GetFullPath($Path);

	WriteOutput("Setting importing source folder to $Path.");
	$errorMsgCannotFindSourceFolder = "Cannot find importing source folder $Path.";
	if( !(Test-Path $Path)) { Write-Error $errorMsgCannotFindSourceFolder; return; }

	if($Configuration -eq $null) { $Configuration = "Diagnostics","Management","Reporting","Scheduler","Soa"; }

	[xml]$metadata = get-content $Path\MetaData.xml;
	$exportedVersion = $metadata.ExportedConfigurations.HpcVersion;
	$importedVersion = (Get-HpcClusterOverview).Version;

	if($error) { return; }
	if($exportedVersion -ne $importedVersion) {
		WriteWarning "The configurations was exported from cluster with version $exportedVersion. They may be not fully compatible with the importing cluster with version $importedVersion.";
	}

	$Global:SuccessCount = $Global:FailureCount = 0;
	$Global:Warning = $Global:Verbose = "";
	$redirectToExportFolderCfg = "ActivationFilterProgram", "SubmissionFilterProgram";
	$bypassCfg = "ActivationFilterProgram","AdFailurePercentageEntry","EmailCredential","EventListenerClosePercentage","InstallCredential","SchedulerOnAzure","SpoolDir","SqlReadFailurePercentageEntry","SqlTransactionFailurePercentage","SubmissionFilterProgram","ReportingDbSize","ClusterId", "AzureBurstFailurePercentageEntry", "ScanAzureBatchTaskWithoutFilterInterval", "PriorityBiasLevel", "CustomNodeSorterPath","CustomNodeSorterTimeout";
	$bypassCfgIfEmpty = "NodeNamingSeries","JobCleanUpDayOfWeek","";
	$bypassSchdEnvVar = "CCP_CLUSTER_NAME","CCP_MPI_NETMASK","CCP_SERVICEREGISTRATION_PATH","WCF_NETWORKPREFIX";
    $bypassRegistry = "ClusterName","ClusterId","SQM","RuntimeDataShare","InstallShare","SpoolDirShare","DiagnosticsShare","ServiceRegistrationShare","NetworkTopology","ReportingDbConnectionString","DiagnosticsDbConnectionString","MonitoringDbConnectionString","SchedulerDbConnectionString","ManagementDbConnectionString","ManagementDbServerName","SchedulerDbServerName","ReportingDbServerName","DiagnosticsDbServerName","MonitoringDbServerName","SSLThumbprint","VNet","Subnet","Location","ResourceGroup";

	if($Configuration -icontains "Diagnostics") {
		PreImportItem -Name:"diagnostics configurations" -Target:"$Path\Diagnostics\DiagnosticsCfg.xml";
		Import-Clixml -Path "$Path\Diagnostics\DiagnosticsCfg.xml" | %{ ImportClusterProperty -Name:"$($_.Name)" -Value:"$($_.Value)"; }
		PostImportItem;
	}

	if($Configuration -icontains "Management") {
		PreImportItem -Name:"drivers" -Target:"$Path\Management\HpcDriver";
		dir "$Path\Management\HpcDriver" -Recurse | ? { $_.Name.EndsWith(".inf") } | % { Add-HpcDriver -Path:"$($_.FullName)" -WV:+Global:WarningForCmdlet } | out-null;
		PostImportItem;

		PreImportItem -Name:"images" -Target:"$Path\Management\HpcImage";
		dir "$Path\Management\HpcImage\*.wim" | % { Add-HpcImage -Path:"$($_.FullName)" -WV:+Global:WarningForCmdlet } | out-null;
		PostImportItem;

		PreImportItem -Name:"users" -Target:"$Path\Management\HpcUser.xml";
		Import-Clixml -Path "$Path\Management\HpcUser.xml" | ? { !($_.Name.EndsWith("$")) } | %{ Add-HpcMember -Name:"$($_.Name)" -Role:"$($_.Role.Value)" -WV:+Global:WarningForCmdlet } | out-null;
		WriteWarning "Machine accounts are not imported as HPC users for security reason. You can add them manually if needed.";
		PostImportItem;

		PreImportItem -Name:"node groups" -Target:"$Path\Management\HpcNodeGroup.xml";
		#Fix for 21688; We modify $Global:OldErrorCount to ignore the error introduced by Get-HpcGroup. The error from this cmdlet, standing for node group not exists, is expected and should not be considered in the overall failure count.
		Import-Clixml -Path "$Path\Management\HpcNodeGroup.xml" | %{$errorBefore = $Global:Error.Count; if( !(Get-HpcGroup -Name:"$($_.Name)" -EA:0) ) { $Global:OldErrorCount += ($Global:Error.Count - $errorBefore); New-HpcGroup -Name:"$($_.Name)" -Description:"$($_.Description)" -WV:+Global:WarningForCmdlet | out-null } }
		PostImportItem;

		PreImportItem -Name:"node templates" -Target:"$Path\Management\HpcNodeTemplate";
		dir "$Path\Management\HpcNodeTemplate\*.xml" | %{ Import-HpcNodeTemplate -Path:$_.FullName -Upgrade -Force:$(if($Force){$true}else{$false}) -WV:+Global:WarningForCmdlet | out-null; }
		PostImportItem;

		PreImportItem -Name:"management configurations" -Target:"$Path\Management\ManagementCfg.xml";
		Import-Clixml -Path "$Path\Management\ManagementCfg.xml" | % { ImportClusterProperty -Name:"$($_.Name)" -Value:"$($_.Value)"; }
		PostImportItem;

		PreImportItem -Name:"hpc metrics" -Target:"$Path\Management\Metrics.xml";
		Import-HpcMetric -Path "$Path\Management\Metrics.xml";
		PostImportItem;

		PreImportItem -Name:"hpc nodes" -Target:"$Path\Management\HpcNode.xml";
		Import-HpcNodeXml -Path "$Path\Management\HpcNode.xml";
		PostImportItem;
	}

	if($Configuration -icontains "Reporting") {
		PreImportItem -Name:"reporting configurations" -Target:"$Path\Reporting\ReportingCfg.xml";
		Import-Clixml -Path "$Path\Reporting\ReportingCfg.xml" | %{ ImportClusterProperty -Name:"$($_.Name)" -Value:"$($_.Value)"; }
		PostImportItem;
	}

	if($Configuration -icontains "Scheduler") {
		PreImportItem -Name:"job templates" -Target:"$Path\Scheduler\HpcJobTemplate";
		dir "$Path\Scheduler\HpcJobTemplate\*.xml" | ?{$_.Name -ine "HpcJobTemplateAcl.xml"} | %{ Import-HpcJobTemplate -Name:$_.Name.SubString(0, $_.Name.Length-4) -Path:$_.FullName -Force:$(if($Force){$true}else{$false}) -WV:+Global:WarningForCmdlet | out-null; }
		PostImportItem;

		PreImportItem -Name:"job template ACL" -Target:"$Path\Scheduler\HpcJobTemplate\HpcJobTemplateAcl.xml";
		Import-Clixml -Path "$Path\Scheduler\HpcJobTemplate\HpcJobTemplateAcl.xml" | %{
			$sddl = New-Object System.Security.AccessControl.CommonSecurityDescriptor $false, $false, $_.Sddl;
			Set-HpcJobTemplateAcl -Name:$_.JobTemplateName -Acl:(New-Object Microsoft.ComputeCluster.CCPPSH.HpcJobTemplateSecurityDescriptor $_.JobTemplateName,$sddl,$env:CCP_SCHEDULER ) -WV:+Global:WarningForCmdlet;
		}
		PostImportItem;

		PreImportItem -Name:"scheduler environment variables" -Target:"$Path\Scheduler\SchedulerEnvVar.xml";
		Import-Clixml -Path "$Path\Scheduler\SchedulerEnvVar.xml" | ?{ $bypassSchdEnvVar -inotcontains $_.Name } | % { Set-HpcClusterProperty -Environment:"$($_.Name)=$($_.Value)" -WV:+Global:WarningForCmdlet }
		WriteWarning "Environment variables CCP_CLUSTER_NAME, CCP_MPI_NETMASK, CCP_SERVICEREGISTRATION_PATH and WCF_NETWORKPREFIX are not imported. You may need to review and configure manually.";
		PostImportItem;

		PreImportItem -Name:"scheduler configurations" -Target:"$Path\Scheduler\SchedulerCfg.xml";
		Import-Clixml -Path "$Path\Scheduler\SchedulerCfg.xml" | % {
			ImportClusterProperty -Name:"$($_.Name)" -Value:"$($_.Value)";
			if( $redirectToExportFolderCfg -icontains $_.Name -and !([string]::IsNullOrEmpty($_.Value)) ) {
				$fileName = [System.IO.Path]::GetFileName($_.Value);
				if( Test-Path "$Path\Scheduler\$($_.Name)\$fileName" ) {
					"Set-HpcClusterProperty -$($_.Name):'$Path\Scheduler\$($_.Name)\$fileName' -WV:+Global:WarningForCmdlet" | iex;
					WriteWarning "Only one assembly file is imported for $($_.Name) If it has dependencies on other assemblies, you need to copy them manually.";
				}
			}
		}
		PostImportItem;
	}

	if($Configuration -icontains "SOA") {
		PreImportItem -Name:"SOA service registration files" -Target:"$Path\SOA\Registration";
        $svcRegFileSource = (Get-HpcClusterRegistry -PropertyName ServiceRegistrationShare).Value
		if( $svcRegFileSource.IndexOf(';') -ne -1) {
			WriteWarning "When the ServiceRegistrationShare cluster property value contains multiple paths seperated by ';', only the first path is imported.";
			$svcRegFileSource = $svcRegFileSource.SubString(0, $svcRegFileSource.IndexOf(';'));
		}
		Copy-Item "$Path\SOA\Registration\*" "$svcRegFileSource" -Recurse -Force:$(if($Force){$true}else{$false});
		WriteWarning "For SOA services, only registration files are imported. You need to import service assemblies manually.";
		PostImportItem;
	}
    
	if(Test-Path "$Path\ClusterRegistry.xml") {
		PreImportItem -Name:"Cluster registry" -Target:"$Path\ClusterRegistry.xml";
		Import-Clixml -Path "$Path\ClusterRegistry.xml" | ?{$bypassRegistry -inotcontains $_.Name} | %{ImportClusterRegistry -Name $_.Name -Value $_.Value}
		PostImportItem
	}
	
	WriteWarning ("Some configurations are not imported due to either security reason or it's not supported to import them: "+ [string]::join(", ", $bypassCfg) + ".");
	WriteWarning "Some imported configurations may refer to the original cluster name or UNC path. You need to review and change appropriately.";
	WriteWarning "This script didn't import any credentials, including: installation credentials, email credentials, diagnostics credentials, SOA session credentials, credentials configured in node template and Windows Azure storage keys."
	WriteWarning "Please provide these credentials after importing, if any of these credentials are in use."
	WriteOutput "Importing is completed. $Global:SuccessCount configurations are imported successfully. $Global:FailureCount configurations fail to be imported.";
	$now = [System.DateTime]::Now.ToString('yyyyMMdd_HHmmss');
	if ( $error ) { $error > "$Path\ImportError_$now.log"; }
	if ( $Global:Warning ) { $Global:Warning > "$Path\ImportWarning_$now.log"; }
	$Global:Verbose > "$Path\ImportVerbose_$now.log";
