#  Script name:    unzip.version.ps1
#  Created on:     2010-10-18
#  Author:         
#  Purpose:        unzip Script with PowerShell.
param(
	[string]$rhVer,
	[string]$AppRoot,
	[string]$LocalScripts,
	[string]$Drive= "E:"
)

if (test-path "$env:ProgramFiles\7-Zip\7z.exe") {
	set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
}
elseif(test-path "$env:ProgramFiles (x86)\7-Zip\7z.exe"){
	set-alias sz "$env:ProgramFiles (x86)\7-Zip\7z.exe"
}
else{
		throw "$env:ProgramFiles\7-Zip\7z.exe needed"
}

switch($AppRoot)
{
    "Applications"
	{
        $AppRoot="$Drive\relayhealth\releases"
		break
	}
    "InteropApplications"
	{
        $AppRoot="$Drive\InteropApplications\releases"
		break
	}
	"CorpSite"
	{
	    $AppRoot="$Drive\CorpSite\releases"
		break
	}
}

sz x "$AppRoot\ci$rhVer.zip" "-ir!ci$rhVer\*" "-o$AppRoot" -y

switch($LocalScripts)
{
    "RelayHealthDeployHelp"
	{
	    $ScriptRoot="$Drive\relayhealth\deployhelp"
		break
	}
	"InteropApplicationsDeployHelp"
	{
	    $ScriptRoot="$Drive\interopapplications\deployhelp"
		break
	}
	"CorpSiteDeployHelp"
	{
	    $ScriptRoot="$Drive\CorpSite\deployhelp"
		break
	}
	"MetricsDeployHelp"
	{
	    $ScriptRoot="$Drive\relayhealth\Metricsdeployhelp"
		break
	}
}

sz e "$AppRoot\ci$rhVer.zip" "-ir!$LocalScripts\*.*" "-o$ScriptRoot" -y

sz e "$AppRoot\ci$rhVer.zip" "-ir!$LocalScripts\scheduleTasks\*.xml" "-o$ScriptRoot\scheduleTasks" -y

pushd  $AppRoot
Remove-Item *.zip -force
popd