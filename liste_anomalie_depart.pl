#!/usr/bin/perl	
use CGI;
use DBI();
use Math::Round;
$html=new CGI;
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$query="select ecartrol_arch.*,v_troltype from ecartrol_arch,vol where ecr_qte!=0 and ecr_stock!=0 and ecr_appro=v_code and datediff(curdate(),v_date_sql)<2 order by ecr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
$pass=0;
while (($ecr_appro,$ecr_cd_pr,$ecr_qte,$ecr_stock,$v_troltype)=$sth->fetchrow_array){
	$pr_desi=&get("select pr_desi from produit where pr_cd_pr=$ecr_cd_pr");
	if ($pr_desi ne $desi_run){
		print "<h4>$ecr_cd_pr $pr_desi </h4>";
		$desi_run=$pr_desi;
	}	
	$prevu=&get("select tr_qte from trolley where tr_code=$v_troltype and tr_cd_pr=$ecr_cd_pr")+0;
	$prevu/=100;
	$ecr_qte/=100;
	print "appro:$ecr_appro qte trolley standard:$prevu qte mise à bord:$ecr_qte qte en stock:$ecr_stock<br>";
}	
