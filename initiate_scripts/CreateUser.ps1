param	(
			[string]$userName="RelayService",
			[string]$passWord="R3l@yH3@lth"
		)
# Function for checking if user account exists
function account-check ([string]$accountName) 
{
	$wmiuser = Get-WmiObject -class "Win32_UserAccount" -filter "name='$accountName'"
	return $wmiuser
}

# Function for creating user account
function account-create ([string]$accountName, [string]$passWord) 
{
	$wmiuser = account-check $accountName
	
	if(!$wmiuser)
	{
		# Create Account
		$comp = [adsi] "WinNT://localhost"
		$user = $comp.Create("User", $accountName)
		$user.SetPassword($passWord)
		$user.SetInfo()
		
		# Set Password Expiration
		$wmiuser = Get-WmiObject -class "Win32_UserAccount" -filter "name='$accountName'"
		$wmiuser.PasswordExpires = $false
		$wmiuser.Put()
		$wmiuser.PasswordExpires
		
		# Add to Administrators Group
		$admgrp = [ADSI]"WinNT://localhost/Administrators,group"
		$admgrp.add("WinNT://$accountName")
	}
}

# Create User Account
account-create $userName $passWord