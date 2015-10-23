param (
	[string] $release,					# Code version e.g. 10.1.0.12345
	[switch] $unzipcode = $true,
	[switch] $isProduction,				# Flag used to disable testing/simulator services on production systems
	[bool]	 $isAutoDeploy = $false,	# Flag to indicate deploy.ps1 is being called from Auto Deployment Site
	$credentials  						#Contains Credential structure:  @{type = "" ; identifier = "" ; username = "" ; password = ""},@{...}
)
#./deployVerification.ps1 -release 15.2.0.119547 -isProduction 

import-module ServerManager -errorAction SilentlyContinue

$ErrorActionPreference = "stop"

write-host -foregroundcolor GREEN "=================================================="
write-host -foregroundcolor GREEN "=         Start Verification deployment         ="
write-host -foregroundcolor GREEN "=================================================="
write-host -foregroundcolor GREEN "Starting to deploy the Verification (deployVerification.ps1)"

$folderPath= "E:\Verification\VerificationDeployHelp\ReleaseInfo"
if(-not (test-path($folderPath)))
{
	write-host -ForegroundColor green "`n Creating $folderPath ....... `n"
	New-Item $folderPath -type directory
}

&{
	#TRY
	pushd E:\Verification\VerificationDeployHelp

	if ($unzipcode)
	{
		write-host -foregroundcolor GREEN "Unzip Verification files"
		.\unzip.version.ps1 -rhVer $release -AppRoot "Verification" -LocalScripts "VerificationDeployHelp"
	}
	popd

	write-host -foregroundcolor GREEN "Deploy Verification code"
	pushd E:\Verification\VerificationDeployhelp
	.\Verification.deployversion.ps1 $release
	
	popd
}
trap [Exception]#CATCH
{
	throw $("ERROR during Code Deployment - : " + $_.Exception.Message)
	popd
	Exit -1
}
write-host -foregroundcolor GREEN "================================================="
write-host -foregroundcolor GREEN "=       Verification Deployment Complete       ="
write-host -foregroundcolor GREEN "=            Start Verification Tests          ="
write-host -foregroundcolor GREEN "================================================="
&{
	#TRY
	pushd E:\Verification\Deploy\Scripts
	.\RunTests.ps1 -InvokeItem $FALSE
	popd
}
trap [Exception]#CATCH
{
	throw $("ERROR during Running of Verification Tests - : " + $_.Exception.Message)
	popd
	Exit -1
}

write-host -foregroundcolor GREEN "=================================================="
write-host -foregroundcolor GREEN "=          Verification Tests Complete          ="
write-host -foregroundcolor GREEN "=================================================="

write-host -foregroundcolor GREEN "End of Verification deployment (deployVerification.ps1)"
