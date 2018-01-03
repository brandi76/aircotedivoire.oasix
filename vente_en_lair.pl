#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$date="2016-12-31";
#$query="select infr_code,v_date,infr_date from inforetsql,vol where infr_date>'$date' and infr_code=v_code and v_rot=1 and  FROM_UNIXTIME(v_date_jl*24*60*60,'%Y-%m-%d')<='$date'";
$query="select v_code,v_date_sql from vol where v_rot=1 and  v_date_sql<='$date' and datediff('$date',v_date_sql)<30";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_date_sql)=$sth->fetchrow_array){
	$vendu=&get("select sum(es_qte*pr_prac)/10000 from produit,enso where es_no_do='$v_code' and es_cd_pr=pr_cd_pr and es_dt>'$date'","af")+0;
	if ($vendu!=0){
	print "$v_code;$v_date_sql;$vendu<br>";
	$total+=$vendu;
	}
}
print "$total";