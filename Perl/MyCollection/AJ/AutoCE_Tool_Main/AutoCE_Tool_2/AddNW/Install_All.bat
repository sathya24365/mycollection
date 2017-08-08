@echo off

adb devices
set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% shell am force-stop com.qualcomm.capella.app
adb -s %D_ID% shell am force-stop com.qualcomm.draco.app
adb -s %D_ID% shell am force-stop com.qualcomm.castor.app
cls

adb -s %D_ID% shell ls -l /sdcard/capella/xml_files
timeout 2
adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*
cls
adb -s %D_ID% push %cd% /sdcard/capella/xml_files
cls

adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*.bat
adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*.conf
adb -s %D_ID% shell ls -l /sdcard/capella/xml_files

adb -s %D_ID% shell am start -a android.intent.action.MAIN -n com.qualcomm.capella.app/.MasterTestApp -e ScenarioXML AddNW.xml -e CapellaRootDir /sdcard -e AutoStart true -e Delay 5

pause 
