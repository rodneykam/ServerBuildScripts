<#
.SYNOPSIS
	This script creates the Push Center scheduled task on a web server. That task allows the automated 
	unzip of code during code deployment.
        
.DESCRIPTION
    The script uses the executable "schtasks.exe" to create the scheduled tasks based on the data provided in the file "PushCenterAgent.xml"
	
.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig

.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

$scriptName = "createPushCernterAgentTask"

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

$Account = [String]$MachineConfig.ScheduledTaskAccount
$Password = [String]$MachineConfig.ScheduledTaskPassword

<#
if (!( test-path -Path PushCenterAgent.xml)) {
	Write-host -ForegroundColor Red "Cannot find Scheduled Task configuration file PushCenterAgent.xml"
	exit
	# Getting this error. Going to define the path on the local server.
}
#>

if (!( test-path -Path C:\Buildout\PushCenterAgent.xml)) {
	Write-host -ForegroundColor Red "Cannot find Scheduled Task configuration file PushCenterAgent.xml"
	exit
}

Write-host -ForegroundColor Green "Running command: schtasks /Create /XML ./PushCenterAgent.xml /TN $taskName /RU `"$Account`" /RP `"xxxxx`" /F"
# Note that the expression " 2>&1" pipes the command output into the return code $result
$result = invoke-expression "schtasks /Create /XML ./PushCenterAgent.xml /TN $taskName /RU `"$Account`" /RP `"$Password`" /F 2>&1"
$result

if (($LastExitCode -ne 0) -or (!($result -match "SUCCESS"))) {
	Write-host -ForegroundColor Red "Failed to create scheduled task PushCenterAgent"
@@ -53,7 +47,7 @@ if (($LastExitCode -ne 0) -or (!($result -match "SUCCESS"))) {
	exit
}

Write-host -ForegroundColor Green "Verify that the task was created"
$result = invoke-expression ".\schtasks.exe /query /FO TABLE /TN PushCenterAgent"

if (($LastExitCode -ne 0) -or (!($result -match "SUCCESS"))) {
	Write-host -ForegroundColor Red "Scheduled task PushCenterAgent does not exist"
	exit
}

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"
