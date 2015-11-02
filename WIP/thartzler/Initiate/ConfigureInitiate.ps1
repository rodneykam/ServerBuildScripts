#############################################################################
##
## configureInitiate
##   
## 10/2015, RelayHealth
## Martin Evans
##
##############################################################################

<#
.SYNOPSIS
	This script configures the Initiate application on a web server
        
.DESCRIPTION
	Initiate is a third-party application that RelayHealth uses to find patient matches in the database.
	It is installed on all Health Systems web servers, in the location E:\MPI.
	
	There are three components:
	+ The Initiate Engine application
	-- Location:                     E:\mpi\product\Engine8.7.0
	+ The Initiate Master Data Engine Service instance
	-- Location:                     E:\mpi\Project\Initiate
	-- Windows Service name:         MPINETDEFAULT
	-- Windows Service display name: Initiate Master Data Engine 8.7.0 Default
	-- Logs location:                E:\mpi\Project\Initiate\Log
	+ The Initiate Passive Server service
	-- This is used to bulk-load data, and utilizes the Initiate MDE service to communicate to the database
	-- Location:                     E:\mpi\Project\Initiate\Passive
	-- Windows Service name:         Initiate PassiveServer 8.7.0
	-- Windows Service display name: Initiate PassiveServer 8.7.0
	-- Logs location:                E:\mpi\Project\Initiate\Passive\Logs
	
	
	This script takes as parameters the server-specific and environment-specific configuration data, and 
	configures the Initiate MDE and Passive services.
	
	The server should have the basic Initiate Engine product installed, without any MDE or Passive application instance, 
	but the script will handle the existance of instances or the case of a missing basic application installation.
	
.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

Write-host -ForegroundColor Green "`nStart of ConfigureInitiate script`n"

function robocopyZipFiles
{
	param
	(
		[string] $sourceDir,
		[string] $destinationDir		
	)
	Write-host -ForegroundColor Yellow "Copying directory $sourceDir to $destinationDir"
	robocopy /z /e $sourceDir  $destinationDir 
	Write-host -ForegroundColor Yellow "Copy complete"
}

# Read all required variables from the parameters passed into this script.
$DestinationDir = [String]$EnvironmentConfig.InitiateDestinationDir
$Database = [String]$EnvironmentConfig.InitiateDatabase	
$Prefix = [String]$EnvironmentConfig.InitiateDatabasePrefix	

$EnvAccount = [String]$MachineConfig.InitiateEnvAccount	
$Account = [String]$MachineConfig.InitiateAccount	
$Password = [String]$MachineConfig.InitiatePassword
$InitateSourceDir = [String]$EnvironmentConfig.InitiateDirectory 
$InitiateDir = "e:\mpi\product"
$InitiateBatFile = "C:\hwebsource\initiate\unattended.cmd"

# Check whether the basic Initiate executables are installed	
if (-not(Test-Path -path $InitiateDir))
{ 
	Write-host -ForegroundColor Yellow "Initiate application is not installed"
	Write-host -ForegroundColor Yellow "Create Initiate application directory"
	New-Item -Path $InitiateDir -itemType directory | Out-Null 
	Write-host -ForegroundColor Yellow "Install Initiate application"
	pushd C:\hwebsource\initiate
	./unattended.cmd
	popd

	if (Test-Path $InitateSourceDir)
	{
		robocopyZipFiles -Directory $InitateSourceDir -DestinationDir $DestinationDir
	}
	else
	{
		Write-host -ForegroundColor Red "Source Directory $InitateSourceDir does not exist"
		exit
	}
}	

# Add the Initiate executable path to the Windows environment Path variable
$path_var = [Environment]::GetEnvironmentVariable("PATH","Machine")
if ($path_var -notmatch "E:\\mpi\\product\\Engine8.7.0\\bin")
{
	Write-host -ForegroundColor Yellow "Add the Initiate executable path to the Windows environment Path variable"
	$BinPath = $Env:Path + ";E:\mpi\product\Engine8.7.0\bin"
	[Environment]::SetEnvironmentVariable("PATH", "$BinPath", "Machine")
}
# Add the Initiate executable path to the Windows environment Path variable
if ($path_var -notmatch "E:\\mpi\\product\\Engine8.7.0\\jre")
{
	Write-host -ForegroundColor Yellow "Add the Initiate Engine executable path to the Windows environment Path variable"
	$JrePath = $Env:Path + ";E:\mpi\product\Engine8.7.0\jre"
	[Environment]::SetEnvironmentVariable("PATH", "$JrePath", "Machine")
}
# Optionally, read back the Environment Path Variable as [Environment]::GetEnvironmentVariable("PATH","Machine")

# The initiate application configuration is stored in conf files. These environment-specific settings in 
# those conf files are extracted from the data in the env.set.bat file.
$initiate_envsetfile = "E:\mpi\project\initiate\scripts\env.set.bat"
if (-not(Test-Path -path $initiate_envsetfile))
{ 
	Write-host -ForegroundColor Red "Environment-specific settings file 'Env.set.bat' does not exist at location $initiate_envsetfile"
	exit
}

# START Configure the SQL Alias so that Initiate can connect to the SQL Instance name on the specific port
# Specify the database server parameters
# Need to add $Server_DatabaseServer to the BuildoutConfig.config
$ServerAlias =$Server_DatabaseServer+"ALIAS"
$ServerName = $Server_DatabaseServer+"\i02"
$Protocol="TCP"
$PortNumber ="49102"
$ip = [System.Net.Dns]::GetHostAddresses("$Server_DatabaseServer") | foreach {echo $_.IPAddressToString }
        
# Put the database server alias and database IP into the Host file
$hostFile="C:\Windows\System32\drivers\etc\hosts"
if(test-path $hostFile) {
	$Sel = select-string -pattern $ServerAlias -path $hostFile 
	if($sel -eq $null) {
		write-host  -ForegroundColor Yellow "Adding database alias to the Host file"
		add-Content -path $hostFile -value "`n$ip 		$ServerAlias"
	}
	else {
		write-host  -ForegroundColor Yellow "Adding database alias already exists in Host file"
	}
}
else 
{
	write-host  -ForegroundColor Red "Cannot process without the Host File"
	exit
}

# Set up the SQL Server Alias in the registry
$aliasValue = "DBMSSOCN,{0},{1}" -f $ServerName,$PortNumber

if (!(test-path 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo'))
{
	New-item -path 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client' -Name 'ConnectTo'
}
sleep 2
if (test-path 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo')
{
	Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\MSSQLServer\Client\ConnectTo' -Name $ServerAlias -Value $aliasValue
}
sleep 5

# Enter the environment-specific settings into that env.set.bat file, including the multi-node SQL alias
$envpattern=@("set MAD_DBSVR=*.*","set MAD_DBPORT=*.*","set MAD_DBPASS=*.*","set MAD_ENGUSER=*.*","set MAD_ENGPASS=*.*","set MAD_AUDIT=1","set MAD_DEBUG=1","set MAD_TRACE=1","set MAD_DBSQL=1","set MAD_RHPATH=*.*","set MAD_DBPREFIX=*.*","set MAD_VER=*.*","set MAD_DIR=*.*","set MAD_DIRESC=*.*")
$envreplace=@("set MAD_DBSVR=$ServerAlias","set MAD_DBPORT=$PortNumber","set MAD_DBUSER=$Account","set MAD_DBPASS=$Password","set MAD_ENGUSER=$EnvAccount","set MAD_ENGPASS=$Password","set MAD_AUDIT=0","set MAD_DEBUG=0","set MAD_TRACE=0","set MAD_DBSQL=0","set MAD_RHPATH=","set MAD_DBPREFIX=$Prefix","set MAD_VER=DEFAULT","set MAD_DIR=","set MAD_DIRESC=")
# END Configure the SQL Alias so that Initiate can connect to the SQL Instance name on the specific port

for ($i = 0 ; $i -le $envpattern.length - 1 ;$i++)
{
	(Get-Content $initiate_envsetfile) | 
	Foreach-Object {$_ -replace $envpattern[$i], $envreplace[$i]} | 
	Set-Content $initiate_envsetfile
}

# Now write the environment-specific settings intro the Passive Server configuration file
$initiate_passsivepropertiesfile = "E:\mpi\Project\Initiate\passive\conf\PassiveServer.properties"
if (-not(Test-Path -path $initiate_passsivepropertiesfile))
{ 
	Write-host -ForegroundColor Red "Environment-specific settings file 'PassiveServer.properties' does not exist at location $initiate_passsivepropertiesfile"
	exit
}

# Read the credentials for the  Passive Server service to connect to the Initiate MDE service from the  Environment.DTD file
pushd e:\relayhealth\deployhelp
$dtd = .\ParseDTD.ps1
$PassivePassword=$dtd.NIMPassword
$PassiveAccount=$dtd.NIMUserId
popd

# Now enter the environment-specific settings into that PassiveServer.properties file
$passsiveenvpattern=@("UsrPass=*.*","UsrName=*.*")
$passsiveenvreplace=@("UsrPass=$PassivePassword","UsrName=$PassiveAccount")

for ($i = 0 ; $i -le $passsiveenvpattern.length - 1 ;$i++)
{
	(Get-Content $initiate_passsivepropertiesfile) | 
	Foreach-Object {$_ -replace $passsiveenvpattern[$i], $passsiveenvreplace[$i]} | 
	Set-Content $initiate_passsivepropertiesfile
}

sleep 3
# Now apply the configuration to the Initiate MDE instance and create the service instance. 
# This will remove and re-create any existing instance.
pushd E:\mpi\project\initiate\scripts
./initiatesetup.ps1 $Prefix

sleep 2
# Now apply the configuration to the Initiate Passive instance and create the service instance. 
# This will remove and re-create any existing instance. Starts the Initiate services
./installpassive.bat
popd

Write-Host "Changing Initiate Monitor Service logon to  $initacct" -ForegroundColor Green
Stop-Service -Name "MPINETDEFAULT" -Force

sleep 10
sc.exe config "MPINETDEFAULT" obj= "$initacct" password= $initpwd

sleep 10

Start-Service -Name "MPINETDEFAULT" -Confirm:$false
sleep 10

start-Service -Name "Initiate PassiveServer 8.7.0" -Confirm:$false



Write-host -ForegroundColor Green "`nEnd of ConfigureInitiate script`n"

#Check logs for full completion!!!!