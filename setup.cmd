@echo off
rem ---------------------------------------------------------------------------
rem  Double-click this file to set up the machine.
rem  It starts setup.ps1, which asks for administrator rights (UAC) by itself.
rem  Optional: setup.cmd -Skip WSL,Npm
rem ---------------------------------------------------------------------------
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1" %*
