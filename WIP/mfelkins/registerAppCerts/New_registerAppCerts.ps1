# 10:53 AM 11/2/2015

#.SYNOPSIS
        
# This script creates batch files that set Certificates for various applications
# It logs its progress in C:\Logs. If C:\logs does not exist, it will create it.
#       
# .DESCRIPTION
# 
# .EXAMPLE
        
# .\registerAppCerts.ps1 $EnvironmentConfig $MachineConfig        
# .NOTES
# Script Name :  registerAppCerts.ps1 
# Author      :  Mike Felkins       
# Date        :  10:54 AM 11/2/2015
#
#######################################################################################
# Script begins
param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

# Added these variables to name the new log file.
# Date and time stamp
# Path and file name of the new log file
# Creates a new log file
#sets the Logfile variable to the path and file name.
$Error.clear()

$Date = get-date -f "MM-dd-yyyy hh-mm-ss"

$Path = "C:\Hwebsource\scripts\logs\registerAppCerts_$($env:computername)_" + $Date + ".log"

Write-Host -ForegroundColor Yellow $Path

$NewLogFile = New-Item $Path -Force -ItemType File

$Logfile = $Path

# Import the Logfile function.
Import-module C:\Hwebsource\scripts\LogfileFunction.ps1

$Account = $MachineConfig.RelayServicesAccount

# Write the Date and time to the log file
LogWrite "$Date"
# Check for the existence of the the MachineConfig.RelayServicesAccount

if([string]::IsNullOrEmpty($account))
{
	Write-Host -ForegroundColor Yellow "`n HVRelayServicesAccount does not exits in buildoutconfig"
    LogWrite "HVRelayServicesAccount does not exits in buildoutconfig"
}	

# Change the directory to E:\Relayhealth\Deployhelp

pushd E:\Relayhealth\Deployhelp

#Set the wincertdir variable to winhttpcertcfg.exe 
$wincertdir = "E:\healthvault\winhttpcertcfg.exe"

# set the hvsubject variable to "healthvault.relayhealth.com"
$hvsubject ="healthvault.relayhealth.com"
$emrsubject = "emr-prod.relayhealth.com"
$vorsubject = "$vortex-prod.relayhealth.com"
popd

$hvcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$hvsubject"}
if([string]::IsNullOrEmpty($hvsubject))
{
    Write-Host -ForegroundColor Yellow "`n healthvault.relayhealth.com does not exist in cert:\LocalMachine\MY" `n
}

$emrcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$emrsubject"}
if([string]::IsNullOrEmpty($emrcert))
{
    Write-Host -ForegroundColor Yellow "`n emr-prod.relayhealth.com does not exist in cert:\LocalMachine\MY" `n
}

$vortexcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$vorsubject"}
if([string]::IsNullOrEmpty($emrcert))
{
    Write-Host -ForegroundColor Yellow "`n vortex-prod.relayhealth.com does not exist in cert:\LocalMachine\MY" `n
}

$accounts = @("Network Service",$account)

Foreach ($Item in $Accounts){
$AppCert1 = "$wincertdir -g -a" + $account + "-c LOCAL_MACHINE\My -s $hvsubject"
LogWrite $AppCert1

$AppCert2 = "$wincertdir -g -a" + $account + "-c LOCAL_MACHINE\My -s $emrsubject"
LogWrite $AppCert2

$AppCert3 = "$wincertdir -g -a" + $account + "-c LOCAL_MACHINE\My -s $vorsubject"
LogWrite $AppCert3
}

$Output = $AppCert1
LogWrite $Output

If ($Error) {
    $E1 = [string]$Error
    $E2 = $E1.Split(".")
    Write-Host $E2[1]
    LogWrite $E2[1]
$Error.clear()
}


$Output = $AppCert2
LogWrite $Output
If ($Error) {
    $E1 = [string]$Error
    $E2 = $E1.Split(".")
    Write-Host $E2[1]
    LogWrite $E2[1]
$Error.clear()
}

$Output = $AppCert3
LogWrite = $Output
If ($Error) {
    $E1 = [string]$Error
    $E2 = $E1.Split(".")
    Write-Host $E2[1]
    LogWrite $E2[1]
$Error.clear()
}

