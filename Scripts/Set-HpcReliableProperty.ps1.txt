<#
.Synopsis.DESCRIPTION
   This script set HPC related properties from service fabric cluster property store
.EXAMPLE
   Set-HpcReliableProperty.ps1 -PropertyName SSLThumbprint -PropertyValue C54DA9DE74AB45957EF04A72EC893199A238908B
#>
Param
(
    [Parameter(Mandatory=$false)]
    [String] $ConnectionEndpoint = "",

    [Parameter(Mandatory=$true)]
    [String] $PropertyName,

    [Parameter(Mandatory=$true)]
    $PropertyValue
)

$ccpHome = Get-ChildItem env:CCP_HOME
Add-Type -Path "$($ccpHome.Value)bin\HpcCommon.dll"

$script:ParentNames = [Microsoft.Hpc.HpcConstants]::ParentNames
$script:ReliableProperties = [Microsoft.Hpc.HpcConstants]::ReliableProperties
if($ReliableProperties.ContainsKey($PropertyName) -eq $false)
{
    throw "Property name $PropertyName is not existed for current cluster"
}
$prop = $ReliableProperties[$PropertyName]
if($prop.ReadOnly)
{
    throw "Property name $PropertyName is not allowed to modify"
}
$propValue = $PropertyValue
$type = $prop.ValueType
if($type -eq [Int32])
{
    $type = [Long]
    [Long]$propValue = $PropertyValue
}
elseif($type -eq [String[]])
{
    $type = [String]
    [String]$propValue = [String[]]$PropertyValue -join ","
}

[Uri]$parentName = new-object system.uri("fabric:/$($prop.ParentName -replace '\\','/')".ToLower())
[String]$propName = $PropertyName
if([String]::IsNullOrWhiteSpace($ConnectionEndpoint))
{
    $cluster = Connect-ServiceFabricCluster
}
else
{
    $cluster = Connect-ServiceFabricCluster -ConnectionEndpoint $ConnectionEndpoint
}

$client = $cluster.FabricClient.PropertyManager

$CreateNameAsync = $client.GetType().GetMethod("CreateNameAsync", [Type[]]@([Uri]))
[Object[]]$params = @($parentName)
$CreateNameAsync.Invoke($client,$params).Result | Out-Null

[Object[]]$params = @($parentName,$propName,$propValue)
$PutPropertyAsync = $client.GetType().GetMethod("PutPropertyAsync", [Type[]]@([Uri], [String], $type))
$PutPropertyAsync.Invoke($client,$params).Result
Write-Host "Update $PropertyName to $PropertyValue"