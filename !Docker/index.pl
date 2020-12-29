#!/usr/bin/perl
use Socket 'inet_ntoa';
use Sys::Hostname 'hostname';
my $addr = inet_ntoa(scalar gethostbyname(hostname() || 'localhost'));


print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Hello World - First CGI script on Apache2!</title>';
print '</head>';
print '<body>';
print '<h2>Hello World! TUX is in the house!</h2>';
print "<p>Server IP = $addr </p>";
print '</body>';
print '</html>';
