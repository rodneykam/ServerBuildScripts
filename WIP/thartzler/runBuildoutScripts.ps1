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
Option 1 - run the AllBuildScripts.ps1 script 
Option 2 - run individual scripts contained in the AllBuildScripts.ps1 script independently

.PARAMETERS

$EnvironmentPrefix  (INTE, STAG, DEMO, PROD)
$scriptNumber		(see BUILDOUT SCRIPTS list)
$servers
$noDatabase
	
.BUILDOUT SCRIPTS

Script					Number	Purpose
==================================================================================
script1					(1)		purpose of script 1		
next					(2)		purpose of script 2		
next					(3)		purpose of script 3	
next					(4)		purpose of script 4	
next					(5)		purpose of script 5		
next					(6)		purpose of script 6			
next					(7)		purpose of script 7		
next					(8)		purpose of script 8		
next					(9)		purpose of script 9		
next					(10)	purpose of script 10			
next					(11)	purpose of script 11		
next					(12)	purpose of script 12			
buildoutAllScripts.ps1 	(99)	Runs the complete set of buildout scripts
	
.EXAMPLE 1 
To run the complete set of buildout scripts:        
	runBuildoutScripts.ps1 -EnvironmentPrefix -noDatabase -scriptNumber 
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatase 99    

.EXAMPLE 2
To only run the script corresponding to script number 1:        
	runBuildoutScripts.ps1 -EnvironmentPrefix -noDatabase -scriptNumber 
	runBuildoutScripts.ps1 -EnvironmentPrefix Prod -noDatabase 1   

#>


param (
	[string] $EnvironmentPrefix = $(throw "You must specify a environment."),
	[string] $scriptNumber = $(throw "script number missing"),
	$servers=$null,
	[switch]$noDatabase
	)

# Import-Module that contains custom functions
    
    Import-Module -Name .\BuildoutPackageExecuterFunctions.ps1

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
				write-host -ForegroundColor Red "Buildout script debug 1"
			}			
            }
	    else
	    {
			if($machine.codedeployed -match "False")
			{
				$ReadyForDeploy=$True
				write-host -ForegroundColor Red "Buildout script debug 2"				
			}
			else
			{
				$ReadyForDeploy=$False
				write-host -ForegroundColor Red "Buildout script debug 3"
			}
	    }
	
		write-host -ForegroundColor yellow "Working on ready for deploy = true."	

	    if($ReadyForDeploy -eq $True)
	    {	
		$HwebName=$machine.HwebName
		write-host -ForegroundColor green "You are going to execute on $HwebName"
		$destinationWinRMServer = [string]::Format("{0}", $machine.HwebName)
			
		$currentexecuter= $machine.domain +"\"+"$currentuser"
		if(!($password))
		{
		    $password=SetPassword -user $currentexecuter 
		}
		$Destination = "\\"+$machine.MachineIp+"\"+$machine.PackageDestination
		
		write-host -ForegroundColor Red "Buildout script debug 4"
		
			
		# Run the script indicated by the script number entered in the run command
		if ($nodatabase)
		{
			if ($scriptNumber -eq 99)
			{       
				Write-host -ForegroundColor Green "`nscriptNumber = 99, Running buildoutAllScripts_test.ps1"
				 $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
				 #C:\Hwebsource\scripts\buildoutAllScripts_test.ps1 -config $p1 -MachineConfig $p2 -noDatabase
				 #C:\Hwebsource\scripts\buildoutAllScripts_test.ps1 $p1 $p2 -noDatabase
				 C:\Hwebsource\scripts\buildoutAllScripts_test.ps1 $p1 $p2
				 }
			     $argsList = $config,$machine
			     executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer			      
			}
			elseif ($scriptNumber -eq 1)
			{       
				Write-host -ForegroundColor Green "`nscriptNumber = 1, Running permtest_mod.ps1"
				 $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
				 C:\Hwebsource\scripts\permtest_mod.ps1 $p1 $p2
				 }
			     $argsList = $config,$machine
			     executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer			      
			}
			elseif ($scriptNumber -eq 2)
			{
				Write-host -ForegroundColor Green "`nscriptNumber = 2, Running hv.ps1"
				 $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
				 C:\Hwebsource\scripts\hv.ps1 $p1 $p2
				 }
		
			         $argsList = $config,$machine
			         executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer			      
   			}
			else
			{
				Write-host -ForegroundColor Red "`nThe scriptNumber entered does not match validation list, not running any scripts."
			}
		  
		}
		
	     }

	}	
}
Write-host -ForegroundColor Green "`nEnd of runBuildoutScripts"