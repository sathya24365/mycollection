import os, time, sys, glob

srcfile='wmi_buf.txt'
with open(srcfile) as file:

	f1 = open(("out_wmi_buf" + ".txt"), "a")	
	f1.write(" ".join(line.strip() for line in file));
	f1.close()
 
os.system("pause")