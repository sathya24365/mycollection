@echo off

adb devices
set /p D_ID=Enter Device ID:

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root


ls
set /p apk=Enter ur choice:
adb -s %D_ID% install %apk%

pause
exit