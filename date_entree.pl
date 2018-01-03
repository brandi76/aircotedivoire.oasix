#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);

$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$query="select enh_no,enh_date,enh_document from enthead where enh_no>=1324 and enh_document!='' order by enh_date";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1><tr><th>No cde</th><th>four</th><th>date cde</th><th>date entree</th><th>delai</th><th>Date lta</th><th>Delai</th></tr>";
while (($enh_no,$enh_date,$enh_document)=$sth->fetchrow_array){
  $date_entree=&julian($enh_date,"YYYY-MM-DD");
  $query="select distinct com2_no,com2_date,fo2_add from commandearch,fournis where com2_no_liv='$enh_document' and com2_cd_fo=fo2_cd_fo";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($com2_no,$date_commande,$fo2_add)=$sth2->fetchrow_array){
    ($fo_nom)=split(/\*/,$fo2_add);
    print "<tr><td>$com2_no</td><td>$fo_nom</td><td>$date_commande</td><td>$date_entree";
    $delai=&get("select datediff('$date_entree','$date_commande')")+0;
    print "</td><td>$delai</td>";
    $date_lta=&get("select livh_date_lta from dfc.livraison_h where livh_id='$enh_document'");
    print "<td>$date_lta $enh_document</td>";
    $delai=&get("select datediff('$date_entree','$date_lta')")+0;
    print "<td>$delai</td>";
    print "</tR>";
  }
}
print "</table>";
