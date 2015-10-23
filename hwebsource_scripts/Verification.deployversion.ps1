param(
	[string]$releaseNum,
	[string]$Drive = "E:",
	[int]$depMode = 1
)

$LocalScriptPath = "$Drive\Verification\VerificationDeployHelp"

$AppDeploy = "$Drive\Verification\deploy"
$TargetDir = "$Drive\Verification\releases\ci$releaseNum"
if(Test-Path($AppDeploy)){
	#Remove the junction point
	cmd /c "rd $AppDeploy"
}
write-host "Started Junction..." -foregroundcolor green
cmd /c "mklink /J $AppDeploy $TargetDir"
if ( $LASTEXITCODE -ne 0) {throw "mklink command failed $LASTEXITCODE"}
write-host "Completed Junction." -foregroundcolor green

pushd $AppDeploy

cd RelayHealth.Verification.Clinical.Features
$command = ".\ConfigTemplate\generateconfig.cmd .\ ."
Invoke-Expression $command
copy-item app.config RelayHealth.Verification.Clinical.Features.dll.config
popd