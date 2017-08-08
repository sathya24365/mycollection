::@echo off

adb devices
set /p D_ID1=Enter Device ID:
adb -s %D_ID1% wait-for-device root

cls
echo Remounting File System 
adb -s %D_ID1% shell mount -o remount,rw /system

cls
echo Loading Bin Files

adb -s %D_ID1% push %CD%\bin\wlantool /system/bin
adb -s %D_ID1% push %CD%\bin\WlanUiAutomator.jar /system/bin

cls
echo Changing Bin File Permissions 

adb -s %D_ID1% shell chmod 777 /system/bin/wlantool
adb -s %D_ID1% shell chmod 777 /system/bin/WlanUiAutomator.jar
adb -s %D_ID1% install -r %CD%\bin\com.wlan.wlanservice_jb.apk

pause
exit