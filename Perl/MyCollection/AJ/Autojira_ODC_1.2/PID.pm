package PID;

sub Status{

    my $pid = shift;
	# print "Process ID is $pid\n" ;
	my $k=system("tasklist | grep $pid");
	
	# print "Process ID is $k\n" ;
    return 0 if $k==256;
    return 1 if $k==0;
}

1;