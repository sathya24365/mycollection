import os, time, sys
import shutil

while(1):

	path = raw_input("Enter path:: ")
	if (path==''):
		print "No input received"
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
			
with open(("ANR_" + date_string + ".txt"), 'r') as file1:
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
		
		if not os.path.isfile(logcat):	
			print"Logcat not found"
			break
		else:
			pass

		# os.system("pause")
		
		with open(anr, 'r') as file2:
			for line2 in file2.readlines(5):
				if 'pid' in line2:
					tanr_pid=line2.split()
					anr_pid=int(tanr_pid[2])							
		print "PID in traces.txt is " , anr_pid
		
						
		with open(logcat, 'r') as file3:
			for line3 in file3:	
				if '/com.android.bluetooth:' in line3:
					tcpu=line3.split()
					tcpu=tcpu[6].split("%")
					tpid1=line3.split("/")
					tpid2=tpid1[0].split()
					
					cpu=float(tcpu[0])
					pid=int(tpid2[7])	
					
					print "CPU:", cpu
					print "Logcat_pid:", pid
					print "anr_pid:", anr_pid
					# os.system("pause")
					
					if (pid==anr_pid):
						print "\nMatch found"
						print "Logcat_pid:", pid
						print "anr_pid:", anr_pid
						print "\nCPU:", cpu
						cpu=cmp(cpu,5)
						# print cpu
						if (cpu==1):
							print "com.android.bluetooth was running on expected CPU....\n"
							srcdir=dir
							dstdir=dir+"_valid"
							os.rename(srcdir,dstdir)
							break
						else:
							print "com.android.bluetooth was running on below expected CPU....\n"
					else:
						# print "PID MisMatch\n"
						pass



		
	# os.system("pause")
			
os.system("pause")
