use File::Find;
find(\&dir_names, "\\\\hope\\SNS-ODC-TESTING\\traces_logs");
sub dir_names {
 print "$File::Find::dir\n" if(-f $File::Find::dir,'/');
}