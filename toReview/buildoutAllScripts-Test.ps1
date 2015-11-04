param
(
[Parameter(Mandatory=$true)] $Config,
[Parameter(Mandatory=$true)] $MachineConfig,
[switch]$noDatabase
)

Import-Module -Name .\ScriptBooterFunctions.ps1
#Test logging
Import-module C:\temp\scripts\ps1\Function-Write-Log.ps1
$Date = get-date -f "MM-dd-yyyy hh-mm-ss"
$Path = "C:\Logs\Test_$($env:computername)_" + $Date + ".log"
Write-Host $Path

$ScriptName = $MyInvocation.MyCommand.Name
Write-Host -Foregroundcolor Yellow $ScriptName
Write-Log -Message "$ScriptName Log Starts" -Path $Path   
# Clear the Error variable for this run.   
$Error.Clear()

$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

Write-Host -ForegroundColor Green "`nRunning buildoutAllScripts_test.ps1 `n"

# Changed this so scrpt would runn with out the $MachineConfig variable.
$codedeployed = "False"
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
  
 }
 
     #   $? returns true if the last command ran successfully. If not it will exit the script.       
if(!$?){
         Write-Log -Message "$ScriptName failed; Exiting" -Path $Path -Level warn
         break
    }
Else
    {
    Write-Log -Message " $ScriptName complete" -Path $Path 
    }
    