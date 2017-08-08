@echo off

adb devices

set /p D_ID=Enter the STA Device ID:

:start

title Ping_%D_ID%

adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell ifconfig wlan0

set /p IP=Enter the IP:

fping %IP% -t 1ms -c

goto start: