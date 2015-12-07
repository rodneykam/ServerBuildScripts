#####################################################################################
# Create a network share and grant Everyone Full Control.  
# Does not modify NTFS permissions.
# Jan, 2012 N.Johnson
#####################################################################################

<#
.SYNOPSIS
	This script creates the required shared folders on the server
	
.DESCRIPTION

    The following hidden shares are created by this script
    Name                  Path
	InteropShuntedEmails$ E:\RelayHealth\InteropShuntedEmails
    ShuntedFaxes$         E:\RelayHealth\ShuntedFaxes"),
    ShuntedEmails$        E:\RelayHealth\ShuntedEmails"),
    Logs$                 E:\RelayHealth\Logs")
	
	
.EXAMPLE 

#>

param
(
	# Configuration XML parameters are not used by this script
	$EnvironmentConfig=$null,
	$MachineConfig=$null
)

#####################################################################################
# Functions
#####################################################################################

Function New-ACE (
	[string] $Name = (throw "Please provide user/group name for trustee"),
	[string] $Domain = (throw "Please provide Domain name for trustee"),
	[string] $Permission = "Read",
	[string] $ComputerName = ".",
	[switch] $Group = $false)
{
	#Create the Trusteee Object
	$Trustee = ([WMIClass] "\\$ComputerName\root\cimv2:Win32_Trustee").CreateInstance()
	#Check for Special cases Everyone and Authenticated Users)
	switch ($Name.ToUpper()) {
		"EVERYONE" {
			$Trustee.Domain = $Null
			$Trustee.Name = "EVERYONE"
			$Trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0)
		}
		"AUTHENTICATED USERS" {
			$Trustee.Domain = "NT AUTHORITY"
			$Trustee.Name = "Authenticated Users"
			$Trustee.SID = @(1, 1, 0, 0, 0, 0, 0, 5, 11, 0, 0, 0)
		}
		default {
			#Search for the user or group, depending on the -Group switch
			if (!$group)
			{ $account = [WMI] "\\$ComputerName\root\cimv2:Win32_Account.Name='$Name',Domain='$Domain'" }
			else
			{ $account = [WMI] "\\$ComputerName\root\cimv2:Win32_Group.Name='$Name',Domain='$Domain'" }
			#Get the SID for the found account.
			$accountSID = [WMI] "\\$ComputerName\root\cimv2:Win32_SID.SID='$($account.sid)'"
			#Setup Trusteee object
			$Trustee.Domain = $Domain
			$Trustee.Name = $Name
			$Trustee.SID = $accountSID.BinaryRepresentation
		}
	}
	#Create ACE (Access Control List) object.
	$ACE = ([WMIClass] "\\$ComputerName\root\cimv2:Win32_ACE").CreateInstance()
	#Select the AccessMask depending on the -Permission parameter
	switch ($Permission)
	{
		"Read" { $ACE.AccessMask = 1179817 }
		"Change" { $ACE.AccessMask = 1245631 }
		"Full" { $ACE.AccessMask = 2032127 }
		default { throw "$Permission is not a supported permission value. Possible values are 'Read','Change','Full'" }
	}
	#Setup the rest of the ACE.
	$ACE.AceFlags = 3
	$ACE.AceType = 0
	$ACE.Trustee = $Trustee
	#Return the ACE
	return $ACE
}

Function New-SecurityDescriptor (
	$ACEs = (throw "Missing one or more Trustees"),
	[string] $ComputerName = ".")
{
	#Create SeCDesc object
	$SecDesc = ([WMIClass] "\\$ComputerName\root\cimv2:Win32_SecurityDescriptor").CreateInstance()
	#Check if input is an array or not.
	if ($ACEs -is [System.Array])
	{
		#Add Each ACE from the ACE array
		foreach ($ACE in $ACEs )
		{
			$SecDesc.DACL += $ACE.psobject.baseobject
		}
	}
	else
	{
		#Add the ACE
		$SecDesc.DACL = $ACEs
	}
	#Return the security Descriptor
	return $SecDesc
}

Function New-Share (
	[string] $FolderPath = (throw "Please provide the share folder path (FolderPath)"),
	[string] $ShareName = (throw "Please provide the Share Name"),
	$ACEs,
	[string] $Description = "",
	[string] $ComputerName = ".",
	$MaxUsers = $null,
	$Password = $null)
{
	#Start the Text for the message.
	$text = "$ShareName ($FolderPath): "
	#Package the SecurityDescriptor via the New-SecurityDescriptor Function.
	$SecDesc = New-SecurityDescriptor $ACEs
	#Check for existing share
	$checkShare = (Get-WmiObject Win32_Share -Filter "Name='$ShareName'")
	if ($checkShare -ne $null) {
		# Write-Host $ShareName "already exists.  It will now be deteted!!!"
		$out = (get-WmiObject Win32_Share -Filter "Name='$ShareName'" | foreach-object { $_.Delete() })
	}

	#Create the share via WMI, get the return code and create the return message.
	$Share = [WMICLASS] "\\$ComputerName\Root\Cimv2:Win32_Share"
	$result = $Share.Create($FolderPath, $ShareName, 0, $MaxUsers, $Description, $Password, $SecDesc)
	switch ($result.ReturnValue)
	{
		0 {$text += "has been success fully created" }
		2 {$text += "Error 2: Access Denied" }
		8 {$text += "Error 8: Unknown Failure" }
		9 {$text += "Error 9: Invalid Name"}
		10 {$text += "Error 10: Invalid Level" }
		21 {$text += "Error 21: Invalid Parameter" }
		22 {$text += "Error 22 : Duplicate Share"}
		23 {$text += "Error 23: Redirected Path" }
		24 {$text += "Error 24: Unknown Device or Directory" }
		25 {$text += "Error 25: Net Name Not Found" }
	}
	#Create Custom return object and Add results
	$return = New-Object System.Object
	$return | Add-Member -type NoteProperty -name ReturnCode -value $result.ReturnValue
	$return | Add-Member -type NoteProperty -name Message -value $text
	#Return result object
	$return
}

#####################################################################################
# Main
#####################################################################################
Write-host -ForegroundColor Green "`nStart Script - createSharedFolders`n"

$shares = @(
("InteropShuntedEmails$", "E:\RelayHealth\InteropShuntedEmails"),
("ShuntedFaxes$", "E:\RelayHealth\ShuntedFaxes"),
("ShuntedEmails$", "E:\RelayHealth\ShuntedEmails"),
("Logs$", "E:\RelayHealth\Logs")
)

$server = $env:computername
#Create Share Permission
$ACE = @(New-ACE -Name "Everyone" -Domain "NT AUTHORITY" -Permission "Full" -Group)
foreach ($share in $shares) {
    $ShareName = $share[0]
    $FolderPath = $share[1]
    
    #Create the share
    $result = New-Share -FolderPath $FolderPath -ShareName $ShareName -ACEs $ACE -Description $ShareName -Computer $env:computername 
    #Output result message from new-share
    Write-Output $result.Message
}

Write-host -ForegroundColor Green "`nStart Script - createSharedFolders`n"
