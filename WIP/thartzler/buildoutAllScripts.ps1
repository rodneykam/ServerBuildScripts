param
(
[Parameter(Mandatory=$true)] $Config,
[Parameter(Mandatory=$true)] $MachineConfig,
[switch]$noDatabase
)

Import-Module -Name .\ScriptBooterFunctions.ps1

$isAdmin = $null
GetAdmin([ref]$isAdmin)
$error.clear()

Write-Host -ForegroundColor Green "`nRunning buildoutAllScripts_test.ps1 `n"


if($MachineConfig.codedeployed -match "False")
	{
	
write-host -ForegroundColor Yellow "Debug 1 running script 1 `n"

write-host -ForegroundColor Yellow "Debug 2 running script 2 `n"

write-host -ForegroundColor Yellow "Debug 3 running script 3 `n"

write-host -ForegroundColor Yellow "Debug 4 running script 4 `n"

write-host -ForegroundColor Yellow "Debug 5 running script 5 `n"

write-host -ForegroundColor Yellow "Debug 6 running script 6 `n"

write-host -ForegroundColor Yellow "Debug 7 running script 7 `n"

write-host -ForegroundColor Yellow "Debug 8 running script 8 `n"

write-host -ForegroundColor Yellow "Debug 9 running script 9 `n"

write-host -ForegroundColor Yellow "Debug 10 running script 10 `n"

write-host -ForegroundColor Yellow "Debug 11 running script 11 `n"

write-host -ForegroundColor Yellow "Debug 12 running script 12 `n"

write-host -ForegroundColor Green " End of buildoutAllScripts_test.s1 script `n"
	
	}
	
	
