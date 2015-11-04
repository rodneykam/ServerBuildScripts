#############################################################################
##
## configureInitiate
##   
## 10/2015, RelayHealth
## Martin Evans
##
##############################################################################

<#
.SYNOPSIS
	This script installs the Push Center Agent scheduled task on a web server
        
.DESCRIPTION
	
	
.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

Write-host -ForegroundColor Green "`nStart of Create Push Center Agent scheduled taks script`n"

$Account = [String]$MachineConfig.ScheduledTaskAccount	
$Password = [String]$MachineConfig.ScheduledTaskPassword

Write-host -ForegroundColor Green "Running command: schtasks /Create /XML ./PushCenterAgent.xml /TN $taskName /RU $Account /RP xxxxx /F"
schtasks /Create /XML ./PushCenterAgent.xml /TN $taskName /RU "$Account" /RP "$Password" /F

Write-host -ForegroundColor Green "`nEnd of Create Push Center Agent scheduled taks script`n"
