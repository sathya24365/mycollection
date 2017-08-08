@echo off

adb devices
set /p D_ID=Enter the Device ID Name :
cls
ls
set /p ch=Select Test profile:

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root


:start
cls
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell /data/local/%ch%

goto :start
pause


