#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

 print  "SUBJECT:fiche solde du stock soci�t� IBS france\n";

print   "Content-type: text/html\n\n";
print   "<html><body>";


require "./src/connect.src";
&detail();
 close();



sub detail {
	$query="select pr_cd_pr,pr_desi,pr_prac/100,pr_ventil from produit where (pr_type=1 or pr_type=5  or pr_ventil=15 or pr_ventil=16 or pr_cd_pr=1223935 or pr_cd_pr=120185 or pr_cd_pr=120170 or pr_cd_pr=120040 or pr_cd_pr=1223076 or pr_cd_pr=1221370 or pr_cd_pr=1222845 or pr_cd_pr=1220068 or pr_cd_pr=1225490 or pr_cd_pr=1225488 or pr_cd_pr=1222945 or pr_cd_pr=260615 or pr_cd_pr=1219970 or pr_cd_pr=120920 or pr_cd_pr=1222851 or pr_cd_pr=1221470 or pr_cd_pr=1222845 or pr_cd_pr=1225488 or pr_cd_pr=400095 or pr_cd_pr=1220700 or pr_cd_pr=1221086 or pr_cd_pr=1221082 or pr_cd_pr=198029 or pr_cd_pr=1220644 or pr_cd_pr=120054) and pr_cd_pr!=1231050 and pr_cd_pr!=1242613 order by pr_ventil,pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$totalgen=0;
	print   " <h3>Soci�t� Ibs France </h3><br><br>stock au ";
	print   `date`;
	print   "<br><table border=1 cellspacing=0 cellpadding=1><tr><th>Code</th><th>produit</th><th>qte</th><th>prix</th><th>total</th></tr>\n";
	while (($pr_cd_pr,$pr_desi,$pr_prac,$pr_ventil)=$sth->fetchrow_array)
	{
		if ($pr_ventil != $ventil){
			$ventil=$pr_ventil;
			if ($ventil==6){ print "<tr><th colspan=5 align=left>Alcool Fort</th></tr>";}
			if ($ventil==3){ print "<tr><th colspan=5 align=left>Alcool Doux</th></tr>";}
			if ($ventil==15){ print "<tr><th colspan=5 align=left>Cigarette</th></tr>";}
			if ($ventil==16){ print "<tr><th colspan=5 align=left>Cigare</th></tr>";}
			if ($ventil==20){ print "<tr><th colspan=5 align=left>Parfum</th></tr>";}
			if ($ventil==21){ print "<tr><th colspan=5 align=left>Cosmetique</th></tr>";}
	
	}

		if ($pr_prac==0){next;}
		%stock=&stock($pr_cd_pr,'',"");
		# $stck=$stock{"pr_stre"};
		$stck=$stock{"stock"}+0;
	
		if ($stck<=0){next;}
		
		$total=$stck*$pr_prac+0;
		$total_gen+=$total;
		print  "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right><nobr> ";
		&carton($pr_cd_pr,$stck);
		print "</td><td align=right>$pr_prac</td><td align=right>";
		print  &deci($total,2,0);
		print  "</td></tr>\n";
	}
	print   "<tr><th>total</th><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td><td align=right>";
	print   &deci($total_gen,2,0);
	print   "</td></tr>\n</table>";
}


sub journal {
	print  "<center><h1>FICHE SOLDE DU STOCK</h1><br><br>\n";
	print  "Veuillez trouver ci-joint la fiche solde du stock du jour<br>\n";

	$datesimple=`/bin/date +%Y%m%d`;
	$query="select sum(es_qte*pr_prac)/10000 from enso,produit where es_dt=$datesimple and pr_cd_pr=es_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$entree=int($sth->fetchrow_array);
	$query="select pr_cd_pr,pr_desi,pr_prac/100 from produit where (pr_type=1 or pr_type=5) and pr_sup=0 order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute;
	$totalgen=0;
	while (($pr_cd_pr,$pr_desi,$pr_prac)=$sth->fetchrow_array)
	{
		%stock=&stock($pr_cd_pr,'',"");
		$stck=$stock{"stock"};
	
		if ($stck==0){next;}
		$total=$stck*$pr_prac;
		$total_gen+=$total;
	}
	$newstock=$total_gen;
	$sortie=$stock-$newstock+$entree;
	print    "�dition du ";
	print    `date`;
	print    "<br><br><br><table border=1 cellspacing=0 ><tr><td>Solde en debut de journ�e (j-1)</td><td align=right>$stock</td></tr>\n";
	print    "<tr><td>montant des entrees</td><td align=right>";
	print  int($entree);
	print  "</td></tr>\n";
	print    "<tr><td>montant des sorties</td><td align=right>";
	print  int($sortie);
	print  "</td></tr>\n";
	print  "<tr><td>solde en fin de journee</td><td align=right>";
	print  int($newstock);
	print  "</td></tr>\n";
	print    "<tr><td>montant du stock plancher</td><td align=right>250000</td></tr>\n";
	print    "</table>";
	print    "<br><br><br>";
	print    "Le d�l�gu� madataire<br> Mme Mouny  Mr Brandicourt<br>\n";
	print    "<br><br><br></center>Fich.Solde.St. - / -Doc. n� bis";
	$maj="ok";
	if ($maj eq "ok") {
		$query="update atad set dt_no=$newstock where dt_cd_dt=500";
		$sth=$dbh->prepare($query);
		$sth->execute;
		
	}
	print    "</body></html>";
}
