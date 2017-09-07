1. Run Start_Automation.pl

2. If P2P connection is not stable, check p2p_supplicant_stable.conf.

3. Open the file, change android device id: Android_abc123 -> Android_deviceID

4. Issue the command: 
	adb -s deviceID push p2p_supplicant_stable.conf /data/misc/wifi/p2p_supplicant.conf

5. Reboot the device and run Start_Automation.pl again


