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
        
.\Web_Build_out_1.ps1 $Environment 1

        
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
    [string] $ScriptName = $(throw "You must specify a script number 1 - 14."),
	[Switch]$FlashDeploy=$false,
	$servers=$null,
	$DropBoxName,
	[switch]$noDatabase
	)
   
# Clean up environment
Remove-Variable Config -ErrorAction SilentlyContinue
Remove-Variable machine -ErrorAction SilentlyContinue 
Remove-Module scriptbooterfunctions -Force -ErrorAction SilentlyContinue
Remove-Module BuildoutPackageExecuterFunctions -Force -ErrorAction SilentlyContinue
  
# Import-Module that contains custom functions

if (-not (Get-Module scriptbooterfunctions.ps1))
{ 
Import-Module -Name C:\Hwebsource\scripts\scriptbooterfunctions.ps1 -Force
}
if (-not (Get-Module BuildoutPackageExecuterFunctions.ps1))
{ 
Import-Module -Name C:\Hwebsource\scripts\BuildoutPackageExecuterFunctions.ps1 -Force
}

# clear-host

# Change to the working directory
$loc = "C:\Hwebsource\scripts"
Set-Location $loc


# Load the configuration xml file
$configFilePath = $loc+"\"+"buildoutSetup.config"

# Set the parameters we will pass to the target script or scripts

$config= XMLParser -filepath $configFilePath -nodequalifier $EnvironmentPrefix
$machines = $config.machines.machine

# Make sure we have a server selected from buildoutSetup.config
if ($machines.count)
{
	foreach ($machine in $machines)
	{
    Write-host $machine
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
            if($ReadyForDeploy -eq $True)
            {
               $P1 = $config
               $P2 = $machine
                
            }
		
    }
 }

 # Calls a script that contains calls to the one of the sub-scripts  as selected with the following switch statement
 # noDatabase is a switch that is optional for some of the script.
 Write-host "start switch"
 Switch ($ScriptName)
 {
    # 1{ ./permtest_mod.ps1 -EnvironmentConfig $P1 -MachineConfig $P2 }
    # 2{ ./hv_mod.ps1 -EnvironmentConfig $P1 -MachineConfig $P2}
    
################### Test Scripts ################################################################    
   
    
    1   {  Write-host "Running permtest_mod.ps1"
            # $config
            $P1
            $P2
            if (test-path "c:\hwebsource ")
            {
			 pushd c:\hwebsource\scripts 
            
            # .\permtest_mod.ps1 -EnvironmentConfig $config -MachineConfig $P2
            .\permtest_mod.ps1 -EnvironmentConfig $P1 -MachineConfig $P2
            }
        }
        
    2 {  Write-host "Running HV.ps1"
         if (test-path "c:\hwebsource ")
        {
			 pushd c:\hwebsource\scripts 
			 # .\hv_mod.ps1 -environmentconfig $config -machineconfig $P2
			.\hv_mod.ps1 -environmentconfig $P1 -machineconfig $P2
		}
    }
    
}


