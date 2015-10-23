#  Script name:    unzip.version.ps1
#  Created on:     2010-10-18
#  Author:         
#  Purpose:        unzip Script with PowerShell.
param(
    [string]$rhVer,
    [string]$AppRoot,
    [string]$LocalScripts,
    [string]$Drive= "E:",
	[switch]$savezip = $false
)

if (test-path "$env:ProgramFiles\7-Zip\7z.exe") {
    set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"
}
elseif (test-path "$env:ProgramFiles (x86)\7-Zip\7z.exe") {
    set-alias sz "$env:ProgramFiles (x86)\7-Zip\7z.exe"
}
else {
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
    "HydroPlatform"
    {
        $AppRoot="$Drive\HydroPlatform\releases"
        break
    }
    "Verification"
    {
        $AppRoot="$Drive\Verification\releases"
        break
    }
}

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
    "DirectMessagingDeployHelp"
    {
        $ScriptRoot="$Drive\relayhealth\DirectMessagingDeployHelp"
        break
    }
    "HydroPlatformDeployHelp"
    {
        $ScriptRoot="$Drive\HydroPlatform\HydroPlatformDeployHelp"
        break
    }
	"VerificationDeployHelp"
    {
        $ScriptRoot="$Drive\Verification\VerificationDeployHelp"
        break
    }
}
$Zipstatus =0

$FileWasAlreadyUnzipped = $false

if (test-path "$scriptroot\ReleaseInfo\UnzipInfo.log")
{
    $zipstatusfile =get-content "$scriptroot\ReleaseInfo\UnzipInfo.log" 
    foreach ($logline in $zipstatusfile)
    {
        if($logline -match "ci$rhver.zip Success")
        {    
            $FileWasAlreadyUnzipped = $true
        }    
    }
}

if ($FileWasAlreadyUnzipped -eq $false)
{
    sz x "$AppRoot\ci$rhVer.zip" "-ir!ci$rhVer\*" "-o$AppRoot" -y

    if (!($lastexitcode -eq 0))
    {
        $Zipstatus = 1
    }
}

if ($FileWasAlreadyUnzipped -eq $false)
{
    sz e "$AppRoot\ci$rhVer.zip" "-ir!$LocalScripts\*.*" "-o$ScriptRoot" -y

    if (!($lastexitcode -eq 0))
    {
        $Zipstatus = 1
    }
}

if ($FileWasAlreadyUnzipped -eq $false)
{
    sz e "$AppRoot\ci$rhVer.zip" "-ir!$LocalScripts\scheduleTasks\*.xml" "-o$ScriptRoot\scheduleTasks" -y
    if (!($lastexitcode -eq 0))
    {
        $Zipstatus = 1
    }
}

$date = get-date
if($Zipstatus -eq 0)
{
    if( !(test-path "$scriptroot\ReleaseInfo\UnzipInfo.log"))
    {
        New-Item -Path "$scriptroot\ReleaseInfo\UnzipInfo.log" -ItemType file    
    }
    
    add-content "$scriptroot\ReleaseInfo\UnzipInfo.log" "ci$rhver.zip Success $date file was already unzipped $FileWasAlreadyUnzipped"
    if($savezip -eq $false)
	{
		#Only Remove the zip if unzip was successful
		pushd  $AppRoot
		Remove-Item *.zip -force
		popd
	}
}
else
{
    if (!(test-path "$scriptroot\ReleaseInfo\UnzipInfo.log"))
    {
        New-Item -Path "$scriptroot\ReleaseInfo\UnzipInfo.log" -ItemType file    
    }
    add-content "$scriptroot\ReleaseInfo\UnzipInfo.log" "ci$rhver.zip Fail $date"
}