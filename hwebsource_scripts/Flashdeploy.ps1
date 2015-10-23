param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

$release = [String]$EnvironmentConfig.BuildNumber
$serviceUser  = [String]$MachineConfig.RelayServicesAccount
$servicePassword  = [String]$MachineConfig.RelayServicesPassword
$domainHostName = [String]$EnvironmentConfig.FQDN
$scheduledUser = [String]$MachineConfig.ScheduledTaskAccount
$scheduledPassword = [String]$MachineConfig.ScheduledTaskPassword
$ServerName = [String]$MachineConfig.HwebName

Function CopyFiles
{
	param (
		$SourceFolder="C:\Hwebsource\Scripts",
		$DestinationFolder,
		$file)

	
	robocopy /E /z $SourceFolder $DestinationFolder $file


	
}

./install_blackbox.bat