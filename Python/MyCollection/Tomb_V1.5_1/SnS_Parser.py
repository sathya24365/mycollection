import os, time, sys
import shutil
import xlrd

def logcat_filter(dir):
	# print dir
	for dirname, dirnames, filenames in os.walk(dir):
		for filename in filenames:
			f = os.path.join(dirname,filename)	
			if (filename[0:6] == 'logcat'):
				if not os.path.isfile("LOGCAT_" + date_string + ".txt"):						
					f1 = open(("LOGCAT_" + date_string + ".txt"), "w+")
					f1.write(f);
					f1.write("\n");
					f1.close()
				else:							
					if f in open("LOGCAT_" + date_string + ".txt").read():
						# print "Duplicate" 
						pass
					else:	
						f1 = open(("LOGCAT_" + date_string + ".txt"), "a+")
						f1.write(f);
						f1.write("\n");
						f1.close()
			else:
				pass
				# print "error3"

def getdata():
	
	if fields[3] in hwid:
		for i in range(worksheet.nrows):
			if fields[3] == hwid[i]:
				return i
				break
	else:
		return 0		
			
while(1):

	path = raw_input("Enter path:: ")
	if (path==''):
		print "No input received"
	else:
		if not os.path.exists(path):
			print "Path does not exists....."
		else:
			break

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
			with open('signatures.txt', 'r') as file1:
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
			with open('signatures.txt', 'r') as file1:
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


if os.path.isfile(srcfile1):
	count=0
	with open(srcfile1) as file3:
		for line3 in file3:
			count += 1
			line3=line3.strip()
			fields = line3.split('\\')
			max=len(fields)
			sep = "\\";
			fld_count=0
			tmbs=[]
			while(fld_count<(max-1)):
				tmbs.append(fields[fld_count])
				fld_count = fld_count + 1						
			dir=sep.join(tmbs)
			print dir
			logcat_filter(dir);
			dstdir="C:\RAMDUMPS"+"\\"+"TMBS"+"\\"+date_string+"\\"+"\\"+"TMBS_"+str(count)+"\\"
			
			if not os.path.exists(dstdir):
				os.makedirs(dstdir)
			try:
				shutil.copy(line3,dstdir)
			except:
				print "TMBS not found"
				
			f3 = open((dstdir+"Scenario.txt"), "a")
			f3.write(tc[getdata()]);
			f3.write("\n");
			f3.close()	
			
			if os.path.isfile(("LOGCAT_" + date_string + ".txt")):
				with open(("LOGCAT_" + date_string + ".txt")) as file4:
					for line4 in file4:
						line4=line4.strip() 
						try:
							shutil.copy(line4,dstdir)
						except:
							print "logcat not found"		
	
	print "\nTMBS Work Done....."	
else:
	print "\nNo TMBS data found"
	
if os.path.isfile("TMBS_" + date_string + ".txt"):	
	os.remove("TMBS_" + date_string + ".txt")
	
if os.path.isfile(srcfile2):
	count=0
	with open(srcfile2) as file3:
		for line3 in file3:
			count += 1
			line3=line3.strip()
			fields = line3.split('\\')
			max=len(fields)
			sep = "\\";
			fld_count=0
			anr=[]
			while(fld_count<(max-1)):
				anr.append(fields[fld_count])
				fld_count = fld_count + 1						
			dir=sep.join(anr)
			print dir
			logcat_filter(dir);
			dstdir="C:\RAMDUMPS"+"\\"+"ANR"+"\\"+date_string+"\\"+"\\"+"ANR_"+str(count)+"\\"
			
			if not os.path.exists(dstdir):
				os.makedirs(dstdir)
			try:
				shutil.copy(line3,dstdir)
			except:
				print "ANR not found"
				
			f3 = open((dstdir+"Scenario.txt"), "a")
			f3.write(tc[getdata()]);
			f3.write("\n");
			f3.close()	
			
			if os.path.isfile(("LOGCAT_" + date_string + ".txt")):
				with open(("LOGCAT_" + date_string + ".txt")) as file4:
					for line4 in file4:
						line4=line4.strip() 
						try:
							shutil.copy(line4,dstdir)
						except:
							print "logcat not found"		
	
	print "\nANR Work Done....."	
else:
	print "\nNo ANR data found"
	
if os.path.isfile("ANR_" + date_string + ".txt"):	
	os.remove("ANR_" + date_string + ".txt")
	
if os.path.isfile("LOGCAT_" + date_string + ".txt"):	
	os.remove("LOGCAT_" + date_string + ".txt")	
	
os.system("pause")
