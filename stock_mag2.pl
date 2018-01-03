#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
require "./src/connect.src";
$query="select lot_nolot from lot where lot_flag=1 order by lot_nolot desc";
my ($sth)=$dbh->prepare($query);
$sth->execute();
while (($lot_nolot)=$sth->fetchrow_array){
	if (grep /$lot_nolot/,@ancien){next;}
	push(@lot,$lot_nolot);
}

$query="select pr_cd_pr,pr_desi,pr_prac/100,pr_four from produit ,mag where pr_prac>0 and pr_prac<30000000 and mag='LeMag27' and code=pr_cd_pr order by pr_cd_pr";
$sth=$dbh->prepare($query);
$sth->execute();
print "stock comptable <br>";
print "<table><tr><th>code</th><th>désignation</th><th>qte</th><th>prix achat</th><th>valeur</th></tr>";
while (($pr_cd_pr,$pr_desi,$pr_prac,$four)=$sth->fetchrow_array)
{
		($fo_nom,$fo_minicde,$fo_delai)=&get("select fo2_add,fo_minicde,fo2_delai from fournis where fo2_cd_fo='$four'");
		%stock=&stock($pr_cd_pr,'',"quick");
		&algo();
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$ideal</td><td align=right>$pr_prac</td><td align=right>$stock</td></tr>";
}
print "</table>";
=pod
print "<b>total:$total_gen</b>";
    print "pick:$pick<br>";
      print "stock:$stock<br>";
      print "vendu:$vendu<br>";
      print "ideal:$ideal<br>";
      print "vendu_freq:$vendu_freq<br>";
      print "pick sup stock:$pick_sup_stck<br>";
      print "presence:$presence<br>";
      print "en cde:$encde (";
	  foreach(@listeacde){print "$_ ";}
	  print ")<br>";
      print "a_cde:$a_cde<br>";
      print "rupture:$rupture<br>";
      print "sera_vendu:$sera_vendu<br>";
      print "arrive_dans:$arrive_dans<br>";
      print "proposition:$proposition<br>";
=cut	  
  

sub algo{
	$pick=$stock=$vendu=$ideal=$pick_sup_stck=$presence=$encde=$a_cde=$rupture=$sera_vendu=$arrive_dans=$proposition=$color=$color2=$color3="";
	if ($fo_delai==0){$fo_delai=21;}
	$freq=14;
	$packing=&get("select car_carton from carton where car_cd_pr='$pr_cd_pr'")+0;
	$pick=&get("select max(pi_qte) from pick where pi_cd_pr='$pr_cd_pr' and pi_date > DATE_SUB(now(),INTERVAL 15 DAY)")+0;
	%stock=&stock($pr_cd_pr,'','quick');
	$stock=$stock{"pr_stre"};
	$pick_sup_stck="non";
	if ($stock<$pick){$pick_sup_stck="oui";}
	$vendu=0;
	$sub=0;
	%lot_vendu=();
	foreach $lot_nolot (@lot){
		$lot_nolotm10=$lot_nolot-10;
		$qte=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;
		$qte+=&get("select sum(ret_qte-ret_retour) from non_sai,retoursql,vol where ret_cd_pr=$pr_cd_pr and ret_code=v_code and ns_code=ret_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<$fo_delai","af")+0;
		# si stock > pick -> qte = vente 21 jours 
		# si stock < pick -> qte = MAX( vente  21 jours, vente 90 jours/4)
		if ($pick_sup_stck eq "oui") {
			$qte2_sup_qte="non";
			$qte2=&get("select sum(ro_qte)/100 from rotation,vol where ro_cd_pr=$pr_cd_pr and ro_code=v_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90")+0;
			$qte2+=&get("select sum(ret_qte-ret_retour) from non_sai,retoursql,vol where ret_cd_pr=$pr_cd_pr and ret_code=v_code and ns_code=ret_code and v_rot=1 and (v_troltype='$lot_nolot' or v_troltype='$lot_nolotm10') and datediff(curdate(),v_date_sql)<90","af")+0;
			$qte2=$qte2*$fo_delai/90;
			$qte2=int($qte2);
			if ($qte2>$qte){$qte=$qte2;$qte2_sup_qte="oui";}
		}
		$ratio=$ratiot{$lot_nolot};
		if ($ratio==0){$ratio=1;}
		if ($noratio eq "on"){$ratio=1;}
		$qtenew=int($qte*$ratio);
		$vendu+=$qtenew;
		$lot_vendu{$lot_nolot}="$qtenew:$qte2_sup_qte";
	}
	$presence=&get("select max(datediff (curdate(),pi_date)) from pick where pi_cd_pr=$pr_cd_pr and datediff (curdate(),pi_date)<=30");
	if ($presence==0){$presence=1}
	$new=0;
	if ($presence<21){
		$vendu=int($vendu*21/$presence);
		$new=1;
	}
	$vendu_jour=$vendu/21;
	$temps_traitement=10;
	$temps_transport=10;
	$securite=&get("select securite from top where code='$pr_cd_pr'")+0;
	$rytme=14;
	$ideal=($temps_traitement+$temps_transport+$securite+$rytme)*$vendu_jour;
	$encde=0;
	@listeacde=();
	$query="select com2_no,com2_qte/100,com2_no_liv from commande,commande_info where com2_cd_pr='$pr_cd_pr' and etat>-1 and com_no=com2_no";
	$sth4=$dbh->prepare($query);
	$sth4->execute();
	while (($com2_no,$com2_qte,$com2_no_liv)=$sth4->fetchrow_array){
		if ($com2_no_liv >0){
			$com2_qte=&get("select livb_qte_liv from dfc.livraison_b where livb_id='$com2_no_liv' and livb_code='$pr_cd_pr'")+0;
		}
		$encde+=$com2_qte;
		push(@listeacde,$com2_no);
	}
	$arrive_dans="";
	$sera_vendu=0;
	$a_cde="non";
	$rupture="non";
	$la_plus_ancienne=&get("select min(date) from commande_info,commande where com_no=com2_no and com2_cd_pr='$pr_cd_pr' and etat>-1");
	$arrive_dans=$fo_delai;
	if ($la_plus_ancienne ne ""){
		$arrive_dans=$fo_delai-&get("select datediff(curdate(),'$la_plus_ancienne')");
		$livh_date_lta=&get("select livh_date_lta from commande_info,commande,dfc.livraison_h where date='$la_plus_ancienne' and com_no=com2_no and com2_cd_pr='$pr_cd_pr' and com2_no_liv=livh_id");
		if (($livh_date_lta ne "")&&($livh_date_lta ne "0000-00-00")){$arrive_dans=3-&get("select datediff(curdate(),'$livh_date_lta')");}
		if ($arrive_dans<0){$arrive_dans=0;}
	}  
	$sera_vendu=$vendu*($arrive_dans)/$fo_delai;
	$sera_vendu_freq=$vendu*($arrive_dans+$freq)/$fo_delai;
	$sera_vendu=int($sera_vendu);
	$sera_vendu_freq=int($sera_vendu_freq);
	if (($stock-$pick)<$sera_vendu){$rupture="oui";}
	if ((($stock-$pick+$encde)<$sera_vendu_freq)){$a_cde="oui";}
	if ((($stock-$pick+$encde)>=$sera_vendu)){$a_cde="non";}
	# modifier le 06/07/2017 remplace <$sera_vendu car ça ne me semble pas logique
	$proposition=$ideal-$stock-$encde;
	if (($packing >0)&&($proposition> $packing*70/100)){
		$proposition2=int($proposition/$packing)*$packing;
		if ($proposition%$packing!=0){$proposition2+=$packing;}
		$proposition=$proposition2;
	}
	if ($proposition<0){$proposition=0;}
	if (($proposition>0)&&($proposition<3)){$proposition=3;}
	if (($proposition<$packing)&&($new==1)){$proposition=$packing;}
}
