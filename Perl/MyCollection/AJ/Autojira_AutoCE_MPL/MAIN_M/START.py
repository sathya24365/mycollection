from xml.dom import minidom
import os, time, sys, subprocess, psutil, thread

def adb(D_ID, *args):
	argv=["adb", "-s", D_ID, "shell"]
	if len(args)>0:
		argv.extend(args)
		stuff = subprocess.Popen(argv, stdout=subprocess.PIPE, stderr=subprocess.STDOUT).stdout.read()
	# print stuff
	return stuff

def Logging():
		print "kmsg"
		proc = subprocess.Popen(["start cmd /c adb -s %s shell cat /proc/kmsg"%(D_ID)], shell=True)
		pid = proc.pid
		print pid
		os.system("pause")
		while 1:
			time.sleep( 5 )
			if psutil.pid_exists(pid):
				print "kmsg already running"
				os.system("pause")
			else:			
				print "New kmsg starting"
				proc = subprocess.Popen(["start cmd /c adb -s %s shell cat /proc/kmsg"%(D_ID)], shell=True)
				pid = proc.pid	
				os.system("pause")


global D_ID
os.system("adb devices")
D_ID= raw_input("select Device ID::")
os.system("cls")	
Logging();
os.system("pause")
	
	