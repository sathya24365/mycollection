@echo off

adb devices


echo 1. Flood Ping
echo 2. Fast Ping

set /p choice=Enter the Choice:

goto %choice%

:1

set /p D_ID1=Enter the 1st Device ID:

adb -s %D_ID1% shell ifconfig p2p0

set /p IP1=Enter the IP:

set /p buff1=Enter the Buff size:



set /p D_ID2=Enter the 2nd Device ID:

adb -s %D_ID2% shell ifconfig p2p0

set /p IP2=Enter the IP:

set /p buff2=Enter the Buff size:


set D_ID=%D_ID1%
set buff=%buff2%
set IP=%IP2%

start Fldping.bat


set D_ID=%D_ID2%
set buff=%buff1%
set IP=%IP1%

start Fldping.bat

exit

:2

set /p D_ID1=Enter the 1st Device ID:

adb -s %D_ID1% shell ifconfig p2p0

set /p IP1=Enter the IP:




set /p D_ID2=Enter the 2nd Device ID:

adb -s %D_ID2% shell ifconfig p2p0

set /p IP2=Enter the IP:


set D_ID=%D_ID1%
set IP=%IP2%

start Fping.bat


set D_ID=%D_ID2%
set IP=%IP1%

start Fping.bat


exit
