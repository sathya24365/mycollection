@echo off
adb devices

set /p GO_D_ID=Enter the GO Device ID :
:start
adb -s %GO_D_ID% shell wlantool -c p2pdsc
sleep 60s

goto :start
pause


