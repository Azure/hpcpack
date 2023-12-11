param(
    [Parameter(Mandatory=$true)]
    [Alias("f")]
    [string]$FilePath,

    [Alias("d")]
    [int]$Delay = 30,

    [Alias("n")]
    [int]$NumOfParallel = 20,

    [string[]]$Computers,

    $Credential
)

$ErrorActionPreference = 'Stop'

$openFile = {
    param(
        [Parameter(Mandatory=$true)]
        [string]$FilePath,

        [Parameter(Mandatory=$true)]
        [int]$Delay,

        [Parameter(Mandatory=$true)]
        [int]$NumOfParallel
    )

    # $ErrorActionPreference = 'Stop'

    "[$env:COMPUTERNAME] Opening $FilePath ..." | out-string

    $jobs = @()
    for ($i = 1; $i -le $NumOfParallel; $i++) {
        $j = Start-Job -ScriptBlock {
            param(
                [Parameter(Mandatory=$true)]
                [string]$FilePath,

                [int]$Delay,

                [int]$Index
            )

            "[$env:COMPUTERNAME][$Index] Opening $FilePath in process $PID..." | out-string
            $bytes = [System.IO.File]::ReadAllBytes($FilePath)
            "[$env:COMPUTERNAME][$Index] Read $($bytes.Count) bytes" | out-string
            sleep $Delay
        } -ArgumentList @($FilePath, $Delay, $i)
        $jobs += $j
    }

    "[$env:COMPUTERNAME] Waiting for $NumOfParallel jobs..." | out-string

    $jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job
}

if (!$Computers) {
    &$openFile $FilePath $Delay $NumOfParallel
}
else {
    # NOTE: refer to the following link for how to read a file in a SMB share.
    # https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/invoke-command#example-17-access-a-network-share-in-a-remote-session
    if (!$Credential) {
        $Credential = Get-Credential
    }
    Enable-WSManCredSSP -Role Client -DelegateComputer $Computers -Force | out-null
    Invoke-Command -ComputerName $Computers -ScriptBlock { Enable-WSManCredSSP -Role Server -Force | out-null }
    Invoke-Command -ComputerName $Computers -Authentication 'CredSSP' -Credential $Credential -ThrottleLimit $([int]::MaxValue) -ScriptBlock $openFile -ArgumentList @($FilePath, $Delay, $NumOfParallel)
}

"Done at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss K")"
