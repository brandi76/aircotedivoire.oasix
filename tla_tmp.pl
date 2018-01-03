#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
require "../oasix/../oasix/outils_corsica.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
require("./src/connect.src");

print "<table border=1 cellspacing=0>";
print "<tr><th>IM 7</th><th>LTA (fichier mail)</th><th>No entree</th><th>Bon de livraison de l'entree</th><th>LTA enregistre pour l'entree</th><th>Bl trouve pour le LTA fichier</th></tr>";
$query="select * from dfc.lta_tmp ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($im7,$lta,$entree)=$sth->fetchrow_array){
	$id=&get("select enh_document from enthead where enh_no=$entree");
	$lta_trouve=&get("select livh_lta from dfc.livraison_h where livh_id='$id'");
	$four=&get("select pr_four from produit,entbody where enb_cdpr=pr_cd_pr and enb_no='$entree' limit 1");
	if ($id eq ""){
		# $id=&get("select livh_id from dfc.livraison_h where livh_id<20 and livh_four='$four'");
		# &save("insert ignore into dfc.livraison_b select $id,enb_cdpr,enb_quantite/100,enb_quantite/100,enb_quantite/100,0 from entbody where enb_no='$entree'","aff"),
		# &save("update enthead set enh_document='$id' where enh_no='$entree'","aff");
	}
	print "<tr><td>$im7</td><td>$lta</td><td>$entree $four</td><td>$id</td><td>$lta_trouve</td><td>";
	$query="select livh_id from dfc.livraison_h where livh_lta='$lta'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($livh_id)=$sth2->fetchrow_array){
		print "$livh_id ";
	}
	print "</td></tr>";
	
}
print "</table>";

