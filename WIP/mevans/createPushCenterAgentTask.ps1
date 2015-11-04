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
	This script creates the PUdh Center scheduled task on a web server. That task allows the automated 
	unzip of code during code deployment
        
.DESCRIPTION
	
	
.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

Write-host -ForegroundColor Green "`nStart of Create Push Center Agent scheduled task script`n"

$Account = [String]$MachineConfig.ScheduledTaskAccount	
$Password = [String]$MachineConfig.ScheduledTaskPassword

Write-host -ForegroundColor Green "Running command: schtasks /Create /XML ./PushCenterAgent.xml /TN $taskName /RU `"$Account`" /RP `"xxxxx`" /F"
# Note that the expression " 2>&1" pipes the command output into the return code $result
$result = invoke-expression "schtasks /Create /XML ./PushCenterAgent.xml /TN $taskName /RU `"$Account`" /RP `"$Password`" /F 2>&1"
$result

if (($LastExitCode -ne 0) -or (!($result -match "SUCCESS")) {
	Write-host -ForegroundColor Red "Failed to create scheduled task PushCenterAgent"
	exit
}

Write-host -ForegroundColor Green "Verify that the task was created"
$result = invoke-expression ".\schtasks.exe /query /FO TABLE /TN PushCenterAgent"

if (($LastExitCode -ne 0) -or (!($result -match "SUCCESS")) {
	Write-host -ForegroundColor Red "Scheduled task PushCenterAgent does not exist"
	exit
}

Write-host -ForegroundColor Green "`nEnd of Create Push Center Agent scheduled task script`n"
