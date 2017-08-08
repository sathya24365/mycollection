REM @echo off
adb devices

set /p GO_D_ID=Enter the GO Device ID :
set /p CL_D_ID=Enter the CL Device ID :


adb -s %GO_D_ID% wait-for-device root
adb -s %GO_D_ID% wait-for-device root
adb -s %GO_D_ID% wait-for-device root

adb -s %CL_D_ID% wait-for-device root
adb -s %CL_D_ID% wait-for-device root
adb -s %CL_D_ID% wait-for-device root

adb -s %GO_D_ID% shell am force-stop com.qualcomm.wifidirectserver
adb -s %CL_D_ID% shell am force-stop com.qualcomm.wifidirectserver


adb -s %GO_D_ID% shell am start -a android.intent.action.MAIN -n com.qualcomm.wifidirectserver/.MainActivity
sleep 2s
for /F "tokens=2 delims==" %%i in ('"adb -s %GO_D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf | grep device_name"') do set GO_DN=%%i 

echo %GO_DN%

adb -s %GO_D_ID% shell svc wifi disable
adb -s %CL_D_ID% shell svc wifi disable

adb -s %GO_D_ID% shell svc wifi enable
adb -s %CL_D_ID% shell svc wifi enable

sleep 1s
adb -s %GO_D_ID% shell wlantool -c p2pdsc
sleep 1s
adb -s %CL_D_ID% shell wlantool -c p2pdsc

adb -s %CL_D_ID% shell wlantool -c p2pcon %GO_DN%

:start
cls
set state=0
sleep 60s
for /F "tokens=4" %%i in ('"adb -s %CL_D_ID% shell wlantool -c p2pconinfo | grep 'Network information:'"') do set state=%%i 
for /F "tokens=4" %%i in ('"adb -s %GO_D_ID% shell wlantool -c p2pconinfo | grep 'Network information:'"') do set state=%%i 
echo Current State::%state%
REM pause
sleep 1s
goto :Current_State_%state%

:Current_State_0
cls
echo Trying to reconnect
adb -s %GO_D_ID% shell svc wifi disable
adb -s %CL_D_ID% shell svc wifi disable
adb -s %GO_D_ID% shell svc wifi enable
adb -s %CL_D_ID% shell svc wifi enable

sleep 1s
adb -s %GO_D_ID% shell wlantool -c p2pdsc

sleep 1s
adb -s %CL_D_ID% shell wlantool -c p2pdsc

for /F "tokens=2 delims==" %%i in ('"adb -s %GO_D_ID% shell cat /data/misc/wifi/p2p_supplicant.conf | grep device_name"') do set GO_DN=%%i 
echo %GO_DN%

sleep 2s
adb -s %CL_D_ID% shell wlantool -c p2pcon %GO_DN%
goto :start

:Current_State_Connected
goto :start
pause


