import os, time, sys
import shutil
	
with open('traces.txt','r') as f:
    for line in f.readlines(5):
		if 'pid' in line:
			word1=line.split()	
			try:
				print word1[2]
			except:
				print "Invalid string"
				
		
os.system("pause")