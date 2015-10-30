# 4:43 PM 10/30/2015
# .SYNOPSIS
        
# This script delets URL acl's for several web sites.
# It then adds them back in with the proper permissions.
        
# .DESCRIPTION
# 
# .EXAMPLE
        
# .\permtest.ps1 $EnvironmentConfig $MachineConfig        
# .NOTES
# Script Name :  Permtest.ps1   
# Author      :  Mike Felkins       
# Date        :  4:43 PM 10/30/2015
    

#######################################################################################
# Script begins
# Here we set the Parameters for this script.

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

# Create the Logfile function.
Function LogWrite  {
Param ([string]$logstring)
Add-content $Logfile -value $logstring
}
 
# Added these variables to name the new log file.
# Date and time stamp
# Path and file name of the new log file
# Creates a new log file
# sets the Logfile variable to the path and script name.
# LogWrite with no subject creates a blank line

$Date = get-date -f "MM-dd-yyyy hh-mm-ss"
$Path = "F:\SCM\Buildout\BuildoutLogs\Permtest_$($env:computername)_" + $Date + ".log"
$NewLogFile = New-Item $Path -Force -ItemType File
$Logfile = $Path 
$ScriptName = $MyInvocation.MyCommand.Name
Write-Host -Foregroundcolor Yellow $ScriptName
LogWrite "$ScriptName `t$Date `n "
LogWrite

# Here we delete the URL acl's
# We capture the output in the $Output variable and write that to the logfile we created above.

$Output = netsh http Delete urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService
LogWrite "Delete urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://+:8080/EScriptIntegration
LogWrite "Delete urlacl url=http://+:8080/EScriptIntegration"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://+:4762/PayorEligibilityService
LogWrite "Delete urlacl url=http://+:4762/PayorEligibilityService"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber
LogWrite "Delete urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber
LogWrite "Delete urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService
LogWrite "Delete urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://localhost:4762/PayorEligibilityService
LogWrite "Delete urlacl url=http://localhost:4762/PayorEligibilityService"
LogWrite $Output
LogWrite

$Output = netsh http Delete urlacl url=http://+:4240/relayhealth/simulator/faxServer
LogWrite "http Delete urlacl url=http://+:4240/relayhealth/simulator/faxServer"
LogWrite $Output
LogWrite

# Here we get the service account from the machine config 

$perm = $MachineConfig.RelayServicesAccount
LogWrite "the service account from the machine config"
LogWrite "MachineConfig.RelayServicesAccount is $perm"
LogWrite

# Here we add the url's with the correct user 

$Output = netsh http add urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService/ user=$perm
LogWrite "add urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService/ user=$perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://+:8080/EScriptIntegration/ user= $perm
LogWrite "add urlacl url=http://+:8080/EScriptIntegration/ user= $perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://+:4762/PayorEligibilityService/ user= $perm
LogWrite "add urlacl url=http://+:4762/PayorEligibilityService/ user= $perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber/ user= $perm
LogWrite "add urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber/ user= $perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber/ user= $perm
LogWrite "add urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber/ user= $perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService/ user= $perm
LogWrite "add urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService/ user= $perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://localhost:4762/PayorEligibilityService/ user=$perm
LogWrite "add urlacl url=http://localhost:4762/PayorEligibilityService/ user=$perm"
LogWrite $Output
LogWrite

$Output = netsh http add urlacl url=http://+:4240/relayhealth/simulator/faxServer/ user= $perm
LogWrite "add urlacl url=http://+:4240/relayhealth/simulator/faxServer/ user= $perm"
LogWrite $Output
LogWrite

$Date = get-date -f "MM-dd-yyyy hh-mm-ss"

LogWrite "End of $ScriptName `t$Date `n "
