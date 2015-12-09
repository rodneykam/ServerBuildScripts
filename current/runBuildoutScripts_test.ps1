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
	
	Script				Number	
	=====================================
	hostnamessingleip.ps1		(1)		
	dotnetcharge.ps1		(2)		
	stats.ps1			(3)
	permtest.ps1			(4)
	metascan.ps1			(5)		
	audit.ps1			(6)		
	wintertree.ps1			(7)		
	hiddenshares.ps1		(8)		
	Msutil.ps1			(9)		
	SetFolderPermissions.ps1	(10)	
	Initiate.ps1			(11)	
	AppFabricSetup.ps1		(12)
	registerAppCerts.ps1		(13)		
	run all scripts 		(99)

	$servers is a comma-delimited list of servers to deploy to. This overrides the "CodeDeployed" flag on
	the buildoutSetup.config configuration for the server. Leave this blank to use the buildoutSetup.config 
	configuration.  Use only the number portion of the servername, example for SJPRWEB34 use "-servers 34".
	
.EXAMPLE 
	To run the complete set of buildout scripts remotely from the management server:        
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase -scriptNumber 99 -servers 34

.EXAMPLE 
	To run the complete set of buildout scripts locally on the target server:         
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase -scriptNumber 99 -runLocal -servers 34
	
.EXAMPLE
	To only run one of scripts remotely from the management server, enter the corresponding script number 1:
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase 1 -servers 34
	
.EXAMPLE
	To only run one of scripts locally on the target server, enter the corresponding script number 1 and the -runLocal switch:
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase 1 -runLocal -servers 34
#>

param (
	[string] $EnvironmentPrefix = $(throw "You must specify a environment."),
	[string] $scriptNumber = $(throw "script number missing"),
	$servers=$null,
	[switch]$noDatabase,
	[switch]$runLocal
	)

$ErrorActionPreference = "Stop"
	
Write-host -ForegroundColor Yellow "`n# # # # # # # # # # Start of runBuildoutScripts # # # # # # # # # # `n"

# Import-Module that contains custom functions
#Import-Module -Name .\BuildoutPackageExecuterFunctions.ps1 -removing because we are using new name and new functions

Import-Module -Name .\BuildoutScriptsFunctions.ps1
Import-Module -Name .\PowerShellLogging\PowerShellLogging.psm1

$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$LogFileName = "$($env:computername)_" + $filedate + ".log"

$LogFile = Enable-LogFile -Path $LogFileName



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
				$ExecuteScripts=$True
				$serverCount++
				write-host -ForegroundColor Yellow "Web server $Hwebname will be processed. (path1)"
				write-host -ForegroundColor Yellow "Incremented Machine Count: $serverCount"		
			}
			else
			{
				$ExecuteScripts=$False
				write-host -ForegroundColor Yellow "Web server $Hwebname will not be processed. (path1)"
				}			
        }
	
	    if($ExecuteScripts -eq $True)
	    {	
			write-host -ForegroundColor Yellow "`nExecuting scripts on $Hwebname"
							
			# Run the script indicated by the script number entered in the run command
			$ScriptList=@()
			if ($scriptNumber -eq 1  -or $scriptNumber -eq 99) {$ScriptList+="createSharedFolders.ps1"}
			if ($scriptNumber -eq 2  -or $scriptNumber -eq 99) {$ScriptList+="createSharedFolders.ps1"}
			if ($scriptNumber -eq 3  -or $scriptNumber -eq 99) {$ScriptList+="createSharedFolders.ps1"}
						
			
			if (!($ScriptList)) {
				Write-host -ForegroundColor Red "`nThe scriptNumber $scriptNumber entered does not match validation list, not running any scripts."
				exit
			}
			
			# Loop through the selected scripts
			foreach ($scriptName in $ScriptList) {
				#Write-host -ForegroundColor Green "`nExecuting script $scriptName"
				
				# Either run in current directory on current server, or run on remote server
				if ($runLocal) {
					$computer=Get-WmiObject -Class Win32_ComputerSystem
					$name=$computer.name
					#Write-host -ForegroundColor Green "Running locally on server $name"
					try
					{
						Invoke-Expression -command ".\$scriptName -EnvironmentConfig $config -MachineConfig $machine"
						write-host "Command execution successful"
					}
					finally {}
				}
				else {
					$destinationServer = [string]::Format("{0}", $machine.HwebName)
						
					$currentexecuter= $machine.domain +"\"+"$currentuser"
					$password=SetPassword -user $currentexecuter 
										
					Write-host -ForegroundColor Green "Executing on remote server $destinationWinRMServer"
					$argsList = $config,$machine
					executeScriptFileInRemoteSession -filePath $scriptName -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationServer
				}
				Write-host -ForegroundColor Yellow "Script execution complete for $scriptName"
			}			
		}
	}	
}
Write-host -ForegroundColor Yellow "`n# # # # # # # # # # End of runBuildoutScripts # # # # # # # # # # `n"