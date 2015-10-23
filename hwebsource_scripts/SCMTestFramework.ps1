#
#  SCM Test  Framework
###########################
#
#  Purpose  -  Verify  endpoints , configurations  before  handing over   Environmet QA 
###########################
#
#
#
param([switch]$prerelease)

#creating the  hash for the DTD

$dtd=.\parseDTD.ps1
$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"
$Error= @()




### TEST 1- Verify all certificates  in the cert store ####

$Patient_Compass_Cert = "client.app.relayhealth.com"

$WildCard_Cert = "\*"+$dtd.ApplicationDomainName

$api_Cert = "api"+$dtd.ApplicationDomainName

$Healthvault_Cert = $dtd.HealthVaultCertSubject 

$Interface_Cert = $dtd.EnterpriseRxCertificateSubject

$erxtemp = $dtd.EnterpriseRxIVRServiceURL 
$erxtemparray = $erxtemp.split("/")

$Erxssl_Cert = $erxtemparray[2]

$Domain_Cert = "$computername"


$Certs = @("$Patient_Compass_Cert","$WildCard_Cert","$api_Cert","$Healthvault_Cert","$Interface_Cert","$Erxssl_Cert","$Domain_Cert")

Write-Host -ForegroundColor Yellow "`n `n `n TEST - 1 Here are the expected Certificates on this $computername `n"

foreach ($cert in $certs)
{
	write-host -ForegroundColor Magenta "`n $cert"
}


Write-Host -ForegroundColor Yellow "`n `n `n The Following Certificates are installed in the Certificates of $computername `n"
foreach ($cert in $certs)
{
	
	$Cert_is_right = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$cert"}
	
	
	if ($Cert_is_right -ne $null)
	{
		$expire =$Cert_is_right.NotAfter -lt (Get-Date)
		
		if ($expire -eq $true)
		{
			write-host  -ForegroundColor Red "`n $Cert Certificate has Expired"
			$err = "$Cert  Certificate has  Expired"
			$Error +=$err
		}
		
		write-host  -ForegroundColor Green "`n $Cert is valid in Personal folder"
		
		
	}
	else
	{
	
		$TrustedPpl_Cert_is_right=gci cert:\LocalMachine\trustedpeople | where-object {$_.Subject -match "$cert"}
	
		if ($TrustedPpl_Cert_is_right -ne $null)
		{
			$expire =$TrustedPpl_Cert_is_right.NotAfter -lt (Get-Date)
			if ($expire -eq $true)
			{
				write-host  -ForegroundColor Red "`n $Cert Certificate has Expired"
				$err = "$Cert  Certificate has  Expired"
				$Error +=$err
			}
			write-host  -ForegroundColor Green "`n $Cert is valid in Trusted People Folder"
		}
		else
		{
			write-host  -ForegroundColor Red "`n $Cert Certificate Does not Exist"
			
			$err = "$Cert Certificate Does not Exist"
			$Error +=$err			
		}
	}
}


### TEST 2- Verifying  thumbprint  for Patient Compass ####

$Patient_Compass_Dtd_Thumbprint = $dtd.PatientCompassBillPay_Thumbprint


Write-Host -ForegroundColor Yellow "`n `n `n TEST - 2 Does the Patient Compass Thumbprint value match The DTD values  `n"

$Patient_Compass_MMC_Cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$Patient_Compass_Cert"}

if ($Patient_Compass_MMC_Cert -ne $null)
{
	$Patient_Compass_MMC_Thumbprint = $Patient_Compass_MMC_Cert.thumbprint
	
	if ($Patient_Compass_Dtd_Thumbprint -eq $Patient_Compass_MMC_Thumbprint)
	{
		write-host  -ForegroundColor Green "`n $Patient_Compass_Cert Thumbprint matches with the DTD value"
	
	}
	else
	{
		write-host  -ForegroundColor Red "`n $Patient_Compass_Cert Thumbprint Does not match with the DTD value"

		$err= "$Patient_Compass_Cert Thumbprint Does not match with the DTD value"

		$Error +=$err
	}
	

}
else 
{
	write-host  -ForegroundColor Red "`n $Patient_Compass_Cert Certificate Does not Exist"

	$err= "Patient Compass Cert Does Not exist"

	$Error +=$err

}

### TEST 4- Checking all DB connection strings    ####



Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 3  Verifying   all DB connection `n"

function ExecuteSqlNonQuery {
	param
	(	
		[string]$connString
	)
	
	if( $connString -ne $null ) 
	{	
		$cn = new-object System.Data.SqlClient.SqlConnection( $connString )
		$cn.Open( )		
		write-host -ForegroundColor Green "$connString is Valid"
		$cn.Close( )
	}
	else 
	{
		Write-Host "$connString is null"
	}

}




function MakeSqlConnString {
	param
	(	
		[string]$databaseUsername,
		[string]$databasePassword,
		[string]$dataSource = $( throw "Missing Argument: dbServerName" ),
		[string]$initialCatalog = $( throw "Missing Argument: initialCatalog" )
	) 
	
	if ([string]::IsNullOrEmpty($databaseUsername))
	{
		$Auth="Integrated Security=SSPI"
	} 
	else 
	{
		$Auth="User Id=$databaseUsername;PWD=$databasePassword"
	}
	
	$connectionString = "Data Source=$dataSource;Initial Catalog=$initialCatalog;Pooling=false;$Auth"
	
	return $connectionString 
}



if($prerelease)
{
}
else
{
$connstringdtd = $dtd.keys 
foreach($value in  $connstringdtd)
{
	if (($value -match "connstring") -or ($value -match "ConnectionString")-or ($value -match "DBHXApp")-or ($value -match "DBRelayImageApp")-or ($value -match "ErrorDB")-or ($value -match "InteropDB")-or ($value -match "MedispanDB")-or ($value -match "RxInterfaceSQLServer"))
	{	$data_source=$null
		$user_id = $null
		$password = $null
		$initial_catalog =$null
		#$dtd.$value
		$conn=$dtd.$value
				
		$dbconnstring=$conn.split(";")

		foreach($connstring in $dbconnstring)
		{
			if ($connString -match "Data Source")
			{	
				$data_source_string = $connstring.split("=")
				$data_source = 	$data_source_string[1]	
			}
	
			if ($connString -match "User id")
			{	
				$user_id_string = $connstring.split("=")
				$user_id = 	$user_id_string[1]		
			}
					
			if ($connString -match "password")
			{	
				$password = $connString.substring($connString.Indexof("=") + 1)	
			}

			if ($connString -match "initial catalog")
			{	
				$initial_catalog_string = $connstring.split("=")
				$initial_catalog = $initial_catalog_string[1]		
			}
			
		}
		
		if (($conn -match "Integrated Security") -or ($conn -match "mongo"))
		{
		$conn
		}
		else
		{
		$connectionString = MakeSqlConnString $user_id $password $data_source $initial_catalog 
				
		try
		{
			ExecuteSqlNonQuery $connectionString
		} 
		catch 
		{
			write-host -foregroundcolor Red "$($_.Exception.message) `n $value is invalid `n"
			$Err = "$value $connectionString is invalid"
			$Error += $Err
		}
		}
	}
}
}
### TEST 4- Verifying   Initiate Settings    ####

# test   db  connection initaite 
# test datasource
# test initiate instanec
# test passive accts and password  


Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 4  Verifying   Initiate Settings `n"

$Initiate_connstringdtd = $dtd.InitiateConnString
$Initiate_dbconnstring=$Initiate_connstringdtd.split(";")

foreach($Initiate_connstring in $Initiate_dbconnstring)
{
	if ($Initiate_connString -match "Data Source")
	{	
		$Initiate_data_source_string = $Initiate_connstring.split("=")
		$Initiate_data_source = $Initiate_data_source_string[1]	
	}
	
	if ($Initiate_connString -match "User id")
	{	
		$Initiate_user_id_string = $Initiate_connstring.split("=")
		$Initiate_user_id = $Initiate_user_id_string[1]		
	}
					
	if ($Initiate_connString -match "password")
	{	
		$Initiate_password = $Initiate_connString.substring($Initiate_connString.Indexof("=") + 1)		
	}

	if ($Initiate_connString -match "initial catalog")
	{	
		$Initiate_initial_catalog_string = $Initiate_connstring.split("=")
		$Initiate_initial_catalog = $Initiate_initial_catalog_string[1]		
	}
			
}

$Initiate_connectionString = MakeSqlConnString $Initiate_user_id $Initiate_password $Initiate_data_source $Initiate_initial_catalog 

if($prerelease)
{	
}
else
{
		
try
{
	ExecuteSqlNonQuery $Initiate_connectionString
} 
catch 
{
	write-host -foregroundcolor Red "$($_.Exception.message) `n $value is invalid `n"
	$Err = "$value $connectionString is invalid"
	$Error += $Err
}		 

}

pushd hklm:\SOFTWARE\ODBC\ODBC.INI


$key = $Initiate_initial_catalog 

$Key_Data_source= test-path $key

if ($Key_Data_source -eq $true )
{
	write-host -foregroundcolor green "Initiate Data Source i.e $key Exists "
}
else
{
	write-host -foregroundcolor red "Initiate Data Source i.e $keyd does not  Exists "
	$Err = "Initiate Data Source i.e $keyd does not  Exists"
	$Error += $Err
}

popd


$Initiate_serviceName= "MPINETDEFAULT"

$Initiate_service=Get-Service | where {$_.name -eq $Initiate_serviceName}
$InitiateService=$Initiate_service.DisplayName

if ($Initiate_service)
{
	write-host -foregroundcolor green "Initiate Service Exists i.e $InitiateService"
	
	$status = $Initiate_service.Status
	
	if($status -eq "running")
	{
		write-host -foregroundcolor green "$InitiateService is  running"	
	}
	else 
	{
		write-host -foregroundcolor red "$InitiateService is not running and has the following status $status "
		try
		{
			Start-Service $Initiate_serviceName
			write-host -foregroundcolor green "$InitiateService is  running"				
		}		 
		catch 
		{
			write-host -foregroundcolor Red "$($_.Exception.message) `n $Initiate_serviceName could not start `n"
			$Err = "$Initiate_serviceName could not start"
			$Error += $Err
		}	
	}
	
}
else
{
	write-host -foregroundcolor red "Initiate Service $Initiate_serviceName does not  Exists "
	$Err = "Initiate Service $Initiate_serviceName does not  Exists "
	$Error += $Err
}

$Initiate_Passive_ServiceName= "Initiate PassiveServer 8.7.0"

$Initiate_Passive_Service=Get-Service | where {$_.name -eq $Initiate_Passive_ServiceName}
$InitiatePassive_Service=$Initiate_Passive_Service.DisplayName

if ($Initiate_Passive_Service)
{
	write-host -foregroundcolor green "Initiate Service Exists i.e $InitiatePassive_Service"
	
	$status = $Initiate_Passive_Service.Status
	
	if($status -eq "running")
	{
		write-host -foregroundcolor green "$InitiatePassive_Service is  running"	
	}
	else 
	{
		write-host -foregroundcolor red "$InitiatePassive_Service is not running and has the following status $status "
		try
		{
			Start-Service $Initiate_Passive_ServiceName
			write-host -foregroundcolor green "$InitiatePassive_Service is  running"				
		}		 
		catch 
		{
			write-host -foregroundcolor Red "$($_.Exception.message) `n $Initiate_Passive_ServiceName could not start `n"
			$Err = "$Initiate_Passive_ServiceName could not start"
			$Error += $Err
		}	
	}
	
}
else
{
	write-host -foregroundcolor red "Initiate Service $Initiate_Passive_ServiceName does not  Exists "
	$Err = "Initiate Service $Initiate_Passive_ServiceName does not  Exists "
	$Error += $Err
}


# test passive accts and password  

$Passive_Properties= "e:\mpi\project\Initiate\passive\conf\PassiveServer.properties"

if(Test-Path $Passive_Properties)
{
	write-host -foregroundcolor green "$Passive_Properties file exists"
	$PassiveContent= Get-Content $Passive_Properties
	
	foreach ($line in $PassiveContent)
	{
		if($line -match "UsrPass") 
		{	
			$passive=$line.split("=")
			$passiveValue=$passive[1]
			$dtdValue=$dtd.NIMPassword
			if($passiveValue -eq $dtdValue)
			{
				write-host -foregroundcolor green "Passive userid  is correct as per DTD"
			}
			else
			{
				write-host -foregroundcolor red "Passive userid  is not correct as per DTD"
				$Err = "Passive userid  is not correct as per DTD"
				$Error += $Err
			}	
		}	
		
		
		if ($line -match "UsrName")
		{	
			$passive=$line.split("=")
			$passiveValue=$passive[1]
			$dtdValue=$dtd.NIMUserId
			if($passiveValue -eq $dtdValue)
			{
				write-host -foregroundcolor green "Passive Password is correct as per DTD"
			}
			else
			{
				write-host -foregroundcolor red "Passive userid  is not correct as per DTD"
				$Err = "Passive Password  is not correct as per DTD"
				$Error += $Err
			}
		}		
	}
	
}
else
{
	write-host -foregroundcolor red "$Passive_Properties file Doesnot Exist"	
	$Err = "$Passive_Properties file Doesnot Exist"
	$Error += $Err	
}


Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 5  Verifying all dtd path values `n"

$paths=@($dtd.EmailShuntPath,$dtd.FaxShuntPath,$dtd.sftpArchiveDirectory,$dtd.sftpRootDirectory)

foreach($path in $paths)
{
	if (test-path $path)
	{
		write-host -foregroundcolor green "$path  is valid "
	}
	else
	{	
		write-host -foregroundcolor red "$path  is invalid "
		$Err = "$path  is invalid "
		$Error += $Err
	}
}

Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 6 Credit Card  check for  enc files `n"

$creditcardfiles=@("C:\ProgramData\DotNetCharge\70234.enc","C:\ProgramData\DotNetCharge\dotnetcharge.dll")

foreach ($file  in $creditcardfiles)
{
	if(Test-Path $file)
	{	
		write-host -foregroundcolor green "$file for credit card charge exists"
	}
	else
	{
		write-host -foregroundcolor red "$file for credit card charge does not exists "
		$Err = "$file for credit card charge does not exists "
		$Error += $Err
	}

}

Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 7 Winter tree Spelling check `n"

pushd HKLM:\software\Wow6432Node\Wintertree
$tmpKey = "SpellingServer.NET"
$tmpKeyExist = Test-Path "$tmpKey"
if ($tmpKeyExist -eq "True")
{
 	write-host -ForegroundColor green "Registry Key for wintertree Exists"	
}
else 
{
	write-host -ForegroundColor red "Registry Key for wintertree Exists doesnot Exist"
	$Err = "Registry Key for wintertree Exists doesnot Exist "
	$Error += $Err
}
popd

$wintertreefiles=@("C:\WINDOWS\SysWOW64\WintertreeSpellingServer.dll","C:\WINDOWS\SysWOW64\WSpellingServer.dll")

foreach ($file  in $wintertreefiles)
{
	if(Test-Path $file)
	{	
		write-host -foregroundcolor green "$file for wintertree exists"
	}
	else
	{
		write-host -foregroundcolor red "$file for wintertree does not exists "
		$Err = "$file for wintertree does not exists "
		$Error += $Err
	}

}



Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 8 Machine key  test  `n"

$dtd_decrypt_machinekey=$dtd.MachineKeyDecryptionKey

$dtd_valid_machinekey=$dtd.MachineKeyValidationKey

if(($dtd_decrypt_machinekey -ne $null) -and ($dtd_valid_machinekey -ne $null))
{

$webConfig = "C:\Windows\Microsoft.NET\Framework\v2.0.50727\CONFIG\web.config"

$bitwebconfig = "C:\Windows\Microsoft.NET\Framework64\v2.0.50727\CONFIG\web.config"

if ((Test-Path $webConfig) -and (Test-Path $bitwebconfig))
{
$readText = Get-Content $webConfig
[string]$machinekey_Config=$readText -match "<machinekey"


$keys=$machinekey_Config.split(" ")

foreach ($key in $keys)
{

	if ($key -match "decryptionkey")
	{
		$decrypt_keys=$key.split("`"")	
		$config_decrypt_machinekey=$decrypt_keys[1]
	}

	if ($key -match "validationkey")
	{
		$valid_keys=$key.split("`"")
		$config_valid_machinekey=$valid_keys[1]
	}

}





$bitreadText = Get-Content $bitwebConfig
[string]$bitmachinekey_Config=$bitreadText -match "<machinekey"

#$bitmachinekeyConfig

$bitkeys=$bitmachinekey_Config.split(" ")

foreach ($bitkey in $bitkeys)
{

	if ($bitkey -match "decryptionkey")
	{
		$decrypt_bitkeys=$bitkey.split("`"")	
		$config_decrypt_bitmachinekey=$decrypt_bitkeys[1]
	}

	if ($bitkey -match "validationkey")
	{
		$valid_bitkeys=$bitkey.split("`"")
		$config_valid_bitmachinekey=$valid_bitkeys[1]
	}

}

if (($config_decrypt_machinekey -eq $config_decrypt_bitmachinekey) -and ($config_valid_machinekey -eq $config_valid_bitmachinekey))
{
	Write-Host -ForegroundColor Green "The Decryption and validation keys in sync in both 32 bit and 64 bit web config files"
	
	if (($dtd_decrypt_machinekey -eq $config_decrypt_machinekey) -and ($dtd_valid_machinekey -eq $config_valid_bitmachinekey))
	{
	Write-Host -ForegroundColor Green "The Decryption and validation keys in sync in the DTD and both 32 bit and 64 bit web config files"
	}
	else
	{
	Write-Host -ForegroundColor Red " $dtd_decrypt_machinekey `n $config_decrypt_machinekey The Decryption and validation keys in sync in the DTD and both 32 bit and 64 bit web config files"
	}
}



}

}





Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 9 Check relayhealth Service `n"



try
{
	./ControlServicesScheduleds.ps1 -checkallRunmode

} 
catch 
{
	write-host -foregroundcolor Red "$($_.Exception.message) `n $value is invalid `n"
	$Err = "$value $connectionString is invalid"
	$Error += $Err
}





Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 10 Filepath  test  `n"

$filepaths = $dtd.keys 
foreach($value in  $filepaths)
{

	$filepath=$dtd.$value
	
	
	if (($filepath -match "^\w:\\*.*\\") -and (($filepath -notmatch "dev") -and ($filepath -notmatch "simTesting")))
	{ 
	 	"$value  $filepath `n" 
		
		test-path $filepath
	}
	
	if ($filepath -match "^\\\\*.*\\")
	{ 
	 if	(test-path $filepath)
	 {
		 Write-Host -ForegroundColor Green "$value = $filepath `n is reachable `n"
	 }
	 else
	 {
		 Write-Host -ForegroundColor Red "The $value which points $filepath and is reachable "
	 }
	}
	<#if (($value -match "path") -or ($value -match "directory"))#-or ($value -match "DBHXApp")-or ($value -match "DBRelayImageApp")-or ($value -match "ErrorDB")-or ($value -match "InteropDB")-or ($value -match "MedispanDB")-or ($value -match "RxInterfaceSQLServer"))
	{	
		$value
		$filepath=$dtd.$value
		Write-Host -ForegroundColor Green "$filepath"
	}#>
}	



#$dtdarray

Write-Host -ForegroundColor Yellow "`n `n `n TEST  - 11 Mongo Connectivity test from the web server  `n"

$mongoDriverPath = "E:\RelayHealth\deploy\WebServiceQA\bin"
add-type -path "$($mongoDriverPath)\MongoDB.Bson.dll"
add-type -path "$($mongoDriverPath)\MongoDB.Driver.dll" 

[string]$mongoconnstring=$dtd.mongoConnectionString
[MongoDB.Driver.MongoServer]$server = [MongoDB.Driver.MongoServer]::Create("$mongoconnstring") 

#[MongoDB.Driver.Mongo] $serve
$server.ReplicaSet
#$server.SecondaryConnectionPools

[MongoDB.Driver.MongoDatabase]$database=$server.GetDatabase("RelayRecord")

$database.GetCollectionNames()

$myService=New-WebServiceProxy –Uri "http://localhost:45540/Services/MyService.svc?wsdl"




$Error	




















