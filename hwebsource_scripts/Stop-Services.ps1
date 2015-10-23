#.\Stop-Services.ps1 (.\Get-RelayServicesConfiguration.ps1)
param($services)

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
		
			do {
				try {
					Stop-Service $service.name -Force -erroraction 1
					
					$stopped = $TRUE      
					write-host -ForegroundColor Green $service.name "stopped Successfully." 
				}
				catch [System.Exception]
				{
					$message = "Exception occurred while trying to execute [Stop-Service" + $service.name + " -Force]:" + $_.Exception.ToString()
					write-host -ForegroundColor Yellow $message
					
					if ($numberAttempt -gt $numberMaxAttempt)
					{  
						#Killing the process was already attempted
						if ($processKilled) {
							$message = "Cannot execute [Stop-Service " + $service.name + " -Force] after " + $numberAttempt + " attempt : " + $_.Exception.ToString()
							throw $message
						}
						else {
							#Get the process name, without the extension
							$exename = $serviceDefinition.exename
							if (!([string]::IsNullOrEmpty($exename))) {	$exename = $exename.Substring(0,$exename.LastIndexOf('.')).split('\')[-1] }
							
							#Getting the process list with where-object wont cause an exception if not found
							$process =  Get-Process | Where-Object {$_.name -eq $exename}
							if ([string]::IsNullOrEmpty($process)) {
								write-host -ForegroundColor Yellow "Cannot find the process $exename"
							}
							else {
								Stop-Process -PassThru $process -Force
								Start-Sleep -s 1
							}
							
							$processKilled = $TRUE
						}
					}
					else
					{
						#Just wait a second before retrying
					   Start-Sleep -s 1
					}      
					 
					$numberAttempt = $numberAttempt + 1
				}
			}  while (!$stopped)
		}
	}
}
