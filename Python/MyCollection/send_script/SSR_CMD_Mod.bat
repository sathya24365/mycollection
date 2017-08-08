@echo off
adb devices
set /p D_ID=Enter the Device ID:
set /p D_PORT=Enter the Device COMPORT:

REM set D_CMD1="send_data 75 37 03 32 00 10"
REM set D_CMD2="send_data 75 37 03 32 01 10"
REM set D_CMD3="send_data 75 37 03 32 02 10"
REM set D_CMD4="send_data 75 37 03 33 00 10"
set D_CMD5="send_data 75 37 03 33 01 10"
REM set D_CMD6="send_data 75 39 03 32 00 10"
REM set D_CMD7="send_data 75 37 03 33 02 10"

@echo Given Details:
@echo %D_ID% 
@echo %D_PORT% 
@echo.
REM @echo %D_CMD1% 
REM @echo %D_CMD2% 
REM @echo %D_CMD3% 
REM @echo %D_CMD4% 
@echo %D_CMD5% 
REM @echo %D_CMD6% 
REM @echo %D_CMD7% 

pause
title QXDM_SSR_OMMAND_%D_ID%
:start
cls
echo Count#%count% for Device :  %D_ID%
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% remount

adb -s %D_ID% shell "echo related > /sys/bus/msm_subsys/devices/subsys0/restart_level"
adb -s %D_ID% shell "echo related > /sys/bus/msm_subsys/devices/subsys1/restart_level"
adb -s %D_ID% shell "echo related > /sys/bus/msm_subsys/devices/subsys2/restart_level"

REM QXDMSendScript.pl %D_PORT% %D_CMD1%
REM timeout 10
REM QXDMSendScript.pl %D_PORT% %D_CMD2%
REM timeout 10
REM QXDMSendScript.pl %D_PORT% %D_CMD3%
REM timeout 10
REM QXDMSendScript.pl %D_PORT% %D_CMD4%
REM timeout 10
QXDMSendScript.pl %D_PORT% %D_CMD5%
timeout 7
REM QXDMSendScript.pl %D_PORT% %D_CMD6%
REM timeout 10
REM QXDMSendScript.pl %D_PORT% %D_CMD7%


set /a count=%count%+1

goto start:




