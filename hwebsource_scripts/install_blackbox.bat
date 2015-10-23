@echo off
@rem test to see if the opnet service is installed
set pan_home=e:\panorama\hedzup\mn
SC QUERY Panorama_Dynamic_Sampling_Agent > NUL
IF ERRORLEVEL 1060 GOTO MISSING
ECHO OPNET Services (AppInternal) Is Installed. Copying...
GOTO INSTALL

:MISSING
ECHO OPNET/Riverbed Services Not Installed
GOTO END

:INSTALL
@rem stop the services
net stop Panorama_Dynamic_Sampling_Agent
net stop DA-NET1
net stop Panorama_IIS_Agent
net stop Panorama_DA-Windows2008R2Blackbox_Agent1
net stop Panorama_DA-BlackBoxDotNet_Agent1
net stop Panorama_MassTransit_Agent_vortex
@rem now we delete the agents
sc delete Panorama_IIS_Agent
sc delete DA-NET1
sc delete Panorama_DA-BlackBoxDotNet_Agent1
sc delete Panorama_DA-Windows2008R2Blackbox_Agent1
sc delete Panorama_MassTransit_Agent_vortex
@rem now we copy over the DSA_governor file
ren %pan_home%\data\DSA_governor.xml %pan_home%\dat\DSA_governor.old
copy /y DSA_governor.xml %pan_home%\data
@rem first we copy over the files then install the services
copy /y DA-Windows2008R2Blackbox.xml %pan_home%\metadata
copy /y DA-BlackBoxDotNet.xml %pan_home%\metadata
@rem now install
call %pan_home%\support\wmi_service.bat install Windows2008R2Blackbox
call %pan_home%\support\wmi_service.bat install BlackBoxDotNet
@rem now let's start them up
net start Panorama_Dynamic_Sampling_Agent
net start Panorama_BlackBoxDotNet_Agent1
net start Panorama_Windows2008R2Blackbox_Agent1
GOTO END

:END
ECHO Done!