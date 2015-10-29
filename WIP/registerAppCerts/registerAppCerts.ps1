# 2:54 PM 10/29/2015

#.SYNOPSIS
        
# This script creates batch files that set Certificates for various applications
# It logs its progress in C:\Logs. If C:\logs does not exist, it will create it.
#       
# .DESCRIPTION
# 
# .EXAMPLE
        
# .\registerAppCerts.ps1 $EnvironmentConfig $MachineConfig        
# .NOTES
# Script Name :  registerAppCerts.ps1 
# Author      :  Mike Felkins       
# Date        :  2:54 PM 10/29/2015 
#
#######################################################################################
# Script begins
param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

# Added these variables to name the new log file.
# Date and time stamp
# Path and file name of the new log file
# Creates a new log file
#sets the Logfile variable to the path and file name.

$Date = get-date -f "MM-dd-yyyy hh-mm-ss"

$Path = "C:\Hwebsource\scripts\logs\registerAppCerts_$($env:computername)_" + $Date + ".log"
Write-Host -ForegroundColor Yellow $Path

$NewLogFile = New-Item $Path -Force -ItemType File

$Logfile = $Path

# Import the Logfile function.
Import-module C:\Hwebsource\scripts\LogfileFunction.psm1

# Added LogWrite to populate the log file everywhere there was a throw statement
# Added this to suppress errors to the console

# $erroractionpreference = "silentlycontinue"

$account = [String]$MachineConfig.HVRelayServicesAccount

# Write the Date and time to the log file
LogWrite "$Date"

if([string]::IsNullOrEmpty($account))
{
	Write-Host -ForegroundColor Yellow "`n HVRelayServicesAccount does not exits in buildoutconfig"
    LogWrite "HVRelayServicesAccount does not exits in buildoutconfig"
}	

pushd E:\Relayhealth\Deployhelp


$wincertdir = "E:\healthvault\winhttpcertcfg.exe"
#$wincertdir = "E:\healthvault"

$hvsubject ="healthvault.relayhealth.com"

popd

$cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$hvsubject"}

if([string]::IsNullOrEmpty($cert))
{
	# corrected spelling
    Write-Host -ForegroundColor Yellow "`n Healthvault cert does not exist in the mmc or DTD does not have the right value"
    LogWrite "Healthvault cert does not exist in the mmc or DTD does not have the right value"
}

$cert.subject

# removed the old throw statement and added this test for the wincertdir.
if (-Not (test-path $wincertdir)) 
{
	Write-Host -ForegroundColor Yellow "`n The folder E:\healthvault does not exist"
    LogWrite "$wincertdir does not exist"
}

if (test-path $wincertdir)
{   
    LogWrite "$wincertdir exist"
	
	$accounts = @("Network Service",$account)
	
	$count = 1
	
	foreach($user in $accounts)
	{
		$healthvaultdir = "E:\healthvault\registercert_generated"+"$count"+".bat"
		
		
		if(test-path  $healthvaultdir )
		{
		   LogWrite "Invoking $healthvaultdir"
           Write-Host -ForegroundColor Yellow "`n E:\healthvault\registercert_generated"+"$count"+".bat exists" 	
		   invoke-expression  $healthvaultdir
		
		}
		else
		{
			# New-Item  $healthvaultdir -type file
		
			# add-content -path $healthvaultdir -value "@SET WC_CERTNAME= $hvsubject"
			
			# add-content -path $healthvaultdir -value "@`"$wincertdir`" -g -a `"$user`"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%"
			# add-content -path $healthvaultdir -value "@SET WC_CERTNAME="
			
            Write-Host -ForegroundColor Yellow "`n Here we would create the batch file and invoke it."
			 LogWrite "Invoking $healthvaultdir"
			 invoke-expression $healthvaultdir
		}
		sleep 5
		$count ++
		
	}

}



