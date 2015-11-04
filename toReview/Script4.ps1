param
(
[Parameter(Mandatory=$true)] $Config,
[Parameter(Mandatory=$true)] $MachineConfig,
[Parameter(Mandatory=$true)] $Path,
[switch]$noDatabase
)

$ScriptName = $MyInvocation.MyCommand.Name
Write-Host -Foregroundcolor Yellow $ScriptName

Write-Log -Message "$ScriptName Log Starts" -Path $Path   
Write-Host -Foregroundcolor Yellow $Path

# Clear the Error variable for this run.   
$Error.Clear()

$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

Write-Log -Message "$ScriptName Information 1" -Path $Path
Write-Log -Message "$ScriptName Information 2" -Path $Path
Write-Log -Message "$ScriptName Information 3" -Path $Path

     #   $? returns true if the last command ran successfully. If not it will exit the script.       
if(!$?){
         Write-Log -Message "$ScriptName failed; Exiting" -Path $Path -Level warn
         break
    }
Else
    {
    Write-Log -Message " $ScriptName complete" -Path $Path 
    }