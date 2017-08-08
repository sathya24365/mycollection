import imp
try:
    imp.find_module('xlrd')
    print "true"
except ImportError:
    found = False
	
print found