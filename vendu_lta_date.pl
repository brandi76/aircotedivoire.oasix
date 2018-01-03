#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");

if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}
	
print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	<link type="text/css" href="http://tool.oasix.fr/css/humanity/jquery-ui-1.9.1.custom.css" rel="stylesheet" />	
	<script type="text/javascript" src="http://tool.oasix.fr/js/jquery-1.4.4.min.js"></script>
	<script type="text/javascript" src="http://tool.oasix.fr/js/jquery-fr.js"></script>
	<script type="text/javascript" src="http://tool.oasix.fr/js/jquery-ui-1.8.7.custom.min.js"></script>
	<script type="text/javascript">
	$(function() {
		$( "#datepicker" ).datepicker();
		$( "#datepicker2" ).datepicker();
	});
	</script>
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

if ($action eq ""){
  print "<form>";
  &form_hidden();
  print "<br> <br>Premiere date incluse (AAAA-MM-JJ)<input id=\"datepicker\" type=text name=firstdate size=12>";
  print "<br> <br>Derniere date incluse (AAAA-MM-JJ)<input id=\"datepicker2\" type=text name=lastdate size=12>";
  print "<br> <input type=hidden name=action value=go><br><input type=submit value='envoie'></form>";
}

if ($action eq "go"){
	$premier=&get("select min(v_code) from vol where  v_rot=1 and  v_date_sql>='$firstdate'");
	$dernier=&get("select max(v_code) from vol where  v_rot=1 and v_date_sql<='$lastdate'","af");
	print "Mouvement du $firstdate au $lastdate bon d'appro $premier au $dernier<br>";
	&save("create temporary table lta_tmp (code_douane int(10),lta varchar(30),id int(8),no_entree int(8),qte int(6),primary key (code_douane,lta))");
	$query="select es_cd_pr,es_qte_en/100,es_no_do,enh_document from enso,enthead where es_dt>='$firstdate' and es_dt<='$lastdate' and es_no_do=enh_no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_cd_pr,$es_qte,$es_no_do,$enh_document)=$sth->fetchrow_array){
		$ndp=&get("select pr_douane from produit where pr_cd_pr='$es_cd_pr'");
		if ($ndp eq ""){
			$pr_desi=&get("select pr_desi from produit where pr_cd_pr='$es_cd_pr'");
			print "$es_cd_pr $pr_desi<br>";
		}	
		$lta=&get("select livh_lta from dfc.livraison_h where livh_id='$enh_document'");
		&save("insert ignore into lta_tmp values ('$ndp','$lta','$enh_document','$es_no_do',0)");
		&save("update lta_tmp set qte=qte+$es_qte where code_douane='$ndp' and lta='$lta'");
	}	
	$code_douane_run=-1;
	$query="select * from lta_tmp order by code_douane,lta";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code_douane,$lta,$id,$no_entree,$qte)=$sth->fetchrow_array){
		if ($code_douane ne $code_douane_run){
			if ($code_douane_run!=-1){
				print "Total entrés :$total_entree<br>";
				print "<span style=color:navy>Produits sorties (bons $premier au bon $dernier):</span>";
				$sortie=&get("select sum(ro_qte)/100 from rotation,vol,produit where v_code=ro_code and v_rot=1 and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and ro_cd_pr=pr_cd_pr and pr_douane='$code_douane_run'")+0;
				# $sortie=$total_entree;
				print "$sortie";
				if ($sortie>=$total_entree){print " <span style=color:red>Apurée</span>";}
				print "<br>";
				$total_entree=0;
				# print "Solde produit au 31/12/$annee_1:";
				# $solde=$total_entree-$sortie;
				# $total_entree=0;
				# print "$solde<br>";
			}
			print "<div><h3>code_douane:$code_douane</h3>";
			$chap_desi=&get("select chap_desi from chapitre where chap_douane='$code_douane'");
			print "<div style=background-color:lightyellow>$chap_desi</div>";
			print "</div>";
			print "<span style=color:navy>Produits entrés:</span><br>";
			$code_douane_run=$code_douane;
		}
		$date=&get("select livh_date from dfc.livraison_h where livh_id='$id'");
		print "entrée no:$no_entree lta:$lta du $date :$qte<br>";
		$total_entree+=$qte;
	}	
	print "Total entrés :$total_entree<br>";
	print "<span style=color:navy>Produits sorties (bons $premier au bon $dernier):</span>";
	$sortie=&get("select sum(ro_qte) from rotation,vol,produit where v_code=ro_code and v_rot=1 and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and ro_cd_pr=pr_cd_pr and pr_douane='$code_douane_run'")+0;
	# $sortie=$total_entree;
	print "$sortie";
	if ($sortie>=$total_entree){print " <span style=color:red>Apurée</span>";}
	print "<br>";
	print "		
			</div>
		</div>
	</div>";
}	
