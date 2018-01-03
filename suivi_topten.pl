#!/usr/bin/perl
# #!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require("./src/connect.src");
$query="select pr_cd_pr,pr_desi,pr_stre,pr_prac from produit where pr_acquit=1";
$sth=$dbh->prepare($query);
$sth->execute();
while (($pr_cd_pr,$pr_desi,$pr_stre,$pr_prac)=$sth->fetchrow_array){
	%stock=&stock($pr_cd_pr,'',"quick");
	$stck=$stock{"pr_stre"};
	$valeur[0]+=$stck*$pr_prac/100;
	print "$pr_cd_pr,$pr_desi,$stck<br>";
	for ($i=7;$i<200;$i=$i+7){
		$mvt=&get("select sum(es_qte_en-es_qte)/100 from enso where es_cd_pr='$pr_cd_pr 'and datediff(curdate(),es_dt)<$i")+0;
		$valeur[$i]+=$mvt;
	}	
 } 
 print "$valeur[0]<br>";
 for ($i=7;$i<200;$i=$i+7){
	$val=$valeur[$i]+$valeur[0];
	$date=&get("select date_sub(curdate(),interval $i day)");
	print "$date $val<br>";
}	
