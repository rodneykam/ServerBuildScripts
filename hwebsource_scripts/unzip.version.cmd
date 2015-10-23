set rhVer=%1
set AppRoot=%2
set LocalScripts=%3
set Drive=%4
if NOT DEFINED Drive set Drive=e:

IF /I %AppRoot%==Applications set AppRoot=%Drive%\relayhealth\releases
IF /I %AppRoot%==InteropApplications set AppRoot=%Drive%\interopapplications\releases
IF /I %AppRoot%==CorpSite set AppRoot=%Drive%\CorpSite\releases

"c:\Program Files\7-Zip\7z.exe" x %AppRoot%\ci%rhVer%.zip -ir!ci%rhVer%\* -o%AppRoot% -y

IF /I %LocalScripts%==RelayHealthDeployHelp set ScriptRoot=%Drive%\relayhealth\deployhelp
IF /I %LocalScripts%==InteropApplicationsDeployHelp set ScriptRoot=%Drive%\interopapplications\deployhelp
IF /I %LocalScripts%==CorpSiteDeployHelp set ScriptRoot=%Drive%\CorpSite\deployhelp

"c:\Program Files\7-Zip\7z.exe" e %AppRoot%\ci%rhVer%.zip -ir!%LocalScripts%\*.* -o%ScriptRoot% -y

"c:\Program Files\7-Zip\7z.exe" e %AppRoot%\ci%rhVer%.zip -ir!%LocalScripts%\scheduleTasks\*.xml -o%ScriptRoot%\scheduleTasks -y

cd /d %AppRoot%
del *.zip