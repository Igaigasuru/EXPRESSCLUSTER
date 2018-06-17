rem ***************************************
rem *               genw.bat              *
rem ***************************************
rem @echo off

rem ***************************************************************
rem Set powershell script file path and a target Web Server URI.
rem  <fip>      Set URI for HTTP monitoring.
rem  <UserName> Set Username for authentication.
rem  <Path>     Set file path of an encrypted passwrd.
rem              e.g.) C:\tmp\sec_key.txt
rem ***************************************************************
 
set SCRIPT=C:\Program` Files\EXPRESSCLUSTER\scripts\httpmonitor\httpmon.ps1
set URI=<Uri>
set NAME=<UserName>
set PASS=<Path>

echo %SCRIPT%
echo %URI%
echo %NAME%
echo %PASS%

Powershell %SCRIPT% %URI% %NAME% %PASS%

if %ERRORLEVEL%==0 (
 exit 0
) else (
 exit 1
)
