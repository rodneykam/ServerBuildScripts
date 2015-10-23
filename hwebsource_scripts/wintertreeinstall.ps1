$tmpProg ="C:\Program Files (x86)\Wintertree Spelling Server"
$tmpProgExist = test-path "$tmpProg"
if ( $tmpProgExist -eq "True") 
{
	write-host -ForegroundColor green "Folder is Present "	
}
else
{
	write-host -ForegroundColor red  "Folder is  Not Found"	
	
	#installation of Spelling Server 
	Write-Host "License key is 3300638297 "

	& 'e:\hwebsource\wintertree\setup.EXE'

}	 