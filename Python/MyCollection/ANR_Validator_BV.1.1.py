import os, time, sys, glob
import shutil

filelist = glob.glob("*.txt")
for f in filelist:
    os.remove(f)

while(1):

	
	path = raw_input("\nEnter path:: ")
	
	if (path==''):
		print "No input received"
	elif not os.path.exists(path):
		print "Enter correct location"	
	else:
		break
	
now = time.time()
date_string = time.strftime("%Y-%m-%d-%H-%M-%S")

# os.system("pause")
print "\nProcessing.....\n"

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
srcfile= os.getcwd()+"\ANR_" + date_string + ".txt"		
if os.path.isfile(srcfile):
	with open(srcfile) as file1:
		for line1 in file1:
			line1=line1.strip()
			fields = line1.split('\\')
			# print fields
			max=len(fields)
			# print max
			# del fields[max-1]
			# print fields
			
			sep = "\\";
			count=0
			logcat=[]
			while(count<(max-1)):
				# print count
				# print fields[count]
				logcat.append(fields[count])
				count = count + 1
			
			dir=sep.join(logcat)
			logcat=dir+"\\logcat.txt"
			anr=line1
			# logcat=fields[0]+"\\"+fields[1]+"\\"+fields[2]+"\\"+fields[3]+"\\"+fields[4]+"\\"+fields[5]+"\\logcat.txt"
			print "-------------------------------------------------------------------"
			print anr
			print logcat
			


			# os.system("pause")
			
			with open(anr, 'r') as file2:
				for line2 in file2.readlines(5):
					if 'pid' in line2:
						tanr_pid=line2.split()
						anr_pid=int(tanr_pid[2])							
			print "PID in traces.txt is " , anr_pid
			
			if not os.path.isfile(logcat):	
				print"Logcat not found"
				# break
			else:							
			# with open('input.txt', 'r') as file1:
				# for line1 in file1:
				with open(logcat, 'r') as file2:
					for line2 in file2:	
						if ('/iperf:' in line2 or '/com.android.bluetooth:' in line2):
							if not os.path.isfile("Logcat_" + date_string + ".txt"):						
								f1 = open(("Logcat_" + date_string + ".txt"), "a")
								# print line2
								line2=line2.strip()
								f1.write(line2);
								f1.write("\n");
								f1.close()
							else:							
								if line2 in open("Logcat_" + date_string + ".txt").read():
									# print "Duplicate" 
									pass
								else:	
									f1 = open(("Logcat_" + date_string + ".txt"), "a+")
									# print line2
									line2=line2.strip()
									f1.write(line2);
									f1.write("\n");
									f1.close()
			
				if os.path.isfile("Logcat_" + date_string + ".txt"):							
					with open(("Logcat_" + date_string + ".txt"),'r') as file1:
						count=0
						iperf=0
						cpu=0
						pid=0
						pidm=0
						for line in file1:
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
							
							# print "CPU:", cpu
							# print "Logcat_pid:", pid
							# print "anr_pid:", anr_pid
							# os.system("pause")
							
							if (pid==anr_pid):

								pidm+= 1
								print "\nMatch found"
								print "Logcat_pid:", pid
								print "anr_pid:", anr_pid
								print "\nCPU:", cpu

								cpu=cmp(cpu,5)
								# print cpu
								if ( cpu==1 and iperf>=1 ):
									print "com.android.bluetooth was running on expected CPU....\n"
									srcdir=dir
									dstdir=dir+"_valid"
									os.rename(srcdir,dstdir)
									break
								elif ( cpu==-1 and iperf==0 ):
									print "Iperf process not found....\n"
									srcdir=dir
									dstdir=dir+"_valid"
									os.rename(srcdir,dstdir)
									break						
								else:
									print "Iperf process found and"
									print "com.android.bluetooth was running on below expected CPU....\n"
									break
									
							else:
								pass
							
						if (pidm>=1):
							pass
						else:
							print "PID MisMatch"
				else: 
					print "No com.android.bluetooth is detected from logcat....\n"	
else:
	print "ANR not found"
			
os.system("pause")
