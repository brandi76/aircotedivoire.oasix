#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src"; 
print "1 Trimestre 2015<br>";
print "<table border=1><tr><tH>Position</th><th>Qte sortie</th><th>Valeur</th></tr>";
$query="select pr_douane,es_qte/100,pr_prac*es_qte/10000 from enso,produit where es_dt>='2015-01-01' and es_dt<='2015-03-31' and es_cd_pr=pr_cd_pr order by pr_douane";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_douane,$qte,$val)=$sth->fetchrow_array){
    if ($pr_douane ne $run){
      if ($total_qte!=0){
	$total_qte=int($total_qte);
	$total_val2=int($total_val*659/1000)*1000;
 	if ($total_val*659%1000>499){$total_val2+=500;}
	print "<tr><td>$run</td><td align=right>$total_qte</td><td align=right>$total_val2</td></tr>";
      }
      $run=$pr_douane;
      $total_qte=0;
      $total_val=0;
    }
     $total_qte+=$qte;
     $total_val+=$val;
}
if ($total_qte!=0){
  $total_qte=int($total_qte);
  $total_val2=int($total_val*659/1000)*1000;
  if ($total_val*659%1000>499){$total_val2+=500;}
  print "<tr><td>$run</td><td align=right>$total_qte</td><td align=right>$total_val2</td></tr>";
}
print "</table>";

