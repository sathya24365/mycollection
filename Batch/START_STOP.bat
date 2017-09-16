@echo off

adb devices
set /p D_ID=Enter the Device ID :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device remount


adb -s %D_ID% shell stop
adb -s %D_ID% shell start


exit

