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
# Script Name :  HV.ps1   
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

$Date = get-date -f "MM-dd-yyyy hh-mm-ss"
$Path = "C:\Logs\RAC_$($env:computername)_" + $Date + ".log"
$NewLogFile = New-Item $Path -Force -ItemType File
$Logfile = $Path

#??? needs directory to point to.
Import-module .\LogfileFunction.psm1

LogWrite "$Date"

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
	Write-Host "Healthvault cert doesnot exist in the mmc or DTD does not have the right value"
    LogWrite "Healthvault cert doesnot exist in the mmc or DTD does not have the right value"
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
			New-Item  $healthvaultdir -type file
		
			add-content -path $healthvaultdir -value "@SET WC_CERTNAME= $hvsubject"
			
			add-content -path $healthvaultdir -value "@`"$wincertdir`" -g -a `"$user`"  -c LOCAL_MACHINE\My -s %WC_CERTNAME%"
			add-content -path $healthvaultdir -value "@SET WC_CERTNAME="
			
			LogWrite "Invoking $healthvaultdir"
			invoke-expression $healthvaultdir
		}
		sleep 5
		$count ++
		
	}

}



