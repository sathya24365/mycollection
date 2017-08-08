@echo off
adb devices
set /p DID=Enter Device ID :
ls
set /p ch=Assign Test:


start
cscript %ch% %DID%
exit
