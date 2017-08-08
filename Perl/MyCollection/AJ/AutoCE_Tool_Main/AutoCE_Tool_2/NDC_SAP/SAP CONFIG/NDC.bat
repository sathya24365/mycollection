@echo off

adb devices
set /p D_ID=Enter the Device ID Name :

adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root
adb -s %D_ID% wait-for-device root

adb -s %D_ID% shell rmmod /system/lib/modules/wlan.ko
adb -s %D_ID% shell insmod /system/lib/modules/wlan.ko
adb -s %D_ID% shell ndc softap qccmd set enable_softap=1
adb -s %D_ID% shell ndc softap qccmd set ssid=AutoCE-SAP
adb -s %D_ID% shell ndc softap qccmd set channel=36
adb -s %D_ID% shell ndc softap qccmd set security_mode=3
adb -s %D_ID% shell ndc softap qccmd set auth_algs=1
adb -s %D_ID% shell ndc softap qccmd set rsn_pairwise=CCMP
adb -s %D_ID% shell ndc softap qccmd set wpa_passphrase=1234567890
adb -s %D_ID% shell ndc softap qccmd set commit
adb -s %D_ID% shell ndc softap startap
adb -s %D_ID% shell ifconfig wlan0 192.168.3.1
adb -s %D_ID% shell /system/bin/dnsmasq -x /data/dnsmasq.pid --no-resolv --no-poll --dhcp-range=192.168.3.2,192.168.3.244 & 

pause


