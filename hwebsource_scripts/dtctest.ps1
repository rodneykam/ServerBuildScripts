#####################################################################################
# Test success of distributed transactions against SQL Server via MSDTC
# April, 2010 E.Gutierrez
#####################################################################################
param
(
	[string]$Instance = ""
	, [string]$Username = ""
	, [string]$Password = ""
	, [switch]$useTrustedAuth = $false
	, [switch]$help = $false
	, [switch]$verboseErrors = $false
)
#####################################################################################
# Constants
#####################################################################################

$MESSAGE_LENGTH = 100
$INTRO = "DTC Test `nTest success of distributed transactions against SQL Server via MSDTC. RelayHealth, Emeryville, CA. 2010"
$HELPMESSAGE = @"
`n.\dtctest.ps1 [-Instance] [-Username] [-Password] [switches]
		-Instance 		Name of target SQL Server instance. Will prompt if not provided.
		-Username		SQL Server login to use for connection. Will prompt if not provided.
		-Password		Password for SQL Server login specified. Will prompt if not provided.
[Switch]	-useTrustedAuth		If set, use Windows authentication (current user's creds) 
					for the SQL Server connection. If this is set, 
					Username and Password params will be ignored.
[Switch]	-verboseErrors		Display more detailed error information, if available
[Switch]	-help			Display help
"@

#####################################################################################
# Initialization
#####################################################################################
[System.Reflection.Assembly]::LoadWithPartialName("System.Transactions") | out-null

$ErrorActionPreference = "SilentlyContinue"
$ReportErrorShowExceptionClass = $true
$ReportErrorShowInnerException = $true
$ReportErrorShowSource = $true
$ReportErrorShowStackTrace = $true

#####################################################################################
# Functions
#####################################################################################

Function Should-Process ($Operation, $Warning = "", [Switch]$Whatif, [Switch]$Verbose, [Switch]$Confirm )
{
# Implements -whatif, -verbose, -confirm functionality
# Borrowed from Jeffrey Snover, Windows PowerShell/MMC Architect
#
#
# Check to see if "YES to All" or "NO to all" has previously been selected
# Note that this technique requires the [REF] attribute on the variable.
# Here is an example of how to use this:
# function Stop-Calc ([Switch]$Verbose, [Switch]$Confirm, [Switch]$Whatif)
# {
# $AllAnswer = $null
# foreach ($p in Get-Process calc)
# { if (Should-Process Stop-Calc $p.Id ([REF]$AllAnswer) "`n***Are you crazy?" -Verbose:$Verbose -Confirm:$Confirm -Whatif:$Whatif)
# { Stop-Process $p.Id
# }
# }
# }

if ($Whatif)
{ 
	Write-Host "What if: " -noNewLine
	Write-Host "$Operation" -fore yellow
	return $false
}

if ($Confirm)
{
	$ConfirmText = @"
Confirm
Are you sure you want to perform this action?
$Operation. $Warning
"@
	Write-Host $ConfirmText
	while ($True)
	{
$answer = Read-Host @"
[Y] Yes [A] Yes to All [N] No [L] No to all [S] Suspend [?] Help (default is "Y")
"@
		switch ($Answer)
		{
		"Y" 	{ return $true														}
		"" 		{ return $true														}
		"N" 	{ return $false 													}
		"S" 	{ $host.EnterNestedPrompt(); Write-Host $ConfirmText 				}	
		"?" 	{ Write-Host @"
					Y - Continue with only the next step of the operation.
					N - Skip this operation and proceed with the next operation.
					S - Pause the current pipeline and return to the command prompt. Type "exit" to resume the pipeline.
"@
				}
		}
	}
}

if ($verbose)
{
	if(($Operation.Length -ge $MESSAGE_LENGTH) -and ($Operation.Length -lt ($MESSAGE_LENGTH * 2 - 4))) {
		$formatted_msg = ($Operation.Substring(0, $MESSAGE_LENGTH) + "`n    " + $Operation.Substring($MESSAGE_LENGTH, $Operation.Length - $MESSAGE_LENGTH)).PadRight(($MESSAGE_LENGTH * 2) + 1)
	}
	elseif($Operation.Length -ge $MESSAGE_LENGTH * 2 - 4) {
		$formatted_msg = ($Operation.Substring(0, $MESSAGE_LENGTH) + "`n    " + $Operation.Substring($MESSAGE_LENGTH, $MESSAGE_LENGTH - 4))		
	}
	else {
		$formatted_msg = $Operation
		if($formatted_msg.Substring(0, 1) -eq "`n") {
			$formatted_msg = $formatted_msg.PadRight($MESSAGE_LENGTH + 1)
		} else {
			$formatted_msg = $formatted_msg.PadRight($MESSAGE_LENGTH)
		}
	}
	Write-Host $formatted_msg -noNewLine
}

return $true
}

Function Print-Result ($result, $separator)
{

	Write-Host " [ " -noNewLine
	if($result) { Write-Host "OK" -Fore Green -noNewLine}
		else { Write-Host "FAILED" -Fore Red -noNewLine }
	Write-Host " ] " -noNewLine
	Write-Host $separator

}

#####################################################################################
# Main
#####################################################################################

Write-Host -foregroundcolor CYAN $INTRO

if($help) {Write-Host $HELPMESSAGE; exit;}

if($Instance -eq "") {$Instance = read-host "Enter server name"}

if($useTrustedAuth -eq $true) {
	$connStr = "Data Source=$Instance;Initial Catalog=master;Integrated Security=SSPI;"
}
else {
	if(($Username -eq "") -or ($Password -eq "")) {
		$creds = get-credential -credential $default_user 
		$Username = $creds.UserName.Remove(0, 1)
		$Password_SecureString = $creds.Password
		# This monstrosity is what you have to do to retrieve a clear text value from a secure string [EG]
		$Ptr=[System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($Password_SecureString)
		$Password = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
		[System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
	}
	$connStr = "Data Source=$Instance;Initial Catalog=master;User Id=${Username};Password=${Password};"
}

$cmTx = new-object("System.Transactions.CommittableTransaction")
$conn1 = new-object("System.Data.SqlClient.SqlConnection") $connStr
$conn2 = new-object("System.Data.SqlClient.SqlConnection") $connStr

if( Should-Process "`nConnecting to db server $Instance ..." -Verbose) { $conn1.Open(); Print-Result $true; }
if( Should-Process "`nEnlisting in transaction..." -Verbose) { $conn1.EnlistTransaction($cmTx); Print-Result $true; }
if( Should-Process "`nOpening second connection to $Instance ..." -Verbose) { $conn2.Open(); Print-Result $true; }
if( Should-Process "`nPromoting to distributed transaction (please wait, timeout can take several minutes)..." -Verbose) { $conn2.EnlistTransaction($cmTx); Print-Result $true; }
if( Should-Process "`nCommitting transaction..." -Verbose) { $cmTx.Commit(); Print-Result $true; }
Write-Host -foregroundcolor GREEN "`nSuccess! MSDTC works. This time."

$conn1.Close()
$conn1.Dispose()
$conn2.Close()
$conn2.Dispose()

trap{
	Print-Result $false
	write-host $_.Exception.GetType( ).FullName -foregroundcolor MAGENTA
	write-host $_.Exception.Message -foregroundcolor MAGENTA
	if ( $conn1 -ne $null ) {
		if($conn1.State -eq [System.Data.ConnectionState]::Open) { $conn1.Close( ) }
		$conn1.Dispose()
	}
	if ( $conn2 -ne $null ) {
		if($conn2.State -eq [System.Data.ConnectionState]::Open) { $conn2.Close( ) }
		$conn2.Dispose()
	}
	if ( $cmd1 -ne $null) { $cmd1.Dispose() }
	if ( $cmd2 -ne $null) { $cmd2.Dispose() }

	if($verboseErrors) { break; } else { exit; }
}
