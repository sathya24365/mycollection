@echo off

:start

color 7
title %ptag%_server
adb -s %D_ID% wait-for-device root


adb -s %D_ID% shell iperf -s -i 1 -u -p %port%
 
color c
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

goto start: