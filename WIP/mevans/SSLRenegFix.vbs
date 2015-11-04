// Apply this setting to the API website (504)
var vdirObj=GetObject("IIS://localhost/W3svc/504");
// replace 1 on this line with the number of the web site you wish to configure

WScript.Echo("Value of SSLAlwaysNegoClientCert Before: " + vdirObj.SSLAlwaysNegoClientCert);
vdirObj.Put("SSLAlwaysNegoClientCert", true);
vdirObj.SetInfo();
WScript.Echo("Value of SSLAlwaysNegoClientCert After: " + vdirObj.SSLAlwaysNegoClientCert);
