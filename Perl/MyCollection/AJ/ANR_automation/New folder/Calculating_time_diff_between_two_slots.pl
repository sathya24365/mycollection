
my $time1 ="05:44:47";
my $time2 ="10:28:24";
$hours1=substr($time1,0,2);
$hours2=substr($time2,0,2);
#coverting hours to seconds

$h2s1=$hours1*60*60;
$h2s2=$hours2*60*60;
$min1=substr($time1,3,2);
$min2=substr($time2,3,2);
#coverting minutes to seconds
$m2s1=$min1*60;
$m2s2=$min2*60;

$sec1=substr($time1,6,2);
$sec2=substr($time2,6,2);
$sec=$sec2-$sec1;

$t1= $h2s1+$m2s1+$sec1;
$t2= $h2s2+$m2s2+$sec2;
$t=$t2-$t1;


#converting result into time format

$s1=$t%60;
$m1=($t/60)%60;
$h1=($t/(60*60))%60;

print "Time difference is $h1 HH $m1 MM $s1 SS ";
#print "$m1 minits \n";
#print "$sec \n";
#print" $h1:$m1:$sec\n";

