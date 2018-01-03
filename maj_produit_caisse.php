<?php
header("Access-Control-Allow-Origin: *");
error_reporting(E_ALL);
$bdd=mysqli_connect('195.114.27.208','web','admin','aircotedivoire');
$query="SELECT pr_cd_pr,pr_desi,tr_prix,pr_famille FROM trolley,produit,produit_plus where tr_code=2511 and tr_cd_pr=produit.pr_cd_pr and produit_plus.pr_cd_pr=produit.pr_cd_pr";
echo $query;
$result = mysqli_query($bdd,$query);
$outp="";
while ($row = mysqli_fetch_array($result)){
	$pr_cd_pr=$row['pr_cd_pr'];
	$pr_desi=$row['pr_desi'];
	$pr_prx_vte=$row['tr_prix'];
	$pr_famille=$row['pr_famille'];
	if ($pr_famille=6 || $pr_famille=7){$famille="Bijouterie";}
	if ($pr_famille=21 || $pr_famille=19){$famille="Accessoires";}
	if ($pr_famille=1 ||$pr_famille=10){$famille="Parfums Femmes";}
	if ($pr_famille=3){$famille="Parfums Hommes";}
	if ($pr_famille=2 || $pr_famille=8 ){$famille="Coffrets Parfums";}
	if ($pr_famille=5){$famille="Comestiques";}
	if ($pr_famille=4){$famille="Montres";}
	
	$pr_remise=0;
	if ($outp == ""){$outp = '[{"pr_cd_pr":"'.$pr_cd_pr.'","pr_desi":"'.$pr_desi.'","pr_prx_vte":'.$pr_prx_vte.',"pr_remise":'.$pr_remise.',"pr_famille":'.$pr_famille.'}';}
	else{
		$outp .= ',{"pr_cd_pr":"'.$pr_cd_pr.'","pr_desi":"'.$pr_desi.'","pr_prx_vte":'.$pr_prx_vte.',"pr_remise":'.$pr_remise.',"pr_famille":'.$pr_famille.'}';	
	}
}
$outp.=']';
echo "$outp";
?> 
