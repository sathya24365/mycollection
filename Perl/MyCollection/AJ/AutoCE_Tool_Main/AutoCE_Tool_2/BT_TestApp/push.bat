@echo off

adb devices
set /p D_ID=Enter the Device ID Name :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
sleep 1s

adb -s %D_ID% remount
adb -s %D_ID% push AVRCP.sh /data/local
adb -s %D_ID% push HFP.sh /data/local
adb -s %D_ID% push MAP.sh /data/local
adb -s %D_ID% push PBAP.sh /data/local
adb -s %D_ID% shell sync
adb -s %D_ID% shell chmod 777 /data/local/*
adb -s %D_ID% shell dos2unix -u /data/local/AVRCP.sh
adb -s %D_ID% shell dos2unix -u /data/local/HFP.sh
adb -s %D_ID% shell dos2unix -u /data/local/MAP.sh
adb -s %D_ID% shell dos2unix -u /data/local/PBAP.sh

pause


