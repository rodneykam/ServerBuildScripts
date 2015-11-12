Import-Module E:\code\ServerBuildScripts\WIP\sayan\Logging.psm1 -Verbose

$ScriptName = $MyInvocation.MyCommand.Name
$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$LogPath = "E:\code\ServerBuildScripts\WIP\sayan\"
$LogFile = "$($env:computername)_" + $filedate + ".log"
$BuildOutLog = "$LogPath" + "$LogFile"

Write-Log "Grand parent start" $BuildOutLog
Write-Log $BuildOutLog $BuildOutLog 
& .\parent.ps1 $BuildOutLog
Write-Log "Grand parent end" $BuildOutLog

