#############################################################################
##
## configureInitiate
##   
## 10/2015, RelayHealth
## Martin Evans
##
##############################################################################

<#
.SYNOPSIS
	This script applies permissions to certificates to grant certain accounts to utilize those certificates.
        
.DESCRIPTION

	Expected output of the raw winhttpcertcfg.exe application is:
	
		Microsoft (R) WinHTTP Certificate Configuration Tool
		Copyright (C) Microsoft Corporation 2001.

		Matching certificate:
		CN=MEVANS-Z620.healinx.inside

		Granting private key access for account:
			NT AUTHORITY\NETWORK SERVICE

	or:
		Microsoft (R) WinHTTP Certificate Configuration Tool
		Copyright (C) Microsoft Corporation 2001.

		Matching certificate:
		CN=MEVANS-Z620.healinx.inside


		Private key access has already been granted for account:
			NT AUTHORITY\NETWORK SERVICE
	
	
.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

Write-host -ForegroundColor Green "`nStart of Certificate Permissions script`n"

### START
### Find the certificates and the winhttpcertcfg executable, per Tracy's registerAppCert.ps1 script
### ....
$emrsubject = "emr-prod.relayhealth.com"
$hvaultsubject = "healthvault.relayhealth.com"
$vortexsubject = "VortexrToolsClient"

$account = [String]$MachineConfig.HVRelayServicesAccount
# ...
# END


# Loop through the three certificates (EMR, HealthVault and VortexrToolsClientCert)
foreach ($certName in $emrsubject,$hvaultsubject,$vortexsubject) {
	Write-host -ForegroundColor Yellow "- Processing certificate $certName"
	
	# Loop through the two accounts (Network Service and the server-specific RelayServices accounts)
	foreach ($account in "Network Service",$account) {
		Write-host -ForegroundColor Yellow "-- Processing account $account on certificate $certName"
		$result=invoke-expression "E:\healthvault\\winhttpcertcfg.exe -g -a `"$account`"  -c LOCAL_MACHINE\My -s $certName"

		# Error handling
		if ($LastExitCode -ne 0) {
			Write-host -ForegroundColor Red "Certificate permissions command failed to run"
			exit
		}
		if (!($result -match $certName)) {
			Write-host -ForegroundColor Red "Could not find the certificate $certName"
			exit
		}
		if ($result -match "Private key access has already been granted for account:") {
			Write-host -ForegroundColor Yellow "Certificate access permissions already granted for account $account on certificate $certName"
		}
		if ($result -match "Granting private key access for account:") {
			Write-host -ForegroundColor Yellow "Granted certificate access permissions for account $account on certificate $certName"
		}
		# Show result text
		$result
	}
}

Write-host -ForegroundColor Green "`nEnd of Certificate Permissions script`n"
