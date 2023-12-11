# Diagnose SMB file issue

## Introduction

This document describes how to diagnose an issue of reading files in a SMB shared directory.

## Cause

When offloading Excel in a HPC Pack cluster, the Excel file is usually placed in a SMB shared directory that can be read by HPC Pack compute nodes. Sometimes, HPC Pack failed opening the shared Excel file because no SMB session could be established, while there were a lot of remaining SMB sessions after previous HPC Pack job runs. This may be an issue of the SMB file server. And you may diagnose this by following this document.

## Resolution

Login an HPC Pack head node as an HPC Pack admin, and copy the PowerShell scripts `Check-SMB.ps1` and `Test-FileRead.ps1` to the head node.

Open a PowerShell windows as admin. Then enter the directory where `Check-SMB.ps1` is and execute

```ps1
.\Check-SMB.ps1
```

The script periodically check and output the living SMB connections and sessions, so that you can observe their changes. To stop it, press `Ctrl + C`. Now keep it running.

Open another PowerShell windows as admin. Then enter the directory where `Test-FileRead.ps1` is and execute

```ps1
$cred = Get-Credential
```

The script pops up a window for a user name and password. Enter your HPC Pack admin user name (prefixing it with the domain name, like "hpc\hpcadmin") and password.

```ps1
$nodes = $(Get-HpcNode |?{ $_.noderole -eq 'ComputeNode' -and $_.nodestate -eq 'Online' -and $_.NodeHealth -eq 'OK'} | %{$_.NetBiosName})
```

The script collects the names of all available compute nodes into an array. You may also populate the array manully, like

```ps1
$nodes = @("computer 1", "computer 2", "computer 3")
```

Then

```ps1
.\Test-FileRead.ps1 -Credential $cred -Computers $nodes -FilePath "full path to a file in a SMB share" -NumOfParallel 50
```

The script opens and reads the file given by the parameter `-FilePath` (like "\\\\hpcpack2019\CcpSpoolDir\data.xlsm") on all the computers given by the parameter `-Computers` at the same time. And for each computer, it starts a number of processes given by the parameter `-NumOfParallel`. Each process opens and reads the file at the same time.

This script tries to simulate HPC Pack's behavior of reading a SMB-shared file from multiple computer nodes when doing Excel offloading, but without using any function from HPC Pack.

You may find that when the `Test-FileRead.ps1` ends, there're still remaining SMB sessions. That's OK and they will be cleared in a short idle time, usually no more than one minute. If you find that the sessions remain there for a long time or never get cleared, then please check your SMB configuration/server, or consult an SMB export for help.


## Status

## More Information