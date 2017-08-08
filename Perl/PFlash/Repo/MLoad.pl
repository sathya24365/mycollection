use Cwd;
use File::Path; 
# use File::pushd;
# use Spreadsheet::ParseExcel;

our $hwid=$ARGV[0];
our $meta=$ARGV[1];
our $apps=$ARGV[2];
our $fw=$ARGV[3];
our $capella=$ARGV[4];
our $tools=$ARGV[5];
our $cwd=getcwd;

our @adblist;
our @fblist;
our @labm;
our @hwid;
our @meta;
our @apps;

if(!$hwid || !$meta)
{ 
	# cleanup();
	# ntf_message("Local Flashing Mode");
	# get_build();
	# fbmonitor();
	# launch();
	print "Not supported"

}else
{
	cleanup();
	ntf_message("Remote Flashing Mode");
	$meta = $meta."\\"."common"."\\"."build";
	# launch();
}

adbmonitor();
# addon();
capella();

print "\nPress enter to Exit....\n";
<STDIN>;
exit;

###############################################################


sub capella{
	ntf_message("Capella Loading");
	my $location_capella= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\QafastInstaller\\';
	my $location_capella_local= 'C:\Dropbox\Installation-bundle-5.0.0\\';
	chdir($location_capella_local) or die "cannot change: $!\n";
	my $capella_cmd = "java -jar Installation.jar -f ".$location_capella."deviceProfileMapping_$hwid.xml -install";
	print "\n$capella_cmd\n";
	system($capella_cmd);
	print"\n";
}


sub addon{
	my $location_addon= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\ADDON';
	my $location_jar= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660';

	my $location_ini= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\ADDON\\INI';
	my $location_postboot= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\ADDON\\Postboot';
	my $location_pdr= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\ADDON\\PDR';

	eval { system("adb -s $hwid wait-for-device"); }; 
	eval { system("adb -s $hwid wait-for-device root"); }; 
	eval { system("adb -s $hwid wait-for-device remount"); }; 
	eval { system("adb -s $hwid shell mount -o rw,remount /"); }; 
	eval { system("adb -s $hwid shell mount -o rw,remount /firmware"); }; 
	
	# mkpath "$location_ini\\$hwid";
	# eval { system("adb -s $hwid pull /system/etc/wifi/WCNSS_qcom_cfg.ini $location_ini\\$hwid\\WCNSS_qcom_cfg.ini"); };	
	# eval { system("$location_jar\\iniReplacer.jar $location_ini\\Param.txt $location_ini\\$hwid\\WCNSS_qcom_cfg.ini"); };
	# eval { system("adb -s $hwid push $location_ini\\$hwid\\WCNSS_qcom_cfg.ini /system/etc/wifi/WCNSS_qcom_cfg.ini"); };
	
	if($tools eq 'GEN')
	{	
		ntf_message("SDM660 Generic AddOn Loading");
		eval { system("adb -s $hwid pull /system/etc/wifi/WCNSS_qcom_cfg.ini $location_ini\\WCNSS_qcom_cfg_$hwid.ini"); };	
		eval { system("$location_jar\\iniReplacer.jar $location_ini\\Param_gen.txt $location_ini\\WCNSS_qcom_cfg_$hwid.ini"); };
		eval { system("adb -s $hwid push $location_ini\\WCNSS_qcom_cfg_$hwid.ini /system/etc/wifi/WCNSS_qcom_cfg.ini"); };
		
		eval { system("adb -s $hwid pull /system/etc/init.qcom.post_boot.sh $location_postboot\\init.qcom.post_boot_$hwid.sh"); };
		eval { system("copy /b $location_postboot\\init.qcom.post_boot_$hwid.sh+$location_postboot\\Param_gen.txt $location_postboot\\init.qcom.post_boot_$hwid.sh"); };
		eval { system("adb -s $hwid push $location_postboot\\init.qcom.post_boot_$hwid.sh /system/etc/init.qcom.post_boot.sh"); };
	}
	elsif($tools eq 'PDR' || $tools eq 'SSR')
	{
		ntf_message("SDM660 PDR AddOn Loading");
		eval { system("adb -s $hwid pull /system/etc/wifi/WCNSS_qcom_cfg.ini $location_ini\\WCNSS_qcom_cfg_$hwid.ini"); };	
		eval { system("$location_jar\\iniReplacer.jar $location_ini\\Param_pdr.txt $location_ini\\WCNSS_qcom_cfg_$hwid.ini"); };
		eval { system("adb -s $hwid push $location_ini\\WCNSS_qcom_cfg_$hwid.ini /system/etc/wifi/WCNSS_qcom_cfg.ini"); };
		
		eval { system("adb -s $hwid pull /system/etc/init.qcom.post_boot.sh $location_postboot\\init.qcom.post_boot_$hwid.sh"); };
		eval { system("copy /b $location_postboot\\init.qcom.post_boot_$hwid.sh+$location_postboot\\Param_pdr.txt $location_postboot\\init.qcom.post_boot_$hwid.sh"); };
		eval { system("adb -s $hwid push $location_postboot\\init.qcom.post_boot_$hwid.sh /system/etc/init.qcom.post_boot.sh"); };
		
		eval { system("adb -s $hwid push $location_pdr\\modemr.jsn /firmware/image/"); };
	}
	
	eval { system("adb -s $hwid push $location_addon\\Tools/. /system/bin"); };
	eval { system("adb -s $hwid push $location_addon\\BT/. /etc/bluetooth/"); };
	eval { system("adb -s $hwid push $location_addon\\GTools/gscan_start_params.txt /etc/wifi"); };
	
	
	eval { system("adb -s $hwid shell busybox dos2unix -u /system/etc/init.qcom.post_boot.sh"); };
	eval { system("adb -s $hwid shell sync"); };
	eval { system("adb -s $hwid shell chmod 777 /system/etc/*"); };
}

sub launch{

	fbmonitor();
	my $pmessage="FLASHING SUCCESSFUL!";
	chomp $pmessage;
	# my @out="FLASHING SUCCESSFUL!";
	my @out;
	
	if($meta && $apps eq 'NA'){ 
		ntf_message("Flashing Self Contained Meta");
		my $cmd=$meta."\\fastboot_complete.py --sn=$hwid";		
		@out=qx($cmd);		
		open(my $fh, '>', "report_$hwid.txt");
		print $fh @out;
		close $fh;
	}
	elsif($meta && $apps ne 'NA'){ 
		ntf_message("Flashing Meta with Custom Apps");
		my $cmd=$meta."\\fastboot_complete.py --ap=$app --sn=$hwid";
		@out=qx($cmd);		
		open(my $fh, '>', "$cwd\report_$hwid.txt");
		print $fh @out;
		close $fh;
	}	
	
	if ( grep( /^$pmessage$/, @out ) ) {
	
		my $location_qcn= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\QCN';
		ntf_message("Loading QCN Image");
		system("fastboot -s $hwid erase modemst1");
		system("fastboot -s $hwid erase modemst2");
		system("fastboot -s $hwid erase fsg");
		system("fastboot -s $hwid flash fsg $location_qcn\\fs_image.tar.gz.mbn.img");
		ntf_message("Flashing has been completed");
		system("fastboot -s $hwid reboot");
	} else{ 
		ntf_message("Flashing has been failed");
		exit;
	}
	if($fw ne 'NA'){ 
		adbmonitor();
		my $location_fw= '\\\\hope\\SNS-ODC-TESTING\\1-Reference\\1-All_in_One\\SDM660\\FW';
		ntf_message("Loading Custom FW");
		eval { system("adb -s $hwid wait-for-device"); }; 
		eval { system("adb -s $hwid wait-for-device root"); }; 
		eval { system("adb -s $hwid wait-for-device remount"); }; 
		eval { system("adb -s $hwid shell mount -o rw,remount /"); }; 
		eval { system("adb -s $hwid shell mount -o rw,remount /firmware"); }; 
		
		eval { system("adb -s $hwid push $location_fw\\wlanmdsp.mbn /firmware/image"); };
		eval { system("adb -s $hwid shell sync"); };
		eval { system("adb -s $hwid reboot"); };
	}	
	undef @out;
}

sub adbmonitor{	

	my $counter = 0;
	while(1){
		get_hwdata();
		$counter++;
		if ( grep( /^$hwid$/, @adblist ) ) {
			print "\n$hwid is in adb mode";
			sleep 10;
			undef @adblist;
			last;
		}
		elsif ( grep( /^$hwid$/, @fblist ) ) {
			print "\n$hwid is in FB mode";
			# system("fastboot -s $hwid reboot");
			undef @fblist;
		}
		else
		{
			if($counter <= 30){
				print "\n$hwid ISN'T FOUND_$counter";	
				sleep 10;				
			}
			else
			{
				print "\n$hwid Flashing aborted....... ";
				exit;
			}
		}
	}
}


sub fbmonitor{	

my $counter = 0;
	while(1){
		get_hwdata();
		$counter++;
		if ( grep( /^$hwid$/, @adblist ) ) {
			print "\nSending device:$hwid to FB mode";
			my $FB_cmd = "adb -s $hwid reboot bootloader";
			system("$FB_cmd");
			sleep 5;
			undef @adblist;
		}
		elsif ( grep( /^$hwid$/, @fblist ) ) {
			print "\n$hwid is in FB mode";
			last;
		}
		else
		{
			if($counter <= 30){
				print "\n$hwid ISN'T FOUND_$counter";	
				sleep 10;				
			}
			else
			{
				print "\n$hwid Flashing aborted....... ";
				exit;
			}
		}
	}
}


sub get_hwdata{

	my @data = `adb devices`;
	foreach (@data)
	{
		my $adbid = $_;
		if ($adbid =~ m/(\S+)\s+device$/)
		{
			$adbid =~ m/(\S+)\s+device/;
			push(@adblist, $1);
		}
	}
	undef @data;
	
	my @data = `fastboot devices`;
	foreach (@data)
	{
		my $fbid = $_;
		if ($fbid =~ m/(\S+)\s+fastboot$/)
		{
			push(@fblist, $1);
		}
	}
	undef @data;
}

sub ntf_message{
	print "\n*****************************************************************";
	print"\n@_";
	print "\n*****************************************************************\n";
}

sub err_message{
	print"\nERROR::@_";
}

sub gen_message{
	print"\nMESSAGE::@_";
}


sub get_build
{	
	open F, "$cwd\\Build.txt" or die "cannot open Build.txt\n";
	my @data = <F>;

	for (my $i=0; $i<@data; $i++)
	{
	   chomp $data[$i];
	   next if ($data[$i] =~ /^\s*$/); 
	   push (@build,split(',', $data[$i]));
	}	  
	close F; 	
	undef @data;

	my @metaid = split(/\\/,$build[0]) ;
	$meta = $build[0]."\\"."common"."\\"."build"."\\";
	$apps = $build[1];
	
	print"\nMetaid: $metaid[5]";
	if($meta && $apps){ 
			print"\nMeta: $meta";	
			print"\nApps: $apps";
	}
	elsif($meta && !$apps){ 
			print"\nMeta: $meta";	
			print"\nApps: NA";
	}	
}

sub cleanup{
	system('TASKKILL /F /IM  Quadro.exe /T');
	system('TASKKILL /F /IM  adb.exe /T');
	# system('TASKKILL /F /IM  cmd.exe /T');
	# system('TASKKILL /F /IM  perl.exe /T');
	system('TASKKILL /F /IM  python.exe /T');
	system('TASKKILL /F /IM  QPSTServer.exe /T');
	system('TASKKILL /F /IM  QPSTConfig.exe /T');
	system('TASKKILL /F /IM  MemoryDebugApp.exe /T');
	system('TASKKILL /F /IM  AtmnServer.exe /T');
}


