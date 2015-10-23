call env.set
set DIR=%MAD_HOMEDIR%\unload
madhubload -useint -objcode dic -tablist all -unldir %DIR% -onepass
if not %errorlevel%==0 goto :error
:end
exit /B 0
:error
echo ERROR ENCOUNTERED
exit /B -1