param(
[switch]$RemoveCacheCluster, 
[string]$database_name= $(throw "You must specify a Domain name of the remote machine "),
[string]$database_server= $(throw "You must specify a Domain name of the remote machine ")
)


$provider = "System.Data.SqlClient"
$host_name = $env:COMPUTERNAME
$cache_port = 22233





Import-Module DistributedCacheAdministration
Import-Module DistributedCacheConfiguration

$connection_string = ""

if ($provider -eq "System.Data.SqlClient")
{
   $connection_string = "Data Source=" + $database_server + `
      ";Initial Catalog=" + $database_name + `
      ";Integrated Security=True"
}

if ($ConnStr)
{
   $connection_string = $ConnStr
}


Write-Host "`nUse-CacheCluster -Provider $provider -ConnectionString"`
   "`"$connection_string`"" -ForegroundColor Green
Use-CacheCluster -Provider $provider -ConnectionString $connection_string

#Make sure the cache host is stopped
$Get_CacheHost_Command = Get-CacheHost -HostName $host_name -CachePort $cache_port

if ($Get_CacheHost_Command.Status -eq "Up")
{
   Write-Host "`nStop-CacheHost -HostName $host_name -CachePort $cache_port" -ForegroundColor Green
   Stop-CacheHost -HostName $host_name -CachePort $cache_port
}

$Get_CacheHost_Command = Get-CacheHost -HostName $host_name -CachePort $cache_port

if ($Get_CacheHost_Command.Status -eq "Down")
{
   Write-Host "`nUnregister-CacheHost -Provider $provider -ConnectionString `"$connection_string`" " `
      "-HostName $host_name -RemoveServicePermissions" -ForegroundColor Green
   Unregister-CacheHost -Provider $provider -ConnectionString $connection_string `
      -HostName $host_name -RemoveServicePermissions
   
   Write-Host "`nRemove-CacheHost" -ForegroundColor Green
   Remove-CacheHost
   
 
  
   
   # Look for a parameter that specifies this is a new cache cluster
   if ($RemoveCacheCluster)
   {
      Write-Host "`nRemove_CacheCluster -Provider $provider -ConnectionString "`
         "`"$connection_string`" -Force" -ForegroundColor Green
      Remove-CacheCluster -Provider $provider -ConnectionString $connection_string -Force
   }
}
else
{
   Write-Host "`nUnable to stop the host $host_name (Port:$cache_port)`n`n" -ForegroundColor Red
}