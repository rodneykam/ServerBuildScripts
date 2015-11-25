Import-Module E:\code\Libraries\PowerShellLogging\PowerShellLogging.psm1

$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$LogFileName = "$($env:computername)_remote_" + $filedate + ".log"
$RemoteComputers = "ACNU350DNBJ"

$LogFile = Enable-LogFile -Path $LogFileName
Write-Host "Hello Remote"
If (Test-Connection -ComputerName $RemoteComputers -Quiet)
{
     Invoke-Command -ComputerName $RemoteComputers -ScriptBlock {Get-ChildItem "C:\DoNOTDelete\Officer"}
}
Write-Host "Bye Remote"

$LogFile | Disable-LogFile