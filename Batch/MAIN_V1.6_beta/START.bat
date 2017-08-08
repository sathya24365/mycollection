@echo off
title Logging

:1
echo Detected adb devices are:
echo.
adb devices | cut -f 1 -s | tee adb_List.txt
echo.
pause

:back
VER>NUL
cls
echo 1.Rescan
echo 2.Continue Loading
echo.
set /p ch=Enter your choice:
IF %ERRORLEVEL%==1 goto :back
goto :%ch%


:2
cls
echo Detected devices are:
echo.
adb devices | cut -f 1 -s | tee adb_List.txt
pause

for /f %%i in (adb_List.txt) do ( 
set D_ID=%%i

REM start DATE.BAT
REM start LOGCAT.BAT
start KMSG.BAT
start Wifi_logger.bat
start BTSnooplogs.bat

start cmd /k TMBS_ANR.py %%i

)

title Log Terminator
:start
cls

set t=%TIME: =0%
set t=%t:~3,2%
set /A t=%t%*60
set /A t=3600-%t%

TIMEOUT /T %t% /NOBREAK


for /f %%i in (adb_List.txt) do ( 
cls
echo Terminating_%%i
set D_ID=%%i



REM adb -s %%i shell busybox killall logcat
adb -s %%i shell busybox killall WifiLogger_app

taskkill /F /FI "WINDOWTITLE eq Administrator:  %%i_kmsg" /T
start KMSG.BAT

taskkill /F /FI "WINDOWTITLE eq Administrator:  %%i_BTSnooplogs" /T
start BTSnooplogs.bat

)
goto :start
exit