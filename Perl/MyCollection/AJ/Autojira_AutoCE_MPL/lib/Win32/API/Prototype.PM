#   An API prototype package.
#   This simply creates a subroutine in the main namespace of Perl.
#
#   Copyright (c) 2000 by Dave Roth.  All rights reserved.
#   Courtesy of Roth Consulting
#   http://www.roth.net/
#

package Win32::API::Prototype;

no strict;
use vars qw( $VERSION @ISA @EXPORT %PROC_LIST %PROTOTYPE );
use Exporter;
use Win32::API;

$VERSION = '20000613';

@ISA = qw( Exporter );

@EXPORT = qw( ApiLink AllocMemory NewString CleanString );

%PROC_LIST = ();

# Pointers declared with an * or & character or by use of a
# macro that begins with "LP" such as LPCTSTR are checked
# in the new() function so they don't need to be in the
# %PROTOTYPE hash
%PROTOTYPE = (
    void    =>  V,

    dword   =>  N,
    long    =>  N,
    ulong   =>  N,
    handle  =>  N,
    hkey    =>  N,
    hwnd    =>  N,

    ushort  =>  I,
    short   =>  I,
    int     =>  I,
    bool    =>  I,
    boolean =>  I,
    uint    =>  I,

    pvoid   =>  P,
);

################################################################
# Public functions

sub ApiLink
{
    my( $Library, $Function, $ParamList, $ReturnValue ) = @_;
    my $LCFunction;
    my $PrefWFlag = $^W;

    # Disable warnings since some of them are inevitable in this package.
    $^W = 0;
    if( 2 == scalar @_ )
    {
        my @ParamList;
        my( $ReturnValueType, $FunctionName, $Parameters ) = ($Function =~ /^\s*(\S+)\s+(\S+)\s*\(\s*(.*?)\s*\)/s );
        $ReturnValue = $PROTOTYPE{lc $ReturnValueType};
        $Function = $FunctionName;
    
        foreach my $Element ( split( /,/, $Parameters ) )
        {
            my( $Type, $Symbol ) = ( $Element =~ /^\s*(\S+)\s*(\*|&)?/s );
            $Type = "$Typedef$Symbol" if( "" ne $Symbol );

            # Test for a pointer...
            if( "$Type $Symbol" =~ /(^LP)|(\*)|(\&)/i )
            {
                $Type = "PVOID";
            }
            push( @$ParamList, $PROTOTYPE{lc $Type} );
        }
    }

    $LCFunction = lc $Function;
    if( ! defined $PROC_LIST{$LCFunction} )
    {
        my $Proc = new Win32::API( $Library, $Function, $ParamList, $ReturnValue );
        if( $Proc )
        {
            my $Subroutine;
            $PROC_LIST{$LCFunction} = $Proc;

            $Subroutine = "sub ::" . $Function . "{ return( Win32::API::Prototype::Execute( \"$Function\", \@_ ) ); };"; 
            eval $Subroutine;

        }
    }
    # Restore any warning flags
    $^W = $PrefWFlag;
    return( $PROC_LIST{$LCFunction} );
}

sub NewString
{
    my( $Param ) = @_;
    my $Size;
    my $String = "";
     
    if( $Param =~ /^\d+$/ )
    {
        $Size = $Param;
    }
    else
    {
        $Size = 0;
        $String = $Param;
    }
    $String .= "\x00" x $Size;
    if( Win32::API::IsUnicode() )
    {
        $String =~ s/(.)/$1\x00/g;
    }
    return( $String );
}

sub AllocMemory
{
    my( $Length ) = @_;
    return( "\x00" x $Length );
}

sub CleanString
{
    my( $String, $ForceUnicode ) = @_;
    if( Win32::API::IsUnicode() || $ForceUnicode )
    {
        $String =~ s/(.)\x00/$1/g;
    }
    $String =~ s/^([^\x00]*).*$/$1/s;
    return( $String );
}

################################################################
# Private functions
sub Execute
{
    my( $Function ) = shift @_;
    my $Result;
    my $PrevWFlag = $^W;

    # Disable warnings since some of them are inevitable in this package.
    $^W = 0;
    if( defined $PROC_LIST{lc $Function} )
    {
        $Result = $PROC_LIST{lc $Function}->Call( @_ );
    }
    else
    {
        undef $Result;
    }
    # Restore any warning flags
    $^W = $PrevWFlag;

    return( $Result );
}

# Return TRUE to indicate that the 'use' or 'require' command was successful
1;

=head1 NAME

Win32::API::Prototype - easily manage Win32::API calls

=head1 SYNOPSIS

        use Win32::API::Prototype;

=head1 DESCRIPTION

This module mimicks calling the Win32 API from C by allowing a script
to specify a C function prototype.

=head1 FUNCTIONS

=over 4

=item ApiLink( $Module, $Prototype, [\@ParameterTypes, $ReturnType] )

Declares a Win32 API prototype. There are two ways to call this:

=over 4

=item a) Traditional Win32::API 

The $Prototype is the name of the Win32 API function and the second and third
parameters are traditional Win32::API parameter and return types such as:

    ApiLink( 'kernel32.dll', 'FindFirstVolume', [P,N], N ) || die;

=item b) Prototype style

The $Prototype is the actual C prototype of the function as in:

    ApiLink( 'kernel32.dll', 'HANDLE FindFirstVolume(LPTSTR lpszVolumeName, DWORD chBufferLength)' ) || die;

=back

This will create a global function by the same name of the Win32 API function. Therefore
a script can call it as a C program would call the function.

B<Example:>

    use Win32::API::Prototype;
    @Days = qw(
        Sun
        Mon
        Tue
        Wed
        Thu
        Fri
        Sat
    );
    ApiLink( 'kernel32.dll', 'void GetLocalTime( LPSYSTEM  lpSystemTime )' ) || die;
    $lpSystemTime = pack( "S8", 0,0,0,0,0,0,0,0 );
    
    # This function does not return any value
    GetLocalTime( $lpSystemTime );
    
    @Time{ year, month, dow, day, hour, min, sec, mil } = unpack( "S*", $lpSystemTime );
    printf( "The time is: %d:%02d:%02d %s %04d.%02d.%02d\n", $Time{hour}, $Time{min}, $Time{sec}, $Days[$Time{dow}], $Time{year}, $Time{month}, $Time{day} );

=item AllocMemory( $Size )

This function will allocate a buffer of C<$String> bytes.  The string will be 
filled with NULL charcters.  This is the equivilent of the C++ code:

    LPBYTE pBuffer = new BYTE [ dwSize ];
    if( NULL != pBuffer )
    {
        ZeroMemory( pBuffer, dwSize );
    }

B<Example:>

    use Win32::API::Prototype;
    $pBuffer = AllocMemory( 256 );
    
      

=item NewString( $String | $Size )

This function will create either a string containing C<$String> or create an empty
string C<$Size> characters in length.  Regardless of what type of string is created
it will be created for UNICODE or ANSI depending on what the Win32 API function will
expect.

B<Example:>

    use Win32::API::Prototype;
    
    ApiLink( 'kernel32.dll', 'DWORD GetCurrentDirectory( DWORD nBufferLength, LPTSTR lpBuffer )' ) || die;
    $nBufferLength = 256;
    $lpBuffer = NewString( $nBufferLength );
    # GetCurrentDirectory() returns the length of the directory string
    $Result = GetCurrentDirectory( $nBufferLength, $lpBuffer );
    print "The current directory is: " . CleanString( $lpBuffer ) . "\n";


=item CleanString( $String )

This function will clean up and return the passed in C<$String>.  This means that
the any trailing NULL characters will be removed and if the string is UNICODE it
will be converted to ANSI.

B<Example:>

Refer to the C<NewString()> example.

=back
