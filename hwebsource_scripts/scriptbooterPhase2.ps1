Import-Module -Name .\ScriptBooterFunctions.ps1

$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

		
		
if (test-path "c:\hwebsource ")
{
	pushd c:\hwebsource\scripts
	reg import c:\hwebsource\scripts\License_64bit_Relay Health_2-27-2014_ALL.reg
}
		
sleep 10

if (test-path "c:\hwebsource ")
{
	pushd c:\hwebsource\scripts 
		 
	./AppFabricSetup.ps1 
}
		
sleep 10

if (test-path "c:\hwebsource ")
{
			 
	pushd C:\hwebsource\initiate

	./unattended.cmd
 
	popd

	sleep 10

	pushd E:\mpi\project\initiate\scripts

	./initiatesetup.ps1 

	sleep 10

	./installpassive.bat

	popd
}
		
		
	
	
