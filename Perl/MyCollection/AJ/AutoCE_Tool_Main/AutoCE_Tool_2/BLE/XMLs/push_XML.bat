@echo off

adb devices
set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*
set name=%CD%
adb -s %D_ID% push %name% /sdcard/capella/xml_files

adb -s %D_ID% shell am start -a android.intent.action.MAIN -n com.qualcomm.capella.app/.MasterTestApp -e ScenarioXML BLE_BT_Scan.xml -e CapellaRootDir /sdcard -e AutoStart true -e Delay 5
pause 
