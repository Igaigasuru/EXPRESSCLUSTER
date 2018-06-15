rem ***************************************
rem *               genw.bat              *
rem ***************************************
@echo off

rem ==============================================================
rem Set powershell script file path and a target Web Server URI.
rem ==============================================================
set SCRIPT=<File path of httpmon.ps1>
set URI=<Targt URI>

Powershell %SCRIPT% %URI%

if %ERRORLEVEL%==0 (
 exit 0
) else (
 exit 1
)
