param
(
[Parameter(Mandatory=$true)] $Config,
[Parameter(Mandatory=$true)] $MachineConfig,
[switch]$noDatabase
)

$scriptpath = "C:\hwebsource\scripts"
cd C:\hwebsource\scripts

write-host -foreground Yellow "`n   buildoutAllScripts - Loading buildoutAllScriptsFunctions.ps1"
Import-Module -Name .\buildoutAllScriptsFunctions.ps1

#Setup logging
#Import-module C:\hwebsource\scripts\FunctionWriteLog.ps1  
#Import-module F:\SCM\Buildout\NewBuildoutScripts\Function-Write-Log.ps1  #imports function

write-host -foreground Yellow "   buildoutAllScripts - Loading FunctionWriteLog.ps1 `n"
Import-Module -Name .\FunctionWriteLog.ps1

$ScriptName = $MyInvocation.MyCommand.Name

#$Date = get-date -f "MM-dd-yyyy hh-mm-ss"
$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$Path = "C:\Logs\Test_$($env:computername)_" + $filedate + ".log" # creates log file path on the new server
Write-Host $Path

$ScriptName = $MyInvocation.MyCommand.Name 			# gets name of the script that is running
Write-Host -Foregroundcolor Yellow $ScriptName
Write-Log -Message "$ScriptName Log Starts" -Path $Path   # First line of the log file

# Clear the Error variable for this run.   
$Error.Clear()

$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

Write-Host -ForegroundColor Green "buildoutAllScripts - Running test scripts 1 and 2 `n"

if($MachineConfig.codedeployed -match "False")
	{
		write-host -ForegroundColor Yellow "   buildoutAllScripts - running script 1."
		# Running script 1 with the environment and machine parameters and the path to the logfile.
		C:\hwebsource\scripts\Script1.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path

		write-host -ForegroundColor Yellow "   buildoutAllScripts - running script 2."
		C:\hwebsource\scripts\Script2.ps1 -Config $Config -MachineConfig $MachineConfig -Path $Path
		  
 }
 
 Stop-Process -Name invalidprocess -EA "SilentlyContinue"
    If ($Error) {
        $E1 = ""
        $E2 = ""
        $E1 = [string]$Error
        $E2 = $E1.Split("\.")
        Write-Host -Foregroundcolor Magenta $E2[0]
        Write-Log -Message ("$ScriptName $E2[0]") -Path $Path -Level warn
        break
        }
 
 write-host -ForegroundColor Green " End of buildoutAllScripts_test.s1 script `n"

	