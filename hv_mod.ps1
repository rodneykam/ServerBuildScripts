#  .SYNOPSIS
        
#  This script derives parameters that are required to run the Web Build out scripts
        
#  .DESCRIPTION
        
#  Writes out the results of this test. We are looking for 
#  the two parameters that were passed from Web_Build_out_1.ps1
#  The parameters that are created are $config and $machine.

#  .EXAMPLE
        
#  .\hv_mod.ps1 -environmentconfig $config -machineconfig $MachineConfig
      
#  .NOTES
#  Script Name :  HV_Mod.ps1   
#  Author      :  Mike Felkins       
#  Date        :  26 Oct 2015
    
param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

Wtite-Host "The HV_Mod script is running"
Write-Host "$EnvironmentConfig has been passed to this script"
Write-Host "$MachineConfig has been passed to this script"

