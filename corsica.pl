#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;
print "<title>corsica</title>";
require "./src/connect.src";
$action=$html->param("action");
$semaine=$html->param("semaine");
$an=`date +%Y`;
$mois=`date +%m`;
if (($semaine <20)&&($mois>11)){$an++;}

if ($action eq ""){
	print "<form>";
	print "Livraison semaine ?:<input type=text name=semaine >";
	print "<input type=hidden name=action value=go>";
	print "<input type=submit></form>";
}
if ($action eq "go"){
	print "<form>";
	print "<table>";
	$query="select distinct nav_nom from horaire where year(nav_date)=$an and weekofyear(nav_date)=$semaine or weekofyear(nav_date)=$semaine+1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($navire)=$sth->fetchrow_array)
	{
		print "<tr>";
		$apres=0+&get("select count(*) from horaire where year(nav_date)=$an and nav_nom='$navire' and weekofyear(nav_date)=$semaine+2");
		$avant=0+&get("select count(*) from horaire where year(nav_date)=$an and nav_nom='$navire' and weekofyear(nav_date)=$semaine");
		print "<tr><td>$navire </td>";
		if ($apres==0){ print "<td>desarmement</td>"; }
		if ($avant==0){ print "<td>armement</td>"; }
		$cde=&get("select ic2_no from infococ2 where ic2_com1='$navire' and ic2_fact=0");
		$sql_navire=$navire;
		while ($sql_navire=~s/ /_/){};
		if (($cde eq "")&&($apres!=0)) { print "<td><input type=checkbox name='$sql_navire' checked></td>";}
		if ($cde ne ""){print "<td>$cde <input type=checkbox name='$sql_navire' checked></td>";$cree=1 ;}
		
		print "</tr>";
	}
	print "</table><br>";
	print "<input type=hidden name=semaine value=$semaine>";
 	if ($cree !=1){
		print "<input type=hidden name=action value=creer>";
		print "<input type=submit value='creation des commandes pour la selection'></form>";
 	}
 	else
 	{
 		print "<input type=hidden name=action value=2100>";
 		print "<input type=submit value='ajout des produits delist�s pour la selection'></form>";
 	}
}
if ($action eq "creer"){
	$datesimple="1".`/bin/date +%y%m%d`;
	$query="select distinct nav_nom from horaire where year(nav_date)=$an and weekofyear(nav_date)=$semaine or weekofyear(nav_date)=$semaine+1";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($navire)=$sth->fetchrow_array)
	{
		$sql_navire=$navire;
		while ($sql_navire=~s/ /_/){};
		if ($html->param("$sql_navire") eq "on" ){
	        	$no_cde=1+&get("select dt_no from atadsql where dt_cd_dt=120");
			&save("update atadsql set dt_no='$no_cde' where dt_cd_dt=120");
			&save("insert ignore into infococ2 values('$no_cde','500','0','$datesimple','0','0','$navire','','$navire','0','0','0','0','$datesimple','','','')");
			print "$navire $no_cde<br>";
		}
	}
}

if ($action eq "deliste"){
	my ($nb);
	$query="select distinct nav_nom from horaire where year(nav_date)=$an and weekofyear(nav_date)=$semaine or weekofyear(nav_date)=$semaine+1";
# 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($navire)=$sth->fetchrow_array)
	{
# 		print "*";
		$sql_navire=$navire;
		while ($sql_navire=~s/ /_/){};
		if ($html->param("$sql_navire") eq "on" ){
			push (@liste,$sql_navire);
			$nb++;
		}
	}	
	foreach $sql_navire (@liste)
	{
		print "*";
		$navire=$sql_navire;
		while ($navire=~s/_/ /){};
		$no_cde=&get("select ic2_no from infococ2 where ic2_com1='$navire' and ic2_fact=0");
		$query="select pr_cd_pr,pr_desi from produit where pr_sup!=0 and pr_sup!=3 and (pr_type=1 or pr_type=5)  and pr_cd_pr >1000000000";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
			%stock=&stock($pr_cd_pr,'','quick','');
			$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot
			$encours=&get("select sum(coc_qte)/100 from comcli,infococ2 where coc_cd_pr=$pr_cd_pr and coc_in_pos=0 and coc_no=ic2_no and ic2_cd_cl=500");
			$pr_stre-=$encours;
			if ($pr_stre<=0){next;}
			$qte=int($pr_stre/$nb);
			# print "-$qte $pr_stre $nb -";
			if ($nb==1){$qte=$pr_stre;}
			if (($pr_stre%$nb)>0){$qte++;}
			%calcul=&table_navire($navire,$pr_cd_pr);
                     	# print "$pr_cd_pr $pr_desi $pr_stre $qte*".$calcul{"stock_navire"}."<br>";
                        if ($qte+$calcul{"stock_navire"}>18){$qte=18-$calcul{"stock_navire"};}
                    	if ($qte<=0){next;}
			$qte*=100;
			&save("replace into comcli values('$no_cde','$pr_cd_pr','$qte','0','0','0','$qte')","aff");
		}
		$nb--;
	}
}

if ($action eq "2100"){
	my ($nb);
	$query="select distinct nav_nom from horaire where year(nav_date)=$an and weekofyear(nav_date)=$semaine or weekofyear(nav_date)=$semaine+1";
 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($navire)=$sth->fetchrow_array)
	{
#  		print "*";
		$sql_navire=$navire;
		while ($sql_navire=~s/ /_/){};
		if ($html->param("$sql_navire") eq "on" ){
			push (@liste,$sql_navire);
			print "*";
			$nb++;
		}
	}	
	foreach $sql_navire (@liste)
	{
		print "*";
		$navire=$sql_navire;
		while ($navire=~s/_/ /){};
		$no_cde=&get("select ic2_no from infococ2 where ic2_com1='$navire' and ic2_fact=0");
		$query="select pr_cd_pr,pr_desi from produit where pr_four=2100  and pr_cd_pr >1000000000";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr,$pr_desi)=$sth->fetchrow_array){
 			%stock=&stock($pr_cd_pr,'','quick','');
 			$pr_stre=$stock{"pr_stre"}+0;  # stock reel entrepot
 			$encours=&get("select sum(coc_qte)/100 from comcli,infococ2 where coc_cd_pr=$pr_cd_pr and coc_in_pos=0 and coc_no=ic2_no and ic2_cd_cl=500");
 			$pr_stre-=$encours;
 			if ($pr_stre<=0){next;}
 			$qte=int($pr_stre/$nb);
 			if ($nb==1){$qte=$pr_stre;}
 			if (($pr_stre%$nb)>0){$qte++;}
 			%calcul=&table_navire($navire,$pr_cd_pr);
                         if ($qte+$calcul{"stock_navire"}>18){$qte=18-$calcul{"stock_navire"};}
                     	if ($qte<=0){next;}
 			$qte*=100;
#			$qte=200;
			&save("replace into comcli values('$no_cde','$pr_cd_pr','$qte','0','0','0','$qte')","aff");
		}
		$nb--;
	}
}
if ($action eq "montre"){
	my ($nb);
	$query="select distinct nav_nom from horaire where year(nav_date)=$an and weekofyear(nav_date)=$semaine or weekofyear(nav_date)=$semaine+1";
# 	print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($navire)=$sth->fetchrow_array)
	{
# 		print "*";
		$sql_navire=$navire;
		while ($sql_navire=~s/ /_/){};
		if ($html->param("$sql_navire") eq "on" ){
			push (@liste,$sql_navire);
			$nb++;
		}
	}	
	foreach $sql_navire (@liste)
	{
		print "*";
		$navire=$sql_navire;
		while ($navire=~s/_/ /){};
		$no_cde=&get("select ic2_no from infococ2 where ic2_com1='$navire' and ic2_fact=0");
		$query="select * from produit where pr_stre=600 and pr_desi like 'MONTRE Y%'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($pr_cd_pr)=$sth->fetchrow_array){
			$qte=100;
			&save("replace into comcli values('$no_cde','$pr_cd_pr','$qte','0','0','0','$qte')","aff");
		}
		$nb--;
	}
}

