#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
$an=$html->param("an");
print "<form>";
print "Ann�e (AA) <input type=text name=an size=2>";
print "<input type=submit>";
print "</form>";
if ($an  eq ""){exit;}

print "<title>Recap de caisse</title>";
$query="select distinct cl_cd_cl,count(*) as nb from vol,client where v_cd_cl=cl_cd_cl order by nb desc limit 1";
$sth=$dbh->prepare($query);
$sth->execute();
($client)=$sth->fetchrow_array;
$query="select cl_nom,cl_com1/100,cl_com2/100 from client where cl_cd_cl='$client'";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom,$cl_com1,$cl_com2)=$sth->fetchrow_array;

print "Ann e:20$an   Client:$cl_nom <br>";

$query="select v_code from vol where v_cd_cl='$client' and v_date%100=$an and v_rot=1 order by v_code";

 # print $query;
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1 bordercolor=black cellspacing=0 style=\"border: solid;\">";
$total_compn=0;
while (($v_code)=$sth->fetchrow_array){
 		$query="select ca_xof,ca_xaf,ca_dol,ca_eur,ca_border from caissesql where ca_code='$v_code'";
 		$sth2=$dbh->prepare($query);
 		$sth2->execute();
 		$total_xof=0;
		$total_xaf=0;
		$total_dol=0;
		$total_eur=0;
	
 		while (($ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_border2)=$sth2->fetchrow_array){
 		($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
 		($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
 		($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
 		($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
 		$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
 		$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
 		$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
 		$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
 		$totalf_xof+=$total_xof;
 		$totalf_xaf+=$total_xaf;
 		$totalf_dol+=$total_dol;
 		$totalf_eur+=$total_eur;
 		$ca_border=$ca_border2;
 		}
 		if (($ca_border ne $border)&&($ca_border!=0)){
		  if ($total_cum!=0){print "<tr><td>$border</td><td>$total_cum</td></tr>";}
		  $total_cum=0;
		  $border=$ca_border;
		  }
 		$total+=$total_xof;
 		$total_cum+=$total_xof;
 		}
 		print "<tr><td>$border</td><td>$total_cum</td></tr>";
		print "</table>$total";
