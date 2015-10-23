# Checking winrm listener  is configured  
$listeners= winrm enumerate winrm/config/listener
$ip=(gwmi -query "Select IPAddress From Win32_NetworkAdapterConfiguration Where IPEnabled = True").IPAddress
if($ip -eq $null)
{
$ip=(gwmi -query "Select IPAddress From Win32_NetworkAdapterConfiguration Where IPEnabled = True and Description = 'HP Network Team #1'").IPAddress
}
$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"
$cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "CN=$computername"}
$CN=$cert.thumbprint
$service = get-service winrm
$Service_Status = $service.status

if($Service_Status -ne "running")
{
Write-host -ForegroundColor Green  "Starting the $Service `n"
start-service winrm
}
else
{
Write-host -ForegroundColor Green "Winrm is running `n" 
}

Write-host -ForegroundColor Green "The Certificate Thumbprint for $computername   is  the following `n $CN `n"

if($listeners)
{
	write-Host -ForegroundColor Green "The following Listeners will be deleted from $computername `n "
	$listeners
	winrm delete winrm/config/listener?Address=IP:$ip+Transport=HTTPS
	write-Host -ForegroundColor yellow "`n All HTTPS Listener have been deleted `n"
}
else
{
	write-Host -ForegroundColor yellow "`n No Listener has been configured on $computername `n "
	
	Write-host -ForegroundColor Green "`n The following  listener is created on  this  $computername"
		
	winrm create winrm/config/listener?Address=IP:$ip+Transport=HTTPS

	winrm set winrm/config/client '@{TrustedHosts="10.12.42.32"}'
	
	Write-host -ForegroundColor Green "`n Here are all the listeners on  this  $computername"
}


winrm enumerate winrm/config/listener








