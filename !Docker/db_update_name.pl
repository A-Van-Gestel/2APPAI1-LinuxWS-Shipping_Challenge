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

# --- START: Get User input using GET ---
my $buffer, my @pairs, my $pair, my $key, my $value, my %FORM;
# Read in text
$ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $buffer = $ENV{'QUERY_STRING'};
}
# Split information into name/value pairs
@pairs = split(/&/, $buffer);
foreach $pair (@pairs) {
    ($key, $value) = split(/=/, $pair);
    $value =~ tr/+/ /;
    $value =~ s/%(..)/pack("C", hex($1))/eg;
    $FORM{$key} = $value;
}
my $form_id = $FORM{id};
my $form_name  = $FORM{name};
# --- END: Get User input using GET ---

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
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <a class="navbar-brand">Shipping Challenge</a>
        <button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav">
                <li class="nav-item">
                    <a class="nav-link" href="/">Home</a>
                </li>
                <li class="nav-item active">
                    <a class="nav-link" href="db_update_name.pl">Update Name</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="db_seed.pl">Reset Database</a>
                </li>
            </ul>
        </div>
    </nav>
    <div class="container">
        <h2>Hello Shipping Challenge! TUX is updating names in the house!</h2>
        <p class="mb-0">Running MySQL + Apache2 + Perl</p>
HTML_HEADER

print <<"HTML_EXTRA1";
    <p>Server IP = $server_ip</p>
    <p class="mb-0">Form input:
    <p class="mb-0">ID = <b>$form_id</b></p>
    <p>Name = <b>$form_name</b></p>
HTML_EXTRA1




# update statement
my $sql = "UPDATE person
           SET name = ?
	       WHERE id = ?";

my $sth = $db_connection->prepare($sql);

my $id = $form_id;
my $name = $form_name;

# bind the corresponding parameter
$sth->bind_param(1,$name);
$sth->bind_param(2,$id);

# execute the query
$sth->execute();

print "<div class=\"alert alert-success\" role=\"alert\">The record on ID <b>$id</b> has been updated to <b>$name</b> successfully!</div>";

$sth->finish();

# Disconnect from the database.
$db_connection->disconnect();

print '<a href="/" class="btn btn-primary">Go Back</a>';

print <<"HTML_FOOTER";
    </div>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.5.3/js/bootstrap.bundle.min.js"></script>
</body>
</html>
HTML_FOOTER
