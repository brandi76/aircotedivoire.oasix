#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
require "./src/connect.src";

$query="select pr_cd_pr,pr_desi,pr_prac/100,ecart,casse from produit,inventaire where pr_cd_pr=code and date='2014-09-17'";
$sth=$dbh->prepare($query);
$sth->execute();
print "<table border=1 cellspacing=0><tr><th></th><th></th><th>Prix achat</th><th>Ecart</th><th>Valeur</th><th>Casse</th><th>Valeur</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_prac,$ecart,$casse)=$sth->fetchrow_array)
{	
      if (($casse==0) && ($ecart==0)){next;}
      $pr_prac=int($pr_prac*100)/100;
	$val=$pr_prac*$ecart;
	$val2=$pr_prac*$casse;
	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$pr_prac</td><td align=right>$ecart</td><td align=right>$val</td><td align=right>$casse</td><td align=right>$val2</td></tr>";
	$total+=$val;
	$total2+=$val2;
}
print "<tr><td colspan=3>Total</td><td align=right>$total</td><td>&nbsp;</td><td align=right>$total2</td></tr>";
print "</table>";


