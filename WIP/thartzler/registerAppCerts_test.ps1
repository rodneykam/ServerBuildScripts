#############################################################################
##
## registerAppCerts
##   
## 11/2015, RelayHealth
## Tracy Hartzler
##
##############################################################################


<#
.SYNOPSIS
	Add overview.
        
.DESCRIPTION
	Add description
	
.EXAMPLE 
	Add run example

.EXAMPLE
	Add run example
#>


param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

$Error.clear()

# The Relay service account to use which is in the buildoutSetup.config file
$account = [String]$MachineConfig.RelayServicesAccount

pushd E:\Relayhealth\Deployhelp

# Set folder and file locations
$wincertdir = "E:\dummyFolder"  ###### put RegisterAppCert back in after testing for fail
$certConfig = "E:\RegisterAppCert\certConfigcertcfg.exe"  #executable that gets run in each batch file


# Test for existence of the E:\RegisterAppCert folder and the winhttpcertcfg.exe file
if (-Not (test-path $wincertdir)) 
{
	Write-Host -ForegroundColor Red "`n registerAppCerts - The E:\RegisterAppCert folder does not exist"
	Write-Host -ForegroundColor Red "`n registerAppCerts - Terminating registerAppCert script. `n"
	Break
}
elseif (-Not (test-path $certConfig)) 
{
	Write-Host -ForegroundColor Yellow "`n registerAppCerts - The E:\RegisterAppCert folder exist, testing for winhttpcertcfg.exe"
	Write-Host -ForegroundColor Red "`n registerAppCerts - The file winhttpcertcfg.exe does not exist"
	Write-Host -ForegroundColor Red "`n registerAppCerts - Terminating registerAppCert script. `n"
    Break
}

# Set the certificate subject value for each certificate
$emrsubject = "emr-prod.relayhealth.com"
### $hvaultsubject = "emr-prod.relayhealth.com"
### $vortexsubject = "emr-prod.relayhealth.com"

$filedate =(Get-Date).ToString("yyyyMMddhhmmss")

popd

Write-Host -ForegroundColor Yellow "Debug 1" `n

# Read certificate subject value in to memory and set it to the $xxxcert vaiable
$emrcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$emrsubject"}
$hvaultcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$emrsubject"}
$vortexcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$emrsubject"}

# Check for the existance of the EMR certificate in the cert directory
if([string]::IsNullOrEmpty($emrcert))
{
    Write-Host -ForegroundColor Yellow "`n EMR cert does not exist in the mmc or DTD does not have the right value" `n
}

# Show the emrcert subject on the console
$emrcert.subject

Write-Host -ForegroundColor Yellow "Debug 2" `n


# Check if E:\RegisterAppCert\certConfigcertcfg.exe exists on the new web server




Write-Host -ForegroundColor Yellow "Debug 3" `n

$NetworkService_EMR = "E:\RegisterAppCert\NetworkService_EMR.bat"
  # Reworking the original as shown below:          
                # New-Item $NetworkService_EMR -type file             
                # add-content -path $NetworkService_EMR -value "@SET WC_CERTNAME= $emrsubject"              
                # add-content -path $NetworkService_EMR -value "@`"$wincertdir`" -g -a "Network Service" -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
                # add-content -path $RegisterAppCertdir -value "@SET WC_CERTNAME="  

New-Item $NetworkService_EMR -type file             
                add-content -path $NetworkService_EMR -value "@SET WC_CERTNAME= $emrsubject"              
                add-content -path $NetworkService_EMR -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
                add-content -path $NetworkService_EMR -value "@SET WC_CERTNAME="  
               
### thartzler edit               invoke-expression $NetworkService_EMR 
sleep 10
cd e:\RegisterAppCert
write-host -foreground yellow "`nAttempting to run the NetworkService_EMR.bat file."
./NetworkService_EMR.bat ### thartzler edit

#Test for Error
# If ($Error) 
    # {
        # $E1 = [string]$Error
        # $E2 = $E1.Split(":")
        # $E3 = $E2.Split(".")
        # Write-Host $E3[4]
        # #LogWrite $E3[4]
    # $Error.clear()
    # }

Write-Host -ForegroundColor Yellow "End of test script" `n



















