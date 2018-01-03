#!/usr/bin/perl
use CGI;
use DBI;

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;
require "./src/connect.src";

$dev="XOF";
&check();
# $dev="EUR";
# &check();
# $dev="USD";
# &check();

sub check(){
	$query="select no,montant from bordereau where devise='$dev' and no >'200000' and montant>0 order by no";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no,$montant_bor)=$sth->fetchrow_array){
		$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
		$total_xof=$total_xaf=$total_dol=$total_eur=$total_stim=$total_cb=0;
		$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ca_code,$ca_rot,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth2->fetchrow_array){
			$date_vol=&get("select v_date from vol where v_code=$ca_code and v_rot=$ca_rot");
			$date_vol=&date(&daten($date_vol));
			$date_vol="20".$date_vol;
			$date_vol=~s/\//-/g;
			# print "$no $ca_code $ca_rot $date_vol";
			$ecart=&get("select datediff('$date_vol','$date_ref_debut')")+0;
			#print " $ecart";
			#print "<br>";
			if ($ecart <0){next;}
			($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
			($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
			($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
			($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
			$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
			$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
			$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
			$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
			$total_cb+=$ca_cab;
			$total_stim+=$ca_papi;
		}
		$montant=0;
		if ($dev eq "XAF") { $montant=$total_xaf;}
		if ($dev eq "XOF") { $montant=$total_xof;}
		if ($dev eq "USD") { $montant=$total_dol;}
		if ($dev eq "EUR") { $montant=$total_eur;}
		if ($montant_bor != $montant){
		    $ecartt+=$montant-$montant_bor;
	
		    print "$no;$dev;$montant_bor;$montant;<br>";
		    &save("update bordereau set montant='$montant',montantdev='$montant' where devise='XOF' and no='$no'","aff");
		}
      }
      print "$ecartt";
}