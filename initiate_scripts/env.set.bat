@echo on

set MAD_RHPATH=C:\src\RelayHealth\trunk\RelayHealth\buildtools\2K8
set MAD_DBPREFIX=trunk_

set MAD_VER=trunk
set MAD_DIR=trunk\
set MAD_DIRESC=trunk\\

set MAD_DRIVE=%cd:~0,2% 
set MAD_DRIVE=%MAD_DRIVE: =%
set MAD_DRIVELTR=%MAD_DRIVE:~0,1%

set MAD_ROOTDIR=%MAD_DRIVE%\mpi\product\Engine8.7.0
set MAD_HOMEDIR=%MAD_DRIVE%\mpi\project\%MAD_DIR%initiate
set MAD_HOMEDIRESC=%MAD_DRIVE%\\mpi\\project\\%MAD_DIRESC%initiate
set MAD_LOGNAME=%MAD_HOMEDIR%\log\MADLOG_ODBC_87.mlg
set PATH=.;%MAD_HOMEDIR%\bin;%MAD_ROOTDIR%\bin;%MAD_ROOTDIR%\jre;%MAD_ROOTDIR%\scripts;C:\WINDOWS\system32;%PATH%;

set MAD_CTXLIB=ODBC

set MAD_DBSVR=localhost
set MAD_DBSERVER=localhost
set MAD_DBPORT=1433
set MAD_DBTYPE=mssqlu
set MAD_DBNAME=%MAD_DBPREFIX%Initiate
set MAD_DBUSER=.\RelayService
set MAD_DBPASS=R3l@yH3@lth
set MAD_DDLFILE=%MAD_ROOTDIR%\sql\mpihub.ddl
set MAD_SRVNO=1
set MAD_STDLOAD=0

set MAD_ENGUSER=.\\RelayService
set MAD_ENGPASS=R3l@yH3@lth

set MAD_SMTCODE=en_US
set MAD_LOADDIR=%MAD_HOMEDIR%\load
set MAD_CONNSTR=DSN=%MAD_DBNAME%;UID=%MAD_DBUSER%;PWD=%MAD_DBPASS%

set MAD_TIMER=1
set MAD_AUDIT=1
set MAD_DEBUG=1
set MAD_TRACE=1
set MAD_DBSQL=1
