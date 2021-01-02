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

print <<"HTML_HEADER";
Content-type:text/html\n\n
<!DOCTYPE html>
<html lang="en">
<head>
    <title>Hello World - First Shipping Challenge CGI script on Apache2!</title>
    <link rel="shortcut icon" href="favicon.ico">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.3/css/bootstrap.min.css"/>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark mb-3">
        <a class="navbar-brand">Shipping Challenge</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="/">Home</a>
                </li>
                <li class="nav-item text-muted">
                    <a class="nav-link" href="db_update_name.pl">Update Name</a>
                </li>
                <li class="nav-item active">
                    <a class="nav-link" href="db_seed.pl">Reset Database</a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container">
        <h2>Hello Shipping Challenge! TUX is resetting the house!</h2>
        <p class="mb-0">Running MySQL + Apache2 + Perl</p>
HTML_HEADER

print <<"HTML_EXTRA1";
    <p>Server IP = $server_ip</p>
HTML_EXTRA1
print '<div class="alert alert-success" role="alert">Database Reset!</div>';


# --- START: Database Table creation & Seeding ---
# Drop table 'person'. This may fail, if 'person' doesn't exist thus we put an eval around it.
eval { $db_connection->do("DROP TABLE person") };
print "<p>Dropping person failed: $@</p>" if $@;

# Create a new table 'person'. This must not fail, thus we don't catch errors.
$db_connection->do("CREATE TABLE person (id INTEGER NOT NULL AUTO_INCREMENT primary key, surname VARCHAR(50) NOT NULL)");

# INSERT some data into 'person'. We are using $db_connection->quote() for quoting the surname.
$db_connection->do("INSERT INTO person VALUES (1, " . $db_connection->quote("Linus") . ")");

# same thing, but using placeholders (recommended!)
$db_connection->do("INSERT INTO person VALUES (?, ?)", undef, 2, "Torvalds");

# now retrieve data from the table.
my $sth = $db_connection->prepare("SELECT * FROM person");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
    print "<p class=\"mb-0\">Found a row: id = $ref->{'id'}, name = $ref->{'surname'}</p>";
}
$sth->finish();

# Disconnect from the database.
$db_connection->disconnect();
# --- END: Database Table creation & Seeding ---


print '<a href="/" class="btn btn-primary">Go Back</a>';

print <<"HTML_FOOTER";
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
</body>
</html>
HTML_FOOTER
