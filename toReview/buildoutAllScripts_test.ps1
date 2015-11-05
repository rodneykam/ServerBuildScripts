#######################################################################################
# Script Name :  buildoutAllScripts-Test  Relay Health
# Author      :  Mike Felkins       
# Date        :  9:13 AM 11/4/2015   
#######################################################################################


<# .SYNOPSIS
        
This script runs 12 scripts, one at a time.
It also creates a log file called the Computer Name and date run.
 
.DESCRIPTION
        
This script runs multiple scripts, one after the other.

.PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
    $Config,
    $MachineConfig,
    [switch]$noDatabase
    
.EXAMPLE
      
.\buildoutAllScripts-Test.ps1 -config Prod -machineconfig $MachineConfig

To test this script:
 
 .\buildoutAllScripts-Test.ps1 -config Prod -machineconfig xxxx

 #>

# Script begins
    # These are the parameters that are required by this script to run.
    # $config generally is Prod. The other possibilities are to be determined.
    # $noDatabase to be determined.
param
(
[Parameter(Mandatory=$true)] $Config,
[Parameter(Mandatory=$true)] $MachineConfig,
[switch]$noDatabase
)

Import-Module -Name .\ScriptBooterFunctions.ps1

# Logging set up
# Imports the Write-Log function
# Gets the current date and time
# Sets the logs location
Import-module C:\temp\scripts\ps1\Function-Write-Log.ps1
$Date = get-date -f "MM-dd-yyyy hh-mm-ss"
$Path = "C:\Logs\Test_$($env:computername)_" + $Date + ".log"
Write-Host -Foregroundcolor Yellow $Path

# Get the running scripts name
$ScriptName = $MyInvocation.MyCommand.Name
Write-Host -Foregroundcolor Yellow $ScriptName
Write-Log -Message "$ScriptName Log Starts" -Path $Path   

# Clear the Error variable and "Error" must be capitalized.
$Error.Clear()

# Check that the user running the script is an Administrator
$isAdmin = $null
GetAdmin([ref]$isAdmin)

Write-Host -ForegroundColor Green "`nRunning buildoutAllScripts_test.ps1 `n"

# Added this so script would run without the $MachineConfig variable.
# Will be $MachineConfig.codedeployed in final script
$codedeployed = "False"

# run twelve scripts one after the other. The $Path parameter is required for the script logging.
if($codedeployed -match "False")
{
	
    write-host -ForegroundColor Yellow "Debug 1 running script 1 `n"
    C:\temp\scripts\ps1\Script1.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 2 running script 2 `n"
    C:\temp\scripts\ps1\Script2.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 3 running script 3 `n"
    C:\temp\scripts\ps1\Script3.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 4 running script 4 `n"
    C:\temp\scripts\ps1\Script4.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 5 running script 5 `n"
    C:\temp\scripts\ps1\Script5.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 6 running script 6 `n"
    C:\temp\scripts\ps1\Script6.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 7 running script 7 `n"
    C:\temp\scripts\ps1\Script7.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 8 running script 8 `n"
    C:\temp\scripts\ps1\Script8.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 9 running script 9 `n"
    C:\temp\scripts\ps1\Script9.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 10 running script 10 `n"
    C:\temp\scripts\ps1\Script10.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 11 running script 11 `n"
    C:\temp\scripts\ps1\Script11.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Yellow "Debug 12 running script 12 `n"
    C:\temp\scripts\ps1\Script12.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

    write-host -ForegroundColor Green " End of buildoutAllScripts_test.s1 script `n"
    Write-Log -Message "$ScriptName complete" -Path $Path 
    Write-Log -Message " " -Path $Path
 }
 

    