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

	robocopy /s /z $Source $Destination

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
