import os, time, sys
import shutil

# with open('Logcat_2016-06-23-14-27-50.txt','r') as f:
    # for line in f:
        # for word in line.split():
           # print word[7]
		   # os.system("pause")
	# print "\nEnter to Continue...."
	# os.system("pause")
	
with open('Logcat_2016-06-23-14-27-50.txt','r') as f:
    for line in f:
		word1=line.split()
		word2=line.split("/")
		word3=word2[0].split()
		
		# word2=text.split("/") 
		try:
			print word1[6]
			print word3[7]
		except:
			print "Invalid string"
		
		os.system("pause")
	
with open('Logcat_2016-06-23-14-27-50.txt','r') as f:
    for line in f:
		word1=line.split()
		word2=line.split("/")
		word3=word2[0].split()
		
		# word2=text.split("/") 
		try:
			print word1[6]
			print word3[7]
		except:
			print "Invalid string"
		
		os.system("pause")