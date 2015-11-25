$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$LogFileName = "$($env:computername)_transcript_" + $filedate + ".log"
$RemoteComputers = "ACNU350DNBJ"

Start-Transcript $LogFileName

Write-Host "Hello Remote"
If (Test-Connection -ComputerName $RemoteComputers -Quiet)
{
     Invoke-Command -ComputerName $RemoteComputers -ScriptBlock {Get-ChildItem "C:\DoNOTDelete\Officer"}
}
Write-Host "Bye Remote"

Stop-Transcript