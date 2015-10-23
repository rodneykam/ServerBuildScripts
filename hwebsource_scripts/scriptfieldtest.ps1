param ($EnvironmentPrefix)
Function GetAdmin([ref]$isAdmin)
{
$currentuser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object security.Principal.WindowsPrincipal($currentuser)
$admin = [Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin.value = $principal.IsInRole($admin)
if($isAdmin.value)
	{ Write-Host -Foregroundcolor Yellow " Current console has admin rights" }
else
	{ Write-Host -Foregroundcolor Yellow " Current console does not have admin rights" # make it red
	exit
	}
}

Function StartTranscript
{

[System.DateTime] $dateTimestamp = [System.DateTime]::Now
[string] $scriptLogFile = [string]::Format("C:\buildout_{0}_{1}_log.txt", $dateTimestamp.ToString("MMddyyyy"), $dateTimestamp.ToString("hhmmss"))
Start-Transcript -Path $scriptLogFile

}

function CopyPackage
{
	param (
		$IP,
		$User,
		$Password,
		$Source,
		$Destination)

	net use \\$IP\IPC$ "$Password" /user:"$User"

	if ($LASTEXITCODE -ne 0) 
	{
		throw "net use command failed $LASTEXITCODE"
	}

	robocopy /s /z $Source $Destination

	net use \\$IP /d

	if ($LASTEXITCODE -ne 0) 
	{
		throw "net use command failed $LASTEXITCODE"
	}
}


$configFilePath = "E:\Buildout\buildoutSetup.config"

$test = Test-Path $configFilePath
if (!$test){
Write-Host -ForegroundColor Red "Config File Does not Exist "
exit
}

$global:configParams = [xml] (gc $configFilePath) 
if ( $error ){
write-host -Foregroundcolor Yellow " Config File Corrupted `r `n $($error[0])"
exit
}

$global:configServerParams = $global:configParams.BuildoutDeployment.Environments.EnvironmentName | ?{[string]$_.name -eq $EnvironmentPrefix}
if ( !$global:configServerParams ){
write-host -Foregroundcolor Yellow " Paramater given doesnt not comply with the config `r `n $($error[0])"
exit
}

$domain = [String]$global:configServerParams.FQDN
$machine= [String]$global:configServerParams.HwebName
$mip=$global:configServerParams.MachineIp




$isAdmin = $null
GetAdmin([ref]$isAdmin)
<#StartTranscript

if (!(test-path "E:"))
{
write-host "DISK PARTITION  INITIATED"
$message +="`r`n DISK PARTITION  INITIATED`r`n$($error[0])"

@'
SELECT DISK 0
SELECT PARTITION 1
# shrink C#
SHRINK DESIRED=49152
CREATE PARTITION PRIMARY
# other options for create partition are LOGICAL|EXTENDED|MSR|ESP
ASSIGN LETTER=E
SELECT PARTITION 3
FORMAT FS=NTFS LABEL="DATA" QUICK
'@ | diskpart
write-host "DISK PARTITION  COMPLETED SUCCESFULLY"
$message +="`r`n DISK PARTITION  COMPLETED SUCCESFULLY`r`n$($error[0])"
}


if ((test-path "E:" ) -and (test-path "\\EMTLSCM01\e$\hwebsource"))
{
write-host "ROBOCOPYING FROM THE SHARE INITIATED"

CopyPackage -IP $machine.ip -User $machineUser -Password $machinePwd -Source $machine.mongoZipSource -Destination $mongoDestination

}	


	
stop-transcript#>