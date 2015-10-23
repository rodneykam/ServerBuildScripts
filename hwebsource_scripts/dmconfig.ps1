$computer = "LocalHost" 
$namespace = "root\CIMV2" 
gwmi -class Win32_DCOMApplicationSetting -computername $computer -namespace $namespace | Where-Object {$_.LocalService -eq "Metascan" }

$metascan = gwmi -class Win32_DCOMApplicationSetting -computername $computer -namespace $namespace | Where-Object {$_.LocalService -eq "Metascan" }
$securityDescriptor = (new-object management.managementclass Win32_SecurityDescriptor).CreateInstance()  
    Write-Host $securityDescriptor
#$securityDescriptor = $metascan.invokeMethod('GetAccessSecurityDescriptor', $null, $null)
$securityDescriptor = $metascan.GetAccessSecurityDescriptor()
Write-Host $securityDescriptor | fl [a-z]*
Write-Host $metascan | fl [a-z]*

