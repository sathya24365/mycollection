@echo off

color c

echo Run this check on client side only
 
pause

cls

color 7

adb devices

set /p D_ID=Enter the 1st Device ID :

adb -s %D_ID% wait-for-device root 

adb -s %D_ID% root

sleep 1s

adb -s %D_ID% root 

sleep 1s

adb -s %D_ID% root 

sleep 1s

adb -s %D_ID% root 

adb -s %D_ID% shell iwconfig p2p0

pause