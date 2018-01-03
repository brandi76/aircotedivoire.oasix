#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require("./src/connect.src");
require "../oasix/outils_perl2.pl";
$html=new CGI;
print $html->header();
$action=$html->param("action");
	
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

</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF

if ($action eq ""){
	$annee=&get("select year(curdate())");
	$annee_1=$annee-1;
	$premier=&get("select min(v_code) from vol where  v_rot=1 and year(v_date_sql)=$annee_1");
	$dernier=&get("select max(v_code) from vol where  v_rot=1 and year(v_date_sql)=$annee_1");
	

	&save("create temporary table lta_tmp (code_douane int(10),lta varchar(30),id int(8),no_entree int(8),qte int(6),primary key (code_douane,lta))");
	$query="select es_cd_pr,es_qte_en/100,es_no_do,enh_document from enso,enthead where year(es_dt)='$annee_1' and es_no_do=enh_no";
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
				print "Total entrés $annee_1:$total_entree<br>";
				print "<span style=color:navy>Produits sorties (bons $premier au bon $dernier):</span>";
				#$sortie=&get("select sum(ro_qte)/100 from rotation,vol,produit where v_code=ro_code and v_rot=1 and year(v_date_sql)=$annee_1 and ro_cd_pr=pr_cd_pr and pr_douane='$code_douane_run'")+0;
				$sortie=$total_entree;
				print "$sortie<br>";
				print "Solde produit au 31/12/$annee_1:";
				$solde=$total_entree-$sortie;
				$total_entree=0;
				print "$solde<br>";
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
	print "Total entrés $annee_1:$total_entree<br>";
	print "<span style=color:navy>Produits sorties (bons $premier au bon $dernier):</span>";
	# $sortie=&get("select sum(ro_qte) from rotation,vol,produit where v_code=ro_code and v_rot=1 and year(v_date_sql)=$annee_1 and ro_cd_pr=pr_cd_pr and pr_douane='$code_douane_run'")+0;
	$sortie=$total_entree;
	print "$sortie<br>";
	print "Solde produit au 31/12/$annee-1:";
	$solde=$total_entree-$sortie;
	print "$solde<br>";
	
	# &save("create temporary table table_ranking (ind int(3),mois int(2),marque varchar(30),qte int(8),qte_1 int(8),ca int(8),ca_1 int(8), primary key (ind,mois))");
	# $query="select livh_id,livh_lta,livh_date from dfc.livraison_h where year(livh_date)=2015";
	# $sth=$dbh->prepare($query);
	# $sth->execute();
	# while (($livh_id,$livh_lta,$livh_date)=$sth->fetchrow_array){
		# print "$livh_date $livh_lta<br>";
	# }
}
=pod	
	print "<table class=\"table table-condensed table-bordered table-hover \">";
	print "<thead>";
	print "<tr>";
	print "<td colspan=24><h4>RANKING QTE PAR MARQUE DE LA FAMILLE DES PARFUMS Annee $annee</h4></td>";
	print "</tr>";
	print "<tr style=font-size:0.8em class=\"info\">";
	for ($i=1;$i<13;$i++){
		print "<th colspan=5>";
		print &cal($i,'l');
		print "</th>";
	}	
	print "<th colspan=5>Total</th>";
	print "</tr>";
	print "<tr style=font-size:0.8em class=\"info\">";
	for ($i=1;$i<14;$i++){
		print "<th style=font-size:0.6em>Marques</th><th>Qte</th><th>Qte N-1</th><th>%</th><th>N/N-1</th>";
	}	
	print "</tr>";
	print "</thead>";
	for ($i=1;$i<13;$i++){
		$j=0;
		$query="select marque,qte,qte_1,ca,ca_1 from stat_marque where mois=$i order by qte desc";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($marque,$qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array){
			$j++;
			&save("insert into table_ranking values ('$j','$i','$marque','$qte','$qte_1','$ca','$ca_1')");
	    }
	}
	$j=0;
	$query="select marque,sum(qte),sum(qte_1),sum(ca),sum(ca_1) from stat_marque where mois<13 group by marque order by qte desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($marque,$qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array){
		$j++;
		&save("insert into table_ranking values ('$j','13','$marque','$qte','$qte_1','$ca','$ca_1')");
	}

	for ($j=1;$j<=$nb_marque;$j++){
		print "<tr>";
		$query="select mois,marque,qte,qte_1,ca,ca_1 from table_ranking where ind=$j order by mois";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($mois,$marque,$qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array){
			$marque=uc($marque);
			$color="";
			if (($mois%2)==1){$color="lightyellow";}
			print "<td style=background-color:$color;font-size:0.8em>$marque</td><td align=right style=background-color:$color;>$qte</td>";
			print "<td style=background-color:$color; align=right>$qte_1</td>";
			$z=$y=0;
			if ($qte_1>0){$z=int(10*$qte/$qte_1)/10;$y=int(100*($qte-$qte_1)/$qte_1);}	
			print "<td style=background-color:$color; align=right>$y</td>";
			print "<td style=background-color:$color; align=right>$z</td>";
		}
		print "</tr>";
	}
	print "<tr>";
	for ($i=1;$i<14;$i++){
		$query="select sum(qte),sum(qte_1),sum(ca),sum(ca_1) from table_ranking where mois=$i";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array;
		$color="";
		if (($mois%2)==1){$color="lightyellow";}
		print "<td style=background-color:$color;font-size:0.8em>Total</td><td align=right style=background-color:$color;>$qte</td>";
		print "<td style=background-color:$color; align=right>$qte_1</td>";
		$z=$y=0;
		if ($qte_1>0){$z=int(10*$qte/$qte_1)/10;$y=int(100*($qte-$qte_1)/$qte_1);}	
		print "<td style=background-color:$color; align=right>$y</td>";
		print "<td style=background-color:$color; align=right>$z</td>";
	}	
	print "</tr>";
	print "</table>";

	print "<table class=\"table table-condensed table-bordered table-hover \">";
	print "<thead>";
	print "<tr>";
	print "<td colspan=24><h4>RANKING CA PAR MARQUE DE LA FAMILLE DES PARFUMS Annee $annee</h4></td>";
	print "</tr>";
	print "<tr style=font-size:0.8em class=\"info\">";
	for ($i=1;$i<13;$i++){
		print "<th colspan=5>";
		print &cal($i,'l');
		print "</th>";
	}	
	print "<th colspan=5>Total</th>";
	print "</tr>";
	print "<tr style=font-size:0.8em class=\"info\">";
	for ($i=1;$i<14;$i++){
		print "<th style=font-size:0.6em>Marques</th><th>CA</th><th>CA N-1</th><th>%</th><th>N/N-1</th>";
	}	
	print "</tr>";
	print "</thead>";
	&save("truncate table  table_ranking");
	for ($i=1;$i<13;$i++){
		$j=0;
		$query="select marque,qte,qte_1,ca,ca_1 from stat_marque where mois=$i order by ca desc";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($marque,$qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array){
			$j++;
			&save("insert into table_ranking values ('$j','$i','$marque','$qte','$qte_1','$ca','$ca_1')");
	    }
	}
	$j=0;
	$query="select marque,sum(qte),sum(qte_1),sum(ca),sum(ca_1) from stat_marque where mois<13 group by marque order by ca desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($marque,$qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array){
		$j++;
		&save("insert into table_ranking values ('$j','13','$marque','$qte','$qte_1','$ca','$ca_1')");
	}

	for ($j=1;$j<=$nb_marque;$j++){
		print "<tr>";
		$query="select mois,marque,qte,qte_1,ca,ca_1 from table_ranking where ind=$j order by mois";
		$sth=$dbh->prepare($query);
		$sth->execute();
		while (($mois,$marque,$qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array){
			$color="";
			$marque=uc($marque);
			if (($mois%2)==1){$color="lightyellow";}
			print "<td style=background-color:$color;font-size:0.8em>$marque</td><td align=right style=background-color:$color;>$ca</td>";
			print "<td style=background-color:$color; align=right>$ca_1</td>";
			$z=$y=0;
			if ($ca_1>0){$z=int(10*$ca/$ca_1)/10;$y=int(100*($ca-$ca_1)/$ca_1);}	
			print "<td style=background-color:$color; align=right>$y</td>";
			print "<td style=background-color:$color; align=right>$z</td>";
		}
		print "</tr>";
	}
	print "<tr>";
	for ($i=1;$i<14;$i++){
		$query="select sum(qte),sum(qte_1),sum(ca),sum(ca_1) from table_ranking where mois=$i";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($qte,$qte_1,$ca,$ca_1)=$sth->fetchrow_array;
		$color="";
		if (($mois%2)==1){$color="lightyellow";}
		print "<td style=background-color:$color;font-size:0.8em>Total</td><td align=right style=background-color:$color;>$qte</td>";
		print "<td style=background-color:$color; align=right>$qte_1</td>";
		$z=$y=0;
		if ($qte_1>0){$z=int(10*$qte/$qte_1)/10;$y=int(100*($qte-$qte_1)/$qte_1);}	
		print "<td style=background-color:$color; align=right>$y</td>";
		print "<td style=background-color:$color; align=right>$z</td>";
	}	
	print "</tr>";
		
	print "</table>";

	
	
}
print "		
		</div>
	</div>
</div>";
