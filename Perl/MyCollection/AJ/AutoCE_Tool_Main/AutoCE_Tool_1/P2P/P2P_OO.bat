@echo off
adb devices

set /p D_ID=Enter the Device ID :

:start
adb -s %D_ID% shell wlantool -c p2p_oo
sleep 1s
goto :start

pause


