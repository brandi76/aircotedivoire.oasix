#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param('action');
require "./src/connect.src";

# print "<h1> Prevenir sylvain , merci</h1>";
# exit;
$saler=&get("select sum(es_qte)/100 from enso where datediff(curdate(),es_dt)<120")+0;
print " sailer:$saler";
$query="select pr_cd_pr,pr_desi,pr_prac/100,pr_stre/100 from produit where pr_stre>0";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_stre)=$sth->fetchrow_array){
$vendu=&get("select sum(es_qte)/100 from enso where es_cd_pr=$pr_cd_pr and datediff(curdate(),es_dt)<120")+0;
print "$pr_cd_pr;$pr_desi;$vendu;$pr_prac,$pr_stre<br>";

}
