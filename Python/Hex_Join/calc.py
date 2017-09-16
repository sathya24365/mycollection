import os, time, sys, glob

srcfile='wmilength.txt'
with open(srcfile) as file:
	for line in file:
		line=line.strip()
		line=line.strip(',')	
		out = open(("out_wmilength" + ".txt"), "a")
		cal= int (line) / 4
		print cal
		out.write(str(cal));
		out.write('\n');
		out.close()
 
	os.system("pause")