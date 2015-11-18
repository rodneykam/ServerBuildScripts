param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

$perm = $MachineConfig.RelayServicesAccount
$urls = @(
"http://+:8888/patient/DrugBenefitRxHistoryService/",
"http://+:8080/EScriptIntegration/",
"http://+:4762/PayorEligibilityService/",
"http://+:2201/relayhealth/service/surescripts/prescriber/",
"http://+:2201/relayhealth/service/rxhub/prescriber/",
"http://localhost:8888/patient/DrugBenefitRxHistoryService/",
"http://localhost:4762/PayorEligibilityService/",
"http://+:4240/relayhealth/simulator/faxServer/"
)

foreach ($url in $urls) {
	netsh http Delete urlacl url=$url
	netsh http add urlacl url="$url" user=$perm
}


