#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$query="select enh_no,enh_date from enthead where enh_no>=1058 and enh_no<=1275 order by enh_date";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table>";
while (($enh_no,$enh_date)=$sth->fetchrow_array){
#   print "$enh_no ";
  $query="select pr_cd_pr,pr_desi,enb_quantite/100,pr_prac/100 from entbody,produit where enb_no=$enh_no and enb_cdpr=pr_cd_pr";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($pr_cd_pr,$pr_desi,$enb_quantite,$pr_prac)=$sth2->fetchrow_array){
    print "<tr><td>'";
    print &julian($enh_date,"YYYY-MM-DD");
    print "</td><td>$enh_no</td><td>$pr_cd_pr</td><td>$pr_desi</td><td>$enb_quantite</td><td>$pr_prac</td></tr>";
  }
}
print "</table>";
