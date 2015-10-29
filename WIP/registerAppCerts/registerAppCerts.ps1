# 9:36 AM 10/29/2015

#.SYNOPSIS
        
# This script creates batch files that set Certificates for various applications
# It logs its progress in C:\Logs. If C:\logs does not exist, it will create it.
#       
# .DESCRIPTION
# 
# .EXAMPLE
        
# .\hv.ps1 $EnvironmentConfig $MachineConfig        
# .NOTES
# Script Name :  registerAppCerts.ps1 
# Author      :  Mike Felkins       
# Date        :  9:36 AM 10/29/2015  
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
$Date = get-date -f "MM-dd-yyyy hh-mm-ss"
# Path and file name of the new log file
$Path = "C:\Hwebsource\scripts\logs\registerAppCerts_$($env:computername)_" + $Date + ".log"
# Creates a new log file
$NewLogFile = New-Item $Path -Force -ItemType File
#sets the Logfile variable to the path and file name.
$Logfile = $Path

# Import the Logfile function.
Import-module .\LogfileFunction.psm1

# Write the Date and time to the log file
LogWrite "$Date"

# Added LogWrite to populate the log file everywhere there was a throw statement

$erroractionpreference = "silentlycontinue"

$account = [String]$MachineConfig.HVRelayServicesAccount

if([string]::IsNullOrEmpty($account))
{
	Write-Host "HVRelayServicesAccount does not exits in buildoutconfig"
    LogWrite "HVRelayServicesAccount does not exits in buildoutconfig"
}	

pushd E:\Relayhealth\Deployhelp


$wincertdir = "E:\healthvault\winhttpcertcfg.exe"

$hvsubject ="healthvault.relayhealth.com"

popd

$cert = gci cert:\LocalMachine\MY | where-object {$_.Subject -match "$hvsubject"}

if([string]::IsNullOrEmpty($cert))
{
	# corrected spelling
    Write-Host "Healthvault cert does not exist in the mmc or DTD does not have the right value"
    LogWrite "Healthvault cert does not exist in the mmc or DTD does not have the right value"
}

$cert.subject

if (-Not (test-path $wincertdir)) 
{
	Write-host "$wincertdir does not exist"
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
           write-host "$healthvaultdir exist" 	
		   invoke-expression  $healthvaultdir
		
		}
		else
		{
			# New-Item  $healthvaultdir -type file
		
			# add-content -path $healthvaultdir -value "@SET WC_CERTNAME= $hvsubject"
			
			# add-content -path $healthvaultdir -value "@`"$wincertdir`" -g -a `"$user`"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%"
			# add-content -path $healthvaultdir -value "@SET WC_CERTNAME="
			
            write-host "Here we would create the batch file and invoke it."
			 LogWrite "Invoking $healthvaultdir"
			 invoke-expression $healthvaultdir
		}
		sleep 5
		$count ++
		
	}

}



