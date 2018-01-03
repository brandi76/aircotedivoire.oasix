#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
require "../oasix/../oasix/outils_corsica.pl";

use CGI;
use DBI();
$html=new CGI;
print $html->header();
require("./src/connect.src");
$premiere=&nb_jour("01","01","2013");
$derniere=&nb_jour("31","12","2013");

$query="select pr_ventil,sum(enb_quantite/100) from entbody,produit,enthead where enb_cdpr=pr_cd_pr and enh_no=enb_no and enh_date>='$premiere' and enh_date<='$derniere' group by pr_ventil"; 
$sth=$dbh->prepare($query);
$sth->execute();
$total=0;
$tamp=0;

while (($pr_ventil,$qte)=$sth->fetchrow_array){
  print "$pr_ventil $qte<br>";
}
print "fin";
