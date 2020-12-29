#!/usr/bin/perl
use Socket;
my $server_address = inet_ntoa(inet_aton($name)) or die "Can't get Server IP";
my $server_name = gethostbyaddr(inet_aton($server_address), AF_INET) or die "Can't get Server HostName";


print "Content-type:text/html\r\n\r\n";
print '<html>';
print '<head>';
print '<title>Hello World - First CGI script on Apache2!</title>';
print '</head>';
print '<body>';
print '<h2>Hello World! TUX is in the house!</h2>';
print "<p>Server IP = $server_address </p>";
print "<p>Server Name = $server_name </p>";
print '</body>';
print '</html>';
