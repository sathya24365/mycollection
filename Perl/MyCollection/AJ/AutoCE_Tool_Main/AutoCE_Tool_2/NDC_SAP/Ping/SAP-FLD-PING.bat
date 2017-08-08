@echo off

adb devices

set /p D_ID=Enter the STA Device ID:

:start

title Ping_%D_ID%

adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell ping -f -l %buff% 192.168.43.1

goto start: