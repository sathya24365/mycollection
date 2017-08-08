adb devices

set /p D_ID=Enter CL Device ID :

adb -s %D_ID% wait-for-device root 

adb -s %D_ID% root

sleep 1s

adb -s %D_ID% root 

sleep 1s

adb -s %D_ID% root 

sleep 1s

adb -s %D_ID% root 

adb -s %D_ID% remount


adb -s %D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf

pause

adb devices

set /p D_ID=Enter the STA Device ID :

set /p psk=Enter psk :

adb -s %D_ID% wait-for-device root 

adb -s %D_ID% root

sleep 1s

adb -s %D_ID% root 

sleep 1s

adb -s %D_ID% shell input text %psk%

pause













