rem ***************************************
rem *               genw.bat              *
rem ***************************************
@echo off

rem ==============================================================
rem Set powershell script file path and a target Web Server URI.
rem ==============================================================
set SCRIPT=<File path of [Powershell Script](https://github.com/Igaigasuru/EXPRESSCLUSTER/blob/master/memo/script/httpmon.ps1)>
set URI=<Targt URI>

Powershell %SCRIPT% %URI%

if %ERRORLEVEL%==0 (
 exit 0
) else (
 exit 1
)
