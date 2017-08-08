@echo off

adb devices

set /p D_ID=Enter the Device ID Name :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf | grep ssid=
adb -s %D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf | grep psk=


pause
