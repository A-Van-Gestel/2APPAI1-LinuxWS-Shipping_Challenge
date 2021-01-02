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
                <li class="nav-item active">
                    <a class="nav-link" href="/">Home</a>
                </li>
                <li class="nav-item text-muted">
                    <a class="nav-link" href="db_update_name.pl">Update Name</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="db_seed.pl">Reset Database</a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container">
        <h2>Hello Shipping Challenge! TUX is in the house!</h2>
        <p class="mb-0">Running MySQL + Apache2 + Perl</p>
HTML_HEADER

print <<"HTML_EXTRA1";
    <p>Server IP = $server_ip</p>
HTML_EXTRA1

print <<"HTML_FORM";
<FORM action = "db_update_name.pl" method = "GET" class="mb-3">
    <div class="form-row">
        <div class="col-md-6 mb-3">
            <label for="id">ID:</label>
            <input type="number" class="form-control" id="id" name="id" aria-describedby="id_help" min="0" step="1" value="1" required>
            <small id="id_help" class="form-text text-muted">Input the ID of the name you wish to update.</small>
        </div>
        <div class="col-md-6 mb-3">
            <label for="name">Name:</label>
            <input type="text" class="form-control" id="name" name="name" aria-describedby="name_help" minlength="1" maxlength="50" value="Updated Name" required>
            <small id="name_help" class="form-text text-muted">Input the new name for the chosen ID.</small>
        </div>
    </div>
    <button type="submit" class="btn btn-primary">Update Name</button>
</FORM>
HTML_FORM


# --- START: Database Receive Process ---
# now retrieve data from the table.
my $sth = $db_connection->prepare("SELECT * FROM person");
$sth->execute();
while (my $ref = $sth->fetchrow_hashref()) {
    print "<p class=\"mb-0\">Found a row: id = $ref->{'id'}, name = $ref->{'surname'}</p>";
}
$sth->finish();

# Disconnect from the database.
$db_connection->disconnect();
# --- END: Database Receive Process ---


print <<"HTML_FOOTER";
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
</body>
</html>
HTML_FOOTER
