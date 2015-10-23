param(
    [string] $siteprefix,
    [string] $deployroot = "E:\RelayHealth\deploy",
    [string] $devroot = (gi (join-path (get-location) "..\..\dev")).FullName,
    [switch] $useProductionPaths,
    $dtdFolder = "E:\Config\",
	[string] $BuildMode = "Debug"
)

$ErrorActionPreference = "stop"

### PLACE Service CONFIGURATIONS HERE ###
# Each site configuration is a hash 
# table.  Fill in the details for
# each site here.
#name,displayname,devpath,deploypath,exename
$services = 
    @{
        name = "rhcmxsvc"
        displayname = "RelayHealth Message Exchange Service"
        devpath = "$devroot\Applications\MessageExchangeService\src\RelayHealth.Services.MessageExchangeService\bin\" + $BuildMode + "\"
        deploypath = "$deployroot\MessageExchangeService\bin\Release\"
        exename = "RelayHealth.Services.MessageExchangeService.exe"
        description = "RelayHealth Message Exchange Service (Vortex)"
        recovery = $false 
    },
    @{
        name = "rhciasvc"
        displayname = "RelayHealth Inbound Activity Service"
        devpath = "$devroot\Applications\MessageExchangeService\src\RelayHealth.Services.InboundActivityService\bin\" + $BuildMode + "\"
        deploypath = "$deployroot\InboundActivityService\bin\Release\"
        exename = "RelayHealth.Services.InboundActivityService.exe"
        description = "RelayHealth Inbound Activity Service (Vortex)"
        recovery = $false 
    },
    @{
        name = "rhcsasvc"
        displayname = "RelayHealth Subscriber Activity Service"
        devpath = "$devroot\Applications\MessageExchangeService\src\RelayHealth.Services.SubscriberActivityService\bin\" + $BuildMode + "\"
        deploypath = "$deployroot\SubscriberActivityService\bin\Release\"
        exename = "RelayHealth.Services.SubscriberActivityService.exe"
        description = "RelayHealth Subscriber Activity Service (Vortex)"
        recovery = $false 
    },
    @{
        name = "rhceisvc"
        displayname = "RelayHealth Exchange Infrastructure Service"
        devpath = "$devroot\Applications\MessageExchangeService\src\RelayHealth.Services.ExchangeInfrastructureService\bin\" + $BuildMode + "\"
        deploypath = "$deployroot\ExchangeInfrastructureService\bin\Release\"
        exename = "RelayHealth.Services.ExchangeInfrastructureService.exe"
        description = "RelayHealth Exchange Infrastructure Service (Vortex)"
        recovery = $false 
    },
    @{
        name = "rhctksvc"
        displayname = "RelayHealth Message Tracking Service"
        devpath = "$devroot\Applications\MessageExchangeService\src\RelayHealth.Services.MessageTrackingService\bin\" + $BuildMode + "\"
        deploypath = "$deployroot\MessageTrackingService\bin\Release\"
        exename = "RelayHealth.Services.MessageTrackingService.exe"
        description = "RelayHealth Message Tracking Service (Vortex)"
        recovery = $false 
    }
    
### PROCESS THE CONFIGURATION FOR THE CURRENT SYSTEM ###
foreach ($service in $services){
    $service.name = $siteprefix + $service.name

    if ($useProductionPaths.IsPresent){
        $service.Add("physicalpath",$service.deploypath)
    } else {
        $service.Add("physicalpath",$service.devpath)
    }
    
}
### RETURN THE ARRAY OF SERVICE CONFIGURATIONS ###
#$services = .\filterHash.ps1 -paramNameToFilter "DeploymentExcludedService" -hashParamName "name" -hashToFilter $services -dtdFolder $dtdFolder

return $services 
    
    
