#############################################################################
##
## permtest
##
## 11/2015, RelayHealth
## Martin Evans
##
##############################################################################


<#
.SYNOPSIS
	This script gives the RelayServicesAccount permission to the URLs defined in IIS
	
.DESCRIPTION

	The script calls netsh to give the required permissions to the RelayServicesAccount on the following URLs
    
	"http://+:8888/patient/DrugBenefitRxHistoryService/"
    "http://+:8080/EScriptIntegration/"
    "http://+:4762/PayorEligibilityService/"
    "http://+:2201/relayhealth/service/surescripts/prescriber/"
    "http://+:2201/relayhealth/service/rxhub/prescriber/"
    "http://localhost:8888/patient/DrugBenefitRxHistoryService/"
    "http://localhost:4762/PayorEligibilityService/"
    "http://+:4240/relayhealth/simulator/faxServer/"
	
.EXAMPLE 

#>

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)



Write-Host -ForegroundColor Green "Start Script - registerUrls"

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

# Call netsh command to first delete and then allow the RelayServiceAccount to access the URLs listed above.
foreach ($url in $urls) {

	netsh http Delete urlacl url=$url
	Handle-Error $LastExitCode "RegisterUrls.ps1 - Delete Url - $url"

	netsh http add urlacl url="$url" user=$perm
	Handle-Error $LastExitCode "RegisterUrls.ps1 - Add Url  - $url"
}

Write-Host -ForegroundColor Green "Start Script - registerUrls"

