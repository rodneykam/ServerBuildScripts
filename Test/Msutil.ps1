param (
[string]$environment,
$Config,
$MachineConfig
)

if ([string]::IsNullOrEmpty($Environment) )
{
	$environment=$Config.Environment
}


if ([string]::IsNullOrEmpty($Environment) )
{
	throw New-Object System.ArgumentNullException " $Environment Environment value is Null "
}
	
$Error.Clear()

Function EnvironmentParser
{
	param (
		$filepath= $(throw "You must specify a path."),
		$nodequalifier= $(throw "You must specify a xmltag in order to process the xml.")
        	)
	
	$configParams = [xml] (gc $filepath) 
	if ( $error ){
	write-host -Foregroundcolor Yellow " Config File Corrupted `r `n $($error[0])"
	exit
	}
	

	$configServerParams = $configParams.Environments.Environment | ?{[string]$_.name -eq $nodequalifier}
	if ( !$configServerParams ){
	write-host -Foregroundcolor Yellow " Paramater $configParams given doesnt not comply with the config `r `n $($error[0])"
	exit
	}

	return $configServerParams

}

function setPermissions
{
    PARAM ($DSIdentity)
    
    # Get the SID for the account
    $id = new-object System.Security.Principal.NTAccount($DSIdentity)
    $sid = $id.Translate( [System.Security.Principal.SecurityIdentifier] ).toString()
    
    # LaunchPermission - Local Launch, Remote Launch, Local Activation, Remote Activation
    $SDDLLaunchPermission = "A;;CCDCSW;;;$sid"
   
    # PartialMatch
    $SDDLPartialMatch = "A;;\w+;;;$sid"
    
    write-host "Working with principal $DSIdentity ($sid):"
    # Get the respective binary values of the  registry entries
    $currentLaunchPermission = $Reg.GetBinaryValue(2147483648, $MsutilKey, "LaunchPermission").uValue
  
    # Convert the current permissions to SDDL
    write-host "`tConverting current permissions to SDDL format..."
    $currentSDDLLaunchPermission = $Converter.BinarySDToSDDL($currentLaunchPermission)
    
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

   
    # Convert SDDL back to Binary
    write-host "`tConverting SDDL back into binary form..."
    $binarySDLaunchPermission = $Converter.SDDLToBinarySD($newSDDLLaunchPermission)
 
    # Apply the changes
    write-host "`tApplying changes..."
    if ($currentSDDLLaunchPermission.SDDL -match $SDDLLaunchPermission)
    {
        write-host "`t`tCurrent LaunchPermission matches desired value."
    }
    else
    {
        $result = $Reg.SetBinaryValue(2147483648, $MsutilKey, "LaunchPermission", $binarySDLaunchPermission.BinarySD)
        if($result.ReturnValue='0'){write-host "`t`tApplied LaunchPermission complete."}
    }
   
}




$environmentconfig= EnvironmentParser -filepath "Environmentdomain.config" -nodequalifier $Environment
$environmentprefix= $environmentconfig.prefix
$environmentdomain= $environmentconfig.domain

write-Host "Set-Msutil-DCOM: Updates Permissions for Msutil"

[string]$Principal= $environmentdomain+"\"+$environmentprefix+"WEB_DL - DCOM Access"

# Globals
$Computer = "."
$Converter = new-object system.management.ManagementClass Win32_SecurityDescriptorHelper
$Reg = [WMIClass]"\\$Computer\root\default:StdRegProv"
$MsutilKey = "AppID\{3040E2D1-C692-4081-91BB-75F08FEE0EF6}"

# Check for pre-exisitng LaunchPermission and AccessPermission values
$keyValues = $Reg.EnumValues(2147483648, $MsutilKey)

if($keyValues.sNames -notcontains "LaunchPermission")
{
    write-host "Creating default LaunchPermission"
    $defaultLaunchPermission = "O:BAG:BAD:(A;;CCDCLCSWRP;;;SY)(A;;CCDCLCSWRP;;;BA)(A;;CCDCLCSWRP;;;IU)"
    $defaultBinaryLaunchPermission = $Converter.SDDLToBinarySD($defaultLaunchPermission)
    $result = $Reg.SetBinaryValue(2147483648, $MsutilKey, "LaunchPermission", $defaultBinaryLaunchPermission.BinarySD)
    if($result.ReturnValue='0'){write-host "`t`tApplied Default LaunchPermission."}
}
#setPermissions("NetworkService")
setPermissions($Principal)

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