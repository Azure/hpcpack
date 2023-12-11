param(
    [int]$interval = 1
)

$ErrorActionPreference = 'Stop'

while ($true) {
    Get-Date -Format "yyyy-MM-dd HH:mm:ss K" | out-string
    Get-SmbConnection | out-string
    Get-SmbSession | out-string
    sleep $interval
}
