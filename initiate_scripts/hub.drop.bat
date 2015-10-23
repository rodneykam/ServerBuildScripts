madhubdrop -confirm
if not %errorlevel%==0 goto :error
madentdrop -entType id
if not %errorlevel%==0 goto :error
:end
exit /B 0
:error
echo ERROR ENCOUNTERED
exit /B -1