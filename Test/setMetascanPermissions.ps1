<#
.SYNOPSIS
	 This script will set permissions for the local IUSR and NetworkService accounts to launch Metascan
 
.DESCRIPTION
    Adapted from script from Brad Turner (http://www.identitychaos.com)
	http://social.technet.microsoft.com/Forums/en-US/ilm2/thread/5db2707c-87c9-4bb2-a0eb-912363e2814a
	
.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig

.EXAMPLE

#>

param
(
[Parameter(Mandatory=$true)] $EnvironmentConfig,
[Parameter(Mandatory=$true)] $MachineConfig
)

$scriptName = "setMetascanPermissions"

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

write-Host "Set-Metascan-DCOM: Updates Permissions for Metascan"

[string]$Principal= $MachineConfig.RelayServicesAccount

function setPermissions
{
    PARAM ($DSIdentity)
    
    # Get the SID for the account
    $id = new-object System.Security.Principal.NTAccount($DSIdentity)
    $sid = $id.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
    
    # LaunchPermission - Local Launch, Remote Launch, Local Activation, Remote Activation
    $SDDLLaunchPermission = "A;;CCDCLCSWRP;;;$sid"

    # AccessPermission - Local Access, Remote Access
    $SDDLAccessPermission = "A;;CCDCLC;;;$sid"

    # PartialMatch
    $SDDLPartialMatch = "A;;\w+;;;$sid"
    
    write-host "Working with principal $DSIdentity ($sid):"
    # Get the respective binary values of the  registry entries
    $currentLaunchPermission = $Reg.GetBinaryValue(2147483648, $MetascanKey, "LaunchPermission").uValue
    $currentAccessPermission = $Reg.GetBinaryValue(2147483648, $MetascanKey, "AccessPermission").uValue

    # Convert the current permissions to SDDL
    write-host "`tConverting current permissions to SDDL format..."
    $currentSDDLLaunchPermission = $Converter.BinarySDToSDDL($currentLaunchPermission)
    $currentSDDLAccessPermission = $Converter.BinarySDToSDDL($currentAccessPermission)
    
    # Build the new permissions
    write-host "`tBuilding the new permissions..."
    if (($currentSDDLLaunchPermission.SDDL -match $SDDLPartialMatch) -and ($currentSDDLLaunchPermission.SDDL -notmatch $SDDLLaunchPermission))
    {
        $newSDDLLaunchPermission = $currentSDDLLaunchPermission.SDDL -replace $SDDLPartialMatch, $SDDLLaunchPermission
    }
    else
    {
        $newSDDLLaunchPermission = $currentSDDLLaunchPermission.SDDL + "(" + $SDDLLaunchPermission + ")"
    }

    if (($currentSDDLAccessPermission.SDDL -match $SDDLPartialMatch) -and ($currentSDDLAccessPermission.SDDL -notmatch $SDDLAccessPermission))
    {
        $newSDDLAccessPermission = $currentSDDLAccessPermission.SDDL -replace $SDDLPartialMatch, $SDDLAccessPermission
    }
    else
    {
        $newSDDLAccessPermission = $currentSDDLAccessPermission.SDDL + "(" + $SDDLAccessPermission + ")"
    }

    # Convert SDDL back to Binary
    write-host "`tConverting SDDL back into binary form..."
    $binarySDLaunchPermission = $Converter.SDDLToBinarySD($newSDDLLaunchPermission)
    $binarySDAccessPermission = $Converter.SDDLToBinarySD($newSDDLAccessPermission)

    # Apply the changes
    write-host "`tApplying changes..."
    if ($currentSDDLLaunchPermission.SDDL -match $SDDLLaunchPermission)
    {
        write-host "`t`tCurrent LaunchPermission matches desired value."
    }
    else
    {
        $result = $Reg.SetBinaryValue(2147483648, $MetascanKey, "LaunchPermission", $binarySDLaunchPermission.BinarySD)
        if($result.ReturnValue='0'){write-host "`t`tApplied LaunchPermission complete."}
    }

    if ($currentSDDLAccessPermission.SDDL -match $SDDLAccessPermission)
    {
        write-host "`t`tCurrent AccessPermission matches desired value."
    }
    else
    {
        $result = $Reg.SetBinaryValue(2147483648, $MetascanKey, "AccessPermission", $binarySDAccessPermission.BinarySD)
        if($result.ReturnValue='0'){write-host "`t`tApplied AccessPermission complete."}
    }
}

# Globals
$Computer = "."
$Converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
$Reg = [WMIClass]"\\$Computer\root\default:StdRegProv"
$MetascanKey = "AppID\{05E50668-B91C-4412-A73B-3F6931164576}"

# Check for pre-exisitng LaunchPermission and AccessPermission values
$keyValues = $Reg.EnumValues(2147483648, $MetascanKey)

if($keyValues.sNames -notcontains "LaunchPermission")
{
    write-host "Creating default LaunchPermission"
    $defaultLaunchPermission = "O:BAG:BAD:(A;;CCDCLCSWRP;;;SY)(A;;CCDCLCSWRP;;;BA)(A;;CCDCLCSWRP;;;IU)"
    $defaultBinaryLaunchPermission = $Converter.SDDLToBinarySD($defaultLaunchPermission)
    $result = $Reg.SetBinaryValue(2147483648, $MetascanKey, "LaunchPermission", $defaultBinaryLaunchPermission.BinarySD)
    if($result.ReturnValue='0'){write-host "`t`tApplied Default LaunchPermission."}
}

if($keyValues.sNames -notcontains "AccessPermission")
{
    write-host "Creating default AccessPermission"
    $defaultAccessPermission = "O:BAG:BAD:(A;;CCDCLC;;;PS)(A;;CCDC;;;SY)(A;;CCDCLC;;;BA)"
    $defaultBinaryAccessPermission = $Converter.SDDLToBinarySD($defaultAccessPermission)
    $result = $Reg.SetBinaryValue(2147483648, $MetascanKey, "AccessPermission", $defaultBinaryAccessPermission.BinarySD)
    if($result.ReturnValue='0'){write-host "`t`tApplied default AccessPermission."}
}

setPermissions("IUSR")
setPermissions("NetworkService")
setPermissions($Principal)

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"

#----------------------------------------------------------------------------------------------------------
 trap 
 { 
    $exMessage = $_.Exception.Message
    if($exMessage.StartsWith("L:"))
    {
        write-host "`n" $exMessage.substring(2) "`n" -foregroundcolor white -backgroundcolor darkblue
    }
    else 
    {
        write-host "`nError: " $exMessage "`n" -foregroundcolor white -backgroundcolor darkred
    }
 Exit
 }
#----------------------------------------------------------------------------------------------------------
