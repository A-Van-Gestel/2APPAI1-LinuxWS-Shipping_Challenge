#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser); # Print all errors to the browser
use strict;
use warnings;

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
print '<title>Hello World - First Shipping Challenge CGI script on Apache2!</title>';
print '<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css"/>';
print '</head>';
print '<body>';
print '<div class="container">';
print '<h2>Hello World! TUX is in the house!</h2>';
print '<p">Running MySQL + Apache2 + Perl</p>';
print "<p>Server IP = $server_ip</p>";




# Drop table 'person'. This may fail, if 'person' doesn't exist thus we put an eval around it.
eval { $db_connection->do("DROP TABLE person") };
print "<p>Dropping person failed: $@</p>" if $@;

# Create a new table 'person'. This must not fail, thus we don't catch errors.
$db_connection->do("CREATE TABLE person (id INTEGER, name VARCHAR(20))");

# INSERT some data into 'person'. We are using $db_connection->quote() for quoting the name.
$db_connection->do("INSERT INTO person VALUES (1, " . $db_connection->quote("Tim") . ")");

# same thing, but using placeholders (recommended!)
$db_connection->do("INSERT INTO person VALUES (?, ?)", undef, 2, "Jochen");

# now retrieve data from the table.
my $sth = $db_connection->prepare("SELECT * FROM person");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
    print "<p>Found a row: id = $ref->{'id'}, name = $ref->{'name'}</p>";
}
$sth->finish();

# Disconnect from the database.
$db_connection->disconnect();



print '</div>';
print '</body>';
print '</html>';
