@echo off

adb devices
set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
cls

adb -s %D_ID% shell mount -o remount,rw /system
adb -s %D_ID% pull /system/etc/init.qcom.post_boot.sh
pause


