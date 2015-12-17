<#
.SYNOPSIS
	This script applies permissions to certificates to grant certain accounts to utilize those certificates.
	
.DESCRIPTION

	The account "HVRelayServicesAccount" is given permission on the following certificates. 
	"emr-prod.relayhealth.com"
	"healthvault.relayhealth.com"
	"VortexrToolsClient"
	
	We are doing this by calling the executable winhttpcertcfg.exe located in E:\RegisterAppCert directory.
	
.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig
	
.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

$scriptName = "registerAppCert"
$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"
# Find the certificates and the winhttpcertcfg executable
$emrsubject = "emr-prod.relayhealth.com"
$hvaultsubject = "healthvault.relayhealth.com"
$vortexsubject = "VortexrToolsClient"

# Set folder and file locations
$wincertdir = "E:\RegisterAppCert"
$certConfig = "E:\RegisterAppCert\winhttpcertcfg.exe"  #executable that gets run in each batch file

 
write-host -foreground Green "`n Checking for existing RegisterAppCert folder and file section."

# Test for existence of the E:\RegisterAppCert folder and the winhttpcertcfg.exe file
if (-Not (test-path $wincertdir)) 
{
	Write-Host -ForegroundColor Red "   The E:\RegisterAppCert folder does not exist."
	Write-Host -ForegroundColor Red "   Terminating registerAppCert script. `n"
	exit
}
elseif (-Not (test-path $certConfig)) 
{
	Write-Host -ForegroundColor Yellow "   The E:\RegisterAppCert folder exists, testing for winhttpcertcfg.exe"
	Write-Host -ForegroundColor Red "   Terminating registerAppCert script because the file winhttpcertcfg.exe does not exist. `n"
	exit
}
else
{
	Write-Host -ForegroundColor White "`n   The E:\RegisterAppCert folder and file winhttpcertcfg.exe exist."
}

$account = [String]$MachineConfig.HVRelayServicesAccount

# Loop through the three certificates (EMR, HealthVault and VortexrToolsClientCert)
foreach ($certName in $emrsubject,$hvaultsubject,$vortexsubject) {
	Write-host -ForegroundColor White "`n- Processing certificate $certName"
	$certificate = Get-ChildItem cert:\LocalMachine\MY | where-object {$_.Subject -match "$certName"}

	# Check for the existance of the certificate in the cert directory
	if([string]::IsNullOrEmpty($certificate))
	{
		Write-Host -ForegroundColor Yellow "   The $certName certificate does not exist in the mmc or the DTD does not have the right value `n"
		throw "The ($certName) certificate does not exist in the mmc or the DTD does not have the right value"
	}
	else
	{
		Write-Host -ForegroundColor Yellow "   Found the ($certName) certificate."
	}
	
	# Loop through the two accounts (Network Service and the server-specific RelayServices accounts)
	foreach ($account in "Network Service",$account) {
		Write-host -ForegroundColor White "`n   -- Processing account ($account) on certificate: $certName"
		$result=invoke-expression "E:\healthvault\winhttpcertcfg.exe -g -a `"$account`"  -c LOCAL_MACHINE\My -s $certName"
		#$result

		# Error handling
		if ($LastExitCode -ne 0) {
			Write-host -ForegroundColor Red "   Certificate permissions command failed to run. - Exiting script."
			exit
		}
		if (!($result -match $certName)) {
			Write-host -ForegroundColor Red "   Could not find the ACCOUNT for ($certName) - Exiting script."
			exit  
		}
		if ($result -match "Private key access has already been granted for account:") {
			Write-host -ForegroundColor Yellow "   Certificate access permissions already granted for account ($account) on:  $certName"
		}
		if ($result -match "Granting private key access for account:") {
			Write-host -ForegroundColor Yellow "   Granted certificate access permissions for account ($account) on:  $certName"
		}
		# Show result text
		#$result
	}
}

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"
