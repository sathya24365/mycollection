@echo off

adb devices
set /p D_ID=Enter the Device ID :

adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
adb -s %D_ID% wait-for-device root 
cls

adb -s %D_ID% shell cat /data/misc/wifi/WCNSS_qcom_cfg.ini | grep gDot11Mode
echo.
adb -s %D_ID% shell cat /data/misc/wifi/WCNSS_qcom_cfg.ini | grep gChannelBondingMode5GHz
echo.
adb -s %D_ID% shell cat /data/misc/wifi/hostapd.conf | grep hw_mode
echo.
adb -s %D_ID% shell cat /data/misc/wifi/hostapd.conf | grep ieee80211n
echo.
pause