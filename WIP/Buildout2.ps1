# 1:09 PM 10/27/2015
 
# .SYNOPSIS
        
# This script derives parameters that are required to run the Web Build out scrpits
        
# .DESCRIPTION
        
# This script reads in the buildoutSetup.config document which is a XML file.
# It then parses that file in order to select the approprite section for the web server we are building.
# Next it calls a script with the parameters we have derived.

# The paramters that are created are $config and $machine.

# This script will run either the original ScriptBooter.ps1 or the NewScript.ps1
# Newscript runs one BuildOut script at a time and is used for testing and trouble shooting

# .EXAMPLE
        
# .\Buildout2.ps1 $Environment NewScript
#     
# .NOTES
# Script Name :  Buildout2.ps1   
# Author      :  Mike Felkins       
# Date        :  11:39 AM 10/27/2015
#######################################################################################
# Script begins

#   These are the parameters that are required by this script to run.
#   $EnvironmentPrefix generally is Prod. The other possibilities are to be determined.
#   $ScriptName can be either "ScriptBooter or NewScript"
#   $FlashDeploy=$false by default.
#   $DropBoxName to be determined.
#   $noDatabase to be determined

param (
	[string] $EnvironmentPrefix = $(throw "You must specify a environment."),
	[string] $ScriptName = $(throw "ScriptBooter or NewScript"),
	$servers=$null,
	[switch]$noDatabase
	)

# Import-Module that contains custom functions
    
    Import-Module -Name .\BuildoutPackageExecuterFunctions.ps1

# Check if current console has admin rights
$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

# Change to the working directory
$loc=get-location

$configFilePath = $loc.path +"\"+"buildoutSetup.config"

TestPath  -path $configFilePath

$currentuser= [Environment]::UserName

# Load the configuration xml file
# Set the parameters we will pass to the target script or scripts
$config= XMLParser -filepath $configFilePath -nodequalifier $EnvironmentPrefix

$machines= $config.machines.machine

# check if their are more than one target servers

$servers=$servers |sort -unique

$Serverlist=@()

if($servers)
{
	foreach($server in $servers)
	{
		if (!(($server -ge 0) -and ($server -le $machines.count)))
		{
			write-host -foregroundcolor Yellow "You $server input  in not right. Here is what you entered $servers"
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
# Look for the server in the configuration xml (buildoutSetup.config) file that needs to be built.
# codedeployed will be false for the server that needs to be built.

if ($machines.count)
{
	foreach ($machine in $machines)
	{
		# Is this required?????
        #  if($serverlist)
		#  {
			#  $Hwebnumber=((([int](((($machine.HwebName).split("."))[0])[-2]))-48)*10)+((([int](((($machine.HwebName).split("."))[0])[-1]))-48))
			#  if ($Hwebnumber -eq $serverlist[$count])
			#  {
				#  $ReadyForDeploy=$True
				#  $count++	
			#  }
			#  else
			#  {
				#  $ReadyForDeploy=$False
			#  }			
		#  }
		#  else
		#{
			if($machine.codedeployed -match "False")
			{
				$ReadyForDeploy=$True
								
			}
			else
			{
				$ReadyForDeploy=$False
			}
		#}
	
		
		if($ReadyForDeploy -eq $True)
		{	
			$config
			$machine
			
            $destinationWinRMServer = [string]::Format("{0}", $machine.HwebName)
            $currentexecuter= $machine.domain +"\"+"$currentuser"
			if(!($password))
			{
			$password=SetPassword -user $currentexecuter 
			}
			$Destination = "\\"+$machine.MachineIp+"\"+$machine.PackageDestination

            
# Calls a script that contains calls to the one of the scripts as selected with the following switch statement
# noDatabase is a switch that is optional for some of the script.
# added buildscript parameter to Newscript to select script to run on the new windows server.

 Write-host "start switch"            
            Switch ($ScriptName)
            {
                    
          ScriptBooter  {
                        $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
                        C:\Hwebsource\scripts\scriptbooter.ps1 -config $p1	-MachineConfig $p2	
                        }
                        $argsList = $config,$machine

                        executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList -deployLoginame $currentexecuter -deployUserPassword $password -serverFQDN $destinationWinRMServer				
                        }	
          NewScript {
                        $buildscript = Read-Host -Prompt 'Input the name of the script you want to run'
                        
                        $scriptBlock = { param($p1,$p2,$buildscript) pushd C:\Hwebsource\scripts
                        C:\Hwebsource\scripts\NewScript.ps1 -config $p1	-MachineConfig $p2 $buildscript
                        }
                        $argsList = $config,$machine,$buildscript

                        executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList			
                    }                 
			}	
		}
	}
}
	