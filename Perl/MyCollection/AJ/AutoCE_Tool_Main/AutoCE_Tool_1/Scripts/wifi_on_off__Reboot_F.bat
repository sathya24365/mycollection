@echo off

adb devices
set /p D_ID=Enter Device ID :
title Reboot_Wlan-on-off_%D_ID% 

:start

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

FOR /L %%A IN (1,1,100) DO (

adb -s %D_ID% wait-for-device root

echo wifi enable
adb -s %D_ID% shell svc wifi enable
timeout 1

echo wifi disable
adb -s %D_ID% shell svc wifi disable
timeout 1

)
cls
echo DUT Reboot
adb -s %D_ID% reboot
adb -s %D_ID% wait-for-device root

goto start
