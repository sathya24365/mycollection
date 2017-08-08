REM @echo off

adb devices
set /p D_ID=Enter Device ID:

cls
ls
set /p xml=Enter xml:


adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell am force-stop com.qualcomm.capella.app

cls

adb -s %D_ID% shell ls -l /sdcard/capella/xml_files

echo Deleting Old XML files
pause

adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*

cls

set name=%CD%

adb -s %D_ID% push %xml% /sdcard/capella/xml_files

cls

adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*.bat
adb -s %D_ID% shell ls -l /sdcard/capella/xml_files

adb -s %D_ID% shell am start -a android.intent.action.MAIN -n com.qualcomm.capella.app/.MasterTestApp -e ScenarioXML %xml% -e CapellaRootDir /sdcard -e AutoStart true -e Delay 5
pause 
