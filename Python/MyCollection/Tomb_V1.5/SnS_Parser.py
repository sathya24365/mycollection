import os, time, sys
import shutil
import xlrd


def getdata():
	
	if fields[3] in hwid:
		for i in range(worksheet.nrows):
			if fields[3] == hwid[i]:
				return i
				break
	else:
		return 0		
			
path = raw_input("Enter path:: ")
# print path
# os.system("pause")


now = time.time()
date_string = time.strftime("%Y-%m-%d-%H-%M-%S")

workbook = xlrd.open_workbook('Book.xls')
worksheet = workbook.sheet_by_index(0)

pl=[]
hwid=[]
tc=[]
meta=[]
ext=[]

for x in range(worksheet.nrows):
  for y in range(worksheet.ncols):
 
    if worksheet.cell(x,y).value == xlrd.empty_cell.value:
        print "Empty"
    else:
		if y==0:       
			pl.append(worksheet.cell(x,y).value)
		elif y==1:
			hwid.append(worksheet.cell(x,y).value)
		elif y==2:  
			tc.append(worksheet.cell(x,y).value)
		elif y==3:  
			meta.append(worksheet.cell(x,y).value)
		elif y==4:  
			ext.append(worksheet.cell(x,y).value)
		# else:
			# print "Mismatch"

for p in range(worksheet.nrows):
	print meta[p]
print "\n"
for q in range(worksheet.nrows):
	print ext[q]

os.system("pause")
print "\nProcessing.....\n"

for dirname, dirnames, filenames in os.walk(path):

	for filename in filenames:
		f = os.path.join(dirname,filename)	

		if (filename[0:9] == 'tombstone'):
			# if not os.path.isfile("TMBS_" + date_string + ".txt"):
				# file(("TMBS_" + date_string + ".txt"), 'w').close()
			with open('input.txt', 'r') as file1:
				for line1 in file1:
					with open(f, 'r') as file2:
						for line2 in file2.readlines(10):	
							if line1 in line2:
								if not os.path.isfile("TMBS_" + date_string + ".txt"):						
									f1 = open(("TMBS_" + date_string + ".txt"), "a")
									f1.write(f);
									f1.write("\n");
									f1.close()
								else:							
									if f in open("TMBS_" + date_string + ".txt").read():
										print "Duplicate" 
									else:	
										f1 = open(("TMBS_" + date_string + ".txt"), "a+")
										f1.write(f);
										f1.write("\n");
										f1.close()
								
		elif (filename[0:6] == 'traces'):
			with open('input.txt', 'r') as file1:
				for line1 in file1:
					with open(f, 'r') as file2:
						for line2 in file2.readlines(5):	
							if line1 in line2:
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
								
		# else: 
			
			# print "Other file:", f
			
srcfile1= os.getcwd()+"\TMBS_" + date_string + ".txt"
srcfile2= os.getcwd()+"\ANR_" + date_string + ".txt"
print "\n"
print "\nPhase-I completed"
os.system("pause")

# C:\Android\02-25-2016\bfe4ad62\05\TMBS_05.33.46.25\tombstone_00
# 0: C:\
# 1: Android\
# 2: 01-13-2016\
# 3: 3c918d6c\
# 4: 20\
# 5: TMBS_20.56.29.84
# 6: tombstone_00


# \\lab5988\c$\Android\02-25-2016\3cc9bb64\04\TMBS_04.33.25.30\tombstone_00
# 0: \
# 1: \
# 2: lab5988\
# 3: c$\
# 4: Android\
# 5: 02-25-2016\
# 6: 3cc9bb64\
# 7: 04\
# 8:TMBS_04.33.25.30
# 9: tombstone_00


count=0

if os.path.isfile(srcfile1):

	with open(srcfile1) as file3:
		for line3 in file3:
			count += 1
			line3=line3.strip()	
			fields = line3.split('\\')
			max=len(fields)
			print max
			if (max == 10):
			
				print "remote Machine"
				# os.system("pause")
				# print line3
				# print dstdir	
				logcat= "\\\\"+fields[2]+"\\"+fields[3]+"\\"+fields[4]+"\\"+fields[5]+"\\"+fields[6]+"\\"+fields[7]+"\\logcat.txt"
				
				filename=fields[max-2]
				print filename
				if (filename[0:4] == 'TMBS'):
					dstdir="C:\RAMDUMPS"+"\\"+"TMBS"+"\\"+fields[5]+"\\"+fields[6]+"\\"+str(count)+"_"+filename+"\\"
					if not os.path.exists(dstdir):
						os.makedirs(dstdir)
					f3 = open((dstdir+"Scenario.txt"), "a")
					f3.write(tc[getdata()]);
					f3.write("\n");
					f3.close()					

					print line3
					try:
						shutil.copy(line3,dstdir)
					except:
						print "TMBS not found"
					try:
						shutil.copy(logcat,dstdir)
					except:
						print "logcat not found"
					# try:
						# shutil.copy(kmsg,dstdir)
					# except:
						# print "kmsg not found"
				else:
					print "Mismatch"
			
			else: 
			
				# print line3
				# print dstdir	
				logcat= fields[0]+"\\"+fields[1]+"\\"+fields[2]+"\\"+fields[3]+"\\"+fields[4]+"\\logcat.txt"
				
				filename=fields[max-2]
				print filename
				if (filename[0:4] == 'TMBS'):
					dstdir="C:\RAMDUMPS"+"\\"+"TMBS"+"\\"+fields[2]+"\\"+fields[3]+"\\"+str(count)+"_"+filename+"\\"
					if not os.path.exists(dstdir):
						os.makedirs(dstdir)
					f3 = open((dstdir+"Scenario.txt"), "a")
					f3.write(tc[getdata()]);
					f3.write("\n");
					f3.close()					

					print line3
					try:
						shutil.copy(line3,dstdir)
					except:
						print "TMBS not found"
					try:
						shutil.copy(logcat,dstdir)
					except:
						print "logcat not found"
					# try:
						# shutil.copy(kmsg,dstdir)
					# except:
						# print "kmsg not found"
				else:
					print "Mismatch"		
	
	print "\nTMBS Work Done....."	
else:

	print "\nNo TMBS data found"

# os.system("pause")	
count=0
if os.path.isfile(srcfile2):

	with open(srcfile2) as file4:
		for line4 in file4:
			count += 1
			line4=line4.strip()	
			fields = line4.split('\\')
			max=len(fields)
			print max
			if (max == 10):			
				print "remote Machine"
				# print line4
				# print dstdir	
				logcat= "\\\\"+fields[2]+"\\"+fields[3]+"\\"+fields[4]+"\\"+fields[5]+"\\"+fields[6]+"\\"+fields[7]+"\\logcat.txt"
				kmsg= "\\\\"+fields[2]+"\\"+fields[3]+"\\"+fields[4]+"\\"+fields[5]+"\\"+fields[6]+"\\kmsg.txt"
				
				filename=fields[max-2]				
				if (filename[0:3] == 'ANR'):
					dstdir="C:\RAMDUMPS"+"\\"+"ANR"+"\\"+fields[5]+"\\"+fields[6]+"\\"+str(count)+"_"+filename+"\\"
					if not os.path.exists(dstdir):
						os.makedirs(dstdir)
					f4 = open((dstdir+"Scenario.txt"), "a")
					f4.write(tc[getdata()]);
					f4.write("\n");
					f4.close()	
					print line4
					try:
						shutil.copy(line4,dstdir)
					except:
						print "ANR not found"
					try:
						shutil.copy(logcat,dstdir)
					except:
						print "logcat not found"
					try:
						shutil.copy(kmsg,dstdir)
					except:
						print "kmsg not found"
				else:
					print "Mismatch"					
			else: 
				# print line4
				# print dstdir	
				logcat= fields[0]+"\\"+fields[1]+"\\"+fields[2]+"\\"+fields[3]+"\\"+fields[4]+"\\logcat.txt"
				kmsg= fields[0]+"\\"+fields[1]+"\\"+fields[2]+"\\"+fields[3]+"\\kmsg.txt"
				
				filename=fields[max-2]
				
				if (filename[0:3] == 'ANR'):
					dstdir="C:\RAMDUMPS"+"\\"+"ANR"+"\\"+fields[2]+"\\"+fields[3]+"\\"+str(count)+"_"+filename+"\\"
					if not os.path.exists(dstdir):
						os.makedirs(dstdir)
					f4 = open((dstdir+"Scenario.txt"), "a")
					f4.write(tc[getdata()]);
					f4.write("\n");
					f4.close()	
					print line4
					try:
						shutil.copy(line4,dstdir)
					except:
						print "ANR not found"
					try:
						shutil.copy(logcat,dstdir)
					except:
						print "logcat not found"
					try:
						shutil.copy(kmsg,dstdir)
					except:
						print "kmsg not found"
				else:
					print "Mismatch"	

	print "\nANR Work Done....."	
else:
	print "\nNo ANR data found"		

			
os.system("pause")
