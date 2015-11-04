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

# Stop-Process -Name invalidprocess -EA "SilentlyContinue"
    If ($Error) {
        $E1 = ""
        $E2 = ""
        $E1 = [string]$Error
        $E2 = $E1.Split("\.")
        Write-Host -Foregroundcolor Magenta $E2[0]
        Write-Log -Message ("$ScriptName $E2[0]") -Path $Path -Level warn
        break
        }
Write-Log -Message " " -Path $Path