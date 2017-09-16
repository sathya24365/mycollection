import os, sys, binascii, struct
srcfile= os.getcwd()+"\\"+"data.txt"
print srcfile
with open(srcfile) as file:
	for line in file:
		line=line.strip()
		i = int(line, 16)
		str(i)
		print i