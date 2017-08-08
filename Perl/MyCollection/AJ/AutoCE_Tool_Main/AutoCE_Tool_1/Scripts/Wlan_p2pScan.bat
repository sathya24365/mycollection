adb devices
set /p D_ID=Enter 1st Device ID :
title wlan+p2p_Scan_%D_ID%
:Beginning
adb -s %D_ID%  root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% shell wpa_cli ifname=wlan0 scan
sleep 1
adb -s %D_ID% shell wpa_cli p2p_find 
sleep 5
GOTO Beginning


