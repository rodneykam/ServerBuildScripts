Function GetAdmin([ref]$isAdmin)
{
	$currentuser = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object security.Principal.WindowsPrincipal($currentuser)
	$admin = [Security.Principal.WindowsBuiltInRole]::Administrator
	$isAdmin.value = $principal.IsInRole($admin)
	if($isAdmin.value)
		{ Write-Host -Foregroundcolor Yellow "From BuildoutScriptsFunctions - Current console has admin rights `n" } 
	else
		{ Write-Host -Foregroundcolor Red "GetAdmin function - Current console does not have admin rights. `n" 
		exit
		}
}

Function StartTranscript
{

	[System.DateTime] $dateTimestamp = [System.DateTime]::Now
	[string] $scriptLogFile = [string]::Format("C:\buildout_{0}_{1}_log.txt", $dateTimestamp.ToString("MMddyyyy"), $dateTimestamp.ToString("hhmmss"))
	Start-Transcript -Path $scriptLogFile

}

Function CopyPackage
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

	robocopy /E /z $Source $Destination

	net use \\$IP /d

	if ($LASTEXITCODE -ne 0) 
	{
		throw "net use command failed $LASTEXITCODE"
	}
}

Function TestPath
{
	param ($path = $(throw "You must specify a path.") )
	
	if(test-path $path)
	{
		write-host "$Path Exits"
	}
	else
	{
		throw (" Folder Location $Path doesnot exist")
	}
}

Function XMLParser
{
	param (
		$filepath= $(throw "You must specify a path."),
		$nodequalifier= $(throw "You must specify a xmltag in order to process the xml.")
        	)
	
	$configParams = [xml] (gc $filepath) 
	if ( $error ){
	write-host -Foregroundcolor Yellow " Config File Corrupted `r `n $($error[0])"
	exit
	}
	

	$configServerParams = $configParams.BuildoutDeployment.Environments.EnvironmentPrefix | ?{[string]$_.name -eq $nodequalifier}
	if ( !$configServerParams ){
	write-host -Foregroundcolor Yellow " Paramater given doesnt not comply with the config `r `n $($error[0])"
	exit
	}

	return $configServerParams

}

Function SetPassword
{
	param( $user= $(throw "You must specify a login") )
	
	$machineUser = $user
	$machineCreds = Get-Credential -Credential $machineUser
	$secureMachinePwdStr = $machineCreds.password 
	$ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($secureMachinePwdStr)
	$machinePwd = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($ptr)
	[System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($ptr)
	
	return $machinePwd	
}

function executeScriptInRemoteSession($scriptBlock, $argsList, $deployLoginame, $deployUserPassword, $serverFQDN)
{
	$passWord = ConvertTo-SecureString $deployUserPassword -Force -AsPlainText 
	$mycreds = New-Object System.Management.Automation.PSCredential ($deployLoginame, $passWord)			
	$skipRev = New-PsSessionOption -SkipRevocationCheck
	
	#$session = new-pssession -computername $serverFQDN -credential $mycreds -Port 5985 -sessionOption $skipRev

	$session = new-pssession -computername $serverFQDN -credential $mycreds -Port 5986 -useSSL -sessionOption $skipRev

	write-host "Remote session successfully opened"
	
	try
	{
		Invoke-Command -session $session -scriptblock $scriptBlock -argumentList $argsList
		write-host "Command execution successful"
	}
	finally
	{
		write-host "Stopping the remote session"
		Remove-PSSession $session
	}
}

function executeScriptFileInRemoteSession( $filePath, $argsList, $deployLoginame, $deployUserPassword, $serverFQDN)
{
	$passWord = ConvertTo-SecureString $deployUserPassword -Force -AsPlainText 
	$mycreds = New-Object System.Management.Automation.PSCredential ($deployLoginame, $passWord)
	$skipRev = New-PsSessionOption -SkipRevocationCheck

	$session = new-pssession -computername $serverFQDN -credential $mycreds -Port 5986 -useSSL -sessionOption $skipRev

	write-host "Remote session successfully opened"
	
	try
	{
		Invoke-Command -session $session -filePath $filePath -argumentList $argsList
		write-host "Command execution successful"
	}
	finally
	{
		write-host "Stopping the remote session"
		Remove-PSSession $session
	}	
}

