@echo off

adb devices
set /p D_ID=Enter the Device ID Name :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% pull /data/misc/wifi/WCNSS_qcom_cfg.ini
adb -s %D_ID% pull /data/misc/wifi/hostapd.conf
pause

adb -s %D_ID% reboot 
