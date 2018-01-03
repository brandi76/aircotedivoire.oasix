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
	$query="select es_no_do,enh_document from enso,enthead where year(es_dt)='$annee_1' and es_no_do=enh_no group by es_no_do";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($es_no_do,$enh_document)=$sth->fetchrow_array){
		$lta=&get("select livh_lta from dfc.livraison_h where livh_id='$enh_document'");
		if ($lta eq ""){
			$four=&get("select pr_four from produit,enso where es_no_do='$es_no_do' and es_cd_pr=pr_cd_pr");
			$fo2_add=&get("select fo2_add from fournis where fo2_cd_fo='$four'");
			($nom_four)=split(/\*/,$fo2_add);
			$es_dt=&get("select es_dt from enso where es_no_do='$es_no_do'");
			print "entree no:$es_no_do du $es_dt $nom_four<br>";
		}
	}	
}


print "		
		</div>
	</div>
</div>";
