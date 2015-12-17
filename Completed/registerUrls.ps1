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

.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig

.EXAMPLE 

#>

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

$scriptName = "registerUrls"

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

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

	$result = netsh http Delete urlacl url=$url
	Handle-Error $LastExitCode "$url - $result"

	$result = netsh http add urlacl url="$url" user=$perm
	Handle-Error $LastExitCode "$url - $result"
}

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"

