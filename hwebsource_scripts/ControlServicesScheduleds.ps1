param([switch]$MaintenanceMode,
	  [switch]$StopAllMode,
	  [switch]$StartAllMode,
	  [switch]$CheckAllRunMode,
	  [switch]$CheckAllStopMode,
	  [switch]$DisableServices
	  ) ## if MaintenanceMode,Stop all RelayHealth Windows Services and Disable All Scheduled Tasks

$ErrorActionPreference = "stop"

# Change to the DeployHelp directory - this allows the script to be run remotely through WinRM
pushd E:\RelayHealth\DeployHelp
write-host -f green "Entering ControlServicesScheduleds.ps1";
write-host -f green "- MaintenanceMode set to $MaintenanceMode"

function CheckServiceDependency
{
	param (
		[Object] $service,
		[string] $dependentOnServiceName
	)
	
	if($dependentOnServiceName -ne "")
	{
		$isDependentSet = $false
		foreach( $dependentService in $service.RequiredServices)
		{
			if($dependentService.Name -eq $dependentOnServiceName)
			{
				$isDependentSet = $true
				break
			}
		}
		
		if(!$isDependentSet)
		{
			$serviceName = $service.name
			throw $("'$serviceName service' has not been installed to require '$dependentOnServiceName' service to be started.")
		}
	}
}

function GetServiceByName($serviceName)
{
	$service = Get-Service | where {$_.name -eq $serviceName}
	
	if($service -eq $null)
	{
		#throw (New-Object System.NullReferenceException -arg "Can't find service '$serviceName'")
		write-host -ForegroundColor Yellow "$serviceName Does not exist" 
		
	}
	
	return $service
}

function Stop-Services($services)
{
	Write-Host
	Write-Host "STOPPING SERVICES..." -ForegroundColor Yellow
	
	if ($services -ne $null)
	{
		foreach ($serviceDefinition in $services)
		{
			$service = GetServiceByName $serviceDefinition.name
			
			if ($service.Status -eq "Running")
			{
				Write-Host "Attempting to stop service " -NoNewline -ForegroundColor DarkGray
				Write-Host $service.name -NoNewline -ForegroundColor Cyan
				Write-Host "..." -ForegroundColor DarkGray
				Stop-Service $service.name -Force
			}
			
			CheckServiceDependency -service $service -dependentOnServiceName $serviceDefinition.dependentOn
		
		
		   
		      If($DisableServices)
			  {
		                     $isEnabled  = gwmi win32_service | ? { $_.name -eq $service.name -and  $_.startmode -ne 'disabled'}
		                   if($isEnabled )
						     {
		                      # $isEnabled | % -process { SC.EXE config $isEnabled.Name start= disabled}
							   & { SC.EXE config $service.Name start= disabled}
							   sleep 2
		                     }
		      }	
		}	  
      Confirm-ServicesWereStopped $services			  
	}
	else
	{
		throw (New-Object System.NullReferenceException -arg "Can't stop services.")
	}
}

function Confirm-ServicesWereStopped($services)
{
	foreach ($serviceDefinition in $services)
	{
		$service = GetServiceByName $serviceDefinition.name
		if (($service.Status -eq "Stopping") -or ($service.Status -eq "Stopped") -or ($service.Status -eq "StopPending"))
		{
			Write-Host "Confirmed service " -NoNewline -ForegroundColor Green
			Write-Host $service.name -NoNewline -ForegroundColor Cyan
			Write-Host " stopped..." -ForegroundColor Green
			if($DisableServices){
			                      $disabled  = gwmi win32_service | ? { $_.name -eq $service.name -and  $_.startmode -eq 'disabled'}
								  If($disabled){
								                Write-Host "Confirmed service " -NoNewline -ForegroundColor Green
			                                    Write-Host $service.name -NoNewline -ForegroundColor Cyan
			                                    Write-Host " Disabled..." -ForegroundColor Green
								               }else{
											         Write-Host "Confirmed service " -NoNewline -ForegroundColor Green
			                                         Write-Host $service.name -NoNewline -ForegroundColor Cyan
			                                         Write-Host " could not be disabled..." -ForegroundColor Green
											        } 
			                    } 
		}
		else
		{
			Write-Host "Confirmed service " -NoNewline -ForegroundColor Red
			Write-Host $service.name -NoNewline -ForegroundColor Cyan
			Write-Host "could not be stopped..." -ForegroundColor Red
			if($DisableServices){
			                      $disabled  = gwmi win32_service | ? { $_.name -eq $service.name -and  $_.startmode -eq 'disabled'}
								  If($disabled){
								                Write-Host "Confirmed service " -NoNewline -ForegroundColor Green
			                                    Write-Host $service.name -NoNewline -ForegroundColor Cyan
			                                    Write-Host " Disabled..." -ForegroundColor Green
								               }else{
											         Write-Host "Confirmed service " -NoNewline -ForegroundColor Green
			                                         Write-Host $service.name -NoNewline -ForegroundColor Cyan
			                                         Write-Host " could not be disabled..." -ForegroundColor Green
											        } 
			                    }      
		}
	}
}

function Start-Services($services)
{
	Write-Host
	Write-Host "STARTING SERVICES..." -ForegroundColor Yellow
	
	if ($services -ne $null)
	{
		foreach ($serviceDefinition in $services)
		{
		   
			$service = GetServiceByName $serviceDefinition.name
			Chk-ServiceEnabled $service.name
			if ($service.Status -eq "Stopped")
			{
				Write-Host "Attempting to start service " -NoNewline -ForegroundColor DarkGray
				Write-Host $service.name -NoNewline -ForegroundColor Cyan
				Write-Host "..." -ForegroundColor DarkGray
				Start-Service $service.name
			}
			
			CheckServiceDependency -service $service -dependentOnServiceName $serviceDefinition.dependentOn
		}
		
		Confirm-ServicesWereStarted $services
	}
	else
	{
		throw (New-Object System.NullReferenceException -arg "Can't stop services.")
	}
}

function Confirm-ServicesWereStarted($services)
{
	foreach ($serviceDefinition in $services)
	{
		$service = GetServiceByName $serviceDefinition.name
		if ($service.Status -eq "Running")
		{
			Write-Host "Confirmed service " -NoNewline -ForegroundColor Green
			Write-Host $service.name -NoNewline -ForegroundColor Cyan
			Write-Host " started..." -ForegroundColor Green
		}
		else
		{
			Write-Host "Confirmed service " -NoNewline -ForegroundColor Red
			Write-Host $service.name -NoNewline -ForegroundColor Cyan
			Write-Host "could not be started..." -ForegroundColor Red
		}
	}
}

function ChangeScheduledTask($status)
{
	write-host "====================================" -ForegroundColor DarkGray
	write-host "Processing Disabled ALL Scheduled Tasks: " -ForegroundColor DarkGray
	$taskFile = "scheduledTasks.csv"
	$tasks = Import-csv $taskFile

	foreach($task in $tasks)
	{
		if(($task -ne $null) -and ($task.scheduleType -ne ""))
		{
			$taskName = $task.taskName
			$taskExist = schtasks /Query /TN $taskName
			if($?)
			{
				$ErrorActionPreference = "continue"
				[void](schtasks /Change /TN $taskName /$status)
				if($LASTEXITCODE -ne 0) {
					write-host "Error $status $taskName at Line 84" -foregroundcolor red
				}
				else
				{
					Write-Host "$status " -NoNewline -ForegroundColor Green
					Write-Host $taskName -NoNewline -ForegroundColor Cyan
					Write-Host "Successful" -ForegroundColor Green
				}
				$ErrorActionPreference = "stop"
			}
		}
	}
}


function RunScheduledTask
{
	write-host "====================================" -ForegroundColor DarkGray
	write-host "Running ALL Scheduled Tasks: " -ForegroundColor DarkGray
	$taskFile = "scheduledTasks.csv"
	$tasks = Import-csv $taskFile
	
	foreach($task in $tasks)
	{
		if(($task -ne $null) -and ($task.scheduleType -ne ""))
		{
			$taskName = $task.taskName
			$taskExist = schtasks /Query /TN $taskName
			if($taskExist)
			{	
				$ErrorActionPreference = "continue" 
				$i =0
				
				schtasks /run /tn $taskName
  				while($true){
				$schstatus=schtasks /query /TN $taskName |Select-String -Pattern "Run_","$taskname"
				$state = $schstatus.tostring().substring(64,7)
				$i++
				if(( $state -eq "Running") -and ($i -le 12)) 
					{"Still running..."}
				else
					{						
						if($state -eq "Ready  ")
						{
							write-host -ForegroundColor Green "The $taskname completed successfuly `n"														
						}
							else
						{
							write-host -ForegroundColor red "The $taskname failed because `n $schstatus `n"
						}
						break					    
					}
				start-sleep -s 5
				}				
				$ErrorActionPreference = "stop"
			}
			else
			{
				write-host -ForegroundColor red "`n Error $taskName Does not Exist on the server`n "
			}
		}
	}
}

function Chk-ServiceEnabled([string] $svcs)
{
	Write-Host
	Write-Host "Checking Services Startuptype..." -ForegroundColor Yellow
	
	if ($svcs -ne $null)
	{
			
			$disabled  = gwmi win32_service | ? { $_.name -eq $svcs -and  $_.startmode -eq 'disabled'}
			if($disabled){	
			              Write-Host "..." $disabled.name -NoNewline -ForegroundColor Cyan
			              $disabled.ChangeStartMode("delayed-auto")
						  sleep 2
			              $enabled =  gwmi win32_service | ? { $_.name -eq $svcs -and  $_.startmode -eq 'auto'}
			
			        if (! $enabled)
			            {
			              $disabled | % -process { SC.EXE config $disabled.Name start= delayed-auto}
						  sleep 2
			               $enabled =  gwmi win32_service | ? { $_.name -eq $svcs -and  $_.startmode -eq 'auto'}
			        if($enabled)
					        {
					        Write-Host $disabled.name "starupmode was changed from disabled to " $enabled.startmode  -ForegroundColor Cyan	
					        }
			 }else{ Write-Host $disabled.name "starupmode was changed from disabled to " $enabled.startmode  -ForegroundColor Cyan	}
			
			
		
		}
		
	}
}	
write-host -f green "Starting ControlServicesScheduleds.ps1";
	
$RelayServices = .\Get-RelayServicesConfigurations.ps1 -devroot "" -useProductionPaths
$InteropServices = .\Get-InteropServicesConfigurations.ps1 -devroot "" -useProductionPaths
$InitiateServices = .\Get-InitiateServicesConfigurations.ps1 -useProductionPaths
$WindowsServices = .\Get-WindowsServicesConfigurations.ps1


if($MaintenanceMode)
{
	###STOP ALL RELAY WINDOWS SERVICES AND CHANGE SCHEDULED TASK DISABLED###
	write-host -f green "Stopping RelayServices";
	Stop-Services $RelayServices
	write-host -f green "Stopping InteropServices";
	Stop-Services $InteropServices
	write-host -f green "Stopping InitiateServices";
	Stop-Services $InitiateServices
	write-host -f green "Stopping Scheduled Tasks";
	
	ChangeScheduledTask DISABLE
}
elseif($StopAllMode)
{
	###STOP ALL RELAY WINDOWS SERVICES AND CHANGE SCHEDULED TASK DISABLED###
	write-host -f green "Stopping RelayServices";
	Stop-Services $RelayServices
	write-host -f green "Stopping InteropServices";
	Stop-Services $InteropServices
	write-host -f green "Stopping InitiateServices";
	Stop-Services $InitiateServices
	write-host -f green "Stopping WindowsServices";
	Stop-Services $WindowsServices
	write-host -f green "Stopping Scheduled Tasks";
	
	ChangeScheduledTask DISABLE
}
elseif($StartAllMode)
{
	###START ALL RELAY WINDOWS SERVICES AND CHANGE SCHEDULED TASK ENABLED###
	write-host -f green "Starting RelayServices";
	Start-Services $RelayServices
	write-host -f green "Starting InteropServices";
	Start-Services $InteropServices
	write-host -f green "Starting InitiateServices - note that Passive Mode service takes 30 seconds to start";
	Start-Services $InitiateServices
	write-host -f green "Starting WindowsServices";
	Start-Services $WindowsServices
	write-host -f green "Starting Scheduled Tasks";
	
	ChangeScheduledTask ENABLE
}
elseif($CheckAllRunMode)
{
	###START ALL RELAY WINDOWS SERVICES AND CHANGE SCHEDULED TASK ENABLED###
	write-host -f green "Checking RelayServices";
	Confirm-ServicesWereStarted $RelayServices
	write-host -f green "Checking InteropServices";
	Confirm-ServicesWereStarted $InteropServices
	write-host -f green "Checking InitiateServices";
	Confirm-ServicesWereStarted $InitiateServices
	write-host -f green "Checking WindowsServices";
	Confirm-ServicesWereStarted $WindowsServices
	write-host -f green "Running Scheduled Tasks";
	
	RunScheduledTask
	#ChangeScheduledTask ENABLE
}
elseif($CheckAllStopMode)
{
	###START ALL RELAY WINDOWS SERVICES AND CHANGE SCHEDULED TASK ENABLED###
	write-host -f green "Checking RelayServices";
	Confirm-ServicesWereStopped $RelayServices
	write-host -f green "Checking InteropServices";
	Confirm-ServicesWereStopped $InteropServices
	write-host -f green "Checking InitiateServices";
	Confirm-ServicesWereStopped $InitiateServices
	write-host -f green "Checking WindowsServices";
	Confirm-ServicesWereStopped $WindowsServices
	#write-host -f green "Starting Scheduled Tasks";
	
	#ChangeScheduledTask ENABLE
}
else
{
	###START ALL RELAY WINDOWS SERVICES AND CHANGE SCHEDULED TASK ENABLED###
	write-host -f green "Starting RelayServices";
	Start-Services $RelayServices
	write-host -f green "Starting InteropServices";
	Start-Services $InteropServices
	write-host -f green "Starting InitiateServices - note that Passive Mode service takes 30 seconds to start";
	Start-Services $InitiateServices
	write-host -f green "Starting Scheduled Tasks";
	
	ChangeScheduledTask ENABLE
}

popd
write-host -f green "End ControlServicesScheduleds.ps1";
