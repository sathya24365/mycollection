import os, time, sys
import shutil



if os.path.isfile("logcat.txt"):							
	with open(("logcat.txt"),'r') as file1:
		count=0
		iperf=0
		cpu=0
		pid=0
		pidm=0
		for line in file1:
			if '/com.android.bluetooth:' in line:
				tcpu=line.split()
				print tcpu[6]
				tcpu=tcpu[6].split("%")
				tpid1=line.split("/")
				# print tpid1
				tpid2=tpid1[0].split()
				print tpid2[7]
				print tcpu[0]
				cpu=float(tcpu[0])
				pid=int(tpid2[7])	
				iperf=count
				count=0		
			elif 'later with' in line:
				tcpu=line.split()
				print tcpu[14]
				tcpu=tcpu[14].split("%")
				total_cpu=int(tcpu[0])
				print total_cpu

else: 
	print "No com.android.bluetooth is detected from logcat....\n"