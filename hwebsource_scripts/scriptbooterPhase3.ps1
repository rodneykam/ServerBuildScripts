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
			
			if($noDatabase)
			{	
			./deploy.ps1 -environmentconfig $config -machineconfig $MachineConfig -noDatabase
			
			
			}
			else
			{
			./deploy.ps1 -environmentconfig $config -machineconfig $MachineConfig 
			}
		
		
		}
		sleep 10
			
		
		#gpupdate /force
		<#	
		if (test-path "c:\hwebsource ")
		{
			pushd c:\hwebsource\scripts 
			 
			#./AddCacheHost.ps1 -NewCacheCluster -database_name $config.AppFabricDatabase -database_server $config.InitiateDatabase
			
			pushd E:\RelayHealth\Deployhelp
			
			#./DeployWindowsServerAppFabric.ps1
			
			
		}#>
			
			
		if (test-path "c:\hwebsource ")
		{
			pushd c:\hwebsource\scripts 
			 
			./Msutil.ps1 -config $config -machineconfig $MachineConfig
		}
		
		sleep 10
		if (test-path "c:\hwebsource ")
		{
			pushd c:\hwebsource\scripts 
			 
			./SetFolderPermissions.ps1 -config $config -machineconfig $MachineConfig
		}
		
		sleep 10
		if (test-path "c:\hwebsource ")
		{
			 pushd c:\hwebsource\scripts 
			 
			  ./initiate.ps1 -environmentconfig $config -machineconfig $MachineConfig
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
			 pushd c:\hwebsource\scripts 
			 
			./hv.ps1 -environmentconfig $config -machineconfig $MachineConfig
		}
		#gpupdate /force
		if (test-path "E:\RelayHealth\Deployhelp")
		{
			 pushd E:\RelayHealth\Deployhelp
			 
			# ./SCMTestFramework.ps1
		}
		
	
	
