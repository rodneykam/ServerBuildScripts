 set-executionpolicy remotesigned
 #####checking the number of IP's########

$cNICs=Get-WMIObject win32_NetworkAdapterConfiguration `
|where{$_.IPEnabled -eq "TRUE"}

$check=0

ForEach($cNIC in $cNICs)

	{
	  $cNICips=$cNIC.ipaddress
	  ForEach($cNICip in $cNICips)	
		{	
			$check=$check+1
		}
	}

if ($check -le 13)
{
Write-Host -ForegroundColor Red "`n`nNIC card and HostFile Setup"
Write-Host -ForegroundColor Red "============================"
[string]$pool =Read-Host  "`n Pick the name of the pool from the following  `n sclust  tws  ci-trunk   ci-hotfix  integration  demo  prodtest"
[string]$machine =Read-Host  "`n What is the machine name`n "


#names of the  hostheader
$hostheaders=@("machine","www","app","rtools","api","api2","interop","salesdata","webqa")
$ip=@()
$ips=@()
$hostnames=@()
$machinehostnames=@()
$akamaihostnames=@()
$localhostnames=@()
$sm=@()

#procuring required ips , mask and hostheaders


for($i=1; $i -le $hostheaders.count; $i++)
	{
	
	$ip+=Read-Host "IP address for "$hostheaders[$i -1]"is "
	$tmp2=$hostheaders[$i -1]
	
	If (($pool -eq "ci-hotfix") -or($pool -eq "ci-trunk"))
		{
		$hostnames+="$tmp2.$pool"
		
		if (($tmp2 -eq "app") -or ($tmp2 -eq "www") -or ($tmp2 -eq "rtools"))
			{
			$machinehostnames+="$tmp2.$machine.$pool"
			$akamaihostnames+="origin-$tmp2.$pool"
			}
		else
			{
			$machinehostnames+="$tmp2.$pool"
			$akamaihostnames+="$tmp2.$pool"
			}
		}	
	else
		{
		$hostnames+="$tmp2.$pool.relayhealth.com"
		
		if (($tmp2 -eq "app") -or ($tmp2 -eq "www") -or ($tmp2 -eq "rtools"))
			{
			$machinehostnames+="$tmp2.$machine.$pool.relayhealth.com"
			$akamaihostnames+="origin-$tmp2.$pool.relayhealth.com"
			}
		else
			{
			$machinehostnames+="$tmp2.$pool.relayhealth.com"
			$akamaihostnames+="$tmp2.$pool.relayhealth.com"
			}
		}	
	#$hostnames+="$tmp2.$pool.relayhealth.com"
	$sm+="255.255.255.0"
	
	}
	
	for($i=1; $i -le $hostheaders.count; $i++)
	{
	$tmp2=$hostheaders[$i -1]
	If (($pool -eq "ci-hotfix") -or($pool -eq "ci-trunk"))
		{
		$localhostnames+="$tmp2.localhost"
		}	
	else
		{
		$localhostnames+="$tmp2.localhost"
		}	
	#$hostnames+="$tmp2.$pool.relayhealth.com"
	}

#adding ip's and masks
$NICs=Get-WMIObject win32_NetworkAdapterConfiguration `
|where{$_.IPEnabled -eq "TRUE"}



ForEach($NIC in $NICs)
	{	
	#$NIC.EnableStatic($ip,$sm)
	}

$location="C:\Windows\System32\drivers\etc\hosts"

	
	
#adding hostheaders	and ip's to the HOST file
	
	
for($i=2; $i -le $hostheaders.count; $i++)
	{
	$tmp3="127.0.0.1" 
	$tmp4=$localhostnames[$i -1]
	$tmp5=" localhost "
	
	$Sel = select-string  -pattern $tmp5 -path $Location 
	If ($Sel -eq $null)
		{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp5"
		}
	
	$Sel = select-string  -pattern $tmp4 -path $Location 
	If ($Sel -eq $null)
		{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp4"
		}
		
	}

for($i=2; $i -le $hostheaders.count; $i++)
	{
	$tmp3=$ip[$i-1]                         
	$tmp4=$hostnames[$i -1]
	$Sel = select-string  -pattern $tmp4 -path $Location 
	If ($Sel -eq $null)
		{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp4"
		}
	
	if (($tmp4 -eq "app.$pool.relayhealth.com") -or ($tmp4 -eq "rtools.$pool.relayhealth.com") -or ($tmp4 -eq "www.$pool.relayhealth.com") -or ($tmp4 -eq "app.$pool") -or ($tmp4 -eq "rtools.$pool") -or ($tmp4 -eq "www.$pool"))
		{
		$tmp6=$machinehostnames[$i -1]
		$Sel = select-string  -pattern $tmp6 -path $Location 
		If ($Sel -eq $null)
			{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp6"
			}
		
		$tmp7=$akamaihostnames[$i -1]
		$Sel = select-string  -pattern $tmp7 -path $Location 
		If ($Sel -eq $null)
			{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp7"
			}
		if ($tmp4 -eq "www.$pool") 
			{
			$tmp8=" $pool "
			$Sel = select-string  -pattern $tmp8 -path $Location 
			If ($Sel -eq $null)
			{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp8"
			}
			
			}
		if ($tmp4 -eq "www.$pool.relayhealth.com")
			{
			$tmp9=" $pool.relayhealth.com "
			$Sel = select-string  -pattern $tmp9 -path $Location 
			If ($Sel -eq $null)
			{	
			add-Content -path "C:\Windows\System32\drivers\etc\hosts" -value "`n$tmp3 		$tmp9"
			}
			
		    } 
		}
		
		
		
	}
}
else 
{
Write-Host "`n`n`nIt has the required IP's"
}