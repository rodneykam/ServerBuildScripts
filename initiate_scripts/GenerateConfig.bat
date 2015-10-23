set	templateFile=%1%
set outputFile=%2%

if not defined templateFile set templateFile="initiate.properties.template"
if not defined outputFile set outputFile="initiate.properties"

copy /Y %templateFile% %outputFile%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_VER -newValue %MAD_VER%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_DRIVELTR -newValue %MAD_DRIVELTR%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_HOMEDIRESC -newValue %MAD_HOMEDIRESC%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_DBNAME -newValue %MAD_DBNAME%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_DBSVR -newValue %MAD_DBSVR%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_DBPORT -newValue %MAD_DBPORT%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_ENGUSER -newValue %MAD_ENGUSER%
PowerShell .\SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_ENGPASS -newValue %MAD_ENGPASS%