#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";

print $html->header;
require "./src/connect.src";

print "<form>";
&form_hidden();
print "appro <input name=appro> <input type=submit></form>";
$appro=$html->param("appro");
if ($appro ne ""){
&save("update geslot set gsl_ind=0,gsl_novol='',gsl_apcode='' where gsl_apcode='$appro'","aff");
&save("update etatap set at_etat=-1 where at_code='$appro'","aff");
print "fin";
}
