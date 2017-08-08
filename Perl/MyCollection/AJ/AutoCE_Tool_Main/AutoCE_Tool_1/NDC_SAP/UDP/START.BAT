@echo off

adb devices
set /p D_ID1=Enter the SAP/GO Device ID :
set /p D_ID2=Enter the DUT Device ID :

set ptag1=%D_ID1%
set ptag2=%D_ID2%
set IP=192.168.3.1
set port=%random%

set ptag=%ptag1%
set D_ID=%D_ID1%
start Ser.bat

set ptag=%ptag2%
set D_ID=%D_ID2%
start Cli.bat


exit