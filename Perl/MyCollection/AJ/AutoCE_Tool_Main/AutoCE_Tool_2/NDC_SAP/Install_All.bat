@echo off

adb devices

set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root
sleep 1s
adb -s %D_ID% wait-for-device root
sleep 1s
adb -s %D_ID% wait-for-device root

cls

adb -s %D_ID% shell ls -l /sdcard/capella/xml_files

echo Deleting Old XML files
pause

adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*

cls

set name=%CD%

adb -s %D_ID% push %name% /sdcard/capella/xml_files

cls

adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*.bat
adb -s %D_ID% shell ls -l /sdcard/capella/xml_files

adb -s %D_ID% shell am start -a android.intent.action.MAIN -n com.qualcomm.capella.app/.MasterTestApp -e ScenarioXML SAP.xml -e CapellaRootDir /sdcard -e AutoStart true -e Delay 5
pause 
