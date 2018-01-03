#!/usr/bin/perl
use DBI();
use CGI();
use JSON;
#$html=new CGI;
	print $html->header(-type=>"text/plain", -Access_Control_Allow_Origin=>"*",
	-access_control_allow_headers => 'content-type,X-Requested-With',
-access_control_allow_methods => 'GET,POST,OPTIONS',
-access_control_allow_credentials => 'true',
	
	);
print "Content-type:application/json\n\n";
require "../oasix/../oasix/outils_perl2.pl";
require("./src/connect.src");

$trolley=2511;
$outp="";
&save("create temporary table ordre_temp (famille int(3),desi varchar(50),code int(10),code_court int(5))"); 
$query = "select tr_cd_pr from trolley where tr_code='$trolley'";
$sth=$dbh->prepare($query);
$sth->execute();
while (($code)=$sth->fetchrow_array){
	&famille($code);
	$desi_tpe=&get("select pr_desi from produit where pr_cd_pr='$code'");
	$desi_tpe=lc($desi_tpe);
	$desi_tpe=ucfirst($desi_tpe);
	$desi_tpe=~s/\&//g;
	&save ("insert into ordre_temp values ('$fa_cat','$desi_tpe','$code','$code_court')");
}
$query="select famille,desi,code,code_court from ordre_temp order by famille,desi";
$sth=$dbh->prepare($query);
$sth->execute();
while (($famille,$pr_desi,$code,$code_court)=$sth->fetchrow_array){
	$pr_prix=&get("select tr_prix/100 from trolley where tr_code='$trolley' and tr_cd_pr='$code'")+0; 
	$pr_prix=int($pr_prix);
	$pr_prix0=$pr_prix;
	$pr_prix1=&get("select tr_prix/100 from trolley where tr_code='$trolley2' and tr_cd_pr='$code'")+0;
	$pr_prix1=int($pr_prix1);
	if ($pr_prix1==0){
			$pr_prix1=int($pr_prix*$cours_xof/1000)*1000;
	}
	$pr_cd_pr=$code;
	$pr_prx_vte=$pr_prix0;
	$pr_remise=$pr_prix1;
    $pr_desi=~s/\"//;
	$pr_desi=~s/\'//;
	$pr_desi=~s/\://;
	$pr_desi=~s/\.//;
	$pr_desi=~s/\{//;
	$pr_desi=~s/\}//;
	$pr_desi=~s/\]//;
	$pr_desi=~s/\[//;
	$pr_desi=~s/\n//;
	if ($outp eq ""){$outp = '[{"pr_cd_pr":"'.$pr_cd_pr.'","pr_desi":"'.$pr_desi.'","pr_prx_vte":'.$pr_prx_vte.',"pr_remise":'.$pr_remise.'}';}
	else{
		$outp .= ',{"pr_cd_pr":"'.$pr_cd_pr.'","pr_desi":"'.$pr_desi.'","pr_prx_vte":'.$pr_prx_vte.',"pr_remise":'.$pr_remise.'}';	
	}
}
$outp.=']';
