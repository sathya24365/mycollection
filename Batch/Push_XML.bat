@echo off

adb devices
set /p D_ID=Enter Device ID:

echo.
echo Wechat_2E4BCF13.xml
echo Wechat_CFC9B77A.xml

set /p xml=Enter xml name:

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device remount

adb -s %D_ID% shell am force-stop com.qualcomm.capella.app
adb -s %D_ID% shell rm -r /sdcard/capella/xml_files/*
adb -s %D_ID% push %cd%\%xml% /sdcard/capella/xml_files/
adb -s %D_ID% shell am start -a android.intent.action.MAIN -n com.qualcomm.capella.app/.MasterTestApp -e ScenarioXML %xml% -e CapellaRootDir /sdcard -e AutoStart true -e Delay 5

pause
