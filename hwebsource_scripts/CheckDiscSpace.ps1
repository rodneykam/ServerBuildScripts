# PowerShell cmdlet to display a disk's free space
$Item = @("DeviceId", "MediaType", "Size", "FreeSpace")
# Next follows one command split over two lines by a backtick `
Get-WmiObject -query "Select * from Win32_logicaldisk" `
| Format-Table $item -auto 
