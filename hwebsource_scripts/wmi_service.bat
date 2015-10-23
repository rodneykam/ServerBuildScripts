@echo off
rem ***************************************************************************
rem
rem     - - - - - - - - - - -  Altaworks Corporation  - - - - - - - - - - - -
rem
rem     The following code is the sole property of Altaworks corp., and
rem     contains its proprietary and confidential information.  This code
rem     is used under license.  No reproduction of this code may be made
rem     in any form without the express written consent of the owner.
rem
rem     Copyright (c) 2000-2004, Altaworks Corporation. All rights reserved.
rem     Copyright (c) 2004-2010, OPNET Technologies. All rights reserved.
rem
rem     - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
rem
rem  Description:     Script to add/remove Windows service for WMI DA
rem
rem  Changes:
rem
rem  - Date   -  UID  --------------------- Description ---------------------
rem  09/16/2003   ks   Initial implementation.
rem  09/19/2003   ks   Move to support directory.
rem  06/16/2010   tm   Add -auto for autostart to install command
rem                    Add start/stop commands
rem  05/31/2012  yyc   Add double quotes for the path of BIN variable to properly 
rem		       handle spaces
rem  11/20/2013  yyc   Fix SPR 180316 for the issue of command path having spaces
rem ****************************************************************************
rem
@setlocal
rem
rem For directions on how to use, see Usage:
rem 

set COMMAND=%1
set DANAME=%2
set DAFILENAME=DA-%2
set SERVICENAME="Panorama_%2_Agent"
set DAINST=%3

set BINDIR="%~dp0..\bin"

if {%COMMAND%} == {install} (
  %BINDIR%\dasdkservice.exe %COMMAND% -s "auto" -d %SERVICENAME%_%DAINST% -n %SERVICENAME%_ -i %DAINST% -p ..\bin\wmi_agent.exe -w ""%BINDIR%"" -a "%DAFILENAME% %DAINST%"
  goto EXIT
)

if {%COMMAND%} == {uninstall} (
  %BINDIR%\dasdkservice.exe %COMMAND% -n %SERVICENAME% -i "1" 
  goto EXIT
)

if {%COMMAND%} == {start} (
  %BINDIR%\dasdkservice.exe %COMMAND% -n %SERVICENAME% -i "1" 
  goto EXIT
)

if {%COMMAND%} == {stop} (
  %BINDIR%\dasdkservice.exe %COMMAND% -n %SERVICENAME% -i "1" 
  goto EXIT
)

:usage
echo Usage: %0 ^{install ^| uninstall ^| start ^| stop^} ^<da-name^> ^[^<da-inst^>^]
echo     Where ^<da-name^> has a valid XML metadata file in ..\metadata
echo     install creates a service with display name Panorama_^<da-name^>_Agent
echo     uninstall removes the service 
echo     Example: wmi_service.bat install WindowsProcesses 
echo              for a DA with a file named DA-WindowsProcesses.xml in \metadata
echo              will create a service with the display name Panorama_WindowsProcesses_Agent
:EXIT
@endlocal
