#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);  # Print all errors to the browser
# use strict;
# use warnings FATAL => 'all';

# Dynamic Server IP getting
use Socket 'inet_ntoa';
use Sys::Hostname 'hostname';
my $server_ip = inet_ntoa(scalar gethostbyname(hostname() || 'localhost'));

# MySQL Database Connection
use DBI;
my $db_driver = 'mysql';
my $db_scheme = 'shipping_challenge';
my $db_ip = '10.99.221.78';
my $db_username = 'shipping_challenge';
my $db_password = 'admin1234';
my $db_connection = DBI->connect("DBI:$db_driver:$db_scheme:$db_ip", "$db_username", "$db_password"); #or die $DBI::errstr;


print "Content-type:text/html\r\n\r\n";
print '<html lang="en">';
print '<head>';
print '<title>Hello World - First CGI script on Apache2!</title>';
print '</head>';
print '<body>';
print '<h2>Hello World! TUX is in the house!</h2>';
print "<p>Server IP = $server_ip</p>";




# Drop table 'foo'. This may fail, if 'foo' doesn't exist
# Thus we put an eval around it.
eval { $db_connection->do("DROP TABLE foo") };
print "<p>Dropping foo failed: $@</p>" if $@;

# Create a new table 'foo'. This must not fail, thus we don't
# catch errors.
$db_connection->do("CREATE TABLE foo (id INTEGER, name VARCHAR(20))");

# INSERT some data into 'foo'. We are using $db_connection->quote() for
# quoting the name.
$db_connection->do("INSERT INTO foo VALUES (1, " . $db_connection->quote("Tim") . ")");

# same thing, but using placeholders (recommended!)
$db_connection->do("INSERT INTO foo VALUES (?, ?)", undef, 2, "Jochen");

# now retrieve data from the table.
my $sth = $db_connection->prepare("SELECT * FROM foo");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
    print "<p>Found a row: id = $ref->{'id'}, name = $ref->{'name'}</p>";
}
$sth->finish();

# Disconnect from the database.
$db_connection->disconnect();




print '</body>';
print '</html>';
