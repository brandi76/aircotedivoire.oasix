#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";

$query="select * from enso where es_no_do=13945 and es_dt='2015-06-18'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array)
{
	&save("update produit set pr_stre=pr_stre+$es_qte where pr_cd_pr=$es_cd_pr","aff");
}
&save("delete from enso where es_no_do=13945 and es_dt='2015-06-18'");
