@echo off

REM get dir of the script and set it to %mypath%
for %%i in ("%~dp0.") do SET "mypath=%%~fi"

REM set vars for ps script and the file to write to
set "filepath=%mypath%\specs.json"
set "script=%mypath%\GetHardwareInfo.ps1"

REM run the ps script with file path as arg
start /b powershell.exe -noexit -ExecutionPolicy Bypass -Command "& '%script%' -path '%filepath%'"
exit
