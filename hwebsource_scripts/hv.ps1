param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)


$account = [String]$MachineConfig.HVRelayServicesAccount

if([string]::IsNullOrEmpty($account))
{
	throw ("HVRelayServicesAccount does not exits in buildoutconfig")
}	

pushd E:\Relayhealth\Deployhelp

#$dtd=.\parseDTD.ps1



$wincertdir = "E:\healthvault\winhttpcertcfg.exe"


$hvsubject ="healthvault.relayhealth.com"




popd

$cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$hvsubject"}

if([string]::IsNullOrEmpty($cert))
{
	throw ("Healthvault cert doesnot exist in the mmc or DTD   does nat have the right value")
}

$cert.subject

if (test-path $wincertdir)
{
	
	$accounts = @("Network Service",$account)
	
	$count = 1
	
	foreach($user in $accounts)
	{
		$healthvaultdir = "E:\healthvault\registercert_generated"+"$count"+".bat"
		
		
		if(test-path  $healthvaultdir )
		{
		   write-host "$healthvaultdir exist" 	
		   invoke-expression  $healthvaultdir
		
		}
		else
		{
			New-Item  $healthvaultdir -type file
		
			add-content -path $healthvaultdir -value "@SET WC_CERTNAME= $hvsubject"
			
			add-content -path $healthvaultdir -value "@`"$wincertdir`" -g -a `"$user`"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%"
			add-content -path $healthvaultdir -value "@SET WC_CERTNAME="
			
			
			invoke-expression $healthvaultdir
		}
		sleep 5
		$count ++
		
	}

}
else
{
	throw ("Healthvault doesnot exist")
}

