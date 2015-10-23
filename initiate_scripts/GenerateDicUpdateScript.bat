set	templateFile=%1%
set outputFile=%2%
set relayPath=%1%

if not defined templateFile set templateFile="UpdateInitiateDictionary.template"
if not defined outputFile set outputFile="UpdateInitiateDictionary.ps1"
if not defined relayPath set relayPath=%MAD_RHPATH%

copy /Y %templateFile% %outputFile%
PowerShell SearchAndReplace.ps1 -file %outputFile% -oldValue MAD_HOMEDIR -newValue %MAD_HOMEDIR%
copy /Y %outputFile% %relayPath%