import os, time, sys, re, serial

port = '/dev/ttyUSB0'
baudrate = 115200

control = serial.Serial(port, baudrate)
print (control.name)

date_string = time.strftime("%Y-%m-%d-%H-%M-%S")

keyword_1 = "downloading"
keyword_2 = "downloaded"
keyword_3 = "verified"
keyword_4 = "applying"
keyword_5 = "complete"
keyword_6 = "CrashInfo"


# cmd_1 = "otaStartUpgrade http://ota.cleartheair.io/fw/Molekule-FWv9.4.29.150-Cv1.0-20210212_23_09_24.bin"
# cmd_1 = "otaStartUpgrade http://fw.prod-env.molekule.com/Molekule-FWv9.4.29.150-Cv1.0-20210212_23_09_24.bin"
cmd_1 = "otaStartUpgrade http://fw.prod-env.molekule.com/Molekule-FWv10.1.40.4-Cv1.40-20210323_13_43_42.ota.bin"
cmd_2 = 'version'
cmd_3 = "reboot"
# cmd_4 = "setlevel 8 4" #MMO
cmd_4 = "setlevel 9 4" #SEQ

cwd_1 = "cd .."
cwd_2 = "cd ota"

cwd = os.getcwd()

def minicom_log_monitor(keyword):
    #log = open('minicom_log')
    log = open('minicom_log', encoding = "ISO-8859-1")
    count = 0
    for line in log:
        line = line.rstrip()
        if re.search(keyword, line) :
            count +=1		
    return count
	
def minicom_log_stats():

	global total_downloading_events
	global total_downloaded_events
	global total_verified_events
	global total_applying_events
	global total_complete_events
	global total_FRR_events

	
	total_downloading_events=minicom_log_monitor(keyword_1)
	total_downloaded_events=minicom_log_monitor(keyword_2)
	total_verified_events=minicom_log_monitor(keyword_3)
	total_applying_events=minicom_log_monitor(keyword_4)
	total_complete_events=minicom_log_monitor(keyword_5)
	total_FRR_events=minicom_log_monitor(keyword_6)

	print ("*********************DUT STATS**************************")
	print ("total_downloading_events::%s" %total_downloading_events)
	print ("total_downloaded_events::%s" %total_downloaded_events)
	print ("total_verified_events::%s" %total_verified_events)
	print ("total_applying_events::%s" %total_applying_events)
	print ("total_complete_events::%s" %total_complete_events)
	print ("total_FRR_events::%s" %total_FRR_events)

	print ("\n")
	
def send_cmd1(cmd,delay): # not using
	
	os.chdir(path)
	os.system(cmd)
	print ("\n")
	os.chdir(cwd)
	time.sleep(delay)
    
    
def send_cmd(cmd):

    control.write (bytes("%s\n" %cmd, 'utf-8')) 
	
iteration=0
ota_complete=0
ota_fail=0

# control.write ("%s\n" %cmd_2) # Version
send_cmd (cmd_2)
time.sleep(2)
# control.write ("%s\n" %cmd_4) # Enable AWS logs
send_cmd (cmd_4)
time.sleep(2)

# os.system("sudo minicom -D /dev/ttyUSB0 -C minicom_log&")

while (1): #OTA Triggering 

    iteration +=1
    watchdog=0
    
    os.system("clear")
    print ("Appending minicom_log to minicom_log_main")
    os.system("cat minicom_log | tee -a minicom_log_main_%s" %date_string)   
    print ("Clearing minicom_log")    
    os.system(".>minicom_log")
    
    print ("Iteration::%s\n" %iteration)
    print ("ota_complete::%s\n" %ota_complete)
    print ("ota_fail::%s\n" %ota_fail)
    
    
    # control.write ("%s\n" %cwd_1) # cwd to root
    
    time.sleep(2)
    #control.write ("%s\n" %cwd_2) # cwd to ota
    send_cmd (cwd_2)
    time.sleep(2)
    
    print ("Triggering OTA") 
    #control.write ("%s\n" %cmd_1) # Trigger OTA
    send_cmd (cmd_1)
    time.sleep(2)
    

    while(1): #OTA status Monitoring  
        
        minicom_log_stats()		
        
        if ((total_downloading_events == 1 or total_downloaded_events ==1 or total_verified_events == 1 or total_applying_events == 1) and (total_complete_events==1 )): 
            #Breaks if OTA is successful
            ota_complete +=1	
            print ("DUT is successfully updated with 40.4:%s.....\n" %ota_complete)
            time.sleep(360)
            break
        else: 
            #Breaks if OTA / watchdog fails
            watchdog +=1
            print ("Monitoring DUT state.....\n")	
            print ("Watchdog is started::%s.....\n" %watchdog)	
            if (watchdog==90):
                ota_fail +=1	
                print ("Rebooting DUT.....\n")
                #control.write ("%s\n" %cmd_3)
                send_cmd (cmd_3)
                time.sleep(30)
                break
            else:	
                pass
        time.sleep(10)
    time.sleep(2)
