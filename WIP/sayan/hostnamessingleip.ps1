param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)




$domain = [String]$EnvironmentConfig.FQDN
$machine= [String]$MachineConfig.HwebName
$mip=$MachineConfig.MachineIp


if ( [string]::IsNullOrEmpty($domain) -or  [string]::IsNullOrEmpty($domain) -or  [string]::IsNullOrEmpty($mip))
	{
		throw  " Expected pareamters for settup  host file are missing"
	}
$domain
$machine
$mip
	


$hostheaders=@("machine","www","app","rtools","api","interop","salesdata","webqa")
$localhost=@{}
$hostentries=@{}

$txt=Get-Content "C:\Windows\System32\drivers\etc\hosts"

$match= $txt -match "^127\.0\.0\.1\s+?localhost"
if(! $match)
{
add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n127.0.0.1      localhost"
write-host "`r`n As this host file entry  127.0.0.1	localhost wasnt present , Hence added to the host File `r`n" 	
}

for($i=1; $i -le ($hostheaders.count - 1); $i++)
	{
	$tmp2=$hostheaders[$i]

	$match=$txt -match "^127\.0\.0\.1\s*$tmp2.localhost"
	if(! $match)
	{
	add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n127.0.0.1      $tmp2.localhost"
	write-host "`r`n  As this host file entry  127.0.0.1	$tmp2.localhost wasnt present , Hence added to the host File `r`n"  
	}
	}

	
for($i=1; $i -le ($hostheaders.count - 1); $i++)
	{
	$tmp2=$hostheaders[$i]
	
	$match=$txt -match "^$mip\s+$tmp2.$domain"
	if(! $match)
	{
	add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$mip    $tmp2.$domain"	
    write-host "`r`n As this host file entry  127.0.0.1	$($tmp2).localhost wasnt present , Hence added to the host File `r`n"			
	}
		
	if (($tmp2 -eq "app") -or ($tmp2 -eq "www") -or ($tmp2 -eq "rtools"))
		{
		
		$match=$txt -match "^$mip\s+origin-$tmp2.$domain"
		if(! $match)
		{
		add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$mip    origin-$tmp2.$domain"
		write-host "`r`n As this host file entry  $mip	origin-$($tmp2).$($domain) wasnt present , Hence added to the host File `r`n"	
		}
		
		}
		
	if ($tmp2 -eq "www")
		{
		$match = $txt -match "^$mip\s+$domain"
		if(! $match)
		{
		add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$mip    $domain"
		$message += "`r`n As this host file entry  $mip	$domain wasnt present , Hence added to the host File `r`n"	
	 write-host $message
		}
		}
		
	}






