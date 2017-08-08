import os, time, sys, glob
import subprocess

def adb(D_ID, *args):
	argv=["adb", "-s", D_ID, "shell"]
	# print argv
	if len(args)>0:
		argv.extend(args)
		stuff = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()
	# print stuff
	return stuff

global D_ID
os.system("adb devices")
D_ID= raw_input("select Device ID::")

cmd1='find /data/core -name *.*.com.android.bluetooth'
cmd2='rm -r data/core/*'


while 1:
	command_result = adb(D_ID, cmd1)
	if command_result:
		print "result pass"
		command_result=command_result.strip()
		print command_result
		result=command_result.split('\n')
		for line in result:
			file=line[1:len(line)]
			# print file
			# print ("adb -s %s pull %s" %(D_ID, file))
			os.system("adb -s %s pull %s" %(D_ID, file))		
	else: 
		print "result fail"
	adb(D_ID, cmd2)	
	time.sleep(10)

os.system("pause")









