@echo off

:start
title %D_ID%_kmsg
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

set t=%TIME: =0%
set t=%t::=.%
set t=%t:~0,2%

set d=%date:~4,10%
set d=%d:/=-%

REM mkdir C:\Android\%d%\%D_ID%\%t%

adb -s %D_ID% shell cat /dev/kmsg | tee -a C:\Android\%d%\%D_ID%\%t%\kmsg.txt

adb -s %D_ID% wait-for-device root
goto start: