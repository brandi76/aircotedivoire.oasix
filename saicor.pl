#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";

$query="select code,rot,count(*),sum(montant) from carte_bancaire group by code,rot";
$sth=$dbh->prepare($query);
$sth->execute();
while  (($code,$rot,$nbcb,$montant)=$sth->fetchrow_array){
	# print "update caissesql set ca_nbcb=$nbcb,ca_cb=$montant where ca_code=$code and ca_rot=$rot<br>"
	&save("update caissesql set ca_nbcb=$nbcb,ca_cb=$montant where ca_code=$code and ca_rot=$rot","aff");
}
