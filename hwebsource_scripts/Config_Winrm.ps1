#certutil -ping -config "SJMGCABA1.RHB.AD\RelayHealth Class 2 Primary Intermediate Server CA"
#certutil -catemplates -config "SJMGCABA1.RHB.AD\RelayHealth Class 2 Primary Intermediate Server CA"

 

###################
function Configure-Listener
{
$listeners= winrm enumerate winrm/config/listener
$IP=(((gwmi -query "Select IPAddress From Win32_NetworkAdapterConfiguration Where IPEnabled = True") | % {$_.ipaddress[0]}) -split("`n"))[0]
$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"
$cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "CN=$computername"}
$CN=$cert.thumbprint
$service = get-service winrm
$Service_Status = $service.status

if($Service_Status -ne "running")
{
Write-host -ForegroundColor Green  "Starting the $Service `n"
start-service winrm
}
else
{
Write-host -ForegroundColor Green "Winrm is running `n" 
}

Write-host -ForegroundColor Green "The Certificate Thumbprint for $computername   is  the following `n $CN `n"

if($listeners)
{
	write-Host -ForegroundColor Green "The following Listeners will be deleted from $computername `n "
	$listeners
	winrm delete winrm/config/listener?Address=IP:$IP+Transport=HTTPS
	winrm delete winrm/config/listener?Address=IP:$IP+Transport=HTTP
	write-Host -ForegroundColor yellow "`n All HTTPS Listeners have been deleted `n"
}
$listeners= winrm enumerate winrm/config/listener
if($listeners)
{
	write-Host -ForegroundColor Green "The following Listeners will be deleted from $computername `n "
	$listeners
	winrm set winrm/config/service @{EnableCompatibilityHttpsListener="false"}
	winrm delete winrm/config/Listener?Address=Address=*+Transport=HTTPS
	write-Host -ForegroundColor yellow "`n All HTTPS Listener have been deleted `n"
}

winrm create winrm/config/listener?Address=IP:$IP+Transport=HTTPS

winrm enumerate winrm/config/listener
}
################
$Comp = gwmi win32_computersystem
$comp1 = """CN={0}.{1}""" -f $Comp.Name, $Comp.Domain
$d = '"Machine"'
$b = "[NewRequest]
Subject = $comp1
Exportable = TRUE
KeySpec = 1
KeyLength = 2048
KeyUsage = 0xf0
MachineKeySet = TRUE
CERT_DIGITAL_SIGNATURE_KEY_USAGE -- 80 (128)
CERT_KEY_ENCIPHERMENT_KEY_USAGE -- 20 (32)
[RequestAttributes]
CertificateTemplate = $d
[EnhancedKeyUsageExtension]
OID=1.3.6.1.5.5.7.3.1 ; Server Authentication
OID=1.3.6.1.5.5.7.3.2 ; Client Authentication
"
$b

$path = "C:\windows\temp\"+$comp.Name+".inf"
$path1 = "C:\windows\temp\"+$comp.Name+".req"
$path2 = "C:\windows\temp\"+$comp.Name+".pfx"
$path3 = "C:\windows\temp\"+$comp.Name+".log"
$Paths = @($path,$path1,$path2,$path3)
foreach($p in $Paths){
 If (Test-Path $p)
 {
  remove-item -path $p -force
 }

}

$cername = "Cert"+$comp.Name+".pfx"

add-content $path $b

certreq -new -machine $path $path1 

certreq -submit -AdminForceMachine -config  "SJMGCABA1.RHB.AD\RelayHealth Class 2 Primary Intermediate Server CA" $path1 $path2  |out-file $path3
$certid = Get-content $path3 |Select-String -Pattern 'Requestid: "' 
$certid = $certid -replace 'Requestid: "' -replace '"'

certreq -retrieve -AdminForceMachine -f -config "SJMGCABA1.RHB.AD\RelayHealth Class 2 Primary Intermediate Server CA" $certid $cername

certreq –accept $cername


try{
	Configure-Listener
    write-Host -ForegroundColor Green "Wimrm listener created successfuly`n "     
   }catch{
           write-Host -ForegroundColor Red "Failed to create wimrm listener `n "
         }


