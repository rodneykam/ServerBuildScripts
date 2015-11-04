#############################################################################
##
## getDtd
##   
## 10/2015, RelayHealth
## Martin Evans
##
##############################################################################

<#
.SYNOPSIS
	This script obtains and encrypts the server's environment.DTD file.
 
 	Includes a verification that the encrypted DTD file is usable

.DESCRIPTION

	
.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

Write-host -ForegroundColor Green "`nStart of Get DTD File script`n"

# Obtain the server-specific DTD file from deployment server
$sourcePath="\\Sjmgdep01\f$\SCM\Buildout\MachineSpecifics\"+$MachineConfig.HwebName+"\dirstruct\config"
foreach ($fileName in "\environment.dtd", "\tools_encryption\RelayHealth.EncryptDecryptConfig.exe.config"){
	$localPath="E:\config"+$fileName
	if (test-path -Path $localPath) {
		Write-host -ForegroundColor Yellow "File $localPath already exists on server"
	} else {
		$filePath=$sourcePath+$fileName
		if (test-path -Path $filePath) {
			Write-host -ForegroundColor Yellow "File $filePath will be copied to server location $localPath"
			copy-item -path $filePath -destination $localPath
		} else {
			Write-host -ForegroundColor Red "Cannot find source file $filePath"
			exit
		}
	}
}

# Encrypt the DTD file
$result=Invoke-Expression "E:\config\tools_encryption\RelayHealth.EncryptDecryptConfig.exe e"

# Error handling
if ($LastExitCode -ne 0) {
	Write-host -ForegroundColor Red "DTD encryption failed"
	exit
}
if ($result -match "Encrypting .. E:\config\environment.dtd") {
	Write-host -ForegroundColor Yellow "DTD Encryption completed"
}

# Verify the dtd encryption is readable
if (test-path -Path "E:\RelayHealth\DeployHelp\ParseDtd.ps1") {
	$dtd=E:\RelayHealth\DeployHelp\ParseDtd.ps1
	if ($dtd) {
	Write-host -ForegroundColor Yellow "DTD read successful"
}

Write-host -ForegroundColor Green "`nEnd of Get DTD File script`n"
