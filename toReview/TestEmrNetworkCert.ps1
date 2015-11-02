param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

$account = [String]$MachineConfig.RelayServicesAccount

pushd E:\Relayhealth\Deployhelp

$wincertdir = "E:\healthvault\winhttpcertcfg.exe"

$emrsubject = "emr-prod.relayhealth.com"

popd

Write-Host -ForegroundColor Yellow "Debug 1" `n

# Read emr-prod.relayhealth.com in to memory and set it to the $emrcert vaiable

$emrcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$emrsubject"}

# Check for the existance of the EMR certificate in the cert directory
 
if([string]::IsNullOrEmpty($emrcert))
{
    Write-Host -ForegroundColor Yellow "`n EMR cert does not exist in the mmc or DTD does not have the right value" `n
}

# Show the emrcert subject on the console

$emrcert.subject

Write-Host -ForegroundColor Yellow "Debug 2" `n

# Check if E:\healthvault\winhttpcertcfg.exe exists on the new web server

if (-Not (test-path $wincertdir)) 
{
	Write-Host -ForegroundColor Yellow "`n The folder E:\healthvault does not exist"
}

Write-Host -ForegroundColor Yellow "Debug 3" `n


            
                # New-Item $NetworkService_EMR -type file             
                # add-content -path $NetworkService_EMR -value "@SET WC_CERTNAME= $emrsubject"              
                # add-content -path $NetworkService_EMR -value "@`"$wincertdir`" -g -a "Network Service" -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
                # add-content -path $healthvaultdir -value "@SET WC_CERTNAME="  


Write-Host -ForegroundColor Yellow "`n Here we create the command line."

$NetworkService_EMR = "$wincertdir -g -a" + " Network Service " + "-c LOCAL_MACHINE\My -s $emrsubject"

Write-host -ForegroundColor Yellow "$NetworkService_EMR" `n

# Pass the command line to the Test_NetworkService_EMR log.

$NetworkService_EMR | out-file -filepath F:\SCM\buildout\buildoutlogs\Test_NetworkService_EMR.log

Write-Host -ForegroundColor Yellow "End of Test_NetworkService_EMR script." `n