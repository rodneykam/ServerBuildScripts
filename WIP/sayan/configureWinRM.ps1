#############################################################################
##
## configureWinRM
##   
## 10/2015, RelayHealth
## Martin Evans
##
##############################################################################

<#
.SYNOPSIS
	This script configures Windows Remoting WinRM listener to use HTTPS on a web server

.DESCRIPTION
	
.EXAMPLE 

#>

param
(
	# Configuration XML parameters are not used by this script
	$EnvironmentConfig=$null,
	$MachineConfig=$null,
	[switch] $remove
)

Write-host -ForegroundColor Green "`nStart of ConfigureWinRM script`n"

# Checking whether WinRM listeners are configured
$listeners= winrm enumerate winrm/config/listener


# Remove listeners if -Remove flag was set
if ($remove) {
	if ($listeners) {
		write-Host -ForegroundColor Green "The following Listeners will be deleted from $computername `n "
		$listeners
		winrm delete winrm/config/listener?Address=IP:$ip+Transport=HTTPS
        Handle-Error $LastExitCode "configureWinRM - Delete Listener"

		write-Host -ForegroundColor yellow "`n All HTTPS Listeners have been deleted `n"
		winrm enumerate winrm/config/listener

	} else {
		write-Host -ForegroundColor Green "There are no Listeners to delete from $computername `n "
	}
	exit
}

# Any listeners should be deleted before we create the new listener
if ($listeners) {
	write-Host -ForegroundColor Red "The following Listeners are enabled on $computername"
	write-Host -ForegroundColor Red "Remove the listeners by running configureWinRM.ps1 -remove"
	write-Host -ForegroundColor Red "Then re-run the configureWinRM.ps1 script"
	$listeners
	exit
}

# Otherwise, create the WinRM listener
write-Host -ForegroundColor yellow "`n No WinRM Listener has been configured on $computername `n "

# Get server IP address, computer name and domain
$ip=(gwmi -query "Select IPAddress From Win32_NetworkAdapterConfiguration Where IPEnabled = True").IPAddress
if($ip -eq $null)
{
	$ip=(gwmi -query "Select IPAddress From Win32_NetworkAdapterConfiguration Where IPEnabled = True and Description = 'HP Network Team #1'").IPAddress
}
$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

# Identify the server certificate
$cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "CN=$computername"}
if (!($cert)) {
	Write-host -ForegroundColor Red "No certificate found to match 'CN=$computername'"
	exit
}
$CN=$cert.thumbprint
Write-host -ForegroundColor Green "The Certificate Thumbprint for $computername is  the following `n $CN `n"

# Ensure Windows Remoting service is running
$service = get-service winrm
$Service_Status = $service.status

if($Service_Status -ne "running")
{
	Write-host -ForegroundColor Green  "Starting the Windows service $Service`n"
	start-service winrm
}
else
{
	Write-host -ForegroundColor Green "Windows service $Service is running `n" 
}

Write-host -ForegroundColor Green "`n The following  listener is created on  this  $computername"
winrm create winrm/config/listener?Address=IP:$ip+Transport=HTTPS
Handle-Error $LastExitCode "configureWinRM - Create Listener"

winrm set winrm/config/client '@{TrustedHosts="10.12.42.32"}'
Handle-Error $LastExitCode "configureWinRM - Set Client"

Write-host -ForegroundColor Green "`n Here are all the listeners on  this  $computername"
winrm enumerate winrm/config/listener

Write-host -ForegroundColor Green "`nEnd of ConfigureWinRM script`n"