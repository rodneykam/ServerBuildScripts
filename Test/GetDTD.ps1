<#
.SYNOPSIS
	This script obtains and encrypts the server's environment.DTD file.
 
 	Includes a verification that the encrypted DTD file is usable

.DESCRIPTION
    The DTD file is pre-generated at \\Sjmgdep01\f$\SCM\Buildout\MachineSpecifics\<ServerName>\dirstruct\config
	The script copies the file to the webserver and encrypts it.
	
.PARAMETER EnvironmentConfig

.PARAMETER MachineConfig

.EXAMPLE 

#>

param
(
	[Parameter(Mandatory=$true)] $EnvironmentConfig,
	[Parameter(Mandatory=$true)] $MachineConfig
)

$scriptName = "getDtd"

$computer=Get-WmiObject -Class Win32_ComputerSystem
$name=$computer.name
$domain=$computer.domain
$computername="$name"+".$domain"

Write-Host -ForegroundColor Green "`nSTART SCRIPT - $scriptName running on $computername`n"

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

Write-Host -ForegroundColor Green "`nEND SCRIPT - $scriptName running on $computername`n"
