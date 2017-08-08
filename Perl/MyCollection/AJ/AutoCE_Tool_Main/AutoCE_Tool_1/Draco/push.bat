@echo off

adb devices
set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root
sleep 1s
adb -s %D_ID% wait-for-device root
sleep 1s
adb -s %D_ID% wait-for-device root

cls

adb -s %D_ID% shell am force-stop com.qualcomm.capella.app
adb -s %D_ID% shell am force-stop com.qualcomm.draco.app
adb -s %D_ID% shell busybox killall lookbusy

adb -s %D_ID% install Draco.apk

echo Deleting Old XML files


adb -s %D_ID% shell rm -r /sdcard/draco/xml_files
adb -s %D_ID% shell mkdir /sdcard/draco/xml_files
adb -s %D_ID% shell rm -r /sdcard/draco/xml_files/1.3_Draco_CPU_Qblizz_RAM.xml
adb -s %D_ID% push 1.3_Draco_CPU_Qblizz_RAM.xml /sdcard/draco/xml_files
cls
echo 1.3_Draco_CPU_Qblizz_RAM.xml@
echo.
adb -s %D_ID% shell cat /sdcard/draco/xml_files/1.3_Draco_CPU_Qblizz_RAM.xml
pause 
adb -s %D_ID% shell am start -n com.qualcomm.draco.app/.DracoPortal -e ScenarioXML 1.3_Draco_CPU_Qblizz_RAM.xml

exit
