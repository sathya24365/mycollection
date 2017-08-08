@echo off
adb devices
set /p D_ID=Enter the Device ID :

adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
adb -s %D_ID% remount
REM mkdir %D_ID%

adb -s %D_ID% pull /data/misc/wifi/p2p_supplicant.conf %cd%/%D_ID%/p2p_supplicant.conf
pause

