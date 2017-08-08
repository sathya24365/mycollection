package Data::Lazy;
use vars qw($VERSION);
$VERSION='0.5';

require Tie::Scalar;
require Exporter;
@ISA=qw(Exporter Tie::Scalar);

@EXPORT = qw(LAZY_STOREVALUE LAZY_STORECODE LAZY_READONLY);

sub LAZY_STOREVALUE () {0}
sub LAZY_STORECODE  () {1}
sub LAZY_READONLY   () {2}

use Carp;
use strict;

sub TIESCALAR {
  my $pack = shift;
  my $self = {};
  $self->{code} = shift;
  $self->{'store'} = $_[0] if $_[0];
  $self->{'type'} = 0;
  bless $self => $pack;		# That's it?  Yup!
}

sub TIEARRAY {
  my $pack = shift;
  my $self = {};
  $self->{code} = shift;
  $self->{'store'} = $_[0] if $_[0];
  $self->{'type'} = 1;
  $self->{'size'} = 1;
  bless $self => $pack;		# That's it?  Yup!
}

sub TIEHASH {
  my $pack = shift;
  my $self = {};
  $self->{code} = shift;
  $self->{'store'} = $_[0] if $_[0];
  $self->{'type'} = 2;
  ${$self->{'value'}}{$;} = $self->{code};
  bless $self => $pack;		# That's it?  Yup!
}

sub FETCH {

  my $self = shift;
  if ($self->{'type'} == 0) {
   return $self->{value} if exists $self->{value};
   if (ref $self->{code} eq 'CODE') {
         $self->{value} = &{$self->{code}};
   } else {
         $self->{value} = eval $self->{code};
   }
   $self->{value};
  } elsif ($self->{'type'} == 1) {
   if ($_[0] < 0) {
    $_[0] %= $self->{'size'}
   } elsif ($_[0] - $self->{'size'} >= 0) {
    $self->{'size'} = $_[0]+1;
   }
   return ${$self->{'value'}}[$_[0]] if defined ${$self->{'value'}}[$_[0]];
   if (ref $self->{code} eq 'CODE') {
         ${$self->{'value'}}[$_[0]] = &{$self->{code}};
   } else {
         ${$self->{'value'}}[$_[0]] = eval $self->{code};
   }
   ${$self->{'value'}}[$_[0]];
  } else {
   return ${$self->{'value'}}{$_[0]} if defined ${$self->{'value'}}{$_[0]};
   if (ref $self->{code} eq 'CODE') {
         ${$self->{'value'}}{$_[0]} = &{$self->{code}};
   } else {
         ${$self->{'value'}}{$_[0]} = eval $self->{code};
   }
   ${$self->{'value'}}{$_[0]};
  }
}

sub STORE {
    
  my $self = shift;
  if ($self->{'type'} == 0) {
   if ($self->{'store'}) {

      delete $self->{value};
      if (defined $_[0]) {
       if ($self->{'store'} == LAZY_READONLY) {
        croak "Modification of a read-only value attempted";
       } else {
        $self->{code} = $_[0];
       }
      }
    } else {
      $self->{value} = $_[0];
    }
  } elsif ($self->{'type'} == 1) {
    ${$self->{'value'}}[$_[0]] = $_[1];
  } else {
    if ($_[0] eq $;) {
     %{$self->{'value'}} = ();
     $self->{'code'} = $_[1];
     ${$self->{'value'}}{$;} = $self->{code};
    } else {
     ${$self->{'value'}}{$_[0]} = $_[1];
    }
  }
}

sub EXISTS {1}

sub DELETE {undef}

sub CLEAR {%{$_[0]->{'value'}} = ()}

sub FIRSTKEY {
    my ($key,$val) = each %{$_[0]->{'value'}};
    ($key,$val) = each %{$_[0]->{'value'}}if ($key eq $;);
    $key
}
sub NEXTKEY {
    my ($key,$val) = each %{$_[0]->{'value'}};
    ($key,$val) = each %{$_[0]->{'value'}}if ($key eq $;);
    $key
}

no strict 'refs';
sub import {
  my $caller_pack = caller;
  my $my_pack = shift;
#  print STDERR "exporter args: (@_); caller pack: $caller_pack\n";
#  if (@_ % 2) {
#    croak "Argument list in `use $my_pack' must be list of pairs; aborting";
#  }
  while (@_) {
    my $varname = shift;
    my $function = shift;
    my $store = (($_[0] =~ /^[012]$/) ? shift : ($function ? LAZY_STOREVALUE : LAZY_STORECODE));

    if ($varname =~ /^\%(.*)$/) {  #<???>
     my %fakehash;
     tie %fakehash, $my_pack, $function, $store;          #<???>
     *{$caller_pack . '::' . $1} = \%fakehash;
    } elsif ($varname =~ /^\@(.*)$/) {  #<???>
     my @fakearray;
     tie @fakearray, $my_pack, $function, $store;          #<???>
     *{$caller_pack . '::' . $1} = \@fakearray;
    } else {
     $varname =~ s/^\$//;
     my $fakescalar;
     tie $fakescalar, $my_pack, $function, $store;          #<???>
     *{$caller_pack . '::' . $varname} = \$fakescalar;
    }
  }
 @_ = ($my_pack);
 goto &Exporter::import;
}
use strict 'refs';

1;

=head1 NAME

Data::Lazy.pm - "lazy" variables.

version 0.5

(rem: Obsoletes Lazy.pm)

=head1 SYNOPSIS

  use Data::Lazy variablename => 'code', LAZY_READONLY ;
  use Data::Lazy variablename => \&fun;
  use Data::Lazy '@variablename' => \&fun;

=head1 DESCRIPTION

A very little module for simulating lazines in perl.
It provides scalars that are "lazy", that is their value is
computed only if necessary and at most once.

=head2 Scalars

  tie $variable_often_unnecessary, Data::Lazy,
    sub {a function taking a long time} [, $store_options];

  tie $var, Data::Lazy, 'a string containing some code' [, $store_options];

  use Data::Lazy variablename => 'code' [, $store_options];

  use Data::Lazy '$variablename' => \&function [, $store_options];

The first time you access the variable, the code gets executed
and the result is saved for later as well as returned to you.
Next accesses will use this value without executing anything.

You may specify what will happen if you try to reset the variable.
You may either change the value or the code.

 1.
    tie $var, Data::Lazy, 'sleep 1; 1';
    # or tie $var, Data::Lazy, 'sleep 1; 1', LAZY_STOREVALUE;
    $var = 'sleep 2; 2';
    print "'$var'\n";

 will return

    'sleep 2; 2'


 2.
    tie $var, Data::Lazy, 'sleep 1; 1', LAZY_STORECODE;

 will return

    '2'

after 2 seconds of waiting.

 3.
    tie $var, Data::Lazy, 'sleep 1; 1', LAZY_READONLY;
    $var = 'sleep 2; 2';
    print "'$var'\n";

 Will give you an error message :
   Modification of a read-only value attempted at ...

If you tie the variable with LAZY_STORECODE option and then
undef the variable, only the stored value is forgoten and
next time you access this variable, the code is reevaluated.

It's possible to create several variables in one "use Data::Lazy ..." statement.

=head2 Array

 Eg.

  tie @variable, Data::Lazy, sub {a function taking a long time};

  tie @var, Data::Lazy, 'a string containing some code';

  use Data::Lazy '@variablename' => \&function;

The first time you access some item of the list, the code gets executed
with $_[0] being the index and the result is saved for later as well as
returned to you. Next accesses will use this value without executing
anything.

You may change the values in the array, but there is no way (currently)
to change the code :-(

 Ex.
    tie @var, Data::Lazy, sub {$_[0]*1.5+15};
    print ">$var[1]<\n";
    $var[2]=1;
    print ">$var[2]<\n";

    tie @fib, Data::Lazy, sub {
        if ($_[0] < 0) {0}
        elsif ($_[0] == 0) {1}
        elsif ($_[0] == 1) {1}
        else {$fib[$_[0]-1]+$fib[$_[0]-2]}
    };
    print $fib[15];

Currently it's next to imposible to change the code to be evaluated
in a Data::Lazy array. Any options you pass to tie() are ignored.

 Due to current suport for tieing arrays in Perl (or lack thereof)
 you have to use
  tied(@a)->{'size'}
 to get the size of the array, if you use usual
  scalar(@a)
 you will get zero! :-(

=head2 Hash

 Eg.

  tie %variable, Data::Lazy, sub {a function taking a long time};

  tie %var, Data::Lazy, 'a string containing some code';

  use Data::Lazy '%variablename' => \&function;

The first time you access some item of the hash, the code gets executed
with $_[0] being the key and the result is saved for later as well as
returned to you. Next accesses will use this value without executing
anything.

If you want to get or set the code that's being evaluated for the previously
unknown items you will find it in $variable{$;}. If you change the code
all previously computed values are forgotten.

 Ex.
    tie %var, Data::Lazy, sub {reverse $_[0]};
    print ">$var{'Hello world'}<\n";
    $var{Jenda}='Jan Krynicky';
    print ">$var{'Jenda'}<\n";
    $fun = $var{$;};
    $var{$;} = sub {$_ = $_[0];tr/a-z/A-Z/g;$_};
    print ">$var[2]<\n";

! If you write something like

  while (($key,$value) = each %lazy_hash) {
   print " $key = $value\n"; #
  };

only the previously fetched items are returned.
Otherwise the listing would be infinite :-)

=head2 Internals

If you want to access the code or value stored in the variable directly you may use

    ${tied $var}{code}
    and
    ${tied $var}{value} # scalar $var
    ${tied @var}{value}[$i] # array @var
    ${tied %var}{value}{$name} # hash %var

This way you may modify the code even for arrays and hashes, but be very
careful with this. Of course if you redefine the code, you'll want to
undef the {value}!

There are two more internal variables:

    ${tied $var}{type}
     0 => scalar
     1 => array
     2 => hash
    ${tied $var}{store}
     0 => LAZY_STOREVALUE
     1 => LAZY_STORECODE
     2 => LAZY_READONLY

If you touch these, prepare for very strange results!

=head2 Examples

 1.
 use Data::Lazy;
 tie $x, Data::Lazy, sub{sleep 3; 3};
 # or
 # use Data::Lazy '$x' => sub{sleep 3; 3};

 print "1. ";
 print "$x\n";
 print "2. ";
 print "$x\n";

 $x = 'sleep 10; 10';

 print "3. ";
 print "$x\n";
 print "4. ";
 print "$x\n";


 2. (from Win32::FileOp)
 tie $Win32::FileOp::SHAddToRecentDocs, Data::Lazy, sub {
    new Win32::API("shell32", "SHAddToRecentDocs", ['I','P'], 'I')
    or
    die "new Win32::API::SHAddToRecentDocs: $!\n"
 };
 ...


=head2 Comment

Please note that there are single guotes around the variable names in
"use Data::Lazy '...' => ..." statements. The guotes are REQUIRED as soon as
you use any variable type characters ($, @ or %)!

=head2 AUTHOR

 Jan Krynicky <Jenda@Krynicky.cz>

=head2 COPYRIGHT

Copyright (c) 2001 Jan Krynicky <Jenda@Krynicky.cz>. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=cut
