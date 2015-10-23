param(
[switch]$NewCacheCluster, 
[string]$database_name= $(throw "You must specify a Domain name of the remote machine "),
[string]$database_server= $(throw "You must specify a Domain name of the remote machine ")
)


$provider = "System.Data.SqlClient"
$host_name = $env:COMPUTERNAME
$service_account = "NT Authority\Network Service"
$starting_port = 22233
$cluster_size = "Small"


#$database_name = "trunk_AppFabricCacheConfiguration"
#$database_server = "localhost"



Import-Module DistributedCacheAdministration
Import-Module DistributedCacheConfiguration

$cache_port = $starting_port + 0
$cluster_port = $starting_port + 1
$arbitration_port = $starting_port + 2
$replication_port = $starting_port + 3
$connection_string = ""

if ($provider -eq "System.Data.SqlClient")
{
   $connection_string = "Data Source=" + $database_server + `
      ";Initial Catalog=" + $database_name + `
      ";Integrated Security=True"
}


# If provided, command-line parameters override 
# internal script variables:
if ($ConnStr)
{
   $connection_string = $ConnStr
}



$Get_CacheClusterInfo_Command = Get-CacheClusterInfo -Provider $provider -ConnectionString $connection_string

# Look for a PowerShell script parameter that specifies this is a new cache cluster
if ($NewCacheCluster -and !$Get_CacheClusterInfo_Command.IsInitialized)
{
   Write-Host "`nNew-CacheCluster -Provider $provider -ConnectionString "`
      "`"$connection_string`" -Size $cluster_size" -ForegroundColor Green
   New-CacheCluster -Provider $provider -ConnectionString $connection_string -Size $cluster_size    
}



Write-Host "`nRegister-CacheHost -Provider $provider -ConnectionString `"$connection_string`" "`
   "-Account `"$service_account`" -CachePort $cache_port -ClusterPort $cluster_port "`
   "-ArbitrationPort $arbitration_port -ReplicationPort $replication_port -HostName "`
   "$host_name" -ForegroundColor Green
Register-CacheHost -Provider $provider -ConnectionString $connection_string -Account `
   $service_account -CachePort $cache_port -ClusterPort $cluster_port -ArbitrationPort `
   $arbitration_port -ReplicationPort $replication_port `
   -HostName $host_name

Write-Host "`nAdd-CacheHost -Provider $provider -ConnectionString `"$connection_string`" "`
   "-Account `"$service_account`"" -ForegroundColor Green
Add-CacheHost -Provider $provider -ConnectionString $connection_string -Account $service_account


Use-CacheCluster -Provider $provider -ConnectionString $connection_string


# If the cluster is not running, don't start the cache host.

$running = 0
$Get_CacheHost_Command = Get-CacheHost -HostName $host_name -CachePort $cache_port

foreach ($cache_host in $Get_CacheHost_Command)
{
   if ($cache_host.Status -eq "Up")
   {
      $running = 1
   }
}

if ($running -eq "0")
{
   Write-Host "`nStart-CacheHost -HostName $host_name -CachePort $cache_port" -ForegroundColor Green
   Start-CacheHost -HostName $host_name -CachePort $cache_port
}
else
{
   Write-Host "`nNot starting new cache host; Cache Cluster is not running..." -ForegroundColor Green
}

Write-Host "`nGet-CacheHost`n" -ForegroundColor Green
Get-CacheHost