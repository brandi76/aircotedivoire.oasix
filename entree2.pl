#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";

&save("create temporary table lta_tmp (lta varchar(30),date date,pr_douane varchar(30),qte decimal(8,2) , valeur decimal(8,2), primary key (lta,pr_douane))");
$query="select livh_id,livh_date,livh_lta from dfc.livraison_h where livh_base='aircotedivoire' and livh_lta!='' order by livh_date";
$sth=$dbh->prepare($query);
$sth->execute();
while (($livh_id,$livh_date,$livh_lta)=$sth->fetchrow_array){
  $query="select enh_no,enh_date from enthead where enh_document='$livh_id'";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($enh_no,$enh_date)=$sth2->fetchrow_array){
    $query="select pr_douane,enb_quantite/100,pr_prac/100 from entbody,produit where enb_no='$enh_no' and enb_cdpr=pr_cd_pr group by pr_douane";
    $sth3=$dbh->prepare($query);
    $sth3->execute();
    $total_qte=0;
    &switch_color();
    $run="nil";
    while (($pr_douane,$enb_quantite,$pr_prac)=$sth3->fetchrow_array){
      $total_qte=$enb_quantite+&get("select qte from lta_tmp where lta='$livh_lta' and pr_douane='$pr_douane'");
      $total_valeur=$enb_quantite*$pr_prac+&get("select valeur from lta_tmp where lta='$livh_lta' and pr_douane='$pr_douane'");
      &save("replace into lta_tmp values ('$livh_lta','$date','$pr_douane','$total_qte','$total_valeur')");
    }
  }
}
print "<table border=1><tr><th>N° LTA </th><th> N° NOMENCLATURE </th><th> QTE </th><th> VALEUR </th></tr>";
$query="select * from lta_tmp order by date,lta,pr_douane";
$sth2=$dbh->prepare($query);
$sth2->execute();
while (($lta,$date,$pr_douane,$qte,$valeur)=$sth2->fetchrow_array){
  if ($lta ne $run){&switch_color($lta);}
  print "<tr bgcolor=$color><td>$lta</td><td>$pr_douane</td><td>$qte</td><td>$valeur</td></tr>";  
}
print "</table>";

