@echo off
pushd %~dp0
set dire=%CD%
popd
for %%i in ("%~dp0.") do SET "mypath=%%~fi"
set "filepath=%mypath%\specs.json"
set "script=%mypath%\GetHardwareInfo.ps1"
echo "& '%script%' -path '%filepath%'"
powershell.exe -Command "& '%script%' -path '%filepath%'"
pause