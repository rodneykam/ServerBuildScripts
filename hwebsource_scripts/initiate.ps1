param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

function robocopyZipFiles
{
	param
	(
		[string] $Directory,
		[string] $DestinationDir		
	)
    
   
		robocopy /z /e $Directory  $DestinationDir 
}

$DestinationDir = [String]$EnvironmentConfig.InitiateDestinationDir
$Database = [String]$EnvironmentConfig.InitiateDatabase	
$Prefix = [String]$EnvironmentConfig.InitiateDatabasePrefix	
$EnvAccount = [String]$MachineConfig.InitiateEnvAccount	
$Account = [String]$MachineConfig.InitiateAccount	
$Password = [String]$MachineConfig.InitiatePassword
$Directory = [String]$EnvironmentConfig.InitiateDirectory 
$InitiateDir = "e:\mpi\product"
$InitiateBatFile = "C:\hwebsource\initiate\unattended.cmd"
$path_var = [Environment]::GetEnvironmentVariable("PATH","Machine")
		
if (-not(Test-Path -path $InitiateDir))
{ 
	New-Item -Path $InitiateDir -itemType directory | Out-Null 
}	
pushd C:\hwebsource\initiate

#./unattended.cmd
 
popd

Get-ChildItem Env:Path

if ($path_var -notmatch "E:\\mpi\\product\\Engine8.7.0\\bin")
{
	$BinPath = $Env:Path + ";E:\mpi\product\Engine8.7.0\bin"
	[Environment]::SetEnvironmentVariable("PATH", "$BinPath", "Machine")

}

if ($path_var -notmatch "E:\\mpi\\product\\Engine8.7.0\\jre")
{
	$JrePath = $Env:Path + ";E:\mpi\product\Engine8.7.0\jre"
	[Environment]::SetEnvironmentVariable("PATH", "$JrePath", "Machine")
}

[Environment]::GetEnvironmentVariable("PATH","Machine")



if (Test-Path $Directory)
{

	robocopyZipFiles -Directory $Directory -DestinationDir $DestinationDir
}
else
{
	throw "Source Directory  $Directory does not exist"
}

$initiate_envsetfile = "E:\mpi\project\initiate\scripts\env.set.bat"

if (-not(Test-Path -path $initiate_envsetfile))
{ 
	throw " $initiate_envsetfile "
}

$envpattern=@("set MAD_DBSVR=*.*","set MAD_DBUSER=*.*","set MAD_DBPASS=*.*","set MAD_ENGUSER=*.*","set MAD_ENGPASS=*.*","set MAD_AUDIT=1","set MAD_DEBUG=1","set MAD_TRACE=1","set MAD_DBSQL=1","set MAD_RHPATH=*.*","set MAD_DBPREFIX=*.*","set MAD_VER=*.*","set MAD_DIR=*.*","set MAD_DIRESC=*.*")
$envreplace=@("set MAD_DBSVR=$Database","set MAD_DBUSER=$Account","set MAD_DBPASS=$Password","set MAD_ENGUSER=$EnvAccount","set MAD_ENGPASS=$Password","set MAD_AUDIT=0","set MAD_DEBUG=0","set MAD_TRACE=0","set MAD_DBSQL=0","set MAD_RHPATH=","set MAD_DBPREFIX=$Prefix","set MAD_VER=DEFAULT","set MAD_DIR=","set MAD_DIRESC=")


for ($i = 0 ; $i -le $envpattern.length - 1 ;$i++)
{
	(Get-Content $initiate_envsetfile) | 
	Foreach-Object {$_ -replace $envpattern[$i], $envreplace[$i]} | 
	Set-Content $initiate_envsetfile
}


$initiate_passsiveenvsetfile = "E:\mpi\Project\Initiate\passive\conf\PassiveServer.properties"

if (-not(Test-Path -path $initiate_passsiveenvsetfile))
{ 
	exit
}

pushd e:\relayhealth\deployhelp
$dtd = .\ParseDTD.ps1
$PassivePassword=$dtd.NIMPassword
$PassiveAccount=$dtd.NIMUserId
popd
$passsiveenvpattern=@("UsrPass=*.*","UsrName=*.*")
$passsiveenvreplace=@("UsrPass=$PassivePassword","UsrName=$PassiveAccount")


for ($i = 0 ; $i -le $passsiveenvpattern.length - 1 ;$i++)
{
	(Get-Content $initiate_passsiveenvsetfile) | 
	Foreach-Object {$_ -replace $passsiveenvpattern[$i], $passsiveenvreplace[$i]} | 
	Set-Content $initiate_passsiveenvsetfile
}

exit
sleep 3
pushd E:\mpi\project\initiate\scripts

./initiatesetup.ps1 $Prefix

sleep 2

./installpassive.bat

popd


