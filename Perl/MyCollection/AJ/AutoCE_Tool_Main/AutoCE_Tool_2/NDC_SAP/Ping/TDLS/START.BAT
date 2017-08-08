@echo off

adb devices

set /p D_ID1=Enter the 1st Device ID:
adb -s %D_ID1% shell ifconfig wlan0
set /p IP1=Enter the IP:
set buff1=1400

set /p D_ID2=Enter the 2nd Device ID:
adb -s %D_ID2% shell ifconfig wlan0
set /p IP2=Enter the IP:
set buff2=1400


set D_ID=%D_ID1%
set buff=%buff2%
set IP=%IP2%

start Fldping.bat
start check


set D_ID=%D_ID2%
set buff=%buff1%
set IP=%IP1%

start Fldping.bat
start check

exit