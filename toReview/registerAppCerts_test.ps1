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

write-host -foreground Magenta "`n # # # Entering registerAppCert script. # # # "

$Error.clear()

$filedate =(Get-Date).ToString("yyyyMMddhhmmss")

# The Relay service account to use which is in the buildoutSetup.config file
$account = [String]$MachineConfig.RelayServicesAccount

pushd E:\Relayhealth\Deployhelp

# Set folder and file locations
$wincertdir = "E:\RegisterAppCert"
$certConfig = "E:\RegisterAppCert\winhttpcertcfg.exe"  #executable that gets run in each batch file


# Test for existence of the E:\RegisterAppCert folder and the winhttpcertcfg.exe file
write-host -foreground Green "`n registerAppCerts -  Checking for existing RegisterAppCert folder and file section."

if (-Not (test-path $wincertdir)) 
{
	Write-Host -ForegroundColor Red "   The E:\RegisterAppCert folder does not exist."
	Write-Host -ForegroundColor Red "   Terminating registerAppCert script. `n"
	Break
}
elseif (-Not (test-path $certConfig)) 
{
	Write-Host -ForegroundColor Yellow "   The E:\RegisterAppCert folder exists, testing for winhttpcertcfg.exe"
	Write-Host -ForegroundColor Red "   The file winhttpcertcfg.exe does not exist"
	Write-Host -ForegroundColor Red "   Terminating registerAppCert script. `n"
    Break
}
else
{
	Write-Host -ForegroundColor Yellow "   The E:\RegisterAppCert folder exists."
	Write-Host -ForegroundColor Yellow "   The file winhttpcertcfg.exe exists"
}

# Set the certificate subject value for each certificate
$emrsubject = "emr-prod.relayhealth.com"
$hvaultsubject = "healthvault.relayhealth.com"
$vortexsubject = "VortexrToolsClient"

popd

write-host -foreground Green "`n registerAppCerts -  Checking for existing certificates section."
# Read certificate subject value in to memory and set it to the $xxxcert vaiable
$emrcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$emrsubject"}
$hvaultcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$hvaultsubject"}
$vortexcert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$vortexsubject"}


# Check for the existance of the emr_prod certificate in the cert directory
if([string]::IsNullOrEmpty($emrcert))
{
    Write-Host -ForegroundColor Yellow "   The emr_prod certificate does not exist in the mmc or the DTD does not have the right value `n"
}
else
{
	Write-Host -ForegroundColor Yellow "   Found the emr_prod certificate."
}


# Check for the existance of the healthvault certificate in the cert directory
if([string]::IsNullOrEmpty($hvaultcert))
{
    Write-Host -ForegroundColor Yellow "   The healthvault certificate does not exist in the mmc or the DTD does not have the right value `n"
}
else
{
	Write-Host -ForegroundColor Yellow "   Found the healthvault certificate."
}


# Check for the existance of the VortexrToolsClient certificate in the cert directory
if([string]::IsNullOrEmpty($vortexcert))
{
    Write-Host -ForegroundColor Yellow "   The VortexrToolsClient certificate does not exist in the mmc or the DTD does not have the right value `n"
}
else
{
	Write-Host -ForegroundColor Yellow "   Found the VortexrToolsClient certificate."
}

write-host -foreground Green "`n registerAppCerts - Checking for or Creating batch files section."

# Show the emrcert subject on the host console
#$emrcert.subject

write-host -foreground Yellow "`n Working on NetworkService_EMR.bat."
$Network_EMR = "E:\RegisterAppCert\NetworkService_EMR.bat"
if (-Not (test-path $Network_EMR)) 
{
	Write-Host -ForegroundColor Red "   File NetworkService_EMR.bat does not exist."
	Write-Host -ForegroundColor Yellow "   Creating file NetworkService_EMR.bat."
	New-Item $Network_EMR -type file             
    add-content -path $Network_EMR -value "@SET WC_CERTNAME= $emrsubject"              
    add-content -path $Network_EMR -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
    add-content -path $Network_EMR -value "@SET WC_CERTNAME="
}
else
{
	Write-Host -ForegroundColor Red "   File NetworkService_EMR.bat already exists. Removing and creating a new one."
	get-childitem "E:\RegisterAppCert\NetworkService_EMR.bat" | Remove-Item -force
	New-Item $Network_EMR -type file             
    add-content -path $Network_EMR -value "@SET WC_CERTNAME= $emrsubject"              
    add-content -path $Network_EMR -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
    add-content -path $Network_EMR -value "@SET WC_CERTNAME="
}


write-host -foreground Yellow "`n Working on NetworkService_HealthVault.bat."
$Network_HV = "E:\RegisterAppCert\NetworkService_HealthVault.bat"
if (-Not (test-path $Network_HV)) 
{
	Write-Host -ForegroundColor Red "   File NetworkService_HealthVault.bat does not exist."
	Write-Host -ForegroundColor Yellow "   Creating file NetworkService_HealthVault.bat. `n"
	New-Item $Network_HV -type file             
    add-content -path $Network_HV -value "@SET WC_CERTNAME= $hvaultsubject"              
    add-content -path $Network_HV -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
    add-content -path $Network_HV -value "@SET WC_CERTNAME="
}
else
{
	Write-Host -ForegroundColor Red "   File NetworkService_HealthVault.bat already exists. Removing and creating a new one. `n"
	get-childitem "E:\RegisterAppCert\NetworkService_HealthVault.bat" | Remove-Item -force
	New-Item $Network_HV -type file             
    add-content -path $Network_HV -value "@SET WC_CERTNAME= $hvaultsubject"              
    add-content -path $Network_HV -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
    add-content -path $Network_HV -value "@SET WC_CERTNAME="
}               

 
write-host -foreground Yellow "`n Working on NetworkService_VortexrTools.bat."
$Network_VT = "E:\RegisterAppCert\NetworkService_VortexrTools.bat"
if (-Not (test-path $Network_VT)) 
{
	Write-Host -ForegroundColor Red "   File NetworkService_VortexrTools.bat does not exist."
	Write-Host -ForegroundColor Yellow "   Creating file NetworkService_VortexrTools.bat. `n"
	New-Item $Network_VT -type file             
    add-content -path $Network_VT -value "@SET WC_CERTNAME= $vortexsubject"              
    add-content -path $Network_VT -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
    add-content -path $Network_VT -value "@SET WC_CERTNAME="
}
else
{
	Write-Host -ForegroundColor Red "   File NetworkService_VortexrTools.bat already exists. Removing and creating a new one. `n"
	get-childitem "E:\RegisterAppCert\NetworkService_VortexrTools.bat" | Remove-Item -force
	New-Item $Network_VT -type file             
    add-content -path $Network_VT -value "@SET WC_CERTNAME= $vortexsubject"              
    add-content -path $Network_VT -value "@`"$certConfig`" -g -a 'Network Service' -c LOCAL_MACHINE\My -s %WC_CERTNAME%"            
    add-content -path $Network_VT -value "@SET WC_CERTNAME="
}               





write-host -foreground Green "`n registerAppCerts - Running batch files section."
write-host -foreground Yellow "   Intentionally not running at this time. `n"
			   
### thartzler edit               invoke-expression $Network_EMR 
# sleep 10
# cd e:\RegisterAppCert
# write-host -foreground yellow "`nAttempting to run the NetworkService_EMR.bat file."
# ./NetworkService_EMR.bat ### thartzler edit


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

write-host -foreground Magenta "`n # # # Exiting registerAppCert script. # # # `n"



















