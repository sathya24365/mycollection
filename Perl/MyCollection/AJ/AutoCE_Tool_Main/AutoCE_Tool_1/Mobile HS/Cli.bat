@echo off

:start
color 7
title %ptag%_client
adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell iperf -c %IP% -i 1 -u -d -b 50M -t 600 -p %port%
adb -s %D_ID% shell iperf -c %IP% -i 1 -u -d -b 100M -t 600 -p %port%
adb -s %D_ID% shell iperf -c %IP% -i 1 -u -d -b 150M -t 600 -p %port%
adb -s %D_ID% shell iperf -c %IP% -i 1 -u -d -b 200M -t 600 -p %port%
adb -s %D_ID% shell iperf -c %IP% -i 1 -u -d -b 300M -t 600 -p %port%

color c
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
goto start: