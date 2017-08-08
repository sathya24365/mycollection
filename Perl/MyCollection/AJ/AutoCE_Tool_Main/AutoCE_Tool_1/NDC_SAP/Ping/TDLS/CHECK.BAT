:start

title %D_ID%

adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell iwpriv wlan0 getTdlsPeers

pause
goto start: