from xml.dom import minidom
import os, time, sys, glob
import subprocess
import shutil

def adb(D_ID, *args):
	argv=["adb", "-s", D_ID, "shell"]
	# print argv
	if len(args)>0:
		argv.extend(args)
		stuff = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()
	# print stuff
	return stuff

	
def Monitor():
	src=os.getcwd()+"\\"+"sh"+"\\."
	des="/data/local"
	
	os.system("adb -s %s push %s %s" %(D_ID,src,des))

	os.system("adb -s %s shell busybox dos2unix -u /data/local/AnrMonitor.sh" %(D_ID))
	os.system("adb -s %s shell busybox dos2unix -u /data/local/Logcat.sh" %(D_ID))
	os.system("adb -s %s shell chmod 777 /data/local/*" %(D_ID))
	
	logcat_pid=adb(D_ID, 'busybox pgrep -fl Logcat.sh')
	logcat_pid=logcat_pid.split('/')
	print logcat_pid[0]	
	
	monitor_pid=adb(D_ID, 'busybox pgrep -fl AnrMonitor.sh')
	monitor_pid=monitor_pid.split('/')
	
	print monitor_pid[0]
	if logcat_pid[0]:
		print "Logcat is already running..."
	else:		
		os.system("start /MIN cmd /c adb -s %s shell ./data/local/Logcat.sh&" %(D_ID))
	
	if monitor_pid[0]:
		print "TMB/ANR Monitor is already running..."
	else:
		os.system("start /MIN cmd /c adb -s %s shell ./data/local/AnrMonitor.sh&" %(D_ID))
	
def Logger():

	global des_tmbs, des_anr, des_logcat
	date_string = time.strftime("%m-%d-%Y")	
	
	src_tmbs="/data/tombstones/Log"
	src_anr="/data/anr/Log"
	src_logcat="/sdcard/logcat/Log"
	
	
	# des_tmbs= os.getcwd()+"\\"+date_string+"\TMBS"
	# des_anr= os.getcwd()+"\\"+date_string+"\ANR"
	# des_logcat= os.getcwd()+"\\"+date_string+"\LOGCAT"
	
	des_tmbs= os.getcwd()+"\\"+D_ID+"\\"+date_string+"\\"
	des_anr= os.getcwd()+"\\"+D_ID+"\\"+date_string+"\\"
	des_logcat= os.getcwd()+"\\"+D_ID+"\\"+date_string+"\\"
	
	if not os.path.exists(des_tmbs):
		os.makedirs(des_tmbs)
	if not os.path.exists(des_anr):
		os.makedirs(des_anr)
	if not os.path.exists(des_logcat):
		os.makedirs(des_logcat)

	os.system("adb -s %s pull %s %s" %(D_ID,src_tmbs,des_tmbs))
	os.system("adb -s %s pull %s %s" %(D_ID,src_anr,des_anr))
	os.system("adb -s %s pull %s %s" %(D_ID,src_logcat,des_logcat))
	
	src_tmbs="/data/tombstones/Log/*"
	src_anr="/data/anr/Log/*.*"
	src_logcat="/sdcard/logcat/Log/*.*"
	# src_logcat="/sdcard/logcat/*"

	os.system("adb -s %s shell rm -r %s" %(D_ID,src_tmbs))
	os.system("adb -s %s shell rm -r %s" %(D_ID,src_anr))
	os.system("adb -s %s shell rm -r %s" %(D_ID,src_logcat))
	
def Filter():

	# filelist = glob.glob("*.txt")
	# for f in filelist:
		# os.remove(f)

	date_string = time.strftime("%Y-%m-%d-%H-%M-%S")
	
	for dirname, dirnames, filenames in os.walk(os.getcwd()+"\\"+D_ID):

		for filename in filenames:
			f = os.path.join(dirname,filename)	
			if (filename[0:6] == 'traces'):
				if not os.path.isfile("ANR_" + date_string + ".txt"):						
					f1 = open(("ANR_" + date_string + ".txt"), "a")
					f1.write(f);
					f1.write("\n");
					f1.close()
				else:							
					if f in open("ANR_" + date_string + ".txt").read():
						print "Duplicate" 
					else:	
						f1 = open(("ANR_" + date_string + ".txt"), "a+")
						f1.write(f);
						f1.write("\n");
						f1.close()
			else:
				pass
				# print "error1"
	for dirname, dirnames, filenames in os.walk(os.getcwd()+"\\"+D_ID):

		for filename in filenames:
			f = os.path.join(dirname,filename)	
			if (filename[0:9] == 'tombstone'):
				if not os.path.isfile("TMB_" + date_string + ".txt"):						
					f1 = open(("TMB_" + date_string + ".txt"), "a")
					f1.write(f);
					f1.write("\n");
					f1.close()
				else:							
					if f in open("TMB_" + date_string + ".txt").read():
						print "Duplicate" 
					else:	
						f1 = open(("TMB_" + date_string + ".txt"), "a+")
						f1.write(f);
						f1.write("\n");
						f1.close()
			else:
				pass
				# print "error2"
				
	for dirname, dirnames, filenames in os.walk(os.getcwd()+"\\"+D_ID):
		for filename in filenames:
			f = os.path.join(dirname,filename)	
			if (filename[0:6] == 'logcat'):
				if not os.path.isfile("LOGCAT_" + date_string + ".txt"):						
					f1 = open(("LOGCAT_" + date_string + ".txt"), "a")
					f1.write(f);
					f1.write("\n");
					f1.close()
				else:							
					if f in open("LOGCAT_" + date_string + ".txt").read():
						print "Duplicate" 
					else:	
						f1 = open(("LOGCAT_" + date_string + ".txt"), "a+")
						f1.write(f);
						f1.write("\n");
						f1.close()
			else:
				pass
				# print "error3"

	if os.path.isfile("LOGCAT_" + date_string + ".txt"):
		with open(("LOGCAT_" + date_string + ".txt"), 'r') as file1:
			for line1 in file1:
				srcdir=line1
				line1=line1.strip()
				line1=line1.replace(" ", "")
				fields = line1.split('\\')
				max=len(fields)-1
				sample=fields[max] # logcat_07-11-2016-17
				sample=sample.strip()
				sample=sample.replace(" ", "")
				# print "length", len(sample)
				
				# for letter in sample:
					# print letter
				
				mm=sample[7:9]
				dd=sample[10:12]
				yy=sample[13:17]
				hrs=sample[18:20]
				# print "sample is ", sample
				# print "date is ", mm
				# print "date is ", dd
				# print "date is ", yy
				# print "date is ", hrs
				
				srcdir=line1
				dstdir="C:\Android"+"\\"+mm+"-"+dd+"-"+yy+"\\"+D_ID+"\\"+hrs+"\\"
				print srcdir
				print dstdir
				if not os.path.exists(dstdir):
					os.makedirs(dstdir)
				try:
					shutil.copy(line1,dstdir)
					os.remove(line1)
				except:
					print "Logcat does not exist"
	else:
		print "\nLogcat does not exist"
		
	if os.path.isfile("ANR_" + date_string + ".txt"):			
		with open(("ANR_" + date_string + ".txt"), 'r') as file1:
			for line1 in file1:
				srcdir=line1
				line1=line1.strip()
				line1=line1.replace(" ", "")
				fields = line1.split('\\')
				max=len(fields)-1
				sample=fields[max] # traces_07-11-2016-17
				sample=sample.strip()
				sample=sample.replace(" ", "")
				
				mm=sample[7:9]
				dd=sample[10:12]
				yy=sample[13:17]
				hrs=sample[18:20]
				
				srcdir=line1
				dstdir="C:\Android"+"\\"+mm+"-"+dd+"-"+yy+"\\"+D_ID+"\\"+hrs+"\\"
				
				with open('signatures.txt', 'r') as file2:
					for line2 in file2:
						with open(line1, 'r') as file3:
							for line3 in file3.readlines(5):	
								if line2 in line3:				
									print srcdir
									print dstdir
									if not os.path.exists(dstdir):
										os.makedirs(dstdir)
									try:
										shutil.copy(line1,dstdir)
										rm_list=line1
									except:
										pass
										# print "error4"
				try:
					os.remove(rm_list)
				except:
					pass
					# print "error5"
	else:
		print "\nANR does not exist"

	if os.path.isfile("TMB_" + date_string + ".txt"):			
		with open(("TMB_" + date_string + ".txt"), 'r') as file1:
			for line1 in file1:
				srcdir=line1
				line1=line1.strip()
				line1=line1.replace(" ", "")
				fields = line1.split('\\')
				max=len(fields)-1
				sample=fields[max] # tombstone_07-11-2016-17
				sample=sample.strip()
				sample=sample.replace(" ", "")
				
				mm=sample[10:12]
				dd=sample[13:15]
				yy=sample[16:20]
				hrs=sample[21:23]
				
				srcdir=line1
				dstdir="C:\Android"+"\\"+mm+"-"+dd+"-"+yy+"\\"+D_ID+"\\"+hrs+"\\"
				with open('signatures.txt', 'r') as file2:
					for line2 in file2:
						with open(line1, 'r') as file3:
							for line3 in file3.readlines(5):	
								if line2 in line3:				
									print srcdir
									print dstdir
									if not os.path.exists(dstdir):
										os.makedirs(dstdir)
									try:
										shutil.copy(line1,dstdir)
										rm_list=line1
									except:
										pass
										# print "error6"
										
				try:
					os.remove(rm_list)
				except:
					pass
					# print "error7"
				

	else:
		print "\nTMB does not exist"

	if os.path.isfile("LOGCAT_" + date_string + ".txt"):	
		os.remove(("LOGCAT_" + date_string + ".txt"))
	if os.path.isfile("ANR_" + date_string + ".txt"):	
		os.remove(("ANR_" + date_string + ".txt"))
	if os.path.isfile("TMB_" + date_string + ".txt"):
		os.remove(("TMB_" + date_string + ".txt"))

def Parser():
	pass
	


global D_ID
os.system("cls")
command_result = ''
command_text = 'adb devices'
results = os.popen(command_text, "r")
while 1:
	line = results.readline()
	if not line: break
	command_result += line
devices = command_result.partition('\n')[2].replace('\n','').split('\tdevice')

count=len(devices)-1
devices=filter(None, devices)

mm = time.strftime("%m")
dd = time.strftime("%d")
yyyy = time.strftime("%Y")
h = time.strftime("%H")
m = time.strftime("%M")
s = time.strftime("%S")



for device in devices:
	cmd1='date %s%s%s%s%s'%(mm,dd,h,m,yyyy)
	cmd2='date -s %s%s%s.%s%s%s'%(yyyy,mm,dd,h,m,s)
	# print cmd1
	# print cmd2
	adb(device, cmd1)
	adb(device, cmd2)
	# print adb(device, 'date')
	print device
	
os.system("pause")
print "Press Enter to continue...."
	
while 1:
	os.system("cls")
	for D_ID in devices:
		print "\n-----------------Monitoring_%s------------------------\n" %(D_ID)
		Monitor();
		Logger();
		Filter();		
	
	for D_ID in devices:
		print "\n-----------------Parsing_%s---------------------------\n" %(D_ID)	
		# Parser();
	
	cmin= int(time.strftime("%M")) * 60
	delay=3600 - int(cmin)
	
	print "Sleep:", delay
	time.sleep(delay)
	time.sleep(60)
	