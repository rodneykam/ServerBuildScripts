Write-Host -ForegroundColor Green "Copy Stats Folder and FacsysDll`n"




if(!(test-path "C:\Windows\system32\Logfiles\W3SVC2"))
	{
	$stat="C:\Windows\system32\Logfiles\W3SVC2"
	New-Item $stat  -type directory
	}


if(((test-path "c:\hwebsource\statsfolder\W3SVC2")) -and (test-path "C:\Windows\system32\Logfiles\W3SVC2"))
	{
	copy-item -path c:\hwebsource\statsfolder\W3SVC2\*  -destination C:\Windows\system32\Logfiles\W3SVC2 -force
	}

	
if(!(test-path "C:\inetpub\logs\LogFiles\W3SVC502"))
	{
	$stat1="C:\inetpub\logs\LogFiles\W3SVC502"
	New-Item $stat1  -type directory
	}


if(((test-path "c:\hwebsource\statsfolder\W3SVC502")) -and (test-path "C:\inetpub\logs\LogFiles\W3SVC502"))
	{
	copy-item -path c:\hwebsource\statsfolder\W3SVC502\*  -destination C:\inetpub\logs\LogFiles\W3SVC502 -force
	}
	
	


if((test-path "c:\hwebsource\facsysdll") -and (test-path "C:\Windows\SYSWOW64"))
{
copy-item -path c:\hwebsource\facsysdll\*  -destination C:\Windows\SYSWOW64 -force
}
else
{
write-host "Source  c:\hwebsource\facsysdll  and destination  C:\Windows\SYSWOW64 are invalid "
}

if(test-path "C:\Windows\SYSWOW64")
{
pushd C:\Windows\SYSWOW64
Regsvr32 fxmsg32.dll -silentlycontinue
popd
}else
{
write-host "Source C:\Windows\SYSWOW64 is invalid"
}







