#!/usr/bin/perl
use strict;
use warnings;
use Net::FTP;
use File::Copy;
use POSIX qw(strftime);

# in file, work file
my $infile = "/var/spool/printsocket.in";
my $workfile = "/var/spool/printsocket.work";
my $outprefix = "";

# hash (key,value)
my %match_report = (
    'somestring1' => 'TITLE1',
    "someother\.*string2" => 'TITLE2',
    "SOMEOTHER\.*STRING3" => 'TITLE3',
);

# function to find a string, similar to grep
# will be used to determine if a key in $match_report exists in $infile
sub match_infile {
    my ($infile, $string) = @_;
    open my $infilehandle, '<', $infile;
    while (<$infilehandle>) {
        return 0 if /$string/;
    }
    return 1;
}

# will stop at first match
my $match_found = 0;

# loop through match_report using match_infile
for my $match_outstring (keys %match_report) {
    # if match do
    if ($match_found == 0 &&
        match_infile($infile, $match_outstring) == 0) {
        # set outprefix to the key's value
        $outprefix = $match_report{$match_outstring};
        # move .in to .work to avoid overwrite from another print
        move($infile,$workfile);
        # stop loop
        ++$match_found;
    }
}

# no match, then exit
if ($match_found == 0) {
    die "no match, exiting.\n";
}

# empty file for .DONE
my $emptyfile = "/var/spool/printsocket.empty";
open(my $emptyfilehandle,">",$emptyfile) or die "$!";
close($emptyfilehandle);

# date suffix
my $datesuffix = strftime "%Y%m%d", localtime;

# destination files
my $ftptxt = "$outprefix.$datesuffix.TXT";
my $ftpdone = "$outprefix.$datesuffix.DONE";
my $nfstxt = "/nfs/$outprefix.$datesuffix.TXT";
my $nfsdone = "/nfs/$outprefix.$datesuffix.DONE";

# ftp (transfer 1 of 2)
my $ftpserver = "ftp.chadg.net";
my $ftpuser = "chad";
my $ftppassword = "{{ salt['pillar.get']('chadftppw') }}";

# connect
my $ftp = Net::FTP->new($ftpserver, Debug => 0)
    or die "Cannot connect to $ftpserver: $@";

# auth
$ftp->login($ftpuser,$ftppassword)
    or die "Cannot login: ", $ftp->message;

# upload files
$ftp->put($workfile,$ftptxt)
    or die "Put failed: ", $ftp->message;
$ftp->put($emptyfile,$ftpdone)
    or die "Put failed: ", $ftp->message;

# nfs (transfer 2 of 2)
copy($workfile,$nfstxt)
    or die "Copy failed: $!";
copy($emptyfile,$nfsdone)
    or die "Copy failed: $!";
