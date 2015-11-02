#############################################################################
##
## runBuildoutScripts
##   
## 10/2015, RelayHealth
## Tracy Hartzler
##
##############################################################################

<#
.SYNOPSIS
	This script provides a means to run a set of nested scripts or an individual script as warranted to facilitate 
	a RelayHealth production Web server buildout. These scripts are referred to as the "buildout scripts".
        
.DESCRIPTION
	This script parses an XML file, buildoutSetup.config, in order to select the approprite <machine> data 
	needed for the web server being built.
	
	This script derives parameters ($config and $machine) that are required by a majority of the buildout scripts.
	
	The user runs this script from a PowerShell command line by entering the command to run the script and 
	including the number ($scriptNumber) corresponding to the script that is desired to be run.

	Use this script to run the following:
		Option 1 - run the AllBuildScripts.ps1 script (Number 99)
		Option 2 - run individual scripts contained in the AllBuildScripts.ps1 script independently
	
	Script						Number	
	=====================================
	hostnamessingleip.ps1		(1)		
	dotnetcharge.ps1			(2)		
	stats.ps1					(3)
	permtest.ps1				(4)
	metascan.ps1				(5)		
	audit.ps1					(6)		
	wintertree.ps1				(7)		
	hiddenshares.ps1			(8)		
	Msutil.ps1					(9)		
	SetFolderPermissions.ps1	(10)	
	Initiate.ps1				(11)	
	AppFabricSetup.ps1			(12)
	registerAppCerts.ps1		(13)		
	buildoutAllScripts.ps1 		(99)

	$script is a comma-delimited list of servers to deploy to. This overrides the "CodeDeployed" flag on
	the buildoutSetup.config configuration for the server. Leave this blank to use the buildoutSetup.config 
	configuration.
	
.EXAMPLE 
	To run the complete set of buildout scripts:        
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatase -scriptNumber 99

.EXAMPLE
	To only run one of scripts from the buildout scripts list, enter the corresponding script number 1:
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase 1
#>

param (
	[string] $EnvironmentPrefix = $(throw "You must specify a environment."),
	[string] $scriptNumber = $(throw "script number missing"),
	$servers=$null,
	[switch]$noDatabase,
	[switch]$runLocal
	)
	
Write-host -ForegroundColor Green "`nStart of runBuildoutScripts`n"

# Import custom functions
Import-Module -Name .\BuildoutPackageExecuterFunctions.ps1

# Check if current console has admin rights
$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

# Change to the working directory and set config file path
$loc=get-location
$configFilePath = $loc.path +"\"+"buildoutSetup.config"
TestPath -path $configFilePath
$currentuser= [Environment]::UserName

# Load the configuration file and set the parameters we will pass to the target script
$config= XMLParser -filepath $configFilePath -nodequalifier $EnvironmentPrefix
$machines= $config.machines.machine

# Were specific target servers requested?
$Serverlist=@()

if($servers)
{
	$servers=$servers | sort -unique
	foreach($server in $servers) {
		$Serverlist+=$server
	}
}

# Make sure we have a server selected from buildoutSetup.config
# Override that server selection if $server value(s) were passed into the script 
# <codedeployed> flag will be false for the server that is being built.
$serverCount=0
if ($machines.count)
{
	# Loop through each of the machines in the configuration
	foreach ($machine in $machines)
	{
	    $Hwebname=$machine.HwebName
		write-host -ForegroundColor Yellow "Reading data for Web server $Hwebname"
		
		# If one or more server number was passed into the script, only use those servers
		if($serverlist)
	    {
			# Obtain the server number from the configuration list
			# Web server name is in the format "SJPRWEBxx.RHF.AD", e.g. "SJPRWEB12.RHF.AD"
			$machine.HwebName -match "\d+"
			$Hwebnumber=$matches[0]
			if (!($Hwebnumber)) {
				write-host -ForegroundColor Red "Cannot read server number from configuration file"
				exit
			}

			# "-contains" ignores leading zeros
			if ($serverlist -contains $Hwebnumber)
			{
				$ReadyForDeploy=$True
				$serverCount++
				write-host -ForegroundColor Yellow "Web server $Hwebname will be processed"
				write-host -ForegroundColor Yellow "Incremented Machine Count: $serverCount"		
			}
			else
			{
				$ReadyForDeploy=$False
				write-host -ForegroundColor Yellow "Web server $Hwebname will not be processed"
				}			
            }
	    # If no server number was passed into the script, determine which servers to process according to the machine configuration file
		else
	    {
			if($machine.codedeployed -match "False")
			{
				$ReadyForDeploy=$True
				write-host -ForegroundColor Yellow "Web server $Hwebname will be processed"
			}
			else
			{
				$ReadyForDeploy=$False
				write-host -ForegroundColor Yellow "Web server $Hwebname will not be processed"
			}
	    }
	
	    if($ReadyForDeploy -eq $True)
	    {	
			write-host -ForegroundColor green "You are going to execute on $Hwebname"
							
			# Run the script indicated by the script number entered in the run command
			# Currently all scripts are in "test" mode with "_test" appended to end of script name. 
			# Remove "_test" after it is known that the script works correctly.
			$ScriptList=@()
			if ($scriptNumber -eq 1  -or $scriptNumber -eq 99) {$ScriptList+="hostnamessingleip_test.ps1"}
			if ($scriptNumber -eq 2  -or $scriptNumber -eq 99) {$ScriptList+="dotnetcharge_test.ps1"}
			if ($scriptNumber -eq 3  -or $scriptNumber -eq 99) {$ScriptList+="stats_test.ps1"}
			if ($scriptNumber -eq 4  -or $scriptNumber -eq 99) {$ScriptList+="permtest_test.ps1"}
			if ($scriptNumber -eq 5  -or $scriptNumber -eq 99) {$ScriptList+="metascan_test.ps1"}
			if ($scriptNumber -eq 6  -or $scriptNumber -eq 99) {$ScriptList+="audit_test.ps1"}
			if ($scriptNumber -eq 7  -or $scriptNumber -eq 99) {$ScriptList+="wintertree_test.ps1"}
			if ($scriptNumber -eq 8  -or $scriptNumber -eq 99) {$ScriptList+="hiddenshares_test.ps1"}
			if ($scriptNumber -eq 9  -or $scriptNumber -eq 99) {$ScriptList+="Msutil_test.ps1"}
			if ($scriptNumber -eq 10 -or $scriptNumber -eq 99) {$ScriptList+="SetFolderPermissions_test.ps1"}
			if ($scriptNumber -eq 11 -or $scriptNumber -eq 99) {$ScriptList+="Initiate_test.ps1"}
			if ($scriptNumber -eq 12 -or $scriptNumber -eq 99) {$ScriptList+="AppFabricSetup_test.ps1"}
			if ($scriptNumber -eq 13 -or $scriptNumber -eq 99) {$ScriptList+="registerAppCerts_test.ps1"}
			if ($scriptNumber -eq 14 -or $scriptNumber -eq 99) {$ScriptList+="buildoutAllScripts_test.ps1"}

			if (!($ScriptList)) {
					Write-host -ForegroundColor Red "`nThe scriptNumber $scriptNumber entered does not match validation list, not running any scripts."
					exit
			}
			
			# Loop thorugh the selected scripts
			foreach ($scriptName in $ScriptList) {
				Write-host -ForegroundColor Green "`nExecuting script $scriptName"
				
				# Either run in current directory on current server, or run on remote server
				if ($runLocal) {
					Write-host -ForegroundColor Green "Executing on local server $destinationWinRMServer"
					try
					{
						Invoke-Expression -command "$scriptName -EnvironmentConfig $config -MachineConfig $machine"
						write-host "Command execution successful"
					}
					finally {}
				}
				else {
					$destinationWinRMServer = [string]::Format("{0}", $machine.HwebName)
						
					$currentexecuter= $machine.domain +"\"+"$currentuser"
					$password=SetPassword -user $currentexecuter 
					$Destination = "\\"+$machine.MachineIp+"\"+$machine.PackageDestination

					Write-host -ForegroundColor Green "Executing on remote server $destinationWinRMServer"
					$scriptBlock = { 
						param($p1,$p2) pushd C:\Hwebsource\scripts
						C:\Hwebsource\scripts\$scriptName $p1 $p2
						$argsList = $config,$machine
				}
					executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer
				}
				Write-host -ForegroundColor Green "Script execution complete for $scriptName"
			}
		}
	}	
}
Write-host -ForegroundColor Green "`nEnd of runBuildoutScripts"