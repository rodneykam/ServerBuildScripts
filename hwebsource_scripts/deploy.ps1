param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig,
[switch]$nodatabase
)

$release = [String]$EnvironmentConfig.BuildNumber
$serviceUser  = [String]$MachineConfig.HVRelayServicesAccount
$servicePassword  = [String]$MachineConfig.RelayServicesPassword
$domainHostName = [String]$EnvironmentConfig.FQDN
$scheduledUser = [String]$MachineConfig.ScheduledTaskAccount
$scheduledPassword = [String]$MachineConfig.ScheduledTaskPassword

.\unzipversion.ps1 -rhver $release -Approot Applications -LocalScripts RelayHealthDeployHelp

pushd E:\RelayHealth\Deployhelp
if($nodatabase)
{
.\deploy.ps1 -release $release -domainHostName $domainHostName -serviceUser $serviceUser -servicePassword $servicePassword -scheduledUser $scheduledUser -scheduledPassword $scheduledPassword -nodatabase -isProduction
}
else
{
.\deploy.ps1 -release $release -domainHostName $domainHostName -serviceUser $serviceUser -servicePassword $servicePassword -scheduledUser $scheduledUser -scheduledPassword $scheduledPassword #-isProduction #-nodatabase
}



popd