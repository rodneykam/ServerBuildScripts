param(
[switch]$MaintenanceMode,
[switch]$isProduction
) ## if MaintenanceMode, stop all websites Except Downtime

import-module WebAdministration -errorAction SilentlyContinue

function get-RHDomainHostname
{
	$computer=Get-WmiObject -Class Win32_ComputerSystem
	$name=$computer.name
	$domain=$computer.domain
	$computername="$name"+".$domain"
	$ip=[System.Net.Dns]::GetHostAddresses($computername)
	$ServerIp=$ip | where {$_.IPAddressToString -match "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b"}
	$ServIp=$ServerIp.IPAddressToString
	$FullDomainhostname=([System.Net.Dns]::GetHostEntry($ServIp)).HostName.tostring()
	$index=$FullDomainhostname.IndexOf(".")
	$Domainhostname=$FullDomainhostname.Substring($index+1)
	return $Domainhostname
}

function Wait-ForStatusToChange()
{
	[System.Threading.Thread]::Sleep(5000)
}

function Maintenance-Sites
{
param (
$sites,
[switch]$OutOfMaintenance
)
	
	if ($sites -ne $null)
	{
		pushd IIS:\
			
		foreach ($siteDefinition in $sites)
		{
		   $sitename=$siteDefinition.sitename
			
		    if(test-path ([string]::Format("IIS:Sites\{0}", $sitename)))
		    {
			if($siteDefinition.serverAutoStart -ne $false )
			{	
			    $SiteState =(Get-WebItemState ([string]::Format("IIS:Sites\{0}", $sitename))).Value
		
			    if ($SiteState -eq "Started")
				{
					if ($OutOfMaintenance)
					{
					Write-Host "`nSite $sitename is already started  .. " -NoNewline -ForegroundColor DarkGray
					Confirm-SitesWereStarted $sitename
					
					}
					else
					{
					Write-Host "`nAttempting to stop $sitename .. " -NoNewline -ForegroundColor DarkGray	
					Stop-Website $sitename
					Wait-ForStatusToChange
					Confirm-SitesWereStopped $sitename
					}
				}
			     else
				{
					if ($OutOfMaintenance)
					{
					Write-Host "`nAttempting to start site $sitename ....." -NoNewline -ForegroundColor DarkGray
					Start-Website $sitename
					Wait-ForStatusToChange
					Confirm-SitesWereStarted $sitename
					
					}
					else
					{
					Write-Host "`nSite $sitename is already stopped  .. " -NoNewline -ForegroundColor DarkGray
								
					Confirm-SitesWereStopped $sitename
					}
				}
			
		
			}
			else
			{
				 $SiteState =(Get-WebItemState ([string]::Format("IIS:Sites\{0}", $sitename))).Value
				
			    if (($SiteState -eq "Started") -and ($sitename -ne "downtime"))
				{
					Write-Host "`nThis Site $sitename was configured to be stopped , but it looks started hence stopping the site ...  " -NoNewline -ForegroundColor Gray
					Stop-Website $sitename
					Wait-ForStatusToChange
					Confirm-SitesWereStopped $sitename
				}
			     else
				{
					if ($sitename -eq "downtime")
					{
					
					}
					else
					{
						Write-Host "`nThis Site $sitename was configured to be stopped  ...  " -NoNewline -ForegroundColor Gray		
						Confirm-SitesWereStopped $sitename		
					}
				
				}
			
			
			}
		    }
		    else
		    {
			write-host "`n$sitename site doesnot exist"
		    }
		}
		
			
		popd
	}
	else
	{
		throw (New-Object System.NullReferenceException -arg "Can't stop sites.")
	}
}

function Confirm-SitesWereStopped([string]$sitename)
{

		if ((Get-WebItemState ([string]::Format("IIS:Sites\{0}", $sitename))).Value -eq "Stopped")
		{
			Write-Host "Confirmed site " -NoNewline -ForegroundColor Green
			Write-Host "$site" -NoNewline -ForegroundColor Cyan
			Write-Host "stopped..." -ForegroundColor Green
		}
		else
		{
			Write-Host "Error - site " -NoNewline -ForegroundColor Red
			Write-Host "$site" -NoNewline -ForegroundColor Cyan
			Write-Host "could not be stopped..." -ForegroundColor Red
		}
	
}

function Maintain-DowntimeSite
{
param (
[switch]$OutOfMaintenance
)
	$sitename = "downtime"

	if (!(test-path ([string]::Format("IIS:Sites\{0}", $sitename))))
	 { exit }
		    
	$SiteState =(Get-WebItemState ([string]::Format("IIS:Sites\{0}", $sitename))).Value
	if ($SiteState -eq "stopped")
	 {
		if ($OutOfMaintenance)
		{
		Write-Host "`nSite $sitename was already stopped " -NoNewline -ForegroundColor Yellow
		Confirm-SitesWereStopped $sitename
		}
		else
		{
		Write-Host "`nAttempting to start $sitename " -NoNewline -ForegroundColor Yellow
		Start-Website $sitename
		Wait-ForStatusToChange
		Confirm-SitesWereStarted $sitename
		}
	}
	else
	{
		if ($OutOfMaintenance)
		{
		Write-Host "Attempting to stop site $sitename " -NoNewline -ForegroundColor Yellow
		Stop-Website $sitename
		Wait-ForStatusToChange
		Confirm-SitesWereStopped $sitename
		
		}
		else
		{
		Write-Host "`nSite $sitename was already started  " -NoNewline -ForegroundColor Yellow
		Confirm-SitesWereStarted $sitename
		}
	}
}

function Confirm-SitesWereStarted([string]$sitename)
{
	
	if ((Get-WebItemState ([string]::Format("IIS:Sites\{0}", $sitename))).Value -eq "Started")
		{
			Write-Host "Confirmed site " -NoNewline -ForegroundColor Green
			Write-Host "$site" -NoNewline -ForegroundColor Cyan
			Write-Host "started..." -ForegroundColor Green
		}
		else
		{
			Write-Host "Error - site " -NoNewline -ForegroundColor Red
			Write-Host "$site" -NoNewline -ForegroundColor Cyan
			Write-Host "could not be started..." -ForegroundColor Red
		}
}


$ErrorActionPreference = "stop"

# Change to the DeployHelp directory - this allows the script to be run remotely through WinRM
pushd E:\RelayHealth\DeployHelp
write-host -f green "Entering ControlWebsitesForRelease.ps1";
write-host -f green "- MaintenanceMode set to $MaintenanceMode"

$domainhostname = get-RHDomainHostname

if ($isProduction.isPresent)
{
	$sites= .\Get-RelayIISConfigurations.ps1 -devroot "" -fqdn "$domainHostName" -useProductionPaths -isProduction
}
else
{
	$sites= .\Get-RelayIISConfigurations.ps1 -devroot "" -fqdn "$domainHostName" -useProductionPaths
}


if($MaintenanceMode){

	Write-Host "`nPutting RelayHealth SITES in Maintenance Mode...`n" -ForegroundColor Yellow
	Maintenance-Sites -sites $Sites
	Maintain-DowntimeSite
	}
else
{
	###START ALL WEBSITES,STOP DOWNTIME###
	write-host -f green "Stopping the Downtime (Maintenance Mode) website";
	Maintain-DowntimeSite -OutOfMaintenance
	Maintenance-Sites -sites $Sites -OutOfMaintenance
	
	#Start-Sites $Sites
}
popd

write-host -f green "End ControlWebsitesForRelease.ps1";
