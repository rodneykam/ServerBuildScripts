

function Import-PfxCertificate {    
  
   param 
   (
   [String]$certPath,
   [String]$certRootStore = "CurrentUser",
   [String]$certStore = "My",
   $pfxPass = $null
   )    
   
   $pfx = new-object System.Security.Cryptography.X509Certificates.X509Certificate2    
  
   if ($pfxPass -eq $null) {$pfxPass = read-host "Enter the pfx password" -assecurestring}    
  
   $pfx.import($certPath,$pfxPass,"Exportable,PersistKeySet")    
  
   $store = new-object System.Security.Cryptography.X509Certificates.X509Store($certStore,$certRootStore)    
   $store.open("MaxAllowed")    
   $store.add($pfx)    
   $store.close()    
}   



Import-PfxCertificate "E:\config\emr-prod.relayhealth.com.p12" "LocalMachine" "My" "F5prod-EMR"


E:\HealthVault\winhttpcertcfg.exe -g -a "$HVRelayServicesAccount" -c LOCAL_MACHINE\My -s "emr-prod.relayhealth.com"

E:\HealthVault\winhttpcertcfg.exe -g -a "NetworkService" -c LOCAL_MACHINE\My -s "emr-prod.relayhealth.com"
