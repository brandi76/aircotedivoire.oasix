#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$client="aircotedivoire";
$an=&get("select year(curdate())");
$an_1=$an-1;
$an_2=$an-2;
$mag_run="";

&save("create temporary table liste_tmp (code int(8),prix int(8),primary key (code))");
#$query="select v_code,v_troltype from vol where v_date_sql>='2016-01-01' and v_date_sql <='2016-12-31' ";
$query="select v_code,v_troltype from vol ";
$sth=$dbh->prepare($query);
  $sth->execute();
  while (($v_code,$trolley)=$sth->fetchrow_array){
  		$mag="lemag".substr($trolley,0,2);
		if ($mag ne $mag_run){
			&save("truncate table liste_tmp");		
			&save("insert ignore into liste_tmp select code,prix from mag where mag='$mag' and code>0");		
			$nb_ref=&get("select count(*) from liste_tmp");
			$mag_run=$mag;
		}	
		$check=&get("select sum(prix) from liste_tmp where code not in (select ap_cd_pr from appro where ap_code='$v_code')","af")+0;
		#print "$v_code $trolley $mag $check<br>";
		&save("update vol set v_retour='$check' where v_code='$v_code'");
		# $query="select code ,pr_desi from liste_tmp,produit where produit.pr_cd_pr=code and code not in (select ap_cd_pr from appro where ap_code='$v_code')";
		# $sth=$dbh->prepare($query);
		# $sth->execute();
		# while (($code,$pr_desi)=$sth->fetchrow_array){
			# print "$code $pr_desi<br>";
		# }	
		
		
	}

print "fin";
;1
