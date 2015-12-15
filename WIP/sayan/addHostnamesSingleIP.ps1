<#
.SYNOPSIS
	This script adds entries to the hosts file.

.DESCRIPTION
    The script edits the file C:\Windows\System32\drivers\etc\hosts and adds entires for the following -
	"machine","www","app","rtools","api","interop","salesdata","webqa","identity","rmc"
	
.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig

.EXAMPLE 

#>

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)


#$domain = [String]$EnvironmentConfig.FQDN
$appdomain = [String]$EnvironmentConfig.FQDN  #thartzler, changed from $domain to $appdomain to not confuse with $domain=$computer.domain 
$machine= [String]$MachineConfig.HwebName
$mip=$MachineConfig.MachineIp

$scriptName = "addHostnamesSingleIP"

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

if ( [string]::IsNullOrEmpty($appdomain) -or  [string]::IsNullOrEmpty($appdomain) -or  [string]::IsNullOrEmpty($mip))
	{
		throw  " Expected pareamters for settup  host file are missing"
	}
$appdomain
$machine
$mip
	
$hostheaders=@("machine","www","app","rtools","api","interop","salesdata","webqa","identity","rmc")
$localhost=@{}
$hostentries=@{}

$txt=Get-Content "C:\Windows\System32\drivers\etc\hosts"

$match= $txt -match "^127\.0\.0\.1\s+?localhost"
if(! $match)
{
#add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n127.0.0.1      localhost"
add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "127.0.0.1      localhost"
write-host -ForegroundColor Yellow "This host file entry  127.0.0.1	localhost did not exist, added to the host file. `r`n" 	
}

for($i=1; $i -le ($hostheaders.count - 1); $i++)
	{
	$tmp2=$hostheaders[$i]

	$match=$txt -match "^127\.0\.0\.1\s*$tmp2.localhost"
	if(! $match)
	{
	#add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n127.0.0.1      $tmp2.localhost"
	add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "127.0.0.1      $tmp2.localhost"
	#write-host -ForegroundColor White "`r`n  As this host file entry  127.0.0.1	$tmp2.localhost wasnt present , Hence added to the host file `r`n"  
	write-host -ForegroundColor Yellow "This host file entry 127.0.0.1	$tmp2.localhost did not exist, added to the host file. `r`n"  
	}
	}

	
for($i=1; $i -le ($hostheaders.count - 1); $i++)
	{
	$tmp2=$hostheaders[$i]
	
	$match=$txt -match "^$mip\s+$tmp2.$appdomain"
	if(! $match)
	{
	#add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$mip    $tmp2.$appdomain"	
	add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "$mip    $tmp2.$appdomain"
    #write-host "`r`n As this host file entry  127.0.0.1	$($tmp2).localhost wasnt present , Hence added to the host file `r`n"			
	write-host -ForegroundColor White "This host file entry 127.0.0.1	$($tmp2).localhost did not exist, added to the host file. `r`n"			
	}
		
	if (($tmp2 -eq "app") -or ($tmp2 -eq "www") -or ($tmp2 -eq "rtools"))
		{
		
		$match=$txt -match "^$mip\s+origin-$tmp2.$appdomain"
		if(! $match)
		{
		#add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$mip    origin-$tmp2.$appdomain"
		add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "$mip    origin-$tmp2.$appdomain"
		#write-host "`r`n As this host file entry  $mip	origin-$($tmp2).$($appdomain) wasnt present , Hence added to the host file `r`n"	
		write-host -ForegroundColor White "This host file entry $mip	origin-$($tmp2).$($appdomain) did not exist, added to the host file. `r`n"	
		}
		
		}
		
	if ($tmp2 -eq "www")
		{
		$match = $txt -match "^$mip\s+$appdomain"
		if(! $match)
		{
		add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$mip    $appdomain"
		#$message += "`r`n As this host file entry  $mip	$appdomain wasnt present , Hence added to the host file `r`n"	
		$message += "This host file entry  $mip	$appdomain did not exist, added to the host file. `r`n"
		write-host -ForegroundColor Green $message
		}
		}
		
	}
Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"





