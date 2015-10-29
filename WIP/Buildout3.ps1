# 3:54 PM 10/27/2015
 
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
        
# .\Buildout3.ps1 $EnvironmentPrefix NewScript
#     
# .NOTES
# Script Name :  Buildout2.ps1   
# Author      :  Mike Felkins       
# Date        :  11:39 AM 10/27/2015
#######################################################################################
Write-host -ForegroundColor Green "Script begins" 

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
    Write-host -ForegroundColor Yellow "Import-Module that contains custom functions"
    Import-Module -Name .\BuildoutPackageExecuterFunctions.ps1

# Check if current console has admin rights
$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

# Change to the working directory
write-host -ForegroundColor Yellow "Change to the working directory"
$loc=get-location

$configFilePath = $loc.path +"\"+"buildoutSetup.config"

TestPath  -path $configFilePath

$currentuser= [Environment]::UserName

# Load the configuration xml file
# Set the parameters we will pass to the target script or scripts
write-host -ForegroundColor Yellow "Load the configuration xml file"
$config= XMLParser -filepath $configFilePath -nodequalifier $EnvironmentPrefix

$machines= $config.machines.machine

# check if their are more than one target servers
write-host -ForegroundColor Yellow "check if their are more than one target servers"
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
         if($serverlist)
		 {
			 $Hwebnumber=((([int](((($machine.HwebName).split("."))[0])[-2]))-48)*10)+((([int](((($machine.HwebName).split("."))[0])[-1]))-48))
			 if ($Hwebnumber -eq $serverlist[$count])
			 {
				 Write-host "Debug 1"
                 $ReadyForDeploy=$True
				 $count++	
			 }
			 else
			 {  Write-host "Debug 2"
				 $ReadyForDeploy=$False
			 }			
		 }
		 else
		{
			if($machine.codedeployed -match "False")
			{
                Write-host "Debug 3"
				$ReadyForDeploy=$True
								
			}
			else
			{   Write-host "Debug 4"
				$ReadyForDeploy=$False
			}
		#}
	
		
		if($ReadyForDeploy -eq $True)
		{	
			Write-host -ForegroundColor Yellow "this is the contents of $config"
            $config
			Write-host "this is the contents of $Machine"
            $machine
			
            $destinationWinRMServer = [string]::Format("{0}", $machine.HwebName)
            $currentexecuter= $machine.domain +"\"+"$currentuser"
			if(!($password))
			{ Write-host "Debug 5"
			$password=SetPassword -user $currentexecuter 
			}
			Write-host "Debug 6"
            $Destination = "\\"+$machine.MachineIp+"\"+$machine.PackageDestination

            
# Calls a script that contains calls to the one of the scripts as selected with the following switch statement
# noDatabase is a switch that is optional for some of the script.
# added buildscript parameter to Newscript to select script to run on the new windows server.

Write-host -foregroundcolor Yellow "start switch"
 Switch ($ScriptName)
 {
    # 1{ ./permtest_mod.ps1 -EnvironmentConfig $P1 -MachineConfig $P2 }
    # 2{ ./hv_mod.ps1 -EnvironmentConfig $P1 -MachineConfig $P2}
    
################### Test Scripts ################################################################    
   
    
    1   {  Write-host -ForegroundColor Yellow "Running permtest_mod.ps1"
                                
            $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
            C:\Hwebsource\scripts\permtest_mod.ps1 -config $p1 -MachineConfig $p2
            }
            $argsList = $config,$machine
            executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList	 
        }
        
    2 {  Write-host -ForegroundColor Yellow "Running HV.ps1"
         if (test-path "c:\hwebsource ")
        {
        
        $scriptBlock = { param($p1,$p2) pushd C:\Hwebsource\scripts
            C:\Hwebsource\scripts\hv_mod.ps1 -config $P1 -machineconfig $P2
            }
            $argsList = $config,$machine
            executeScriptInRemoteSession -scriptBlock $scriptBlock -argsList $argsList	
		}
    }
    
}
Write-host -ForegroundColor Green "End of Script"
