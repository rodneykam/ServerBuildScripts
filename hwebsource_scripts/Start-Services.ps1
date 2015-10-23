#.\Start-Services.ps1 (.\Get-RelayServicesConfiguration.ps1)
param($services)

foreach ($serviceDefinition in $services) {
	if (($serviceDefinition.enabledDTDValue -eq $true) -or ($serviceDefinition.enabledDTDValue -eq $null)) {
	    write-host "===================================="
	    write-host "Processing Site Definition: "
	    $serviceDefinition.GetEnumerator() | sort name 
	    write-host "===================================="

		$service = Get-Service | where {$_.name -eq $serviceDefinition.name}
	
		$numberMaxAttempt = 3
		$numberAttempt = 1

		$started = $FALSE
		
		if (($service -ne $null) -and ($serviceDefinition.startupType -ne 'Disabled')) {
			do {
				try {
					Start-Service $service.name -erroraction 1
					
					$started = $TRUE            
					write-host -ForegroundColor Green $service.name +  "Started Successfully." 
				}
				catch [System.Exception] 
				{
				
					
					$message = "Exception occurred while trying to execute [Start-Service " + $service.name + "]:" + $_.Exception.ToString()
					
					write-host -ForegroundColor Yellow $message
					
					if ($numberAttempt -gt $numberMaxAttempt) {                             
						$message = "Cannot execute [Start-Service " + $service.name + "] after " + $numberAttempt + " attempt : " + $_.Exception.ToString()
						throw $message
					}
					else {
						#Just wait a second before retrying
					   Start-Sleep -s 1
					}      
					 
					$numberAttempt = $numberAttempt + 1
				}
			}  while (!$started)
		}	
	}
}