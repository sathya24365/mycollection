@echo off

adb devices

set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root

adb -s %D_ID% wait-for-device root

adb -s %D_ID% wait-for-device root

adb -s %D_ID% install WifiDirectServer.apk

pause
exit