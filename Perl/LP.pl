# ***********************************************************************************************************************
# **           Confidential and Proprietary – Qualcomm Technologies, Inc.
# **
# **           This technical data may be subject to U.S. and international export, re-export, or transfer
# **           ("export") laws. Diversion contrary to U.S. and international law is strictly prohibited.
# **
# **           Restricted Distribution: Not to be distributed to anyone who is not an employee of either
# **           Qualcomm or its subsidiaries without the express approval of Qualcomm’s Configuration
# **           Management.
# **
# **           © 2015 Qualcomm Technologies, Inc
# ************************************************************************************************************************
#~#	-------------------------------------------------------------------------------------------------
#	File Name	:	Logparser.pl
#	Authors		:	slanka/c_pnagur
#	Purpose		:	Collection of all the shared resources
#/#	-------------------------------------------------------------------------------------------------
use strict;
use warnings;
use POSIX;
use File::Find;
use File::Basename;
use autodie;
no warnings qw(once);


# Local variables
my $numArgs = $#ARGV ;
my $path;
my $appspath ="";
my $mainlog="";
my $systemlog="";
my $crashlog="";
my $kernellog="";
my $MonkeyConsolelog="";
my $dmesg="";
my $trace="";
my $tid;
my $i=0;
my $process=$$;
my $eventlog="";
my $bugreport="";
my $outfilename;
my $tkernel=0;
my $tMonkeyConsole=0;
my $tsystem=0;
my $tcrash=0;
my $tbugreport=0;
my $tuilog=0;
my $tevent = 0;
my $ttrace=0;
my @tdir;
my $chkm=0;#variable to chk for maninlog
my $chkk=0;#variable to chk for kernel log
my $chkd=0;#variable to chk for dmesg
my $chkb=0;#variable to chk for bugreport
my $chkt=0;#variable to chk for trace
my $ret=0;
my $target="";
my $vmlinux;
my $first_file_sizek;
my $first_file_sizeu;
my $first_file_sizee;
my $second_file_sizeu;
my $second_file_sizee;
my $first_file_name;
my $second_file_sizek;
my $second_file_name;
my $androidVersion;
my $targetcrash1; # variable for unicorn ramdump
my $outsnippet1;
my $targetcrash;
my $outmessage_monkeyevents;
my $targetcrash2; # variable for A-family ramdump EBI1
my $targetcrash3; # variable for A-family ramdump EBI2
my $targetcrash4; # variable for B-family ramdump DDR1
my $targetcrash5; # variable for B-family ramdump DDR2
my $targetcrash6; # variable for 8084 ramdump DDR2
my $targetcrash7; # variable for 8084 ramdump DDR2
my $outmessage;
my $outsnippet;
my $outmessage1;
my $sspidfirst;
my $sspidlast;
my $outmessage_forceclose;
my $outmessage_fatal;
our $outmessage_ENOSPC;

#my $ebi_7x27="\\\\lab577\\Dropbox\\ebi_extractor_frm_rak\\ebi_extractor_new.py";
sub Manuallydisconnect(){#function definition to check if the target got manually disconnected(it was defined on the top as we seeing a warning  "main::Manuallydisconnect() called too early to check prototype")
	my $lines;
	if ( -e "$path/AutoMonkeyStop_Result.txt") {
		open (PWD, "$path/AutoMonkeyStop_Result.txt")|| die "cannot open file";
		while (defined($lines = <PWD>)) {
			if($lines=~ m/Monkey is stopped by AutoMonkeyKiller BG/i){#chking for the kernel log in bugreport
				print OUT "Monkey is stopped by Max Duration AutoMonkeyKiller\n";
				print OUTS "Monkey is stopped by Max Duration AutoMonkeyKiller\n";
				goto finish4;
			}
		}
		close(PWD);
	}
}

checkArgs();#checking for the arguments and logs in the log location
if( -e $path){
$targetcrash1="$path\\ebi1_cs0.bin";#ebi bin file for 8x25 and 7x27 targets
$outsnippet1="$path\\chk.txt";
$targetcrash="$path\\EBICS0.BIN";#ebi bin file for 8960,8064 and 8660 targets
$targetcrash2="$path\\EBI1CS1.BIN";#ebi bin file for 8660 dmesg extraction
$targetcrash3="$path\\IMEM_C.BIN";
$targetcrash4="$path\\DDRCS0.BIN";#ebi bin file for B family dmesg extraction
$targetcrash5="$path\\DDRCS1.BIN";#ebi bin file for B family dmesg extraction
$targetcrash6="$path\\DDRCS0_0.BIN";#ebi bin file for 8084 dmesg extraction
$targetcrash7="$path\\DDRCS0_1.BIN";#ebi bin file for 8084 dmesg extraction
$outfilename="$path\\LOGPARSER_OUTPUT.txt";
$outmessage="$path\\ANR_CRASH.txt";
$outmessage1="$path\\NATIVE_CRASH.txt";
$outmessage_monkeyevents="$path\\MonkeyEvents_Results.txt";
$outsnippet="$path\\SNIPPET.txt";
$outmessage_forceclose="$path\\FORCE_CLOSE.txt";
$outmessage_fatal="$path\\FATAL_EXCEPTION.txt";
open(OUTS,">>$outsnippet")|| die "cannot open file";#file handler for SNIPPET.txt
open(OUT,">>$outfilename")|| die "cannot open file";#filehandler for LOGPARSER_OUTPUT.txt
open(S,">$outsnippet1") || die "cannot open file";
if( -e $path && -e $targetcrash || -e $targetcrash1 || -e $targetcrash4 || -e $targetcrash5 || -e $targetcrash6 || -e $targetcrash7 || $chkm eq 1){#checking if the logs are sufficient to parse
	print("
****************************************
*   Starting Log parser  *
****************************************
	\n");
	if( -e $targetcrash || -e $targetcrash1 || -e $targetcrash4 || -e $targetcrash5 || -e $targetcrash6 || -e $targetcrash7 ){#checking for panic's ,watchdog bark and bite in both dmseg and kernel
		if($chkd){
			print "Target got crashed!\n";
			print "checking for panic/watchdog bark or bite exist from the logs.....\n";
			Targetcrash();
			finish:
			print "checking for Native_crahes!\n";
			Nativecrash();#print number of Native crashes and Anr's
			Monkeyevents();
			print "checking for Lost RAM info\n";
			LostRAM($path);
			print "check $outfilename for more information \n";
		}
		else{
			my $chkv;
			$SIG{ALRM} = sub {
				print "Took more than 20 mins to extract RAM dump parser, Hence terminating Python Process for smoother execution \n\n";
				system("taskkill /F /IM python.exe");
				die;
			};
			eval{
				alarm(1200); #Takes 20 mins to extract RAM dump
				$chkv = Dmesg_extractor();#it will extract dmesg and chk for panic's in 7k and 8k targets
				alarm(0);
			};

			#my $chkv = Crashscope();
			if($chkv){
				Targetcrash_dmesg();#it will chk for the issue in extracted dmesg
				finish3:
				print "checking for Native_crahes!\n";
				Nativecrash();#print number of Native crashes and Anr's
				Monkeyevents();
				print "checking for Lost RAM info\n";
				LostRAM($path);
			}
			else{
			print "Dmesg is missing...pls run LPtool to extract Dmesg..trying to check for issues in kernel logs\n";
			print OUT "Phone in Download Mode,Target got freezed\n";
			print OUTS "Phone in Download Mode,Target got Freezed\n";
			Targetcrash_kernel();
			finish1:
			print "checking for Native_crahes!\n";
			Nativecrash();#print number of Native crashes and Anr's if it is a unknown reset happens
			Monkeyevents();
			print "checking for Lost RAM info\n";
			LostRAM($path);
			print "check $outfilename for more information \n";
			}
		}
	}
	elsif( -e "$path\\Uifreeze.txt")
	{
		print OUT "UI-Freeze Occured,Live debugging required";
		print OUTS "UI-Freeze Occured,Live debugging required";
		print "checking for Native Crashes \n";
		Nativecrash();
		Monkeyevents();
		print "checking for Lost RAM info\n";
		LostRAM($path);
	}
	elsif($chkm == 1){#to check for framework reboot scenario
		print "checking for the instances of framework disconnect..... \n";
		my $val=Frameworkdisconnect();#retuns a 1 if framework reboot happens,0 otherwise
		#print "val:$val\n";
		print "checking for Native Crashes \n";
		Nativecrash();
		Monkeyevents();
		print "checking for Lost RAM info\n";
		LostRAM($path);
		if($val){#returns 1 if lock exist to print thread information
			Printtrace();#print the thread information that caused the deadlock in SNIPPET.txt
			print "check $outfilename for more information \n";
		}
		else {
			my $temp=0;
			open (F, $outsnippet1) || die "cannot open file";
			while (defined(my $line = <F>)) {
				#print $line;
				if($line =~ m/Framework/){#chks from LOGPARSER_OUTPUT.txt if framework reboot happend otherwise it chk's for device reboot
					$temp=$temp+1;
				}
			}
			#print $temp;
			if($temp == 0){
				$ret=LMKkiller();#checks for LMK issue
				#print $ret;
				if($ret eq 0){
					# Uifreeze();
					Manuallydisconnect();#chks for manually disconnected
					UVLO();#check for UVLO reset
					Devicereboot();#chks for device reboot if it is not a manually disconnect
					SKIP5:
				}
			}
			finish4:
			close(F);
		}
	}
}
else{#exits if the required logs not present
	print "****No sufficient logs to parse!****\n";
	if( ! -e "$path\\Uifreeze.txt")
	{
		print OUT "Logs are not pulled properly \n";
		open(ANR,">>$outmessage")|| print "cannot open file";#filehandler for ANR
		print ANR "Logs are not pulled properly \n";
		close(ANR);
		open(NATIVE,">>$outmessage1")|| print "cannot open file";#filehandler for NATIVE
		print NATIVE "Logs are not pulled properly \n";
		close(NATIVE);
	}
	else
	{
		print OUT "Uifreeze Detected,device is available for live debuggging\n";
		open(ANR,">>$outmessage")|| print "cannot open file";#filehandler for ANR
		print ANR "Logs are not pulled properly \n";
		close(ANR);
		open(NATIVE,">>$outmessage1")|| print "cannot open file";#filehandler for NATIVE
		print NATIVE "Logs are not pulled properly \n";
		close(NATIVE);
	}
	print("
*********************************
*   Exiting Log parser  *
*********************************
	\n");
}
}
else {
print "****Logs path is invalid!****\n";
	print("
*********************************
*   Exiting Log parser  *
*********************************
	\n");
}
# close(S);
# unlink($outsnippet1);
# unlink("core1_regs.cmm");
# unlink("core0_regs.cmm");
# unlink("core0_secure.cmm");
# unlink("pagetable.txt");
# unlink("raw_stack_dumps.txt");
# unlink("launch_t32.bat");
# unlink("t32_startup_script.cmm");
# unlink("t32_config.t32");
# unlink("config.gz");
# unlink("regs_panic.cmm");
# unlink("sysmapout.txt");
# unlink("$path\\dmesg.txt");

sub checkArgs
{
	# Check number of arguments
	# print $numArgs;
	if ($numArgs ne 7)
	{
		DisplayHelp();
	}

	for (my $i=0; $i<$numArgs; $i++)
	{
		#chking for the folder
		if ("--target" eq (lc $ARGV[$i]) or "-t" eq (lc $ARGV[$i]))
		{
		$i++;
			# Check to make sure argument is not invalid
			if (!defined($ARGV[$i]))
			{
				DisplayHelp();
			}
			$target = $ARGV[$i];
		}
		elsif ("--vmlinux" eq (lc $ARGV[$i]) or "-v" eq (lc $ARGV[$i]))
		{
		$i++;
			# Check to make sure argument is not invalid
			if (!defined($ARGV[$i]) || $target eq "")
			{
				DisplayHelp();
			}
			$appspath = $ARGV[$i];
			$vmlinux = "$appspath\\vmlinux";
			if( -e $vmlinux ){
				print "vmlinux exist!\n";
			}
		}
		elsif ("--androidVersion" eq (lc $ARGV[$i]) or "-a" eq (lc $ARGV[$i]))
		{
		$i++;
			# Check to make sure argument is not invalid
			if (!defined($ARGV[$i]))
			{
				DisplayHelp();
			}
			$androidVersion = $ARGV[$i];
		}
		elsif ("--folder" eq (lc $ARGV[$i]) or "-f" eq (lc $ARGV[$i]))
		{
			$i++;
			# Check to make sure argument is not invalid
			if (!defined($ARGV[$i]) || $target eq "")
			{
				DisplayHelp();
			}
			$path = $ARGV[$i];
			# parseroutput();
			print "Log Location:$path \n";
			# unlink("$path\\LOGPARSER_OUTPUT.txt");
			# unlink("$path\\SNIPPET.txt");
			# unlink("$path\\ANR_NATIVE_CRASH.txt");
			if( -e $path){
			print "checking if the logs exist\n";
			find({ wanted => \&LogDetection }, $path);
			print "kernel log -> $kernellog  \n";
			print "Event log -> $eventlog \n";
			print "Main Log -> $mainlog  \n";
			print "Crash Log -> $crashlog  \n";
			print "System Log -> $systemlog  \n";
			print "Monkey Console -> $MonkeyConsolelog \n";
			}
			else{last;}
			# print "Kernel log is $kernellog\n";
			# LogDetection($path);
			# $mainlog = "$path\\UIlogs.txt";
			# $kernellog = "$path\\kernellogs.txt";
			$dmesg = "$path\\dmesg_TZ.txt";
			# $bugreport = "$path\\bugreport.txt";
			# $trace = "$path\\traces_SystemServer_WDT.txt";
			if (-e $mainlog){#chks if the required logs exist
			print "Uilog Exist! \n";
			$chkm=1;}
			else{
			print "UIlog missing \n";}
			if (-e $kernellog){
			print "kernellog Exist! \n";
			$chkk=1;}
			else{
			print "Kernellog missing ! \n";}
			if (-e $dmesg){
			print "Dmesg Exist! \n";
			$chkd=1;}
			elsif($target eq "8064" || $target eq "8084"){
			$dmesg = $path."\\CrashScope\\txtReports\\APQ".$target."\\Apps\\DMesg.txt";
			if (-e $dmesg){
			print "Dmesg Exist! \n";
			$chkd=1;
			}
			}
			else{
			$dmesg = $path."\\CrashScope\\txtReports\\MSM".$target."\\Apps\\DMesg.txt";
			if (-e $dmesg){
			print "Dmesg Exist! \n";
			$chkd=1;
			}
			}
			if ($chkd eq 0)
			{
			print "dmesg is missing!\n";
			}
			if (-e $bugreport){
			print "Bugreport Exist! \n";
			$chkb=1;}
			else{
			print "Bugreport missing !\n";}
			if (-e $trace){
			print "Trace Exist! \n";
			$chkt=1;
			}
			else{
			if($chkt){
			print "System-Server Trace Exist! \n";
			}
			else{
			print "system-server trace doesnt exist\n";
			}
			}
        #chk for logs if uilogs,kernel logs exist in the locat\nion

		}
	}
}

sub DisplayHelp
{
	printf "\nUsage: Logparser.pl\n
	[-t targetname] or [--target ]\t\t\t\t- target name (REQUIRED)\n[-f foldername] or [--folder ]\t\t\t\t- Folder location (REQUIRED)\n[-v vmlinux] or [--vmlinux ]\t\t\t\t- vmlinux location(REQUIRED)
	";
	exit(0);
}

sub Targetcrash{
	open (FH, $dmesg) || die "cannot open file";
	my @lines=<FH>;
	close(FH);
	my $count3=0;
	for(my $i=0;$i<=$#lines;$i++){
		if($lines[$i]=~ m/Kernel panic/){#chks for kernal panic
			#$count3=$count3+1;
			open (FH, $dmesg) || die "cannot open file";
			my @lines1=<FH>;
			close(FH);
			if($lines[$i] =~ m/Kernel panic - not syncing: subsys-restart: Resetting the SoC - (.*) crashed/){
				print "Kernel panic Detected-$1 crash \n";
				print OUT " Phone in Download Mode,kernel panic Detected - $1 crash!\n";
				print OUTS " kernel panic Detected - $1 crash!\n \n";
				print OUTS " Snippet: \n \n";
				print OUTS "$lines1[$i] \n $lines1[$i+1] \n $lines1[$i+2] \n $lines1[$i+3] \n $lines1[$i+4] \n $lines1[$i+5] \n $lines1[$i+6] \n $lines1[$i+7] \n $lines1[$i+8] \n $lines1[$i+9]";
				goto finish;#skips the results of the scenarios if the issue hits
				}
			else{
				for(my $j=0;$j<=$#lines;$j++){
					if($lines1[$j]=~ m/Unable to handle kernel NULL pointer dereference at virtual address/)
					{
						for(my $k=$j+1;$k <= $j+10;$k++)
						{
							if($lines1[$k]=~ m/PC is at (.*)/ && $lines1[$k]=~ m/PC is at (.*)/){
								$count3++;
								my $chk_add=$1;
								print "Target freezed:\tKernel panic Detected! \n";
								print OUT " Phone in Download Mode,kernel panic Detected at $chk_add \n";
								#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
								print OUTS " kernel panic Detected at $chk_add \n \n";
								print OUTS " Snippet: \n \n";
								print OUTS "$lines1[$j-3] \n $lines1[$j-2] \n $lines1[$j-1] \n $lines1[$j] \n $lines1[$j+1] \n $lines1[$j+2] \n $lines1[$j+3] \n $lines1[$j+4] \n $lines1[$j+5] \n $lines1[$j+6] \n $lines1[$j+7] \n $lines1[$j+8] \n $lines1[$j+9]";
								goto finish;#skips the results of the scenarios if the issue hits
							}
						}
					}
				}
				if($count3 eq 0){
					print "Target freezed:\tKernel panic Detected! \n";
					print OUT "Phone in Download Mode,kernel panic Detected\n";
					#print OUT "Target freezed:  kernel panic Detected \n \n";
					print OUTS " kernel panic Detected \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i-6] \n $lines[$i-5] \n $lines[$i-4] \n $lines[$i-3] \n $lines[$i-2] \n $lines[$i-1] \n $lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n";
					goto finish;
				}
			}
		}
		elsif($lines[$i]=~ m/Unexpected IOMMU page fault!/){
					if($lines[$i+1]=~ m/msm_iommu: name    = (\w+)/){
					print "Target freezed:\tiommu page fault occured in $1! \n";
					print OUT " Phone in Download Mode,iommu page fault occured in $1! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " iommu page fault occured in $1! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9]";
					goto finish;#skips the results of the scenarios if the issue hits
					}
					else{
					print "Target freezed:\tiommu page fault occured! \n";
					print OUT " Phone in Download Mode,iommu page fault occured ! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " iommu page fault occured! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9]";
					goto finish;#skips the results of the scenarios if the issue hits}
					}
				} # BUG: spinlock lockup on CPU#0, mm-qcamera-daem/4143
		elsif($lines[$i]=~ m/BUG: spinlock lockup on CPU(.*)/){
					print "BUG: spinlock lockup on CPU $1! \n";
					print OUT " BUG: spinlock lockup on CPU $1! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " BUG: spinlock lockup on CPU $1! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9] \n $lines[$i+10]";
					goto finish;#skips the results of the scenarios if the issue hits
				}
	}
	print "No Panic Detected! \n";
	#print "checking for Apps watchdog bark \n";
	for(my $i=0;$i<=$#lines;$i++){
		if($lines[$i]=~ m/Watchdog bark! Now/ || $lines[$i]=~ m/Core 0 PC:/){#chks for watchdog bark
			print "Target freezed:\tNS Apps watchdog bark Detected! \n\n";
			print OUT "Phone in Download Mode,NS Apps watchdog bark Detected!\n";
			#print OUT "Target freezed:  Apps watchdog bark Detected! \n";
			print OUTS " NS Apps watchdog bark Detected! \n";
			print OUTS " Snippet:\n \n";
				for(my $j=$i;$j<$i+40;$j++){
					print OUTS "$lines[$j]";
				}
			goto finish;#skips the results of the scenarios if the issue hits
		}
	}
	print "No Watchdog bark Detected,it might be unknown reset\n";
	if ($target eq '8960' || $target eq '8064'){
		print OUT "Phone in Download Mode,It might be a watchdog bite or unknown reset\n";
		#print OUT "It might be a watchdog bite or unknown reset \n \n";
		print OUTS " snippet: \n \n";
		my @chk_dmesg1=`tail -500 $dmesg`;
		for(my $i=0;$i<=$#chk_dmesg1;$i++){
		if($chk_dmesg1[$i]=~ m/<(\d)>/){
			my $check1=$1;
			#print $check;
			if($check1 le 4){
			print OUTS "$chk_dmesg1[$i]";
			}
		}
	}
}
	else{#to print target freezed for other targets.
		print OUT "Phone in Download Mode,Target got freezed\n";
		#print OUT "Target got freezed \n \n";
		print OUTS " snippet: \n \n";
		my @chk_dmesg1=`tail -500 $dmesg`;
		for(my $i=0;$i<=$#chk_dmesg1;$i++){
			if($chk_dmesg1[$i]=~ m/<(\d)>/){
				my $check1=$1;
				#print $check;
				if($check1 le 4){
					print OUTS "$chk_dmesg1[$i]";
				}
			}
		}
	}
}
sub Frameworkdisconnect{
	my $fwcount = 0;
	open (FH, $mainlog)|| die "cannot open file";
	print "checking for Framework reboot in uilogs\n";
	while (defined(my $lines = <FH>)) {
		if($lines=~ m/WATCHDOG KILLING/ || $lines=~ m/Excessive JNI/i ){#chks for watchdog/excessive jni issue exist
			print OUT " $lines";
			print OUTS " $lines ";
			goto SKIP;#to skip checking for frameworking disconnect in bugreport to trace verfication
		}
		elsif(($lines=~ m/: eof/i) && ($androidVersion =~ m/KK/i)){
				print OUTS "Framework disconnected";
				goto SKIP;
		}
		elsif($lines=~ m/: eof/i){
			$fwcount++;
			if($fwcount > 2){
				goto SKIP;
			}
		}
	}
	close(FH);
	if($tbugreport == 1){
		open (FH, $bugreport) || print "cannot open file";
		print "checking for Framework reboot in bugreport\n";
		while (defined(my $lines = <FH>)) {
			if($lines=~ m/WATCHDOG KILLING/ || $lines=~ m/Excessive JNI/i ||$lines=~ m/: eof/i){#chks for eof/watchdog/excessive jni issue exist
				system_serverpidCheck();
			}
		}
		close(FH);
	}
	my $count3 = 0;
	goto SKIP1;#to avoid printing  Target got Framework disconnected in case issue was not seen from both uilog and bugeport
	SKIP:
	print OUT " Framework disconnected \n\n ";
	print OUTS " Framework disconnected \n\n ";
	print S "Framework disconnected \n\n ";
	close(S);
	print "Target got Framework Reboot \n";
	SKIP1:
	if($chkt){#checking for deadlock cases in system-server trace
		open (FH, $trace)|| print "cannot open file";
		my @lines=<FH>;
		close(FH);
		my $count1=0;
		print "checking if any deadlock exist from system-server trace.....\n";
		for(my $i=0;$i<=$#lines;$i++){
			if($lines[$i]=~ m/waiting to lock/){
				$count1=$count1+1;
				if($count1 == 1){#to ignore multiple tid,to print the thread info of tid that exist in first match
					print OUTS "Trace Snippet:";
					print OUTS " $lines[$i] ";
						if($lines[$i]=~ m/tid=(\d+)/){#chking for the tid that caused the deadlock
							$tid=$1;
						}
					else{
						last;
						}
				}
				#print "Waiting for the resource held by tid:$tid\n";
				print OUT "Waiting for the resource held by tid:$tid\n";
				return 1;
			}
			elsif($lines[$i]=~ m/serverthread/){
			$count1=$count1+1;
				if($count1 == 1){#to ignore multiple tid,to print the thread info of tid that exist in first match
					print OUT "serverthread got stuck in a native method\n";
					print OUTS "Trace Snippet:";
					print OUTS " $lines[$i] $lines[$i+1] $lines[$i+2] $lines[$i+3] $lines[$i+4] $lines[$i+5] $lines[$i+6] $lines[$i+7] $lines[$i+8] $lines[$i+9] $lines[$i+10] $lines[$i+11]";}
				}
		}
		if($count1 eq 0){#to return 0 if trace exist and no lock exist in trace
			return 0;
		}
	}
	else {
		#print "Trace File Missing!\n";
		return 0;
	}
}

sub system_serverpidCheck{
	print "Entered Systemserver pid check\n";
	my $toplog = "$path\\SDCardLogs\\MISC\\top.log";
	if (-e $toplog){
		open (FH, $toplog) || print "cannot open file";
		while (my $line = <FH>) {
			if ($line =~ m/(\d+)\s.*(system_server)/i) {
				$sspidfirst = $1 ;
				goto TEST;
			}
		}
		TEST:
		while (my $line = <FH>) {
			if ($line =~ m/(\d+)\s.*(system_server)/i) {
			$sspidlast = $1 ;
			}
		}
		close(FH);
		if ($sspidlast > $sspidfirst){
			print "Last Pid is Greater than the First Pid of system_server\n";
			if($sspidlast > 3000){
				print "Last Pid of system_server is more than 3000 looks like it’s a FWR\n";
				goto SKIP;
			}
		}
		else{
			print "Looks like it’s not a FWR\n";
			goto SKIP1;
		}
	}
	else{
		print "Top log missing \n";
	}
}

sub Printtrace{
	open (FH, $trace) || die "cannot open file";
	my @lines=<FH>;
	close(FH);
	my $count2=0;
	#print "printing thread info\n";
	for(my $i=0;$i<=$#lines;$i++){
		if($lines[$i]=~ m/tid=$tid/ && $lines[$i] !~ m/waiting to lock/){
			$count2=$count2+1;
			if($count2 == 1){
				for(my $k=$i;$k<$i+22;$k++){
					print OUTS "$lines[$k]";
				}
			}
		}
	}
}

sub UVLO{
	if($chkb){
		open (FH, $bugreport) || die "cannot open file";
		my @lines=<FH>;
		close(FH);
		print "checking for UVLO reset! \n";
		for(my $i=0;$i<=$#lines;$i++){
			if($lines[$i]=~ m/UVLO/i)
			{
				print OUT "UVLO Reset Occured\n";
				print OUTS "$lines[$i]";
				goto SKIP5;#to skip printing below print case
			}
		}
		if ( -e "$path\\uvlo_tracker.txt")
		{
			print OUT "UVLO Reset Occured\n";
			print OUTS "UVLO Reset Occured";
			goto SKIP5;#to skip printing below print case
		}
	}
	else{
		if ( -e "$path\\uvlo_tracker.txt")
		{
			print OUT "UVLO Reset Occured\n";
			print OUTS "UVLO Reset Occured";
			goto SKIP5;#to skip printing below print case
		}
	}
}

#checing for Device Reboot
sub Devicereboot{
	if($chkb){
		open (FH, $bugreport) || die "cannot open file";
		my @lines=<FH>;
		close(FH);
		print "checking for device reboot! \n";
		for(my $i=0;$i<=$#lines;$i++){
			if($lines[$i]=~ m/KERNEL LOG/){#chking for the kernel log in bugreport
				if($lines[$i+2]=~m/(\d+).(\d+)/){#chking if kernel time stamp starts with <0.00000> to confirm device reboot
					#print $1;
					my $chk_val=$1;
					if($chk_val == 0){
						print OUT "Looks like a device reboot\n";
						print OUTS "Looks like a device reboot\n";
						goto SKIP5;#to skip printing below print case
					}
				}
			}
		}
        #prints when bugreport exist no device reboot exist in the bugreport kernel log
		print OUT "cannot identify the issue\n";
		print OUTS "cannot identify the issue\n";
	}
	else{
	print OUT "No Issue found from the logs...unable to check device reboot as bugreport is missing\n";
	print OUTS "No Issue found from the logs...unable to check device reboot as bugreport is missing\n";
	}
}
#printing native crashes
sub Nativecrash{
	if ($chkm eq 1){
	if($mainlog =~ m/\s+/g){
        $mainlog =~ s/\s+/\\ /g;
    }
	if($systemlog =~ m/\s+/g){
        $systemlog =~ s/\s+/\\ /g;
    }
	if($crashlog =~ m/\s+/g){
        $crashlog =~ s/\s+/\\ /g;
    }
	my %count;
	my $match=">>>";
	my $count_var=0;
	if($tcrash == 1)
	{
		open(FH1,"$crashlog")|| print "can't open file filename : $!\n";
		my $temp=0;#native crash count
		print "**************************************************************\n";
		print "Wait Generating Native crash count.............\n";
		print "**************************************************************\n";
		open(OUT1,">>$outmessage1") || die "cannot create $outfilename: $!";
		while (defined(my $line = <FH1>)) {
			if( $line =~ />>>(\D+)<<</i && $line !~ />{4}/ && $line !~ />>> enter/i && $line !~ />>> exit/i && $line !~ />>> UNKNOWN/i && $line !~ />>> RESTARTED/i && $line !~ />>> SUSPENDED/i && $line !~ />>> START/i && $line !~ />>> STOP/i){
			#print "$line \n";
				$temp=$temp+1;
				my @split_array= split($match,$line);
				my @split_array1= split(' ',$split_array[1]);
				$count{$split_array1[0]}++;
			}
		}
		if ($temp eq 0){
			print OUT1 "NO Native crashes found! \n";
		}
		else{
			foreach (keys %count) {
				print "Native Crashes in $_ = $count{$_} \n";
				print OUT1 "$_ = $count{$_} <br /> \n";
			}
			print OUT1 "Native crashes count :$temp\n";
		}
		close(OUT1);
	}
	elsif($tuilog ge 1)
	{
		open(FH1,"$mainlog")|| print "can't open file filename : $!\n";
		my $temp=0;#native crash count
		print "**************************************************************\n";
		print "Wait Generating Native crash count.............\n";
		print "**************************************************************\n";
		open(OUT1,">>$outmessage1") || print "cannot create $outfilename: $!";
		while (defined(my $line = <FH1>)) {
			if( $line =~ />>>(\D+)<<</i && $line !~ />{4}/ && $line !~ />>> enter/i && $line !~ />>> exit/i && $line !~ />>> UNKNOWN/i && $line !~ />>> RESTARTED/i && $line !~ />>> SUSPENDED/i && $line !~ />>> START/i && $line !~ />>> STOP/i){
			#print "$line \n";
				$temp=$temp+1;
				my @split_array= split($match,$line);
				my @split_array1= split(' ',$split_array[1]);
				$count{$split_array1[0]}++;
			}
		}
		if ($temp eq 0){
			print OUT1 "NO Native crashes found! \n";
		}
		else{
			foreach (keys %count) {
				print "Native Crashes in $_ = $count{$_} \n";
				print OUT1 "$_ = $count{$_} <br /> \n";
			}
			print OUT1 "Native crashes count :$temp\n";
		}
		close(OUT1);
	}
	else{
		open(OUT1,">>$outmessage1") || die "cannot create $outfilename: $!";
		print OUT1 "NO Native crashes found! \n";
		close(OUT1);
	}
	my %count1;
	my $temp1=0;#total ANR's count
	my $match1="ANR in";
	my $count_var1=0;
	open(FH2,"$systemlog")|| print "can't open file filename : $!\n";
	print "**************************************************************\n";
	print "Wait Generating ANR COUNT..................\n";
	print "**************************************************************\n";
	open(OUT2,">>$outmessage") || die "cannot create $outfilename: $!";
	while (defined(my $line1 = <FH2>)) {
		if( $line1 =~ /$match1/i){
			$temp1=$temp1+1;
			my @split_array2= split($match1,$line1);
			my @split_array3= split(' ',$split_array2[1]);
			$count1{$split_array3[0]}++;
		}
	}
	if ($temp1 eq 0){
		print OUT2 "No ANR'S found! \n";
		print "No ANR'S found! \n";
	}
	else{
		foreach (keys %count1) {
			print " ANR In $_ = $count1{$_} \n";
			print OUT2 "$_ = $count1{$_} <br /> \n";
		}
		print OUT2 "ANR's count :$temp1";
	}
	close(OUT2);
	my %count2;
	my $temp2=0;
	open(FH3,"$systemlog")|| print "can't open file filename : $!\n";
	print "**************************************************************\n";
	print "Wait Generating FORCE CLOSE COUNT..................\n";
	print "**************************************************************\n";
	open(OUT3,">>$outmessage_forceclose") || die "cannot create $outfilename: $!";
	my $match2 = "Force-killing crashed app";
	while (defined(my $line1 = <FH3>)) {
		if( $line1 =~ /Force-killing crashed app/i && $line1 !~ /Force-killing crashed app null/i ){
			$temp2=$temp2+1;
			my @split_array4= split($match2,$line1);
			my @split_array5= split(' ',$split_array4[1]);
			$count2{$split_array5[0]}++;
		}
	}
	if ($temp2 eq 0){
		print OUT3 "No Force Closes found! \n";
		print "No Force Closes found! \n";
	}
	else{
		foreach (keys %count2) {
			print " ForceClose In $_ = $count2{$_} \n";
			print OUT3 "$_ = $count2{$_} <br /> \n";
		}
		print OUT3 "ForceClose count :$temp2";
	}
	close(OUT3);
	my %count3;
	if($tcrash == 1)
	{
		open(FH4,"$crashlog")|| print "can't open file filename : $!\n";
		print "**************************************************************\n";
		print "Wait Generating FATAL EXCEPTIONS COUNT..................\n";
		print "**************************************************************\n";
		open(OUT3,">>$outmessage_fatal") || die "cannot create $outfilename: $!";
		my $tmp = 0;
		my $chk_value;
		my $chk_value1;
		my @split_array6;
		my $temp3=0;
		my $match3 = "E AndroidRuntime: Process:";
		while (defined(my $line1 = <FH4>)) {
			if( $line1 =~ /E AndroidRuntime: Process:/i ){
				$temp3=$temp3+1;
				my @split_array6= split($match3,$line1);
				my @split_array7= split(' ',$split_array6[1]);
				$count3{$split_array7[0]}++;
			}
		}
		if ($temp3 eq 0){
			print OUT3 "No Fatal Exceptions found! \n";
			print "No Fatal Exceptions found! \n";
		}
		else{
			foreach (keys %count3) {
				print " Fatal Exceptions In $_ = $count3{$_} \n";
				print OUT3 "$_ = $count3{$_} <br /> \n";
			}
			print OUT3 "Fatal Exceptions count :$temp3";
		}
		close(OUT3);
	}
	elsif($tuilog ge 1)
	{
		open(FH4,"$mainlog")|| print "can't open file filename : $!\n";
		print "**************************************************************\n";
		print "Wait Generating FATAL EXCEPTIONS COUNT..................\n";
		print "**************************************************************\n";
		open(OUT3,">>$outmessage_fatal") || die "cannot create $outfilename: $!";
		my $tmp = 0;
		my $chk_value;
		my $chk_value1;
		my @split_array6;
		my $temp3=0;
		my $match3 = "E AndroidRuntime: Process:";
		while (defined(my $line1 = <FH4>)) {
			if( $line1 =~ /E AndroidRuntime: Process:/i ){
				$temp3=$temp3+1;
				my @split_array6= split($match3,$line1);
				my @split_array7= split(' ',$split_array6[1]);
				$count3{$split_array7[0]}++;
			}
		}
		if ($temp3 eq 0){
			print OUT3 "No Fatal Exceptions found! \n";
			print "No Fatal Exceptions found! \n";
		}
		else{
			foreach (keys %count3) {
				print " Fatal Exceptions In $_ = $count3{$_} \n";
				print OUT3 "$_ = $count3{$_} <br /> \n";
			}
			print OUT3 "Fatal Exceptions count :$temp3";
		}
		close(OUT3);
	}
	else{
		open(OUT3,">>$outmessage1") || die "cannot create $outfilename: $!";
		print OUT3 "NO Fatal Exceptions found! \n";
		close(OUT3);
	}

	#####################################################################################################
	if($tuilog ge 1){
		open(FH5,"$mainlog")|| print "can't open file filename : $!\n";
		print "**************************************************************\n";
		print "Wait Checking for ENOSPC instances..................\n";
		print "**************************************************************\n";
		$outmessage_ENOSPC="$path\\ENOSPC.txt";
		open(OUT4,">>$outmessage_ENOSPC") || print "cannot create $outfilename: $!";
		my $temp4=0;
		my $match4 = "ENOSPC";

		while (defined(my $line1 = <FH5>)) {
			if( $line1 =~ /$match4/i){
				$temp4=$temp4+1;
			}
		}
		if ($temp4 eq 0){
			print "No ENOSPC instances found! \n";
		}
		else{
			print "ENOSPC instances found \n";
			print OUT4 "ENOSPC instances found";
		}
		close(OUT4);
	}
	#####################################################################################################
}
}

sub Monkeyevents
{
	my $failEvents = 0;
	my $eventcount = undef;
	my $failpercentage = undef;
	if( -e $MonkeyConsolelog)
	{
		open(MC,$MonkeyConsolelog) || die "cannot open file";
		while (defined(my $consollelines = <MC>)) {
			if($consollelines=~ m/Sending event \#(\d+)/i){#chking for the kernel log in bugreport
				$eventcount=$1;
			}
			elsif($consollelines=~ m/Injection Failed/i){
				$failEvents++;
			}
		}
		$failpercentage = ($failEvents/$eventcount)*100;
		$failpercentage = sprintf("%.2f", $failpercentage);
		open(OUTM,">$outmessage_monkeyevents") || print "cannot create $outmessage_monkeyevents: $!";
		print OUTM "Total Events Sent : $eventcount \n";
		print OUTM "Total Events Failed : $failEvents \n";
		print OUTM "Failure Percentage : $failpercentage %\n";
		close(OUTM);
		close(MC);
	}

}


sub LostRAM {
my $start_directory=shift;
#print "input -> $start_directory \n";
directory($start_directory,$start_directory);
	if ( $#tdir >= 0)
	{
		foreach my $g (@tdir) {
			#print "input -> $g \n";
			directory($g,$start_directory);
		}
	}
}

sub directory
{
	my $dir = shift;
	my $old_dir = shift;
	my $outmessaged = "$old_dir/LostRam.txt";
	my $temp=0;
	my $temp1=0;
	my $val;
	my $size;
	if ( -e $outmessaged){}
	else{
	#print "opening directory -> $dir\n";
	opendir(D, "$dir") || die "Can't opedir: $!\n";
	my @list = readdir(D);
	# print " @list \n";
	closedir(D);
	foreach my $f (@list)
	{
		if($f eq "." || $f eq ".."){}
		elsif ( -d $dir."/".$f )
		{
		#print "$dir has Directory -> $f\n";
		$tdir[$i]= "$dir\\$f";
		$i++;
		}
		elsif ( -f $dir."/".$f)
		{
			if ( $f =~ /dumpsys/i)
			{
				open(FH1,"$dir/$f")|| die "can't open file filename : $!\n";
				my $t=0;#native crash count
				open(OUT1,">>$outmessaged") || die "cannot create $outfilename: $!";
				while (defined(my $line = <FH1>))
				{
					if( $line =~ /Lost RAM: (\d+) kB/)
					{
							$t++;
							if($t eq "1"){
							$temp=$1;
							}
							else {
							$temp1=$1;
							}
					}
				}
				if( $temp gt 0 && $temp gt 0){
				$val=$temp1-$temp;
				print OUT1 "Lost RAM before Test : $temp KB<br/>\nLost RAM after test : $temp1 KB<br/>\nTotal Lost RAM : $val KB";
				last;
				print OUT1 "\n***************************************************************\n";
				close OUT1;}

			}
			elsif ($f =~ /meminfo/i)
			{
					open(FH1,"$dir/$f")|| die "can't open file filename : $!\n";
					my $t=0;#native crash count
					open(OUT1,">>$outmessaged") || die "cannot create $outfilename: $!";
					while (defined(my $line = <FH1>))
					{
						if( $line =~ /MemFree:(\s+)(\d+)/)
						{
								$t++;
								#print "search found\n";
								if($t eq "1"){
								$temp=$2;
								}
								else {
								$temp1=$2;
								}
						}
					}
					if( $temp gt 0 && $temp gt 0){
					$val=$temp-$temp1;
					print OUT1 "Free MEM before Test : $temp KB <br/>\nFree MEM after test : $temp1 KB<br/>\nTotal Lost MEM : $val KB";
					close OUT1;}

			}
		}
	}
	}
}

sub Targetcrash_kernel{#to chk for crash in kernel logs

	if($chkk){
		open (FH, $kernellog) || die "cannot open file";
		my @lines=<FH>;
		close(FH);
		for(my $i=0;$i<=$#lines;$i++){
			if($lines[$i]=~ m/Kernel panic/){
				print "Target freezed:\tKernel panic Detected! \n";
				print OUT "Phone in Download Mode,kernel panic Detected\n";
				#print OUT " Target freezed:  kernel panic Detected \n \n";
				print OUTS " kernel panic Detected \n \n";
				print OUTS " Snippet: \n \n";
				print OUTS "$lines[$i-6] \n $lines[$i-5] \n $lines[$i-4] \n $lines[$i-3] \n $lines[$i-2] \n $lines[$i-1] \n $lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n";
				goto finish1;
			}
			elsif($lines[$i]=~ m/Unexpected IOMMU page fault!/){
					if($lines[$i+1]=~ m/msm_iommu: name    = (\w+)/){
					print "Target freezed:\tiommu page fault occured in $1! \n";
					print OUT " Phone in Download Mode,iommu page fault occured in $1! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " iommu page fault occured in $1! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9]";
					goto finish1;#skips the results of the scenarios if the issue hits
					}
					else{
					print "Target freezed:\tiommu page fault occured! \n";
					print OUT " Phone in Download Mode,iommu page fault occured ! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " iommu page fault occured! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9]";
					goto finish1;#skips the results of the scenarios if the issue hits}
					}
				}
		}
	#print "No Panic Detected! \n";
print "checking for other issues in kernel logs \n";
	for(my $i=0;$i<=$#lines;$i++){
		if($lines[$i]=~ m/PC is at [a-z](\w+)/ && $lines[$i]=~ m/PC is at (\w+)/){
			my $match=$1;
			#print $match;
			print "Target freezed:\tkernel panic detected in $match \n\n";
			print OUT "Phone in Download Mode,kernel panic at $match\n";
			#print OUT " Target freezed:  kernel panic at $match \n";
			print OUTS " kernel panic in $match \n";
			print OUTS " Snippet:\n ";
			#for(my $j=$i;$j<$i+40;$j++){
				#print OUTS "$lines[$j]";
			#}
			goto finish1;
		}
	}
	print OUTS " Snippet:\n ";
	my @chk_kernel=`tail -500 $kernellog`;
	for(my $i=0;$i<=$#chk_kernel;$i++){
		if($chk_kernel[$i]=~ m/(\d)/){
			my $check=$1;
			#print $check;
			if($check le 4){
			print OUTS "$chk_kernel[$i]";
			}
		}
	}
	}
	else{
		print "Kernel log is missing \n";
	}
}

sub Tracecheck {
	my $chktr;
	my $counttrace=0;
	my $dir = $path;
	my $match_file = "trace";
	opendir (DIR,$dir);
	my @files = grep(/$match_file/, readdir (DIR));
	closedir (DIR);
	#foreach my $file(@files){
		#print "$file \n";
	#}
	my $count_files = $#files + 1 ;
	#$#files++; #count number of trace files in Logs dir
	print "Number of Trace files found : $count_files \n";
	#checking for deadlock cases in system-server trace

		print "***********************************************************************\n";
		print "Checking for system-server trace in trace files .......\n";
		print "***********************************************************************\n";
		foreach my $file_chk(@files){
			open (FH, "$dir\\$file_chk")|| die "cannot open file";
			my @lines=<FH>;
			close(FH);
			my $count6=0;
			#print "checking if any deadlock exist from system-server trace.....\n";
			for(my $i=0;$i<=$#lines;$i++){
				if($lines[$i]=~ m/waiting to lock/ && $count6 eq 0){
					#print " system_server trace file exist \n";
					$chktr="$dir\\$file_chk";
					$counttrace= $counttrace+1;
					$count6 = $count6+1;
					}
					}
					}
			if($counttrace ge 1){
				#print "system-server trace is $chktr";
				$trace=$chktr;
				return 1;
			}
			else{
				#print "No system-server trace is found\n";
				return 0;
			}
}

sub Dmesg_extractor{
	my $ramdumpParserPath = "python \\\\freeze\\l4linux\\users\\lauraa\\clean_utils\\linux-ramdump-parser-v2\\ramparse.py";
	my $ramdumpParserPath_8952 = "python \\\\freeze\\l4linux\\users\\mitchelh\\tools\\linux-ramdump-parser-v2\\ramparse.py";
	print "Extracting Dmesg for $target! \n";
	if($target eq '7x27'){

		my $ebi_7x27="..\\Python\\ebi_extractor_7x27.py";
		system("$ebi_7x27 -t 7x27 -e $targetcrash1 -l $vmlinux --print-dmesg > \"$path/dmesg.txt\" ");
		if( -e "$path\\dmesg.txt"){
		#print "checking for dmesg\n";
			$dmesg = "$path\\dmesg.txt";
			return 1;
		}
		else {
			return 0;
		}
	}
	elsif($target eq '8x25'){

		my $ebi_8x25="..\\Python\\ebi_extractor_8x25.py";
		system("$ebi_8x25 -t 8x25 -e $targetcrash1 -l $vmlinux --print-dmesg > \"$path/dmesg.txt\" ");
		if( -e "$path\\dmesg.txt"){
			$dmesg = "$path\\dmesg.txt";
			return 1;
		}
		else {
			return 0;
		}
	}
	elsif($target eq '8x60'){

		my $linuxparser1="..\\Executables\\linux-ramdump-parser_8660.exe";
		system("$linuxparser1 -es $targetcrash 0x40000000 -e $targetcrash2 0x60000000 -e $targetcrash3 0x2a05f000 -v $vmlinux  > $path\\dmesg.txt");
		if( -e "$path\\dmesg.txt"){
			$dmesg = "$path\\dmesg.txt";
			return 1;
		}
		else {
			return 0;
		}
	}
	elsif($target eq '8960' || $target eq '8064' || $target eq '8930'){

		# my $linuxparser="..\\Executables\\linux-ramdump-parser.exe";
		system("$ramdumpParserPath  --vmlinux $vmlinux --auto-dump $path  --everything -o $path");
		# system("$linuxparser -v $vmlinux -qcdump $path > $path\\dmesg.txt");
		return (checkDmesg_TZ());
	}
	elsif($target eq '8974' || $target =~ /8(\d|\D)26/ || $target eq '8084' || $target =~ /8(\d|\D)16/){

		# my $linuxparser="..\\Executables\\linux-ramdump-parser.exe";
		system("$ramdumpParserPath --vmlinux $vmlinux  --auto-dump $path  --dmesg --print-irqs --check-for-watchdog --check-for-panic --t32launcher --print-rtb --parse-debug-image  --parse-qdss -o $path ");
		# system("$linuxparser -v $vmlinux -qcdump $path > $path\\dmesg.txt");
		return (checkDmesg_TZ());
	}
	elsif($target =~ /8994/){

		# my $linuxparser="..\\Executables\\linux-ramdump-parser.exe";
		system("$ramdumpParserPath --vmlinux $vmlinux --ram-file $path\\DDRCS0_0.BIN 0x00000000 0x3FFFFFFF --ram-file $path\\DDRCS0_1.BIN 0x40000000 0x7FFFFFFF --ram-file $path\\DDRCS1_0.BIN 0x80000000 0xBFFFFFFF --ram-file $path\\DDRCS1_1.BIN 0xC0000000 0xF7FFFFFF --ram-file $path\\OCIMEM.BIN 0xFE800000 0xFE87FFFF --phys-offset 0x00000000 --64-bit --force-hardware 8994 --dmesg --print-irqs --print-workqueues --t32launcher --parse-debug-image --print-rtb --ddr-compare -o $path");
		# system("$linuxparser -v $vmlinux -qcdump $path > $path\\dmesg.txt");
		return (checkDmesg_TZ());
	}
	elsif($target =~ /8976/){

		system("$ramdumpParserPath_8952 --vmlinux $vmlinux  --ram-file $path\\DDRCS0.BIN 0x20000000 0x7FFFFFFF --ram-file $path\\DDRCS1.BIN 0x80000000 0xDFFFFFFF --ram-file $path\\OCIMEM.BIN 0x08600000 0x08603FFF --phys-offset 0x20000000 --force-hardware 8976 --64-bit --dmesg --print-irqs --print-workqueues --print-kconfig --print-tasks --check-for-watchdog --check-for-panic --t32launcher --parse-debug-image --qtf --print-rtb --ddr-compare --clock-dump --cpr-info --timer-list --print-runqueues -o $path");
		return (checkDmesg_TZ());
	}
	elsif($target =~ /8952/ || $target =~ /8939/){

		system("$ramdumpParserPath_8952 --vmlinux $vmlinux  --ram-file $path\\DDRCS0.BIN 0x80000000 0xBFFFFFFF --ram-file $path\\DDRCS1.BIN 0xC0000000 0xFFFFFFFF --ram-file $path\\OCIMEM.BIN 0x08600000 0x08603FFF --phys-offset 0x80000000 --force-hardware 8939 --64-bit --dmesg --print-irqs --print-workqueues --print-kconfig --print-tasks --check-for-watchdog --check-for-panic --t32launcher --parse-debug-image --qtf --print-rtb --ddr-compare --clock-dump --cpr-info --timer-list --print-runqueues -o $path");
		return (checkDmesg_TZ());
	}
	elsif($target =~ /8937/){

		system("$ramdumpParserPath_8952 --vmlinux $vmlinux  --ram-file $path\\DDRCS0.BIN 0x80000000 0xBFFFFFFF --ram-file $path\\DDRCS1.BIN 0x80000000 0xBFFFFFFF --ram-file $path\\DDRCS1.BIN 00xC0000000 0xFFFFFFFF  --ram-file $path\\OCIMEM.BIN 0x08600000 0x08603FFF --phys-offset 0x80000000 --force-hardware 8939 --dmesg --print-irqs --print-workqueues --print-kconfig --print-tasks --check-for-watchdog --check-for-panic --t32launcher --parse-debug-image --qtf --print-rtb --ddr-compare --clock-dump --cpr-info --timer-list --print-runqueues --print-tasks-timestamps -o $path");
		return (checkDmesg_TZ());
	}
	elsif($target =~ /8996/){
		system("$ramdumpParserPath_8952 --vmlinux $vmlinux --ram-file $path\\DDRCS0.BIN 0x80000000 0xDFFFFFFF --ram-file $path\\DDRCS1.BIN 0x20000000 0x7FFFFFFF --ram-file $path\\PIMEM.BIN 0x0B000000 0x0BFFFFFF --ram-file $path\\OCIMEM.BIN 0x06680000 0x066BFFFF --phys-offset 0x20000000 --64-bit --force-hardware 8996 --dmesg --print-irqs --print-workqueues --print-kconfig --print-tasks --t32launcher --parse-debug-image --print-rtb --ddr-compare --clock-dump --cpr-info --thermal-info --timer-list --check-rodata -o $path");
		return (checkDmesg_TZ());
	}
	elsif($target =~ /8(\d|\D)10/ || $target =~ /8(\d|\D)12/){
		print "Extracting Dmesg for $target! \n";
		# my $linuxparser="..\\Executables\\linux-ramdump-parser.exe";
		system("$ramdumpParserPath  --vmlinux $vmlinux  --auto-dump $path  --everything -o $path ");
		# system("$linuxparser -v $vmlinux -qcdump $path > $path\\dmesg.txt");
		return (checkDmesg_TZ());
	}
}

sub checkDmesg_TZ {
	if( -e "$path\\dmesg_TZ.txt"){
		$dmesg = "$path\\dmesg_TZ.txt";
		return 1;
	}
	else {
		return 0;
	}
}

sub Targetcrash_dmesg{
open (FH, $dmesg) || die "cannot open file";
	my @lines=<FH>;
	close(FH);
	my $count4=0;
	for(my $i=0;$i<=$#lines;$i++){
		if($lines[$i]=~ m/Kernel panic/){#chks for kernal panic
			open (FH, $dmesg) || die "cannot open file";
			my @lines1=<FH>;
			close(FH);
			if($lines[$i] =~ m/Kernel panic - not syncing: subsys-restart: Resetting the SoC - (.*) crashed/){
				print "Kernel panic Detected-$1 crash \n";
				print OUT " Phone in Download Mode,kernel panic Detected - $1 crash!\n";
				print OUTS " kernel panic Detected - $1 crash!\n \n";
				print OUTS " Snippet: \n \n";
				print OUTS "$lines1[$i] \n $lines1[$i+1] \n $lines1[$i+2] \n $lines1[$i+3] \n $lines1[$i+4] \n $lines1[$i+5] \n $lines1[$i+6] \n $lines1[$i+7] \n $lines1[$i+8] \n $lines1[$i+9]";
				goto finish3;#skips the results of the scenarios if the issue hits
				}
			#$count4=$count4+1;
			# open (FH, $dmesg) || die "cannot open file";
			# my @lines1=<FH>;
			# close(FH);
			else{
				for(my $j=0;$j<=$#lines;$j++){
					if($lines1[$j]=~ m/Unable to handle kernel NULL pointer dereference at virtual address/)
					{
						for(my $k=$j+1;$k <= $j+10;$k++)
						{
							if($lines1[$k]=~ m/PC is at (.*)/ && $lines1[$k]=~ m/PC is at (.*)/){
									$count4++;
									my $chk_add=$1;
									print "Target freezed:\tKernel panic Detected! \n";
									print OUT " Phone in Download Mode,kernel panic Detected at $chk_add \n";
									#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
									print OUTS " kernel panic Detected at $chk_add \n \n";
									print OUTS " Snippet: \n \n";
									print OUTS "$lines1[$j-3] \n $lines1[$j-2] \n $lines1[$j-1] \n $lines1[$j] \n $lines1[$j+1] \n $lines1[$j+2] \n $lines1[$j+3] \n $lines1[$j+4] \n $lines1[$j+5] \n $lines1[$j+6] \n $lines1[$j+7] \n $lines1[$j+8] \n $lines1[$j+9]";
									goto finish;#skips the results of the scenarios if the issue hits
							}
						}
					}
				}
				if($count4 eq 0){
					print "Target freezed:\tKernel panic Detected! \n";
					print OUT "Phone in Download Mode,kernel panic Detected!\n";
					#print OUT "Target freezed:  kernel panic Detected \n \n";
					print OUTS " kernel panic Detected \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i-6] \n $lines[$i-5] \n $lines[$i-4] \n $lines[$i-3] \n $lines[$i-2] \n $lines[$i-1] \n $lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n";
					goto finish3;
				}
			}
		}
		elsif($lines[$i]=~ m/Unexpected IOMMU page fault!/){
					if($lines[$i+1]=~ m/msm_iommu: name    = (\w+)/){
					print "Target freezed:\tiommu page fault occured in $1! \n";
					print OUT " Phone in Download Mode,iommu page fault occured in $1! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " iommu page fault occured in $1! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9]";
					goto finish3;#skips the results of the scenarios if the issue hits
					}
					else{
					print "Target freezed:\tiommu page fault occured! \n";
					print OUT " Phone in Download Mode,iommu page fault occured ! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " iommu page fault occured! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9]";
					goto finish3;#skips the results of the scenarios if the issue hits}
					}
				}
		elsif($lines[$i]=~ m/BUG: spinlock lockup on CPU(.*)/){
					print "BUG: spinlock lockup on CPU $1! \n";
					print OUT " BUG: spinlock lockup on CPU $1! \n";
					#print OUT " Target freezed: kernel panic Detected at $chk_add \n \n";
					print OUTS " BUG: spinlock lockup on CPU $1! \n \n";
					print OUTS " Snippet: \n \n";
					print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9] \n $lines[$i+10]";
					goto finish;#skips the results of the scenarios if the issue hits
				}
	}
	#print "No Panic Detected! \n";
	#print "checking for Apps watchdog bark \n";
	for(my $i=0;$i<=$#lines;$i++){
		if($lines[$i]=~ m/Watchdog bark! Now/ || $lines[$i]=~ m/Core 0 PC:/){#chks for watchdog bark
			print "Target freezed:\t NS Apps watchdog bark Detected! \n\n";
			print OUT "Phone in Download Mode,NS Apps watchdog bark Detected!\n";
			#print OUT "Target freezed:  Apps watchdog bark Detected! \n";
			print OUTS " NS Apps watchdog bark Detected! \n";
			print OUTS " Snippet:\n \n";
				for(my $j=$i;$j<$i+40;$j++){
					print OUTS "$lines[$j]";
				}
			goto finish3;#skips the results of the scenarios if the issue hits
		}
	}
	print "No Watchdog bark Detected,it might be unknown reset\n";
	if ($target eq '8960' || $target eq '8064'){
		print OUT "Phone in Download Mode,It might be a watchdog bite or unknown reset\n";
		#print OUT "It might be a watchdog bite or unknown reset \n \n";
		print OUTS " snippet: \n \n";
		my @chk_dmesg1=`tail -500 $dmesg`;
		for(my $i=0;$i<=$#chk_dmesg1;$i++){
			if($chk_dmesg1[$i]=~ m/<(\d)>/){
				my $check1=$1;
				#print $check;
					if($check1 le 4){
						print OUTS "$chk_dmesg1[$i]";
					}
			}
		}
	}
	else{#to print target freezed for other targets.
		print OUT "Phone in Download Mode,Target got freezed\n";
		#print OUT "Target got freezed \n \n";
		print OUTS " snippet: \n \n";
		my @chk_dmesg1=`tail -500 $dmesg`;
		for(my $i=0;$i<=$#chk_dmesg1;$i++){
			if($chk_dmesg1[$i]=~ m/<(\d)>/){
				my $check1=$1;
				#print $check;
				if($check1 le 4){
					print OUTS "$chk_dmesg1[$i]";
				}
			}
		}
	}
}

sub LMKkiller{
	if($chkk){
		print"checking for LMK killer issue..\n";
		open (FH, $kernellog) || die "cannot open file";
		my @lines=<FH>;
		close(FH);
		for(my $i=0;$i<=$#lines;$i++){
		    # print "$lines[$i]\n";
			if($lines[$i]=~ m/sigkill\sto\s(\d+).*monkey/ || $lines[$i]=~ m/Killing 'commands.monkey'/){#checking for the snippet in the kernel logs that has sigkill issued for monkey process
				print "Monkey stopped by LMK\n";
				print OUT "Monkey stopped by LMK\n";
				print OUTS "Monkey stopped by LMK\n";
				print OUTS " Snippet: \n \n";
				print OUTS "$lines[$i-6] \n $lines[$i-5] \n $lines[$i-4] \n $lines[$i-3] \n $lines[$i-2] \n $lines[$i-1] \n $lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n";
				return 1;
				goto finish4;
			}
			elsif($lines[$i]=~ m/dumpstate\:(\s)page(\s)allocation(\s)failure\:/i){#checking for the snippet in the kernel logs that has sigkill issued for monkey process
				print "Observing instances of Out of Memory!\n";
				print OUT "Observing instances of Out of Memory!\n";
				print OUTS " Observing instances of Out of Memory!\n";
				print OUTS " Snippet: \n \n";
				print OUTS "$lines[$i] \n $lines[$i+1] \n $lines[$i+2] \n $lines[$i+3] \n $lines[$i+4] \n $lines[$i+5] \n $lines[$i+6] \n $lines[$i+7] \n $lines[$i+8] \n $lines[$i+9] \n $lines[$i+10] \n";
				return 1;
				goto finish4;
			}
			else{
			 # return 0;
			}
		}
		return 0;
	}
	else{
		print "Kernel log is missing \n";
		return 0;
	}
}

sub LogDetection
{
    if ( -f and /\.txt$/ || /\.log$/ )
    {
        my $file = $_;
        open (my $rd_fh, "<", $file);
		LINE: while (<$rd_fh>)
		{
               if (/<(\d)>/ || /(\d+),(\d+),(\d+)/ || /(\d+) E/i && $file !~ /event/i && $file !~ /main/i && $file !~ /system/i)
				{
					if ($tkernel <= 2 && $file =~ /kernel/i)
					{
						$tkernel++;
						my $dir = $File::Find::name;
						if($tkernel == 1){
							$kernellog  = $dir;
							close $rd_fh;
                            last LINE;
						}
					}
                }
               if (/:Monkey: seed/i && $file !~ /event/i && $file !~ /main/i && $file !~ /system/i)
				{
					if ($tMonkeyConsole < 2 && $file =~ /MonkeyConsole/i)
					{
						$tMonkeyConsole++;
						my $dir = $File::Find::name;
						if($tMonkeyConsole == 1){
							$MonkeyConsolelog  = $dir;
							close $rd_fh;
                            last LINE;
						}
					}
                }
				elsif (m/beginning of events/i || m/I am_create_activity/i)
				{
					if ($tevent <= 2 && $file =~ /event/i || $file =~ /log.events/i )
					{

						$tevent++;
						my $dir = $File::Find::name;
						if($tevent == 1){
							$eventlog  = $dir;
							close $rd_fh;
                            last LINE;
						}
                    }
				}
				elsif (m/beginning of crash/i)
				{
					if ($tcrash <= 2 && $file =~ /log.crash/i)
					{
						$tcrash++;
						my $dir = $File::Find::name;
						if($tcrash == 1){
							$crashlog  = $dir;
							close $rd_fh;
                            last LINE;
						}
                    }
				}
				elsif (/(\d+) E/i)
				{
					if ($tuilog  <= 2 && $file =~ /uilog/i || $file =~ /log.main/i)
					{
						$tuilog ++;
						my $dir = $File::Find::name;
						if($tuilog == 1){
							$mainlog  = $dir;
							close $rd_fh;
                            last LINE;
						}
                    }
					elsif ($tsystem <= 2 && $file =~ /log.system/i)
					{
						$tsystem ++;
						my $dir = $File::Find::name;
						if($tsystem == 1){
							$systemlog  = $dir;
							close $rd_fh;
                            last LINE;
						}
                    }
				}
				elsif (/Cmd line: system_server/i)
				{
					if($ttrace == 0 && $file =~ /traces/i)
					{
						close $rd_fh;
						if($file eq "stdout_tee.txt"){last;}
						$trace = $File::Find::name;
						if(-e $trace){
							$ttrace=1;
							$chkt=1;
						}
						print"Trace->$trace\n";
                        last LINE;
					}
                }
				elsif (/dumpstate:\s(\d+)-(\d+)-(\d+)\s(\d+):(\d+):(\d+)/i)
				{
					if ($tbugreport < 1 && $file =~ /bugreport/i)
					{
						close $rd_fh;
						$bugreport = $File::Find::name;
						if(-e $bugreport){
							$tbugreport = 1;
						}
						print"BugReport->$bugreport\n";
						last LINE;
					}
                }
		}
	}
}

sub Uifreeze{
	my $uifreeze=0;
	open (FH, $mainlog)|| die "cannot open file";
	print "checking for Ui-freeze instances in uilogs\n";
	while (defined(my $lines = <FH>)) {
		if($lines=~ m/W InputManager: Input event injection from pid/i ){#chks for watchdog/excessive jni issue exist
			$uifreeze++;
			if($uifreeze ge 1000){
			print OUT "Observing instances of ui-freeze";
			print OUTS "Observing instances of ui-freeze";
			goto finish4;#to skip checking for frameworking disconnect in bugreport to trace verfication
			}
		}
	}
	close(FH);
}