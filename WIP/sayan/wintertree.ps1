
pushd HKLM:\software\Wow6432Node\Wintertree
$tmpKey = "SpellingServer"
$tmpKeyExist = Test-Path "$tmpKey"
if ($tmpKeyExist -eq "True")
{
 	write-host -ForegroundColor green " Key Exists"
	Move-Item SpellingServer SpellingServer.NET

}
else 
{
	write-host -ForegroundColor red " Key Not Found "
}

popd
#verify DLL's

pushd C:\WINDOWS\SysWOW64

#We want to check for  WintertreeSpellingServer.dll

$tmpFile ="WintertreeSpellingServer.dll"
$tmpFileExist = test-path "$tmpFile"
if ( $tmpFileExist -eq "True") 
{
	write-host -ForegroundColor green "File Found"	
}
else
{
	write-host -ForegroundColor red  "File Not Found"	
	copy-item "C:\Program Files (x86)\Wintertree Spelling Server\$tmpFile" .
}	

$tmpFile1 ="WSpellingServer.dll"
$tmpFile1Exist = test-path "$tmpFile1"
if ( $tmpFile1Exist -eq "True") 
{
	write-host -ForegroundColor green "File Found"	
}
else
{
	write-host -ForegroundColor red  "File Not Found"	
	copy-item "c:\hwebsource\wintertree\$tmpFile1" .
}	

popd