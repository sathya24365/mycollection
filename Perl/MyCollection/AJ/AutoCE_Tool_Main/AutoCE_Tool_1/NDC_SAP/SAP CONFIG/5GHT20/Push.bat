REM @echo off

adb devices
set /p D_ID=Enter the Device ID Name :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% push WCNSS_qcom_cfg.ini /data/misc/wifi/
adb -s %D_ID% push hostapd.conf /data/misc/wifi/
adb -s %D_ID% reboot 
pause
