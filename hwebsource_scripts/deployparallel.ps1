param (
	[string] $release,					# Code version e.g. 10.1.0.12345
	[switch] $unzipcode = $true,
	[string] $corpsiterelease = $null,
	[switch] $unzipcorpsite = $true,
	[string] $serviceUser,
	[string] $servicePassword,
	[string] $domainHostName,			# Pool name - e.g. "SCLUST.RELAYHEALTH.COM"
	[string] $scheduledUser,
	[string] $scheduledPassword,
	[switch] $whitelistFlag = $false,	# Flag used to enable whitelist
	[switch] $isProduction,				# Flag used to disable testing/simulator services on production systems
	[switch] $NoDatabase = $false,				# Flag used when databsae is not present
	[bool]	 $isAutoDeploy = $false,		# Flag to indicate deploy.ps1 is being called from Auto Deployment Site
	$credentials,
	$BuildTypesParam  #Contains Credential structure:  @{type = "" ; identifier = "" ; username = "" ; password = ""},@{...}
)

import-module WebAdministration -errorAction SilentlyContinue
import-module ServerManager -errorAction SilentlyContinue

$ErrorActionPreference = "stop"


$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"
$buildtypes =@()

write-host -foregroundcolor GREEN "===================================="
write-host -foregroundcolor GREEN "=         Start deployment   $BuildTypesParam       ="
write-host -foregroundcolor GREEN "===================================="
write-host -foregroundcolor GREEN "starting deploy.ps1 on $computername"

function WaitProcessJobs ($jobs)
{
		write-host "Parallel Deploy out of loop 1"
		#Get-Job
		(Get-Job).count
		(Get-Job -State Running).count
		
		wait-job -job  $jobs

		write-host "Parallel Deploy out of loop 3"
		$failedjobs =@()
		$successjobs =@() 	
		foreach ($job in $jobs)
		{
			$jfname = $job.name

			if($job.state -eq 'Failed')
			{
				#$jf
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display Started--------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				
				receive-job $job -ea continue
				write-host ($job.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Yellow
				
				$failedjobs += $job.name
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display Stopped---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				remove-job -job $job 
			}
			else
			{	
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display started---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				receive-job $job -ea continue
				
				$successjobs += $job.name
				
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display Stopped---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				#write-host (receive-job $job) -ForegroundColor Green -ea silentlycontinue
				remove-job -job $job
			}


		}

		write-host "Following jobs have been successful $successjobs"
		$successjobs.count

		write-host "Following jobs have failed $Failedjobs"
		$Failedjobs.count
		
			
		get-job |remove-job
		
} 
	

function ProcessJobs ($jobs)
{
		write-host "Parallel Deploy out of loop 1"
		#Get-Job
		(Get-Job).count
		(Get-Job -State Running).count
		
		while(Get-Job -State Running)
		{
			foreach ($job in $jobs)
			{
				$jName = $job.Name
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jName Display has Started---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				receive-job $job -ea continue
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jName Display has Stopped----------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				
			}
			write-host "Parallel Deploy in the loop 2"
		#	Get-Job | ? {$_.State -eq 'running'} | % {Receive-Job -keep $_}
			start-sleep -seconds 15
		}
		# wait-job -job  $jobs
		write-host "Parallel Deploy out of loop 3"
		$failedjobs =@()
		$successjobs =@() 	
		foreach ($job in $jobs)
		{
			$jfname = $job.name

			if($job.state -eq 'Failed')
			{
				#$jf
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				Write-Host -f YELLOW "---------------------Job $jfName Final Display Started---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				
				receive-job $job -ea continue
				write-host ($job.ChildJobs[0].JobStateInfo.Reason.Message) -ForegroundColor Yellow
				
				$failedjobs += $job.name
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display Stopped---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				remove-job -job $job 
			}
			else
			{	
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display started---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				receive-job $job -ea continue
				
				$successjobs += $job.name
				
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				Write-Host -f YELLOW "---------------------Job $jfName Final Display Stopped---------------------"
				Write-Host -f YELLOW "--------------------------------------------------------------------------------"
				
				#write-host (receive-job $job) -ForegroundColor Green -ea silentlycontinue
				remove-job -job $job
			}


		}
		
		
		write-host "Following jobs have been successful $successjobs"
		$successjobs.count

		write-host "Following jobs have failed $Failedjobs"
		$Failedjobs.count
			
		get-job |remove-job
		
} 
	

&{#TRY
	pushd E:\RelayHealth\Deployhelp
	
	$allbuildtypes = 
	@(
		@{
			name="Applications";
			deployhelp = "RelayHealthDeployHelp";
			servicecfg = "Get-RelayServicesConfigurations.ps1";
			deployhelploc = "E:\RelayHealth\DeployHelp\";
			deployscript = "core.deployversion.ps1";
			serviceset= "E:\RelayHealth\Deployhelp\Get-RelayServicesConfigurations.ps1";
			servicesetup= "E:\RelayHealth\Deployhelp\Configure-Services.ps1"
		},
		@{
			name="InteropApplications";
			deployhelp="InteropApplicationsDeployHelp";
			servicecfg="Get-InteropServicesConfigurations.ps1";
			deployhelploc = "E:\InteropApplications\DeployHelp\";
			deployscript = "InteropApplications.deployversion.ps1";
			serviceset= "E:\RelayHealth\Deployhelp\Get-InteropServicesConfigurations.ps1";
			servicesetup= "E:\RelayHealth\Deployhelp\Configure-Services.ps1"
		},
		@{	name="HydroPlatform";
			deployhelp="HydroPlatformDeployHelp";
			servicecfg="Get-HydroPlatformServicesConfigurations.ps1";
			deployhelploc = "E:\HydroPlatform\HydroPlatformDeployHelp\";
			deployscript = "HydroPlatform.deployversion.ps1";
			serviceset= "E:\hydroplatform\hydroplatformDeployhelp\Get-HydroPlatformServicesConfigurations.ps1";
			servicesetup= "E:\hydroplatform\hydroplatformDeployhelp\Configure-TopshelfServices.ps1"
		},
		@{	name="Verification";
			deployhelp="VerificationDeployHelp";
			servicecfg="";
			deployhelploc = "E:\Verification\VerificationDeployHelp\";
			deployscript = "Verification.deployversion.ps1";
			serviceset= "";
			servicesetup= ""
		}
	)

	$DefaultScripts =$false
	
	foreach ($buildtype in $allbuildtypes)
	{
		foreach ($buildtypeparam in $buildtypesparam)
		{
			if ($buildtypeparam -eq $buildtype.name)
			{
			
			$buildtypes += $buildtype
				if ($buildtype.name -eq "Applications")
				{
					$DefaultScripts =$true
				}
			}
		}
	}
	
	foreach ($buildtype in $buildtypes)
		{
		
			$c = $buildtype.name
			write-host "$c  $Defaultscripts"
		}
	
	
	
	
	 #### Stopping Services ####
	
	if (!($NoDatabase)) 
	{
		$jobs = @()
		
		get-job |remove-job
		
		foreach ($buildtype in $buildtypes)
		{
			$scriptblock  = 
			{
			param ($release,$AppRoot,$serviceset)
			pushd e:\relayhealth\deployhelp
				write-host -foregroundcolor GREEN "Stop $approot services"
				
				invoke-expression "E:\RelayHealth\Deployhelp\Stop-Services.ps1 ($serviceset –devroot `"`" –useProductionPaths)"	
			popd			
				
			}
			$jobname = "stop "+ $buildtype.name +" type service on "+ "$computername"  

			if($buildtype.serviceset -ne "")
			{	
				$jobs += start-job -scriptblock $scriptblock -arg $release,$buildtype.name,$buildtype.serviceset -name $jobname
			}	
		}
				
			
		
		$scriptblock = 
			{
				write-host -foregroundcolor GREEN "Stop initiate services"
				
				invoke-expression "E:\RelayHealth\Deployhelp\Stop-Services.ps1 (E:\RelayHealth\Deployhelp\Get-InitiateServicesConfigurations.ps1 –useProductionPaths)"
			} 
		if ($defaultscripts)
		{
		$jobname =  "initiate" +" on "+ "$computername"  		
		$jobs += start-job -scriptblock $scriptblock  -name $jobname
		}
		
		if($jobs)
		{	
		measure-command {waitProcessJobs $jobs}
		}
		
	} 

	
	 #### unzipping and machinekey  and event log####
	
	
	if ($unzipcode) 
	{
		Copy-Item "E:\RelayHealth\Deployhelp\unzip.version.ps1" "E:\RelayHealth\"
		$jobs = @()	
				
		get-job |remove-job

		pushd E:\RelayHealth\
		
		foreach ($buildtype in $buildtypes)
		{
			$scriptblock  = 
			{
			param ($release,$AppRoot,$LocalScripts)
					
			write-host -foregroundcolor GREEN "Unzip $AppRoot files and  $LocalScripts with  build number $release" 

			E:\RelayHealth\unzip.version.ps1 -rhver $release -AppRoot $AppRoot  -Localscripts $LocalScripts | out-host
					
			}
			
			$jobname = "unzip"+ $buildtype.name +" on "+ "$computername" 			
			$jobs += start-job -scriptblock $scriptblock -arg $release,$buildtype.name,$buildtype.deployhelp -name $jobname
				
		}
		
		popd
		
		measure-command {WaitProcessJobs $jobs}
	}
	

	 #### generate config and configure services####
	
	$jobs = @()	
	get-job |remove-job	
	
	foreach ($buildtype in $buildtypes)
	{
		<#
		$scriptblock  = 
		{
		param ($release,$AppRoot,$deployfolder,$deployscript,$serviceset,$servicesetup,$serviceuser,$servicepassword)
		 
		
		
		write-host -foregroundcolor GREEN "Deploy $AppRoot code"
		$FullDeployscript = $deployfolder +"\" + $deployscript
		
		invoke-expression "$FullDeployscript $release" 
		
		write-host -foregroundcolor GREEN "Configure $AppRoot services"
		pushd e:\relayhealth\deployhelp
		
		invoke-expression "$servicesetup($serviceset –devroot `"`" –useProductionPaths) -credentials -username `"$serviceUser`" -password `"$servicePassword`" "
		popd 
					
		}
		$jobname = "Genarate Config and Create Serverice for "+ $buildtype.name +" on " +"$computername"			
		$jobs += start-job -scriptblock $scriptblock -arg $release,$buildtype.name,$buildtype.deployhelploc,$buildtype.deployscript,$buildtype.serviceset,$buildtype.servicesetup,$serviceuser,$servicePassword -name $jobname
		#>
		$AppRoot = $buildtype.name
		$deployfolder = $buildtype.deployhelploc
		$deployscript = $buildtype.deployscript
		write-host -foregroundcolor GREEN "Deploy $AppRoot code"
		$FullDeployscript = $deployfolder +"\" + $deployscript
		
		invoke-expression "$FullDeployscript $release" 
				
	} 
	
	$scriptblock = 
			{
				
				write-host -foregroundcolor GREEN "Configure event sources"
				invoke-expression "E:\RelayHealth\Deployhelp\Configure-EventSources.ps1 (E:\RelayHealth\Deployhelp\Get-RelayEventSources.ps1)"

				write-host -foregroundcolor GREEN "Configure event logs"
				invoke-expression "E:\RelayHealth\Deployhelp\Configure-EventLogs.ps1 (E:\RelayHealth\Deployhelp\Get-RelayEventLogs.ps1)"
				
				pushd e:\relayhealth\deployhelp	
				write-host -foregroundcolor GREEN "Configure machine key from DTD"
				invoke-expression "E:\RelayHealth\Deployhelp\MachineKey.ps1"
				popd
				
			} 
	
	if ($defaultscripts)
	{
	$jobname = "Configure event log and machine key on " + "$computername"			
				
	$jobs += start-job -scriptblock $scriptblock  -name $jobname
	}
	if ($jobs)
	{	
	measure-command {waitProcessJobs $jobs}
	}
	
	#### config iis , services , schedule task and create folders####
	
	$jobs = @()
		
	get-job |remove-job
		
	$scriptblock = 
	{param($scheduleduser,$scheduledpassword)
		pushd e:\relayhealth\deployhelp
		write-host -foregroundcolor GREEN "Create folders"
		E:\RelayHealth\Deployhelp\CreateFolders.ps1
		
		write-host -foregroundcolor GREEN "Configure scheduled tasks"
		E:\RelayHealth\Deployhelp\CreateScheduledTasks.ps1 -username "$scheduledUser" -password "$scheduledPassword" -useProductionPaths
		popd	
	}
	
	if ($defaultscripts)
	{
	$jobname = "Create Scheduled Task on " + "$computername"			
	
	$jobs += start-job -scriptblock $scriptblock  -arg $scheduleduser,$scheduledpassword -name $jobname
	}
	
	
	
	foreach ($buildtype in $buildtypes)
	{
		$scriptblock  = 
		{
		param ($release,$AppRoot,$deployfolder,$deployscript,$serviceset,$servicesetup,$serviceuser,$servicepassword)
		 
		
		write-host -foregroundcolor GREEN "Configure $AppRoot services"
		pushd e:\relayhealth\deployhelp
		invoke-expression "$servicesetup($serviceset –devroot `"`" –useProductionPaths) -credentials -username `"$serviceUser`" -password `"$servicePassword`" "
		popd
					
		}
		
		$jobname = "Create " + $buildtype.name + "type Services on " + "$computername"
		
		if($buildtype.serviceset -ne "")
		{	
			$jobs += start-job -scriptblock $scriptblock -arg $release,$buildtype.name,$buildtype.deployhelploc,$buildtype.deployscript,$buildtype.serviceset,$buildtype.servicesetup,$serviceuser,$servicePassword -name $jobname
		}
		
				
	}
	
	$scriptblock = 
	{param($isProduction,$domainHostName,$credentials)
	
			pushd e:\relayhealth\deployhelp	
			write-host -foregroundcolor GREEN "Configure websites"
			if ($isProduction) {
				E:\Relayhealth\Deployhelp\Get-RelayIISConfigurations.ps1 -devroot "" -fqdn "$domainHostName" -useProductionPaths -isProduction -creds $credentials | E:\Relayhealth\Deployhelp\Configure-IISSite		
				
				pushd e:\relayhealth\deployhelp	
				write-host -foregroundcolor GREEN "Configuring advanced logging"
				invoke-expression "E:\RelayHealth\Deployhelp\logging.ps1"
				popd
			}
			else{
				E:\Relayhealth\Deployhelp\Get-RelayIISConfigurations.ps1 -devroot "" -fqdn "$domainHostName" -useProductionPaths -creds $credentials | E:\Relayhealth\Deployhelp\Configure-IISSite
				
				write-host -foregroundcolor GREEN "Configure test web server settings"
				E:\Relayhealth\Deployhelp\ConfigTestWeb.ps1 -domainHostName "$domainHostName" -appHostName "app.$domainHostName"
				
				pushd e:\relayhealth\deployhelp	
				write-host -foregroundcolor GREEN "Configuring advanced logging"
				invoke-expression "E:\RelayHealth\Deployhelp\logging.ps1"
				popd
			}
			popd
	}
	if ($defaultscripts)
	{
	$jobname = "Configure IIS on " + "$computername"	
	$jobs += start-job -scriptblock $scriptblock  -arg $isProduction,$domainHostName,$credentials -name $jobname
	}
	if($jobs)
	{
	measure-command {WaitProcessJobs $jobs}
	}
	#### start services ####
	
	if (!($NoDatabase)) 
	{
		$jobs = @()
		
		get-job |remove-job
		
		$scriptblock = 
			{
				write-host -foregroundcolor GREEN "Start initiate services"
				
				invoke-expression "E:\RelayHealth\Deployhelp\Start-Services.ps1 (E:\RelayHealth\Deployhelp\Get-InitiateServicesConfigurations.ps1 –useProductionPaths)"
				
				
				
				
			}
		if ($defaultscripts)
		{		
		$jobs += start-job -scriptblock $scriptblock  -name "initiate"
		}		
		$scriptblock = 
			{
				write-host -foregroundcolor GREEN "Start windows services"
				pushd e:\relayhealth\deployhelp
				invoke-expression "E:\RelayHealth\Deployhelp\Start-Services.ps1 (E:\RelayHealth\Deployhelp\Get-WindowsServicesConfigurations.ps1)"
				popd
				
				
				
				Restart-Service W3SVC
			} 
		if ($defaultscripts)
		{
		$jobs += start-job -scriptblock $scriptblock  -name "windows services"
		}
		foreach ($buildtype in $buildtypes)
		{
			$scriptblock  = 
			{
			param ($release,$AppRoot,$serviceset)
				pushd e:\relayhealth\deployhelp
				write-host -foregroundcolor GREEN "Start $approot services"
				invoke-expression "E:\RelayHealth\Deployhelp\Start-Services.ps1 ($serviceset –devroot `"`" –useProductionPaths)"	
				popd	
			}
			$jobname = "stop "+ $buildtype.name +" type service on "+ "$computername"  
			
			if($buildtype.serviceset -ne "")
			{
				$jobs += start-job -scriptblock $scriptblock -arg $release,$buildtype.name,$buildtype.serviceset  -name $jobname
			}	
		}
		if($jobs)
		{
		measure-command {waitProcessJobs $jobs}
		}
	}

	
	
	
	popd
}
trap [Exception]#CATCH
{
	throw $("ERROR during Code Deployment / IIS Configuration - : " + $_.Exception.Message)
	popd
	Exit -1
}
write-host -foregroundcolor GREEN "end of deploy.ps1"
write-host -foregroundcolor GREEN "===================================="
write-host -foregroundcolor GREEN "=        Deployment Complete       ="
write-host -foregroundcolor GREEN "===================================="
