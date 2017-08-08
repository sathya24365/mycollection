@echo off
adb devices
set /p D_ID=Enter the Device ID :

adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 

adb -s %D_ID% remount
adb -s %D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf
pause

cls
adb -s %D_ID% shell rm /data/misc/wifi/p2p_supplicant.conf
adb -s %D_ID% shell ls /data/misc/wifi
adb -s %D_ID% reboot
adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
cls
adb -s %D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf
adb -s %D_ID% pull /data/misc/wifi/p2p_supplicant.conf 
pause

cls
adb -s %D_ID% push p2p_supplicant.conf /data/misc/wifi
adb -s %D_ID% shell sync
adb -s %D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf 
pause

adb -s %D_ID% reboot


