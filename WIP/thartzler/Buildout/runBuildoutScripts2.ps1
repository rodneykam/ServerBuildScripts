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
	
.EXAMPLE 
	To run the complete set of buildout scripts:        
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatase 99

.EXAMPLE
	To only run one of scripts from the buildout scripts list, enter the corresponding script number 1:
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase 1
#>


param (
	[string] $EnvironmentPrefix = $(throw "You must specify a environment."),
	[string] $scriptNumber = $(throw "script number missing"),
	$servers=$null,
	[switch]$noDatabase
	)



# Set file date for time stamping log file and starting the log file transcript
$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
start-transcript "F:\SCM\Buildout\BuildoutLogs\runBuildoutScripts2 $filedate.log"
write-host -foreground Green "`n# # # # # # # # # # # # # # # Entering runBuildoutSrcript2 script. # # # # # # # # # # # # # # # `n"

# Import-Module that contains custom functions
Import-Module -Name .\BuildoutScriptsFunctions.ps1

# Check if current console has admin rights
$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

# Change to the working directory and set config file path
$loc=get-location
$configFilePath = $loc.path +"\"+"buildoutSetup.config"
TestPath  -path $configFilePath
$currentuser= [Environment]::UserName

# Load the configuration file and set the parameters we will pass to the target script
$config= XMLParser -filepath $configFilePath -nodequalifier $EnvironmentPrefix
$machines= $config.machines.machine

# Check if there are more than one target servers
$servers=$servers |sort -unique
$Serverlist=@()
if($servers)
{
	foreach($server in $servers)
	{
		if (!(($server -ge 0) -and ($server -le $machines.count)))
		{
			write-host -foregroundcolor Yellow "The $server input is not correct. Here is what you entered $servers"
			exit
		}
		else
		{
			$Serverlist+=$server
		}

	}
	$count=0
}

# Make sure we have a server selected from buildoutSetup.config
# Look for the target server in the configuration file.
# <codedeployed> flag will be false for the server that is being built.

if ($machines.count)
{
	foreach ($machine in $machines)
	{
	    if($serverlist)
	    {
			$Hwebnumber=((([int](((($machine.HwebName).split("."))[0])[-2]))-48)*10)+((([int](((($machine.HwebName).split("."))[0])[-1]))-48))
			if ($Hwebnumber -eq $serverlist[$count])
			{
				$ReadyForDeploy=$True
				$count++
				write-host -ForegroundColor Yellow "Incremented Machine Count: $count"
			}
			else
			{
				$ReadyForDeploy=$False
			}			
        }
	    else
	    {
			if($machine.codedeployed -match "False")
			{
				$ReadyForDeploy=$True
			}
			else
			{
				$ReadyForDeploy=$False
			}
	    }
	
		write-host -ForegroundColor Green "`nBuildout script - Getting machine data. `n"	

	    if($ReadyForDeploy -eq $True)
	    {	
		$HwebName=$machine.HwebName
		write-host -ForegroundColor green "Buildout script - You are going to execute on $HwebName"
		$destinationWinRMServer = [string]::Format("{0}", $machine.HwebName)
			
		$currentexecuter= $machine.domain +"\"+"$currentuser"
		if(!($password))
		{
		    $password=SetPassword -user $currentexecuter 
		}
		$Destination = "\\"+$machine.MachineIp+"\"+$machine.PackageDestination
		
		#write-host -ForegroundColor Red "Buildout script debug 4"
		
			
		# Run the script indicated by the script number entered in the run command
		if ($nodatabase)
		{
			if ($scriptNumber -eq 99)
			{       
				Write-host -ForegroundColor Green "`nBuildout script - scriptNumber = 99, Running buildoutAllScripts_test.ps1 script. `n"
				 $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
				 C:\Hwebsource\scripts\buildoutAllScripts_test.ps1 $p1 $p2
				 }
			     $argsList = $config,$machine
			     executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer			      
			}
			elseif ($scriptNumber -eq 1)
			{       
				Write-host -ForegroundColor Green "`nBuildout script - scriptNumber = 1, Running permtest_test script. `n"
				 $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
				 C:\Hwebsource\scripts\permtest_test.ps1 $p1 $p2
				 }
			     $argsList = $config,$machine
			     executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer			      
			}
			elseif ($scriptNumber -eq 2)
			{
				Write-host -ForegroundColor Green "`nBuildout script - scriptNumber = 2, Running registerAppCerts_test.ps1 script. `n"
				 $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
				 C:\Hwebsource\scripts\registerAppCerts_test.ps1 $p1 $p2
				 }
				 $argsList = $config,$machine
			     executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer			      
   			}
			else
			{
				Write-host -ForegroundColor Red "`n Buildout script - The scriptNumber entered does not match validation list, not running any scripts."
			}
		  
		}
		
	     }

	}	
}
Write-host -ForegroundColor Green "`n# # # # # # # # # # # # # # # End of runBuildoutScripts # # # # # # # # # # # # # # # `n"
Stop-Transcript 