<#
.SYNOPSIS
	This script sets the SSL renegotiation flag to 2.
        
.DESCRIPTION
	The script automates the following process -
	Launch “regedit” from Windows Start\Run search field.
	Under HKLM\SYSTEM\CurrentControlSet\services\HTTP\Parameters\SslBindingInfo\”new serverip”:8443
	There is a DefaultFlags key for the default value which is set to “0”. Change it to”2”.
		
.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig

.EXAMPLE 

#>

$scriptName = "setSslRenegotiationFlag"

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

#-	Launch “regedit” from Windows Start\Run search field.
#-	Under HKLM\SYSTEM\CurrentControlSet\services\HTTP\Parameters\SslBindingInfo\”new serverip”:8443
#-	There is a DefaultFlags key for the default value which is set to “0”. Change it to”2”.

# Does this need the code deployment to have completed first?
Push-Location

# Get the server IP
$ip=get-WmiObject Win32_NetworkAdapterConfiguration|Where {$_.Ipaddress.length -gt 1} 
$serverIp=$ip.ipaddress[0]
Write-host "Server IP is $serverIp"


$keyPath="HKLM:\SYSTEM\CurrentControlSet\services\HTTP\Parameters\SslBindingInfo"
Set-Location $keyPath
$keyFullName=$keyPath+"\"+$serverIp+":8443"
# Create key if it does not exist
if (!(test-path $keyFullName)) {
	# Create key or fail?
	New-Item -Path $keyFullName -Force | Out-Null
}

# Create/Update the DefaultFlags key, and set to "2"
New-ItemProperty -Path $keyFullName -Name DefaultFlags -Value 2 -PropertyType DWORD -Force | Out-Null

pop-Location

Write-host "Flag has been set to 2"

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"

