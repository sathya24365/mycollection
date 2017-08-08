import os, time, sys
import shutil

def logcat_filter(dir):
	# print dir
	for dirname, dirnames, filenames in os.walk(dir):
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
						f1 = open(("LOGCAT_" + date_string + ".txt"), "w+")
						f1.write(f);
						f1.write("\n");
						f1.close()
			else:
				pass
				# print "error3"

def anr_filter(path):
	# print path
	for dirname, dirnames, filenames in os.walk(path):

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

while(1):

	path = raw_input("Enter path:: ")
	if (path==''):
		print "No input received"
	else:
		if not os.path.exists(path):
			print "Path does not exists....."
		else:
			break
	
now = time.time()
date_string = time.strftime("%Y-%m-%d-%H-%M-%S")

# os.system("pause")
print "\nProcessing.....\n"

anr_filter(path);
			
with open(("ANR_" + date_string + ".txt"), 'r') as file1:
	for line1 in file1:
		line1=line1.strip()
		fields = line1.split('\\')
		max=len(fields)
		
		
		sep = "\\";
		count=0
		logcat=[]
		while(count<(max-1)):
			logcat.append(fields[count])
			count = count + 1
			
		anr=line1		
		dir=sep.join(logcat)
		# print dir 

		logcat_filter(dir);
		# os.system("pause")
		with open(("LOGCAT_" + date_string + ".txt"), 'r') as file2:
			for line2 in file2:
				print "-------------------------------------------------------------------"
				print anr
				print line2
				line2=line2.strip()
				# os.system("pause")
				
				with open(anr, 'r') as file3:
					for line3 in file3.readlines(5):
						if 'pid' in line3:
							tanr_pid=line3.split()
							anr_pid=int(tanr_pid[2])							
				# print "PID in traces.txt is " , anr_pid
				
				if not os.path.isfile(line2):	
					print"Logcat not found"
					print line2
					# break
				else:							
					with open(line2, 'r') as file4:
						for line4 in file4:	
							if (('PID: %s' %anr_pid) in line4 or 'CPU usage from' in line4 or '/iperf:' in line4 or '/com.android.bluetooth:' in line4):
								if not os.path.isfile("parser_" + date_string + ".txt"):						
									f1 = open(("parser_" + date_string + ".txt"), "a")
									# print line4
									line4=line4.strip()
									f1.write(line4);
									f1.write("\n");
									f1.close()
								else:							
									if line4 in open("parser_" + date_string + ".txt").read():
										# print "Duplicate" 
										pass
									else:	
										f1 = open(("parser_" + date_string + ".txt"), "a+")
										# print line4
										line4=line4.strip()
										f1.write(line4);
										f1.write("\n");
										f1.close()
				
					if os.path.isfile("parser_" + date_string + ".txt"):							
						with open(("parser_" + date_string + ".txt"),'r') as file5:
							count=0
							iperf=0
							cpu=0
							pid=0
							pidm=0
							pid2=0
							total_cpu=100
							for line in file5:
								if ('PID: %s' %anr_pid) in line:
									pid2=1		
								if pid2==1:
									if '/com.android.bluetooth:' in line:
										tcpu=line.split()
										tcpu=tcpu[6].split("%")
										tpid1=line.split("/")
										tpid2=tpid1[0].split()
										
										cpu=float(tcpu[0])
										pid=int(tpid2[7])	
										iperf=count
										count=0
									elif '/iperf:' in line:
										count+= 1
									elif 'later with' in line:
										tcpu=line.split()
										# print tcpu[14]
										tcpu=tcpu[14].split("%")
										total_cpu=int(tcpu[0])						
								
								if (pid==anr_pid):

									pidm+= 1
									print "\n********Match found**********"
									print "Logcat_pid:", pid
									print "anr_pid:", anr_pid
									print "\nTotal CPU:", total_cpu
									print "BT CPU:", cpu
									print "iperf:", iperf							

									cpu=cmp(cpu,5)
									# print cpu
									if ( cpu==1 and iperf>=1 and total_cpu>85):
										print "\nValid BT process...."
										print "com.android.bluetooth was running on expected CPU....\n"
										srcdir=dir
										dstdir=dir+"_valid"
										os.rename(srcdir,dstdir)
									elif ( cpu==-1 and iperf==0 and total_cpu>85):
										print "\nValid BT process...."
										srcdir=dir
										dstdir=dir+"_valid"
										os.rename(srcdir,dstdir)
									elif (total_cpu<=85):
										print "\nValid BT process...."
										print "Total CPU:%s was running below threshold value....\n" %(total_cpu)
										srcdir=dir
										dstdir=dir+"_valid"
										os.rename(srcdir,dstdir)									
									else:
										print "\nInValid BT process...."
										print "Iperf process found and"
										print "com.android.bluetooth was running on below expected CPU....\n"
										break
										
								else:
									pass
								
							if (pidm>=1):
								pass
							else:
								print "PID MisMatch\n"
					else: 
						print "No com.android.bluetooth is detected....\n"	
					
					if os.path.isfile("parser_" + date_string + ".txt"):	
						os.remove("parser_" + date_string + ".txt")
if os.path.isfile("Logcat_" + date_string + ".txt"):	
	os.remove("Logcat_" + date_string + ".txt")
if os.path.isfile("ANR_" + date_string + ".txt"):	
	os.remove("ANR_" + date_string + ".txt")
			
os.system("pause")
