@ECHO OFF
call env.set.bat
ECHO Generating wrapper.conf
call .\GenerateConfig passivewrapper.conf.template ..\passive\conf\wrapper.conf
ECHO Installing...  
call ..\passive\bin\installwrapper.bat
sc.exe config "Initiate PassiveServer 8.7.0" start= delayed-auto
