
function SetAcl ([string]$Path, [string]$FileSystemRights, [string]$AccessControlType, [string]$IdentityReference) {

	# Get ACL on FOlder
	
	#$GetACL = Get-Acl $Path
	$GetACL = (Get-Item $path).GetAccessControl("Access")

	# Set up AccessRule
	$InheritanceFlags = [system.security.accesscontrol.InheritanceFlags]"ContainerInherit, ObjectInherit"
	$PropagationFlags = [system.security.accesscontrol.PropagationFlags]"None"
	$AccessRule = New-Object system.security.AccessControl.FileSystemAccessRule($IdentityReference, $FileSystemRights, $InheritanceFlags, $PropagationFlags, $AccessControlType)

	# Check if Access Already Exists

	if ($GetACL.Access | Where { $_.IdentityReference -eq $IdentityReference}) {

		Write-Host "Modifying Permissions For: $IdentityReference" -ForeGroundColor Yellow

		$AccessModification = New-Object system.security.AccessControl.AccessControlModification
		$AccessModification.value__ = 2
		$Modification = $False
		$GetACL.ModifyAccessRule($AccessModification, $AccessRule, [ref]$Modification) | Out-Null
	} else {
		$GetACL.AddAccessRule($AccessRule)
	}

	Set-Acl -aclobject $GetACL -Path $Path 

	Write-Host "Permission:" $AccessRule.FileSystemRights "Set on:" $Path "to:" $AccessRule.IdentityReference -ForeGroundColor Green
}


$serverName = hostname
$serviceAccountName = "RHF\" + $serverName + "SERV"
$serviceBIDW = "RHF\" + $serverName + "BIDW"

$users = @("IIS APPPOOL\DefaultAppPool", "NT AUTHORITY\NETWORK SERVICE", $serviceAccountName, $serviceBIDW)

foreach ($user in $users)
{
SetAcl -Path "e:\Panorama\hedzup\mn\bin" -FileSystemRights "ReadAndExecute" -AccessControlType "Allow" -IdentityReference $user
SetAcl -Path "e:\Panorama\hedzup\mn\data" -FileSystemRights "Modify" -AccessControlType "Allow" -IdentityReference $user
SetAcl -Path "e:\Panorama\hedzup\mn\log" -FileSystemRights "Modify" -AccessControlType "Allow" -IdentityReference $user
SetAcl -Path "e:\Panorama\hedzup\mn\userdata" -FileSystemRights "Modify" -AccessControlType "Allow" -IdentityReference $user
}