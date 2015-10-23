#.\Stop-Services.ps1 (.\Get-RelayServicesConfiguration.ps1)
param($services)
<#
pushd E:\RelayHealth\Deployhelp
$services = .\Get-RmqServicesConfigurations.ps1 
popd
#>
foreach ($serviceDefinition in $services){
	if (($serviceDefinition.enabledDTDValue -eq $true) -or ($serviceDefinition.enabledDTDValue -eq $null)) {  
		write-host "===================================="
		write-host "Processing Site Definition: "
		$serviceDefinition.GetEnumerator() | sort name 
		write-host "===================================="

		$service = Get-Service | where {$_.name -eq $serviceDefinition.name}
		if ($service -ne $null) {

			$numberMaxAttempt = 3
			$numberAttempt = 1
			$processKilled = $FALSE
			$stopped = $FALSE
		
		
                try
	{
		sc.exe stop $service.name

        sleep 3

        
		$ServiceNamePID = get-service | where {($_.Status -eq 'StopPending' -or $_.Status -eq 'stopping') -and ($_.Name -eq $service.name)}
		$servicePID = (Get-wmiobject win32_service| Where {$_.Name -eq $ServiceNamePID.Name } ).processID
		$servicePID
        Stop-Process $ServicePID -force

	}
	catch 
	{
		<#$ServiceNamePID = get-service | where {($_.Status -eq 'StopPending' -or $_.Status -eq 'stopping') -or ($_.Name -eq $service.name)}
		$servicePID = (Get-wmiobject win32_service| Where {$_.Name -eq $ServiceNamePID.Name } ).processID
        $servicePID #>
		#Stop-Process $ServicePID -force
	}    
		}
	}
}
