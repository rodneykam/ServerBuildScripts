#Delete Old Surescripts Account (RelayHealth)
$computer = [ADSI]"WinNT://."
$computer.Delete("user", "SureScripts")
 
#Create New Account (SureScripts), add desciption and set password
$computer = [ADSI]"WinNT://."
 $user = $computer.Create("User", "SureScripts")
 $user.setpassword("uUj34X799")
 $user.put("description","Local Account Used for Surescripts Authentication") 
 $user.SetInfo()
 
#Add to Users
net localgroup users /add Surescripts
