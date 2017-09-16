import xml.etree.ElementTree as ET
import os, time, sys, subprocess, random

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
			
def autoport():
		global port
		port=random.randrange(5000, 5999, 1);
		return port
	
def cleanup():
	# os.system("adb kill-server")
	# os.system("taskkill /f /im adb.exe /t")
	os.system("taskkill /f /im cmd.exe /t")
	# pass
	
def init(tdls1_sap_go_hwid,tdls2_sta_cl_hwid):
	os.system("adb start-server")
	os.system("start cmd /K adb -s %s shell wait-for-device root" %(tdls1_sap_go_hwid))
	os.system("start cmd /K adb -s %s shell wait-for-device root" %(tdls1_sap_go_hwid))
	os.system("start cmd /K adb -s %s shell wait-for-device root" %(tdls2_sta_cl_hwid))
	os.system("start cmd /K adb -s %s shell wait-for-device root" %(tdls2_sta_cl_hwid))
	time.sleep(5)
	

def getdata():
	global data,tsc,tcc,ttime
	root = ET.parse(xml)
	count=0
	tts=0
	data = []
	tcc = []
	ttime = []
	
	for testsuite in root.findall('testsuite'):
		tts = tts + 1

	while (count < tts):
		data.append([])
		tcc.append([])
		ttime.append([])
		count = count + 1	
	for testsuite in root.findall('testsuite'):
		number = testsuite.get('number')

		i=0
		temp=0
		try:
		  tsc+=1
		except: 
		  tsc=1
		for testcase in testsuite.findall('testcase'):
			try:
			  i+=1
			except: 
			  i=1			
			tdls1_sap_go_hwid = testcase.find('tdls1_sap_go_hwid').text
			tdls2_sta_cl_hwid = testcase.find('tdls2_sta_cl_hwid').text
			tdls1_sap_go_pc_ip = testcase.find('tdls1_sap_go_pc_ip').text
			tdls2_sta_cl_sta_ip = testcase.find('tdls2_sta_cl_sta_ip').text
			rtime = testcase.find('rtime').text
			
			name = testcase.get('name')
			number=int(number)					
			data[number].append(name);
			data[number].append(rtime);
			data[number].append(tdls1_sap_go_pc_ip);
			data[number].append(tdls2_sta_cl_sta_ip);
			data[number].append(tdls1_sap_go_hwid);
			data[number].append(tdls2_sta_cl_hwid);
			tcc[number]=i			
			if (rtime>temp):
				temp = rtime
			ttime[number]=temp
	return data,tsc,tcc,ttime
	
def udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid):

	print testcase
	print rtime
	print tdls1_sap_go_pc_ip
	print tdls2_sta_cl_sta_ip
	print tdls1_sap_go_hwid
	print tdls2_sta_cl_hwid
	
	if (tc == 1):	
		print "udpul"			
		port1=autoport();
		os.system("start cmd /K iperf -s -i 1 -u -p %s" %(port1))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port1))
	elif(tc == 2):
		print "udpdl"		
		port2=autoport();		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port2))
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -p %s" %(tdls2_sta_cl_sta_ip, rtime, port2))					
		
	elif(tc == 3):
		print "udpqosul"
		port5=autoport();
		port6=autoport();
		port7=autoport();
		port8=autoport();

		os.system("start cmd /K iperf -s -i 1 -u -p %s" %(port5))
		os.system("start cmd /K iperf -s -i 1 -u -p %s" %(port6))
		os.system("start cmd /K iperf -s -i 1 -u -p %s" %(port7))
		os.system("start cmd /K iperf -s -i 1 -u -p %s" %(port8))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0xe0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port5))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0xa0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port6))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0x20 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port7))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0x00 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port8))

	elif(tc == 4):
		print "udpqosdl"
		port9=autoport();
		port10=autoport();
		port11=autoport();
		port12=autoport();
		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port9))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port10))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port11))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port12))
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0xe0 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port9))	
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0xa0 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port10))	
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0x20 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port11))	
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0x00 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port12))	
	
	elif (tc == 5):	
		print "sapp2ptdlsudpul"
		port3=autoport();		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls1_sap_go_hwid, port3))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port3))
	
	elif(tc == 6):	
		print "sapp2ptdlsudpdl"
		port4=autoport();		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port4))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port4))
		
	
	elif(tc == 7):
		print "sapp2ptdlsudpqosul"
		port13=autoport();
		port14=autoport();
		port15=autoport();
		port16=autoport();

		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls1_sap_go_hwid, port13))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls1_sap_go_hwid, port14))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls1_sap_go_hwid, port15))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls1_sap_go_hwid, port16))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0xe0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port13))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0xa0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port14))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0x20 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port15))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -u -b 900M -t %s -S 0x00 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port16))

	elif(tc == 8):
		print "sapp2ptdlsudpqosdl"
		port17=autoport();
		port18=autoport();
		port19=autoport();
		port20=autoport();
		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port17))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port18))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port19))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -u -p %s" %(tdls2_sta_cl_hwid, port20))
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0xe0 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port17))	
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0xa0 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port18))	
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0x20 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port19))	
		os.system("start cmd /K iperf -c %s -i 1 -u -b 900M -t %s -S 0x00 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port20))
		
	else: 
		print "Wrong Entry!"
	
def tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid):

	if (tc == 1):	
		print "tcpul"			
		port1=autoport();		
		os.system("start cmd /K iperf -s -i 1 -w 1M -p %s" %(port1))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port1))
	
	elif(tc == 2):
		print "tcpdl"
		port2=autoport();		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port2))
		os.system("start cmd /K iperf -c %s -i 1 -w 1M -t %s -p %s" %(tdls2_sta_cl_sta_ip, rtime, port2))			
		
	elif(tc == 3):
		print "tcpqosul"
		port5=autoport();
		port6=autoport();
		port7=autoport();
		port8=autoport();

		os.system("start cmd /K iperf -s -i 1 -w 1M -p %s" %(port5))
		os.system("start cmd /K iperf -s -i 1 -w 1M -p %s" %(port6))
		os.system("start cmd /K iperf -s -i 1 -w 1M -p %s" %(port7))
		os.system("start cmd /K iperf -s -i 1 -w 1M -p %s" %(port8))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0xe0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port5))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0xa0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port6))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0x20 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port7))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0x00 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port8))

	elif(tc == 4):
		print "tcpqosdl"
		port9=autoport();
		port10=autoport();
		port11=autoport();
		port12=autoport();
		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port9))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port10))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port11))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port12))
		os.system("start cmd /K iperf -c %s -i 1 -w 1M -t %s -S 0xe0 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port9))	
		os.system("start cmd /K iperf -c %s -i 1 -w 1M -t %s -S 0xa0 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port10))	
		os.system("start cmd /K iperf -c %s -i 1 -w 1M -t %s -S 0x20 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port11))	
		os.system("start cmd /K iperf -c %s -i 1 -w 1M -t %s -S 0x00 -p %s" %(tdls2_sta_cl_sta_ip, rtime, port12))	
	
	elif (tc == 5):	
		print "sapp2ptdlstcpul"
		port3=autoport();		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls1_sap_go_hwid, port3))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port3))
	
	elif(tc == 6):	
		print "sapp2ptdlstcpdl"
		port4=autoport();		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port4))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port4))
		
	
	elif(tc == 7):
		print "sapp2ptdlstcpqosul"
		port13=autoport();
		port14=autoport();
		port15=autoport();
		port16=autoport();

		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls1_sap_go_hwid, port13))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls1_sap_go_hwid, port14))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls1_sap_go_hwid, port15))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls1_sap_go_hwid, port16))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0xe0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port13))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0xa0 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port14))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0x20 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port15))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0x00 -p %s" %(tdls2_sta_cl_hwid, tdls1_sap_go_pc_ip, rtime, port16))

	elif(tc == 8):
		print "sapp2ptdlstcpqosdl"
		port17=autoport();
		port18=autoport();
		port19=autoport();
		port20=autoport();
		
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port17))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port18))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port19))
		os.system("start cmd /K adb -s %s shell iperf -s -i 1 -w 1M -p %s" %(tdls2_sta_cl_hwid, port20))
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0xe0 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port17))	
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0xa0 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port18))	
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0x20 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port19))	
		os.system("start cmd /K adb -s %s shell iperf -c %s -i 1 -w 1M -t %s -S 0x00 -p %s" %(tdls1_sap_go_hwid, tdls2_sta_cl_sta_ip, rtime, port20))		
		
	else: 
		print "Wrong Entry!"


global xml
os.system("ls")
xml= raw_input("select test xml::")		
getdata()

print "Number of Test Suits::", tsc
count1=0
while (count1 < tsc):
	print "Number of Test Cases in Test Suite-%s::%s" %(count1, tcc[count1])
	print "Max time is", ttime[count1]
	count1 = count1 + 1
os.system("pause")

while 1:
	count2=0
	count3=0
	while (count2 < tsc):
		cleanup();
		count3=0
		while (count3 < tcc[count2]*6):
				testcase=data[count2][count3]
				rtime=data[count2][count3+1]
				tdls1_sap_go_pc_ip=data[count2][count3+2]
				tdls2_sta_cl_sta_ip=data[count2][count3+3]
				tdls1_sap_go_hwid=data[count2][count3+4]
				tdls2_sta_cl_hwid=data[count2][count3+5]
				# init(tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				
				# print testcase
				# print rtime
				# print tdls1_sap_go_pc_ip
				# print tdls2_sta_cl_sta_ip
				# print tdls1_sap_go_hwid
				# print tdls2_sta_cl_hwid
				# os.system("pause")
				
				# ---------------UDP-----------------
				if (testcase == 'udpbidi'):
						tc=1
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=2
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'udpul'):
						tc=1
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'udpdl'):
						tc=2
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'udpqosbidi'):
						tc=3
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=4
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'udpqosul'):
						tc=3
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'udpqosdl'):
						tc=4
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2pudpbidi'):
						tc=5
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=6
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2pudpul'):
						tc=5
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2pudpdl'):
						tc=6
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2pudpqosbidi'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2pudpqosul'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2pudpqosdl'):
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'sapudpbidi'):
						tc=5
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=6
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'sapudpul'):
						tc=5
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'sapudpdl'):
						tc=6
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'sapudpqosbidi'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'sapudpqosul'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'sapudpqosdl'):
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlsudpbidi'):
						tc=5
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=6
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlsudpul'):
						tc=5
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlsudpdl'):
						tc=6
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlsudpqosbidi'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlsudpqosul'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlsudpqosdl'):
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);

				# ---------------TCP-----------------
				elif (testcase == 'tcpbidi'):
						tc=1
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=2
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tcpul'):
						tc=1
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tcpdl'):
						tc=2
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tcpqosbidi'):
						tc=3
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=4
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tcpqosul'):
						tc=3
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tcpqosdl'):
						tc=4
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2ptcpbidi'):
						tc=5
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=6
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2ptcpul'):
						tc=5
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2ptcpdl'):
						tc=6
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2ptcpqosbidi'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2ptcpqosul'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'p2ptcpqosdl'):
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'saptcpbidi'):
						tc=5
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=6
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'saptcpul'):
						tc=5
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'saptcpdl'):
						tc=6
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'saptcpqosbidi'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'saptcpqosul'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'saptcpqosdl'):
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlstcpbidi'):
						tc=5
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=6
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlstcpul'):
						tc=5
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlstcpdl'):
						tc=6
						tcp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlstcpqosbidi'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlstcpqosul'):
						tc=7
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);
				elif (testcase == 'tdlstcpqosdl'):
						tc=8
						udp(tc,rtime,tdls1_sap_go_pc_ip,tdls2_sta_cl_sta_ip,tdls1_sap_go_hwid,tdls2_sta_cl_hwid);

				else:
				   print "NA"
				   
		
				count3 = count3 + 6
		x=int(ttime[count2])
		print "sleep::", x
		time.sleep(x)
		count2 = count2 + 1	

os.system("pause")