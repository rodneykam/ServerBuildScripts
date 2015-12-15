param (
[string]$environment,
$Config,
$MachineConfig
)

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"
$scriptName = "SetFolderPermissions"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

if ([string]::IsNullOrEmpty($Environment) )
{
	$environment=$Config.Environment
}

if ([string]::IsNullOrEmpty($Environment) )
{
	throw New-Object System.ArgumentNullException " $Environment Environment value is Null "
}
	
$Error.Clear()


Function XMLParser
{
	param (
		$filepath= $(throw "You must specify a path.")
        	)
	
	$configParams = [xml] (gc $filepath) 
	if ( $error ){
	write-host -Foregroundcolor Yellow " Config File Corrupted `r `n $($error[0])"
	exit
	}
	

	$configServerParams = $configParams.AccessPermissions.Permission
	if ( !$configServerParams ){
	write-host -Foregroundcolor Yellow " Paramater given doesnt not comply with the config `r `n $($error[0])"
	exit
	}

	return $configServerParams

}

Function EnvironmentParser
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
	

	$configServerParams = $configParams.Environments.Environment | ?{[string]$_.name -eq $nodequalifier}
	if ( !$configServerParams ){
	write-host -Foregroundcolor Yellow " Paramater $configParams given doesnt not comply with the config `r `n $($error[0])"
	exit
	}

	return $configServerParams

}



function GetHelp() {

$HelpText = @"

DESCRIPTION:
NAME: SetFolderPermission.ps1
Sets FolderPermissions for User on a Folder.
Creates folder if not exist.

PARAMETERS: 
-Path			Folder to Create or Modify (Required)
-User			User who should have access (Required)
-Permission		Specify Permission for User, Default set to Modify (Optional)
-help			Prints the HelpFile (Optional)

SYNTAX:
./SetFolderPermission.ps1 -Path C:\Folder\NewFolder -Access Domain\UserName -Permission FullControl

Creates the folder C:\Folder\NewFolder if it doesn't exist.
Sets Full Control for Domain\UserName

./SetFolderPermission.ps1 -Path C:\Folder\NewFolder -Access Domain\UserName

Creates the folder C:\Folder\NewFolder if it doesn't exist.
Sets Modify (Default Value) for Domain\UserName

./SetFolderPermission.ps1 -help

Displays the help topic for the script

Below Are Available Values for -Permission

"@
$HelpText

[system.enum]::getnames([System.Security.AccessControl.FileSystemRights])

}

function CreateFolder ([string]$Path) {

	# Check if the folder Exists

	if (Test-Path $Path) {
		Write-Host "Folder: $Path Already Exists" -ForeGroundColor Yellow
	} else {
		Write-Host "Creating $Path" -Foregroundcolor Green
		New-Item -Path $Path -type directory | Out-Null
	}
}

function SetAcl ([string]$Path, [string]$Access, [string]$Permission) {

	# Get ACL on FOlder
	
	#$GetACL = Get-Acl $Path
	$GetACL = (Get-Item $path).GetAccessControl("Access")

	# Set up AccessRule

	$Allinherit = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$Allpropagation = [system.security.accesscontrol.PropagationFlags]"None"
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule($Access, $Permission, $AllInherit, $Allpropagation, "Allow")

	# Check if Access Already Exists

	if ($GetACL.Access | Where { $_.IdentityReference -eq $Access}) {

		Write-Host "Modifying Permissions For: $Access" -ForeGroundColor Yellow

		$AccessModification = New-Object system.security.AccessControl.AccessControlModification
		$AccessModification.value__ = 2
		$Modification = $False
		$GetACL.ModifyAccessRule($AccessModification, $AccessRule, [ref]$Modification) | Out-Null
	} else {

		Write-Host "Adding Permission: $Permission For: $Access"

		$GetACL.AddAccessRule($AccessRule)
	}

	Set-Acl -aclobject $GetACL -Path $Path

	Write-Host "Permission: $Permission Set For: $Access" -ForeGroundColor Green
}

#if ($help) { GetHelp }

$environmentconfig= EnvironmentParser -filepath "Environmentdomain.config" -nodequalifier $Environment
$environmentprefix= $environmentconfig.prefix
$environmentdomain= $environmentconfig.domain

$xml= XMLParser -filepath "AccessPermissions.config"

foreach($PermissionGroup in $xml)
{
	$Access=$PermissionGroup.OUGroup
	if (!(($access -match "Network Service") -or ($access -match "iusr")))
	{
		$Access = $environmentdomain + "\" + $environmentprefix +$Access
	}
	
	$folders=$PermissionGroup.Folders.folder
	foreach ($folder in $folders)
	{
		$foldersplit=$folder.split(",")
		$Path=$foldersplit[0]
		$Permission=$foldersplit[1]
		#Write-Host "$Path $Access $Permission "
		if ($Path -AND $Access -AND $Permission) 
		{ 
				CreateFolder $Path 
				SetAcl $Path $Access $Permission
		}
	}
}

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"

