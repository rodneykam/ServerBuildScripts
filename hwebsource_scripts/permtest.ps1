param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)



netsh http Delete urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService

netsh http Delete urlacl url=http://+:8080/EScriptIntegration

netsh http Delete urlacl url=http://+:4762/PayorEligibilityService

netsh http Delete urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber

netsh http Delete urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber

netsh http Delete urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService

netsh http Delete urlacl url=http://localhost:4762/PayorEligibilityService

netsh http Delete urlacl url=http://+:4240/relayhealth/simulator/faxServer


$perm = $MachineConfig.RelayServicesAccount
 
netsh http add urlacl url=http://+:8888/patient/DrugBenefitRxHistoryService/ user=$perm
netsh http add urlacl url=http://+:8080/EScriptIntegration/ user= $perm
netsh http add urlacl url=http://+:4762/PayorEligibilityService/ user= $perm
netsh http add urlacl url=http://+:2201/relayhealth/service/surescripts/prescriber/ user= $perm
netsh http add urlacl url=http://+:2201/relayhealth/service/rxhub/prescriber/ user= $perm
netsh http add urlacl url=http://localhost:8888/patient/DrugBenefitRxHistoryService/ user= $perm
netsh http add urlacl url=http://localhost:4762/PayorEligibilityService/ user=$perm
netsh http add urlacl url=http://+:4240/relayhealth/simulator/faxServer/ user= $perm

