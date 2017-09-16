@echo off
adb devices
set /p D_ID=Enter Device ID :

adb -s %D_ID%  root
adb -s %D_ID%  remount

adb -s %D_ID%  shell cat /etc/init.qcom.testscripts.sh | grep command
echo .
adb -s %D_ID%  shell echo "/system/bin/sh /etc/command.sh" >> /etc/init.qcom.testscripts.sh
echo .
adb -s %D_ID%  shell cat /etc/init.qcom.testscripts.sh | grep command.sh

pause