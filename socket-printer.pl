#!/usr/bin/perl
use IO::Socket::INET;

# listen on tcp 9100
$printport = 9100;
$printersocket = IO::Socket::INET->new(
	LocalPort => $printport,
	Type => SOCK_STREAM,
	Reuse => 1,
	Listen => 1) or die "Socket cannot be opened $!\n";

# write traffic from 9100 to printsocket.in file
while ($pjob = $printersocket->accept()) {
  open(J,">>/var/spool/printsocket.in") or print "File cannot be opened $!\n";
  while (<$pjob>) {
  print J "$_";
  }
  close J;
  close $pjob;
}
