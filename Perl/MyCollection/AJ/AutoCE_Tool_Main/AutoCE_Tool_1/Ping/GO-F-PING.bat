@echo off

adb devices

set /p D_ID=Enter the STA Device ID:

set /p buff=Enter the Buff size:

:start

title Ping_%D_ID%

adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell ping -i 0.001 192.168.49.1

goto start:
