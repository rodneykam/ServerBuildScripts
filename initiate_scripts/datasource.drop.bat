cd %MAD_ROOTDIR%\scripts
if not %errorlevel%==0 goto :error
call madconfig -propertyfile initiate.properties remove_datasource
if not %errorlevel%==0 goto :error
cd %MAD_HOMEDIR%\scripts
if not %errorlevel%==0 goto :error
:end
exit /B 0
:error
echo ERROR ENCOUNTERED
exit /B -1