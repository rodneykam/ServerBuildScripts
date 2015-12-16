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
		Option 1 - run all buildout scripts (input $scriptNumber 99)
		Option 2 - run individual scripts independently (input $scriptNumber other than 99)
	
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
	[String][parameter(Mandatory=$true)][ValidateSet("Prod")] $EnvironmentPrefix,
	[String][parameter(Mandatory=$true)] $scriptNumber,
	[String][parameter(Mandatory=$true)]$servers=$null,
	[switch]$noDatabase,
	[switch]$runLocal,
	[switch] $remove  #added for configureWinRM script
	)
	
$ErrorActionPreference = "Stop"
	
Write-host -ForegroundColor Magenta "`n# # # # # # # # # # Start of runBuildoutScripts # # # # # # # # # # `n"

# Import-Module that contains custom functions
#Import-Module -Name .\BuildoutPackageExecuterFunctions.ps1 -removing because we are using new name and new functions

Import-Module -Name .\BuildoutScriptsFunctions.ps1
Import-Module -Name .\PowerShellLogging\PowerShellLogging.psm1

$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$LogFileName = "$($env:computername)_" + $filedate + ".log"

$LogFile = Enable-LogFile -Path .\BuildoutLogs\$LogFileName

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

# Server selection $server value(s) is passed into the script 
# <codedeployed> flag is no longer being used, however we still need machine info from the config file.
$serverCount=0
if ($machines.count) {
	# Loop through each of the machines in the configuration
	foreach ($machine in $machines) {
		$Hwebname=$machine.HwebName
		write-host -ForegroundColor Magenta "Reading data for Web server $Hwebname"
		
		# If one or more server number was passed into the script, only use those servers
		if($serverlist) {
			# Obtain the server number from the configuration list
			# Web server name is in the format "SJPRWEBxx.RHF.AD", e.g. "SJPRWEB12.RHF.AD"
			$machine.HwebName -match "\d+"
			$Hwebnumber=$matches[0]
			
			if (!($Hwebnumber)) {
			    write-host -ForegroundColor Red "Cannot read server number from configuration file"
			    exit
			}

			# "-contains" ignores leading zeros
			if ($serverlist -contains $Hwebnumber) {
			    $ExecuteScripts=$True
			    $serverCount++
			    write-host -ForegroundColor Magenta "Web server $Hwebname will be processed."
			    write-host -ForegroundColor Magenta "Incremented Machine Count: $serverCount"		
			}
			else {
			    $ExecuteScripts=$False
			    write-host -ForegroundColor Magenta "Web server $Hwebname will not be processed."
			}			
		}
	
	    if($ExecuteScripts -eq $True) {	
			# Run the script indicated by the $scriptNumber entered in the run command
			write-host -ForegroundColor Magenta "`nExecuting scripts on $Hwebname" 
			
			$ScriptList=@()
			if ($scriptNumber -eq 1 -or $scriptNumber -eq 99) {$ScriptList+="configureWinRM.ps1"}
			if ($scriptNumber -eq 2 -or $scriptNumber -eq 99) {$ScriptList+="GetDTD.ps1"}
			if ($scriptNumber -eq 3 -or $scriptNumber -eq 99) {$ScriptList+="addHostnamesSingleIP.ps1"}
			if ($scriptNumber -eq 4 -or $scriptNumber -eq 99) {$ScriptList+="registerUrls.ps1"}
			if ($scriptNumber -eq 5 -or $scriptNumber -eq 99) {$ScriptList+="setMetascanPermissions.ps1"}
			if ($scriptNumber -eq 6 -or $scriptNumber -eq 99) {$ScriptList+="registerAppCert.ps1"}
			if ($scriptNumber -eq 7 -or $scriptNumber -eq 99) {$ScriptList+="createPushCenterAgentTask.ps1"}
			if ($scriptNumber -eq 8 -or $scriptNumber -eq 99) {$ScriptList+="ConfigureInitiate.ps1"}
			
		# Additional scripts that may not end up in the final list 
			#if ($scriptNumber -eq 13 -or $scriptNumber -eq 99) {$ScriptList+="SetSslRenegotiationFlag.ps1"}
			#if ($scriptNumber -eq 9 -or $scriptNumber -eq 99) {$ScriptList+="SetFolderPermissions.ps1"}
			#if ($scriptNumber -eq 7 -or $scriptNumber -eq 99) {$ScriptList+="createSharedFolders.ps1"}
		    
			if (!($ScriptList)) {
			    Write-host -ForegroundColor Red "`nThe scriptNumber $scriptNumber entered does not match validation list, not running any scripts."
			    exit
		    }
			
			# get user/password via credentials popup
			$destinationServer = [string]::Format("{0}", $machine.HwebName)
			$currentexecuter= $machine.domain +"\"+"$currentuser"
			$password=SetPassword -user $currentexecuter 
			
		    # Loop through the selected scripts
		    foreach ($scriptName in $ScriptList) {
		    	#Write-host -ForegroundColor Green "`nExecuting script $scriptName"
				
			    # Either run in current directory on current server, or run on remote server
			    if ($runLocal) {
			    	$computer=Get-WmiObject -Class Win32_ComputerSystem
				    $name=$computer.name
				    Write-host -ForegroundColor Magenta "Running locally on server $name"
				    try 
					{
					    Invoke-Expression -command ".\$scriptName -EnvironmentConfig $config -MachineConfig $machine"
					    write-host "Command execution successful"
				    }
					finally {}
			    }
				else {
					Write-host -ForegroundColor Magenta "Executing on remote server $destinationServer"
					$argsList = $config,$machine
					executeScriptFileInRemoteSession -filePath $scriptName -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationServer
				}
				Write-host -ForegroundColor Magenta "Script execution complete for $scriptName"
		}			
	    }
	}	
}
Write-host -ForegroundColor Magenta "`n# # # # # # # # # # End of runBuildoutScripts # # # # # # # # # # `n"