#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";

$query="select * from entbody ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($enb_no,$enb_cdpr,$enb_qte)=$sth->fetchrow_array)
	{
		$check=&get("select count(*) from enso where es_cd_pr='$enb_cdpr' and es_no_do='$enb_no' and es_qte_en!=0 and es_dt>20121231")+0;
		if ($check==0){&save("delete from entbody where enb_no='$enb_no' and enb_cdpr='$enb_cdpr' ");}
		print "$check $enb_no $enb_cdpr <br>";
	}

