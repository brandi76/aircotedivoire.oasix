#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";

print "<table>";
$query="select distinct tr_cd_pr from trolley where tr_code=2400 or tr_code=2401 ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($tr_cd_pr)=$sth->fetchrow_array){
  $pr_desi=&get("select pr_desi from produit where pr_cd_pr=$tr_cd_pr");
  $qte=&get("select count(distinct v_date) from vol,appro where  v_date%10000>=114 and v_date%1000<=314 and v_date%100=14 and v_rot=1 and v_code=ap_code and ap_cd_pr=$tr_cd_pr and ap_qte0=0");
  print "<tR><td>$tr_cd_pr</td><td>$pr_desi</td><td>$qte</td></tr>";
}
print "</table>";

