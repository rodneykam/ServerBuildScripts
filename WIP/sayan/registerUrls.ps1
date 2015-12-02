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
	This script gives the RelayServiceAccount permission to the URLs defined in IIS
	
.DESCRIPTION

	The script calls netsh 
	
	
.EXAMPLE 

#>

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

function handleerror
{
    param ($ParsedLEC, $where)

    if ($ParsedLEC -ne 0){
	    Write-Error "Script failed at $where"
        exit
	    }
    ELSE{	
	    Write-Host -foregroundcolor Green "Successfully processed $where"
   	    }
}


Write-Host "Starting permtest.ps1"

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
	handleerror $LastExitCode "Delete Url"

	netsh http add urlacl url="$url" user=$perm
	handleerror $LastExitCode "Add Url"
}

Write-Host "End permtest.ps1"

