del %MAD_ROOTDIR%\sql\mpihub.ddl
del %MAD_ROOTDIR%\scripts\initiate.properties

copy /Y %MAD_HOMEDIR%\sql\mpihub.ddl %MAD_ROOTDIR%\sql\ 
copy /Y %MAD_HOMEDIR%\scripts\initiate.properties %MAD_ROOTDIR%\scripts\ 
exit /B 0