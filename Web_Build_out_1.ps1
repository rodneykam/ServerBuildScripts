<# 
.SYNOPSIS
        
This script derives parameters that are required to run the Web Build out scrpits
        
.DESCRIPTION
        
This script reads in the buildoutSetup.config document which is a XML file.
It then parses that file in order to select the approprite section for the web server we are building.
Next it calls a script with the parameters we have derived.

The paramters that are created are $config and $machine.

This script runs one BuildOut script at a time and is used for testing and trouble shooting


.EXAMPLE
        
.\Web_Build_out_1.ps1 Prod

        
}
        
.NOTES
Script Name :  Web_Build_out_1.ps1   
Author      :  Mike Felkins       
Date        :  21st of Oct 2015
    
#>

#######################################################################################
# Script begins


#   These are the parameters that are required by this script to run.
#   $EnvironmentPrefix generally is Prod. The other possibilities are to be determined.
#   $FlashDeploy=$false by default.
#   $DropBoxName to be determined.
#   $noDatabase to be determined
    

param (
	[string] $EnvironmentPrefix = $(throw "You must specify a environment."),
    [string] $a = $(throw "You must specify a script number 1 - 14."),
	[Switch]$FlashDeploy=$false,
	$servers=$null,
	$DropBoxName,
	[switch]$noDatabase
	)

# Import-Module that contains custom functions

if (-not (Get-Module scriptbooterfunctions.ps1))
{ 
Import-Module -Name C:\temp\scripts\ps1\scriptbooterfunctions.ps1 -Force
}
if (-not (Get-Module BuildoutPackageExecuterFunctions.ps1))
{ 
Import-Module -Name C:\temp\scripts\ps1\BuildoutPackageExecuterFunctions.ps1 -Force
}

# clear-host

# Change to the working directory
$loc = "C:\temp\scripts\ps1"

# Load the configuration xml file
$configFilePath = $loc+"\"+"buildoutSetup.config"

# Set the parameters we will pass to the target script or scripts
$EnvironmentPrefix
$a

$config = XMLParser -filepath $configFilePath -nodequalifier $EnvironmentPrefix
$machines= $config.machines.machine

# Make sure we have a server selected from buildoutSetup.config
if ($machines.count)
{
	foreach ($machine in $machines)
	{
    
# Look for the server in the configuration xml (buildoutSetup.config) file that needs to be built.
# codedeployed will be false for the server that needs to be built.
    
    if($machine.codedeployed -match "False")
			{
				$ReadyForDeploy=$True  
			}
			else
			{
				$ReadyForDeploy=$False
			}
            if($ReadyForDeploy -eq $True){
               $P1 = $config
               $P2 = $machine
            }
		
    }
 }

 # Displays the contents of $config and $machine on the screen
 
   
 
 # Calls a script that contains calls to the one of the sub-scripts  as selected with the following switch ststement
 # noDatabase is a switch that is optional for some of the script.
 
 Switch ($a)
 {
    # 1{ ./hostnamessingleip.ps1 -EnvironmentConfig $P1 -MachineConfig $P2 }
    # 2{ ./dotnetcharge.ps1 -EnvironmentConfig $P1 -MachineConfig $P2}
    # 3{ ./stats.ps1}
    # 4{ ./newserver.ps1 -EnvironmentConfig $P1 -MachineConfig $P2}
    # 5{ ./newserver2.ps1}
    # 6{ ./Imports the RelayHealthEventLog registry settings.}
    # 7{ ./deploy.ps1 -EnvironmentConfig $P1 -MachineConfig $P2}
    # 8{ ./AddCacheHost.ps1  }
    # 9{ ./DeployWindowsServerAppFabric.ps1} #"This was commented out in the original ScriptBooter script."
    # 10{ ./Msutil.ps1}
    # 11{ ./SetFolderPermissions.ps1}
    # 12{ ./initiate.ps1}
    # 13{ ./AppFabricSetup.ps1}  # "This was commented out in the original ScriptBooter script."
    # 14{ ./hv.ps1 -EnvironmentConfig $P1 -MachineConfig $P2}
################### Test Scripts ################################################################    
    1{  Write-host "Running permtest"
            if (test-path "c:\hwebsource ")
            {
			 pushd c:\hwebsource\scripts 
    
            .\permtest_mod.ps1 -EnvironmentConfig $EnvironmentConfig -MachineConfig $MachineConfig
           }
    }
    
    2{  Write-host "Running HV.ps1"
         if (test-path "c:\hwebsource ")
        {
			 pushd c:\hwebsource\scripts 
			 
			.\hv_mod.ps1 -environmentconfig $config -machineconfig $MachineConfig
		}
    }
    
}
Remove-Module scriptbooterfunctions
Remove-Module BuildoutPackageExecuterFunctions

