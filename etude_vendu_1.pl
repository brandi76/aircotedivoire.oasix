#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
require "../oasix/outils_corsica.pl";
print $html->header;


$navire=$html->param("navire");
$action=$html->param("action");
$option=$html->param("option");

require "./src/connect.src";
print "<title>Ranking produit</title>";
if ($action eq ""){
	print "<body><center><h1>Ranking produit (janvier septembre 2006)<br><form>";
	print "<br> Choix d'un navire<br>";
	$sth = $dbh->prepare("select nav_nom from navire");
    	$sth->execute;
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
  	print "<option value=tout>TOUT\n";
    	print "<option value=France>FRANCE\n";
  	print "<option value=Italie>ITALIE\n";
  	print "<option value=mixte>MIXTE\n";
    	print "</select><br>\n";
    	print "<br><input type=hidden name=action value=visu><input type=submit value=voir></form>";
    	print "<form>";
    	print "<br><input type=hidden name=action value=new><input type=submit value=nouveaute></form>";
    	
    	print "</body>";
}

# open(FILE,"vendu_complet.csv");
# @tab=<FILE>;
# foreach (@tab){
#	while ($_=~s/"//){};
#	($neptune,$desi,$type,$navire,$qte,$famille,$sous_famille)=split(/;/,$_);
#	if ($navire eq "Corsica Marina Seconda"){$navire="MARINA";}
#	if ($navire eq "Corsica Victoria"){$navire="VICTORIA";}
#	if ($navire eq "Sardinia Regina"){$navire="REGINA";}
#	if ($navire eq "Mega Express"){$navire="MEGA 1";}
#	if ($navire eq "Mega Express Two"){$navire="MEGA 2";}
#	if ($navire eq "CE III"){$navire="EXPRESS 3";}
#	if ($navire eq "Corsica Serena Seconda"){$navire="SERENA II";}
#	if ($navire eq "CEII"){$navire="EXPRESS 2";}
#	if ($navire eq "Sardinia Express"){$navire="SARDINIA EXPRESS";}
	

#	$pr_cd_pr=&get("select nep_codebarre from neptune where nep_cd_pr='$neptune'","af");
#	if ($pr_cd_pr eq ""){next;}
#	$qte_old=0+&get("select vdu_qte from vendu_corsica where vdu_type='$type' and vdu_navire='$navire' and vdu_cd_pr='$pr_cd_pr'","af");
#	$qte+=$qte_old;
#	&save("replace into vendu_corsica values ('$pr_cd_pr','$type','$navire','$qte','$famille','$sous_famille')","aff");
# }
if ($action eq "visu"){
print "<table border=1 cellspacing=0><tr bgcolor=#009999><th>ranking</th><th>code produit</th><th>designation</th><th>qte vendue</th><th>part</th></tr>";
$query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte),vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica,produit where vdu_navire='$navire' and vdu_famille='PARFUMS' and vdu_cd_pr=pr_cd_pr and (pr_sup=0 or pr_sup=3) group by vdu_cd_pr order by vdu_qte desc";

if ($navire eq "tout") {
	$query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte),vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica,produit where  vdu_famille='PARFUMS' and vdu_cd_pr=pr_cd_pr and (pr_sup=0 or pr_sup=3) group by vdu_cd_pr order by vdu_qte desc";
}
if (($navire eq "mixte")||($navire eq "France")||($navire eq "Italie")) {
	$query="select vdu_cd_pr,vdu_type,vdu_navire,sum(vdu_qte),vdu_famille,vdu_sous_famille,pr_desi,pr_sup from vendu_corsica,produit where vdu_type='$navire' and vdu_famille='PARFUMS' and vdu_cd_pr=pr_cd_pr and (pr_sup=0 or pr_sup=3) group by vdu_cd_pr order by vdu_qte desc";
}
# print $query;
$sth=$dbh->prepare($query);
$sth->execute();
$i=1;
while (($pr_cd_pr,$type,$navire,$qte,$famille,$sous_famille,$pr_desi,$pr_sup)=$sth->fetchrow_array){
	$color="white";
	# if ($pr_sup==3){$color="green"};
	print "<tr bgcolor=$color><td>$i</td></td><td>$pr_cd_pr</td><td>$pr_desi</td><td>$qte</td>";
	$nb++;
	$vendu+=$qte;
	$vente[$i]=$qte+$vente[$i-1];
	if ($pr_sup==3){print "<td>new</td>"};

	# print "<td>$i $vente[$i]</td>";
	$i++;
	print "</tr>";
}
print "</table>";
$quart=int($nb/4);
print "nombre de reference:$nb<br>";
print "nombre de piece vendus:$vendu<br>";
$pour=int ($vente[$quart]*100/$vendu);
print "nombre de piece vendus par le top 25% des produits :$vente[$quart] $pour%<br>";
}
  
if ($action eq "new"){
	print "<h1>Nouveaute</h1><br>";
	print "<table border=1 cellspacing=0 >";
	$query="select vdu_navire from vendu_corsica group by vdu_navire order by vdu_navire";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<tr bgcolor=#009999><td>&nbsp;</td>";
	while (($navire)=$sth->fetchrow_array){
		print "<th><font size=-2>$navire</th>";
	}
	print "<th>total</th></tr>";                    	
	$query="select vdu_cd_pr,pr_desi from vendu_corsica,produit where vdu_cd_pr=pr_cd_pr and pr_sup=3 and vdu_famille='PARFUMS' group by vdu_cd_pr order by vdu_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($produit,$pr_desi)=$sth->fetchrow_array){
		print "<tr><td><font size=-2>$produit $pr_desi</td>";
		$query="select vdu_navire from vendu_corsica group by vdu_navire order by vdu_navire";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($navire)=$sth2->fetchrow_array){
			$qte=0+&get("select sum(vdu_qte) from vendu_corsica where vdu_cd_pr=$produit and vdu_navire='$navire'");
			print "<td>$qte</td>";
			$total+=$qte;
		}
		print "<td>$total</td></tr>";
		$total_gen+=$total;
		$total=0;
	}
	print "</table>";
	print "Nombre de pieces vendus:$total_gen<br>";
}
