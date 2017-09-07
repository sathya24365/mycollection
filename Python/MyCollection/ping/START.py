import os, time, sys, glob
import shutil

srcfile= os.getcwd()+"\\"+"ips.txt"	

while(1):	
	if os.path.isfile(srcfile):
		with open(srcfile) as file1:
			for line1 in file1:
				print (line1)
				os.system("start cmd /c ping %s -n 30" %(line1))
	time.sleep(120)