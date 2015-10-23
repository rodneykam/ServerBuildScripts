param(
    [string] $paramNameToFilter, # This is the value to filter in DTD
    [string] $hashParamName, # This is the name of the parameter in the hash
	$hashToFilter, # This is the hash to filter
	[string] $dtdFolder = "E:\Config" # This is the default dtd folder
)
$ErrorActionPreference = "stop"

### PLACE Service CONFIGURATIONS HERE ###
# Each site configuration is a hash 
# table.  Fill in the details for
# each site here.
# name, dependentOn
$services = @{
        name = "IISADMIN"       
    },
    @{
        name = "SMTPSVC"
    },
	@{
	    name = "Metascan"
	}	

### RETURN THE ARRAY OF SERVICE CONFIGURATIONS ###


$services = .\filterHash.ps1 -paramNameToFilter "DeploymentExcludedService" -hashParamName "name" -hashToFilter $services -dtdFolder $dtdFolder
return $services 
    
    
