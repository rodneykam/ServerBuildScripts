if(test-path "c:\ProgramData")
{
pushd c:\ProgramData

if((!(test-path "c:\ProgramData\DotNetCharge")) -and (test-path "C:\HwebSource\DotNetCharge"))
{
	$charge="c:\ProgramData\DotNetCharge"
	New-Item $charge  -type directory
	Copy-Item -Path C:\HwebSource\DotNetCharge\*.*  -Destination C:\ProgramData\DotNetCharge
}
popd
}