@echo off

adb devices
set /p D_ID=Enter Device ID :
title Wlan-on-off_F_%D_ID% 

:start

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% wait-for-device root

echo wifi enable
adb -s %D_ID% shell svc wifi enable

echo wifi disable
adb -s %D_ID% shell svc wifi disable
REM timeout 1
cls

goto start
