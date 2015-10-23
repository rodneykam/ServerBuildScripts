$Dbheaders=@("DB01","DB02","DB03","DB04","DB05","DB06","MSDTCNAME-DBCL1","MSDTCNAME-DBCL2","MSDTCNAME-DBCL3"," DBCL1"," DBCL2"," DBCL3")
$Dbip=@("10.0.2.33","10.0.2.34","10.0.2.21","10.0.2.22","10.0.2.110","10.0.2.111","10.0.2.36","10.0.2.24","10.0.2.113","10.0.2.37","10.0.2.25","10.0.2.114") 

$Location= "C:\Windows\System32\drivers\etc\lmhosts"
for($i=1; $i -le $Dbheaders.count; $i++)
	{
	$temp1 = $Dbheaders[$i-1]
	$temp2 = $Dbip[$i-1]
	
	$Sel = select-string  -pattern $temp1  -path $Location 
	If ($Sel -eq $null)
		{	
			add-Content -path "C:\Windows\System32\drivers\etc\lmhosts" -value "`n$temp2   $temp1`n"
		}
		
    }
	
nbtstat /r