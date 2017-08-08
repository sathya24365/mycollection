@echo off

adb devices

set /p D_ID=Enter the Device ID Name :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
sleep 1s
echo *********************************************
echo Running wpa_supplicant.conf
echo *********************************************
adb -s %D_ID% shell cat /data/misc/wifi/wpa_supplicant.conf

echo *********************************************
echo Do you want to remove current wpa_supplicant.conf
echo *********************************************
adb -s %D_ID% pull /data/misc/wifi/wpa_supplicant.conf
pause

cls

echo *********************************************
echo New wpa_supplicant.conf
echo *********************************************

adb -s %D_ID% shell rm -r /data/misc/wifi/wpa_supplicant.conf
adb -s %D_ID% push wpa_supplicant.conf /data/misc/wifi/
adb -s %D_ID% shell cat /data/misc/wifi/wpa_supplicant.conf


adb -s %D_ID% shell svc wifi disable
adb -s %D_ID% shell svc wifi enable

pause
