Function getAdmin([ref]$isAdmin)
{
$currentuser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object security.Principal.WindowsPrincipal($currentuser)
$admin = [Security.Principal.WindowsBuiltInRole]::Administrator
$isAdmin.value = $principal.IsInRole($admin)
if($isAdmin)
	{ Write-Host -Foregroundcolor Yellow " Current console has admin rights" }
else
	{ Write-Host -Foregroundcolor Yellow " Current console does not have admin rights" # make it red
	exit
	}
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
