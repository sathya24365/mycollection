from xml.dom import minidom
import os, time, sys
import subprocess

global D_ID
def adb(D_ID, *args):
	argv=["adb", "-s", D_ID, "shell"]
	if len(args)>0:
		argv.extend(args)
		stuff = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()
	# print stuff
	return stuff

class switch(object):
    def __init__(self, value):
        self.value = value
        self.fall = False

    def __iter__(self):
        """Return the match method once, then stop"""
        yield self.match
        raise StopIteration
    
    def match(self, *args):
        """Indicate whether or not to enter a case suite"""
        if self.fall or not args:
            return True
        elif self.value in args: # changed for v1.5, see below
            self.fall = True
            return True
        else:
            return False

def NAT():

	NAT = minidom.parse("NAT.xml")
	
	ARG1 = NAT.getElementsByTagName("Req_ID")[0]
	ARG2 = NAT.getElementsByTagName("WFC_Cmd")[0]
	ARG3 = NAT.getElementsByTagName("IP_packet_length")[0]
	ARG4 = NAT.getElementsByTagName("IP_packet_Hex")[0]
	ARG5 = NAT.getElementsByTagName("source_mac")[0]
	ARG6 = NAT.getElementsByTagName("dest_mac")[0]
	ARG7 = NAT.getElementsByTagName("period_in_msec")[0]
	ARG8 = NAT.getElementsByTagName("iterations")[0]
	ARG9 = NAT.getElementsByTagName("interval")[0]
	os.system("cls")

	WFC_Cmd=ARG2.firstChild.data
	IP_packet_length=ARG3.firstChild.data
	IP_packet_Hex=ARG4.firstChild.data
	source_mac=ARG5.firstChild.data
	dest_mac=ARG6.firstChild.data
	period_in_msec=ARG7.firstChild.data
	iterations=ARG8.firstChild.data
	interval=ARG9.firstChild.data
	
	if int(WFC_Cmd) == 1:
		print WFC_Cmd, IP_packet_length, IP_packet_Hex, source_mac, dest_mac, period_in_msec, iterations, interval
		while 1:
			print "NAT_Start"
			os.system("start cmd /c adb -s %s shell hal_proxy_daemon wfc wlan0 %s %s [%s] %s %s %s %s %s" %(D_ID, WFC_Cmd, IP_packet_length, IP_packet_Hex, source_mac, dest_mac, period_in_msec, iterations, interval))
			# os.system("echo adb shell hal_proxy_daemon wfc wlan0 %s %s %s %s %s" %(WFC_Cmd, Min_Rssi, Max_Rssi, iterations, interval))
			time.sleep((int(interval)*int(iterations))+5)
			adb(D_ID, 'busybox killall hal_proxy_daemon')
			
	elif int(WFC_Cmd) == 2:
		print WFC_Cmd, iterations, interval
		while 1:
			print "NAT_Stop"
			os.system("start cmd /c adb -s %s shell hal_proxy_daemon wfc wlan0 %s %s %s" %(D_ID, WFC_Cmd, iterations, interval))
			time.sleep((int(interval)*int(iterations))+5)
			adb(D_ID, 'busybox killall hal_proxy_daemon')
	else:
		print "Got a false value, Update NAT.xml with correct value"
	
		
def GSCAN():

	while 1:
		print "GSCAN"
		os.system("start cmd /c adb -s %s shell hal_proxy_daemon gscan wlan0 1 2"%(D_ID))
		time.sleep( 5 )
		adb(D_ID, 'busybox killall hal_proxy_daemon')

def RTT():

	print "No code for RTT"	

def RSSI():

	RSSI = minidom.parse("RSSI.xml")

	ARG1 = RSSI.getElementsByTagName("Req_ID")[0]
	ARG2 = RSSI.getElementsByTagName("WFC_Cmd")[0]
	ARG3 = RSSI.getElementsByTagName("Max_Rssi")[0]
	ARG4 = RSSI.getElementsByTagName("Min_Rssi")[0]
	ARG5 = RSSI.getElementsByTagName("iterations")[0]
	ARG6 = RSSI.getElementsByTagName("interval")[0]
	
	WFC_Cmd=ARG2.firstChild.data
	Max_Rssi=ARG3.firstChild.data
	Min_Rssi=ARG4.firstChild.data
	iterations=ARG5.firstChild.data
	interval=ARG6.firstChild.data
	
	# print("Max_Rssi::%s \nMin_Rssi::%s" %(ARG3.firstChild.data, ARG4.firstChild.data))
	
	if int(WFC_Cmd) == 3:
		print WFC_Cmd, Min_Rssi, Max_Rssi, iterations, interval
		while 1:
			print "RSSI_Start"
			os.system("start cmd /k adb -s %s shell hal_proxy_daemon wfc wlan0 %s %s %s %s %s" %(D_ID, WFC_Cmd, Min_Rssi, Max_Rssi, iterations, interval))
			# os.system("echo adb -s %s shell hal_proxy_daemon wfc wlan0 %s %s %s %s %s" %(D_ID, WFC_Cmd, Min_Rssi, Max_Rssi, iterations, interval))
			time.sleep((int(interval)*int(iterations))+5)
			adb(D_ID, 'busybox killall hal_proxy_daemon')
	elif int(WFC_Cmd) == 4:
		print WFC_Cmd, iterations, interval
		while 1:
			print "RSSI_Stop"
			os.system("start cmd /c adb -s %s shell hal_proxy_daemon wfc wlan0 %s %s %s" %(D_ID, WFC_Cmd, iterations, interval))
			time.sleep((int(interval)*int(iterations))+5)
			adb(D_ID, 'busybox killall hal_proxy_daemon')
	else:
		print "Got a false value, Update RSSI.xml with correct value"

		
os.system("adb devices")
D_ID= raw_input("select Device ID::")
while 1:

	os.system("cls")
	print "1.NAT"
	print "2.GSCAN"
	print "3.RTT"
	print "4.RSSI"

	x= raw_input("Enter Your Choice::")
	adb(D_ID, 'busybox killall hal_proxy_daemon')	
	for case in switch(x):
		if case('1'):
			NAT();
			break
		if case('2'):
			GSCAN();
			break
		if case('3'):
			RTT();
			break
		if case('4'):
			RSSI();
			break
		if case(): 
			print "Wrong Entry!"	
		
	os.system("pause")