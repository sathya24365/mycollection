import os, time, sys
import shutil

now = time.time()
date_string = time.strftime("%Y-%m-%d-%H-%M-%S")

path = raw_input("Enter path:: ")
f = os.path.join(path,'logcat.txt')
print f

os.system("pause")
print "\nProcessing.....\n"
logcat=[]

# with open('input.txt', 'r') as file1:
	# for line1 in file1:
		# with open(f, 'r') as file2:
			# for line2 in file2:	
				# if line1 in line2:
					# if not os.path.isfile("Logcat_" + date_string + ".txt"):						
						# f1 = open(("Logcat_" + date_string + ".txt"), "a")
						# f1.write(line2);
						# f1.write("\n");
						# f1.close()
					# else:							
						# if line2 in open("Logcat_" + date_string + ".txt").read():
							# print "Duplicate" 
						# else:	
							# f1 = open(("Logcat_" + date_string + ".txt"), "a+")
							# f1.write(line2);
							# f1.write("\n");
							# f1.close()
							
with open('input.txt', 'r') as file1:
	for line1 in file1:
		with open(f, 'r') as file2:
			for line2 in file2:	
				if line1 in line2:
						logcat.append(line2)
						
					else:							
						if line2 in open("Logcat_" + date_string + ".txt").read():
							print "Duplicate" 
						else:	
							f1 = open(("Logcat_" + date_string + ".txt"), "a+")
							f1.write(line2);
							f1.write("\n");
							f1.close()

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
								

print "\n"
print "\nPhase-I completed"
os.system("pause")
