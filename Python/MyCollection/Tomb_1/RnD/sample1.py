import os, time, sys

"""
file1 = open('data.txt', 'r')
# FO = open('data3.txt', 'w')

for line1 in file1:
	# print "loop1", line1
	file2 = open('tombstone_00', 'r')
	for line2 in file2:		
		# print "loop2", line2

		if line1 == line2:
			# FO.write("%s\n" %(line1))
			print line2
			print "Found"
	file2.close()
	# os.system("pause")


# FO.close()
file1.close()
"""


with open('input.txt', 'r') as file1:
    with open('traces.txt', 'r') as file2:
        same = set(file1).intersection(file2)

# same.discard('\n')

print same

# with open('some_output_file.txt', 'w') as file_out:
    # for line in same:
        # file_out.write(line)
		
		
