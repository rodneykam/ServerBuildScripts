Import-Module E:\code\Libraries\PowerShellLogging\PowerShellLogging.psm1

$filedate =(Get-Date).ToString("yyyyMMddhhmmss")
$LogFileName = "$($env:computername)_" + $filedate + ".log"

$LogFile = Enable-LogFile -Path $LogFileName
Write-Host "Hello World"
Write-Host "Multi`r`nLine`r`n`r`nOutput"
& .\trial1.ps1
Write-Host "Bye World"

$LogFile | Disable-LogFile