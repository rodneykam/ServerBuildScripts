# 4:43 PM 10/30/2015
# .SYNOPSIS
        
# This script delets URL acl's for several web sites.
# It then adds them back in with the proper permissions.
        
# .DESCRIPTION
# 
# .EXAMPLE
        
# .\permtest.ps1 $EnvironmentConfig $MachineConfig        

#######################################################################################
# Script begins
# Here we set the Parameters for this script.

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
[Parameter(Mandatory=$true)] $BuildOutLog
)

Write-Log "$ScriptName `t$Date `n " $BuildOutLog Info

# Here we delete the URL acl's
# We capture the output in the $Output variable and write that to the logfile we created above.

$Output = netsh http Delete urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService
Write-Log "Delete urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info


$Output = netsh http Delete urlacl url=http://+:8080/EScriptIntegration
Write-Log "Delete urlacl url=http://+:8080/EScriptIntegration" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http Delete urlacl url=http://+:4762/PayorEligibilityService
Write-Log "Delete urlacl url=http://+:4762/PayorEligibilityService" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http Delete urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber
Write-Log "Delete urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http Delete urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber
Write-Log "Delete urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber" $BuildOutLog Info
Write-Log $Output$BuildOutLog Info

$Output = netsh http Delete urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService
Write-Log "Delete urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http Delete urlacl url=http://localhost:4762/PayorEligibilityService
Write-Log "Delete urlacl url=http://localhost:4762/PayorEligibilityService" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http Delete urlacl url=http://+:4240/relayhealth/simulator/faxServer
Write-Log "http Delete urlacl url=http://+:4240/relayhealth/simulator/faxServer" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

# Here we get the service account from the machine config 

$perm = $MachineConfig.RelayServicesAccount
Write-Log "the service account from the machine config" $BuildOutLog Info
Write-Log "MachineConfig.RelayServicesAccount is $perm" $BuildOutLog Info

# Here we add the url's with the correct user 

$Output = netsh http add urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService/ user=$perm
Write-Log "add urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService/ user=$perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://+:8080/EScriptIntegration/ user= $perm
Write-Log "add urlacl url=http://+:8080/EScriptIntegration/ user= $perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://+:4762/PayorEligibilityService/ user= $perm
Write-Log "add urlacl url=http://+:4762/PayorEligibilityService/ user= $perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber/ user= $perm
Write-Log "add urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber/ user= $perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber/ user= $perm
Write-Log "add urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber/ user= $perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService/ user= $perm
Write-Log "add urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService/ user= $perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://localhost:4762/PayorEligibilityService/ user=$perm 
Write-Log "add urlacl url=http://localhost:4762/PayorEligibilityService/ user=$perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Output = netsh http add urlacl url=http://+:4240/relayhealth/simulator/faxServer/ user= $perm
Write-Log "add urlacl url=http://+:4240/relayhealth/simulator/faxServer/ user= $perm" $BuildOutLog Info
Write-Log $Output $BuildOutLog Info

$Date = get-date -f "MM-dd-yyyy hh-mm-ss"

Write-Log "End of $ScriptName `t$Date `n " $BuildOutLog Info
