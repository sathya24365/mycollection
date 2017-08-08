:start

title %D_ID%_Ping_%IP%

adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell ping -f -l %buff% %IP%

goto start: