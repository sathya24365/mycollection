import os
import sys
ListFiles = []

def parseFile(rootdir):
    global ListFiles
    fileName = ''
    for root, subFolder, files in os.walk(rootdir):
        #print root
        path = root.split('/')
        #print (len(path) - 1) *'---' , os.path.basename(root)
        for file in files:
            if 'capella.log' in file:
                fileName = root+'\\'+file
                #print root+'\\'+file
                ListFiles.append(fileName)
            #print len(path)*'---', file
    '''for i in ListFiles:
        print i'''

    return  None
def Testfile(Test):
    #print len(Test)
    #print 'mergingfiles'
    DestFile = sys.argv[1]+'\\capella.log'
    with open(DestFile, 'w') as outfile:
        for fname in Test:
            with open(fname) as infile:
                for line in infile:
                    outfile.write(line)
    #print DestFile

parseFile(sys.argv[1])
Testfile(ListFiles)