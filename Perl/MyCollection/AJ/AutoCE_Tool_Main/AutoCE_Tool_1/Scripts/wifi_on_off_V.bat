@echo off

adb devices
set /p D_ID=Enter Device ID :
title Wlan-on-off_V_%D_ID% 

:start

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

FOR /L %%A IN (1,1,60) DO (

adb -s %D_ID% wait-for-device root

echo wifi enable
adb -s %D_ID% shell svc wifi enable
timeout %%A

echo wifi disable
adb -s %D_ID% shell svc wifi disable
timeout 1

)
cls


goto start
