param($prefix)
write-host -foregroundcolor yellow "Creating Initiate" 
./createinitiate.bat 

pushd hklm:\SOFTWARE\ODBC\ODBC.INI

$key ="$prefix"+"Initiate"

$Data_source= test-path $key

popd
if ($Data_source -eq "True")
{	

 write-host -foregroundcolor yellow "Dropping Data source " 
   ./droppingdatasource.bat 	
}

$serviceName= "MPINETDEFAULT"

$mde_service=Get-Service | where {$_.name -eq $serviceName}

if($mde_service)
{

	if (($mde_service.status) -eq "running")
	{
		write-host -foregroundcolor yellow "Stopping service" 
	  ./stoppinginstance.bat	
		
	}
	 write-host -foregroundcolor yellow "Dropping service" 
	./droppinginstance.bat

}



sleep 3

write-host -foregroundcolor yellow "Creating Datasource" 

./creatingdatasource.bat


sleep 10
write-host -foregroundcolor yellow "Creating Service" 
./creatinginstance.bat




