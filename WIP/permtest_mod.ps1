#  .SYNOPSIS
        
#  This script derives parameters that are required to run the Web Build out scripts
        
#  .DESCRIPTION
        
#  Writes out the results of this test. We are looking for 
#  the two parameters that were passed from Web_Build_out_1.ps1
#  The parameters that are created are $config and $machine.

#  .EXAMPLE
        
#  .\permtest_mod.ps1 -EnvironmentConfig $Config -MachineConfig $MachineConfig
      
#  .NOTES
#  Script Name :  permtest_mod.ps1
#  Author      :  Mike Felkins       
#  Date        :  26 Oct 2015
  
param
(
[Parameter(Mandatory=$true)] $EnviromentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

Write-Host "The Premtest_mod script is running"
Write-Host "$EnviromentConfig has been passed to this script"
Write-Host "$MachineConfig has been passed to this script"

