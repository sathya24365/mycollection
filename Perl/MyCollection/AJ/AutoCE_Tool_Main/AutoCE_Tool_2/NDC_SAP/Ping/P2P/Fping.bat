:start

title %D_ID%_Ping_%IP%

adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell ping -i 0.001 %IP%

goto start: