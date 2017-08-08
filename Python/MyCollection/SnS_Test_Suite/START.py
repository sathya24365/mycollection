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

def bidi():

	os.system("cls")
	
	print "1.UDP"
	print "2.TCP"
	x1= raw_input("Enter Your Choice::")
	os.system("adb devices")
	D_ID= raw_input("select Device ID::")
	
	os.system("adb -s %s shell ifconfig wlan0" %(D_ID))
	mip= raw_input("enter DUT IP::")
	
	os.system('ipconfig | find "IPv4"')
	dip= raw_input("enter Desktop IP::")
	os.system("run-client.bat param1 param2")
	for case in switch(x1):
		if case('1'):
			port1=5001
			port2=5002
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID, port1))
			os.system("start cmd /k iperf -s -i 1 -u -p %s" %(port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID, dip, port2))
			os.system("start cmd /k iperf -c %s -i 1 -u -b 100M -t 3600 -p %s" %(mip, port1))	
			break
		if case('2'):
			port1=5003
			port2=5004
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID, port1))
			os.system("start cmd /k iperf -s -i 1 -w 1M -p %s" %(port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -p %s" %(D_ID, dip, port2))
			os.system("start cmd /k iperf -c %s -i 1 -u -w 1M -t 3600 -p %s" %(mip, port1))
			break
			
		if case(): 
			print "Wrong Entry!"
	
	return
	
	
def qos():

	os.system("cls")
	
	print "1.UDP"
	print "2.TCP"
	x2= raw_input("Enter Your Choice::")
	os.system("adb devices")
	D_ID= raw_input("select Device ID::")
	
	os.system("adb -s %s shell ifconfig wlan0" %(D_ID))
	mip= raw_input("enter DUT IP::")
	
	os.system('ipconfig | find "IPv4"')
	dip= raw_input("enter Desktop IP::")
	
	for case in switch(x2):
		if case('1'):
			port1=5010
			port2=5011
			port3=5012
			port4=5013
			
			port5=5014
			port6=5015
			port7=5016
			port8=5017
			
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID, port5))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID, port6))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID, port7))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID, port8))
			
			os.system("start cmd /k iperf -s -i 1 -u -p %s" %(port1))
			os.system("start cmd /k iperf -s -i 1 -u -p %s" %(port2))
			os.system("start cmd /k iperf -s -i 1 -u -p %s" %(port3))
			os.system("start cmd /k iperf -s -i 1 -u -p %s" %(port4))
			
			
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -S 0xe0 -p %s" %(D_ID, dip, port1))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -S 0xa0 -p %s" %(D_ID, dip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -S 0x20 -p %s" %(D_ID, dip, port3))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -S 0x00 -p %s" %(D_ID, dip, port4))
			
			os.system("start cmd /k iperf -c %s -i 1 -u -b 100M -t 86400 -S 0xe0 -p %s" %(mip, port5))	
			os.system("start cmd /k iperf -c %s -i 1 -u -b 100M -t 86400 -S 0xa0 -p %s" %(mip, port6))	
			os.system("start cmd /k iperf -c %s -i 1 -u -b 100M -t 86400 -S 0x20 -p %s" %(mip, port7))	
			os.system("start cmd /k iperf -c %s -i 1 -u -b 100M -t 86400 -S 0x00 -p %s" %(mip, port8))	
			break
		if case('2'):
			port1=6010
			port2=6011
			port3=6012
			port4=6013
			
			port5=6014
			port6=6015
			port7=6016
			port8=6017
			
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID, port2))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID, port3))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID, port4))
			
			
			os.system("start cmd /k iperf -s -i 1 -w 1M -p %s" %(port5))
			os.system("start cmd /k iperf -s -i 1 -w 1M -p %s" %(port6))
			os.system("start cmd /k iperf -s -i 1 -w 1M -p %s" %(port7))
			os.system("start cmd /k iperf -s -i 1 -w 1M -p %s" %(port8))
			
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -S 0xe0 -p %s" %(D_ID, dip, port5))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -S 0xa0 -p %s" %(D_ID, dip, port6))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -S 0x20 -p %s" %(D_ID, dip, port7))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -S 0x00 -p %s" %(D_ID, dip, port8))
			
			os.system("start cmd /k iperf -c %s -i 1 -u -w 1M -t 3600 -S 0xe0 -p %s" %(mip, port1))
			os.system("start cmd /k iperf -c %s -i 1 -u -w 1M -t 3600 -S 0xa0 -p %s" %(mip, port2))
			os.system("start cmd /k iperf -c %s -i 1 -u -w 1M -t 3600 -S 0x20 -p %s" %(mip, port3))
			os.system("start cmd /k iperf -c %s -i 1 -u -w 1M -t 3600 -S 0x00 -p %s" %(mip, port4))
			break
			
		if case(): 
			print "Wrong Entry!"
	
	return

def sap():

	os.system("cls")
	
	print "1.UDP"
	print "2.TCP"
	x3= raw_input("Enter Your Choice::")
	os.system("adb devices")
	D_ID1= raw_input("select SAP Device ID::")
	D_ID2= raw_input("select STA Device ID::")
	
	os.system("adb -s %s shell ifconfig wlan0" %(D_ID2))
	sta_ip= raw_input("enter STA DUT IP::")
	print "192.168.43.1"
	sap_ip= raw_input("enter SAP DUT IP::")
	

	for case in switch(x3):
		if case('1'):
			port1=6001
			port2=6002
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID1, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID2, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID1, sta_ip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID2, sap_ip, port1))	
			break
		if case('2'):
			port1=6003
			port2=6004
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID1, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID2, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -p %s" %(D_ID1, sta_ip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -w 1M -t 86400 -p %s" %(D_ID2, sap_ip, port1))
			break
			
		if case(): 
			print "Wrong Entry!"
	
	return
	
def p2p():

	os.system("cls")
	
	print "1.UDP"
	print "2.TCP"
	x4= raw_input("Enter Your Choice::")
	os.system("adb devices")
	D_ID1= raw_input("select GO Device ID::")
	D_ID2= raw_input("select CL Device ID::")
	
	os.system("adb -s %s shell ifconfig p2p0" %(D_ID2))
	cl_ip= raw_input("Enter CL DUT IP::")
	print"192.168.49.1"
	go_ip=raw_input("Enter GO DUT IP::")
	

	for case in switch(x4):
		if case('1'):
			port1=7001
			port2=7002
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID1, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID2, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID1, cl_ip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID2, go_ip, port1))	
			break
		if case('2'):
			port1=7003
			port2=7004
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID1, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID2, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -p %s" %(D_ID1, cl_ip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -w 1M -t 86400 -p %s" %(D_ID2, go_ip, port1))
			break
			
		if case(): 
			print "Wrong Entry!"
	
	return

def tdls():

	os.system("cls")
	
	print "1.UDP"
	print "2.TCP"
	x5= raw_input("Enter Your Choice::")
	os.system("adb devices")
	D_ID1= raw_input("select D_ID1 Device ID::")
	D_ID2= raw_input("select D_ID2 Device ID::")
	
	os.system("adb -s %s shell ifconfig wlan0" %(D_ID1))
	dut1_ip= raw_input("Enter DUT-1 IP::")
	os.system("adb -s %s shell ifconfig wlan0" %(D_ID2))
	dut2_ip= raw_input("Enter CL DUT-2 IP::")

	

	for case in switch(x5):
		if case('1'):
			port1=7001
			port2=7002
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID1, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -u -p %s" %(D_ID2, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID1, dut2_ip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -b 100M -t 86400 -p %s" %(D_ID2, dut1_ip, port1))	
			break
		if case('2'):
			port1=7003
			port2=7004
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID1, port1))
			os.system("start cmd /k adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(D_ID2, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -w 1M -t 86400 -p %s" %(D_ID1, dut1_ip, port2))
			os.system("start cmd /k adb -s %s shell iperf -c %s -i 1 -u -w 1M -t 86400 -p %s" %(D_ID2, dut2_ip, port1))
			break
			
		if case(): 
			print "Wrong Entry!"
	
	return

def traffic():

	
	os.system("cls")
	print "1.BIDI"
	print "2.QOS"
	print "3.SAP"
	print "4.P2P"
	print "5.TDLS"
	x6= raw_input("Enter Your Choice::")
	
	for case in switch(x6):
		if case('1'):
			bidi();
			break
		if case('2'):
			qos();
			break
		if case('3'):
			sap();
			break
		if case('4'):
			p2p();
			break
		if case('4'):
			tdls();
			break
			
		if case(): 
			print "Wrong Entry!"
	return 

	
def toggle():	

	os.system("cls")
	print "1.WIFI ON OFF"
	print "2.BT ON OFF"
	print "3.LCD ON OFF"
	print "4.APN ON OFF"
	print "5.DATA ON OFF"
	x7= raw_input("Enter Your Choice::")

	os.system("adb devices")
	D_ID= raw_input("select Device ID::")

	for case in switch(x7):
		if case('1'):
			os.system("start cmd /k wifi.bat %s" %(D_ID))
			break
		if case('2'):
			os.system("start cmd /k bt.bat %s" %(D_ID))
			break
		if case('3'):
			os.system("start cmd /k lcd.bat %s" %(D_ID))
			break
		if case('4'):
			os.system("start cmd /k apn.bat %s" %(D_ID))
			break
		if case('5'):
			os.system("start cmd /k data.bat %s" %(D_ID))
			break

		if case(): 
			print "Wrong Entry!"


	return

		

while 1:

	os.system("cls")
	print "1.Traffic Scenarios"
	print "2.On Off Scenarios"

	x8= raw_input("Enter Your Choice::")
	for case in switch(x8):
		if case('1'):
			traffic();
			break
		if case('2'):
			toggle();
			break
		if case(): 
			print "Wrong Entry!"	
		
	os.system("pause")