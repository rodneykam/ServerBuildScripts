
<# Expected output is:
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
#>

# Loop through the three certificates (EMR, HealthVault and VortexrToolsClientCert)
foreach ($certName in "MEVANS-Z620.healinx.inside","MEVANS-Z620.na.corp.mckesson.com") {
	Write-host -ForegroundColor Yellow "Processing certificate $certName"
	
	# Loop through the two accounts (Network Service and RelayServices)
	foreach ($account in "Network Service","ek8t4xb") {
		Write-host -ForegroundColor Yellow "Processing account $account on certificate $certName"
		$result=invoke-expression "C:\GitHub\ServerBuildScripts\WIP\mevans\winhttpcertcfg.exe -g -a `"$account`"  -c LOCAL_MACHINE\My -s $certName"

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