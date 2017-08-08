adb devices

set /p D_ID=Enter the Device ID Name :

:start

title kmsg_%D_ID%

adb -s %D_ID% wait-for-device root

set t=%TIME: =0%

set d=%date:~4,10%

adb -s %D_ID% shell cat /proc/kmsg | tee %D_ID%_kmsg_%d:/=-%_%t::=.%.txt

sleep 30s

goto start:




