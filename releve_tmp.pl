#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
print "<style>";
print "table {display:none;}";
print "</style>";
$premiere="2014-01-01";
$derniere="2014-12-31";
print "<script>";

print "function on_off(anId)
{
	node = document.getElementById(anId);
	if (node.style.display==\"none\")
	{
		node.style.display = \"block\";
	}
	else
	{
		node.style.display = \"none\";
	}
}";
print "</script>";
print "<h4 style=background-color:lavender>Information Système</h4>";
$val_anc=&get("select montant from encaissement where date='$premiere' and devise='XOF'","af")+0;
print "Position au 31/12/2013<br>";
print "Xof:$val_anc<br>";
$total_gen+=$val_anc;
# $val_anc=&get("select montant from encaissement where date='$premiere' and devise='EUR'","af")+0;
# $montant_xof=int($val_anc*655.957);
# print "Eur:$val_anc Conversion Xof(655.957):$montant_xof<br>";
# $total_gen+=$montant_xof;
# $val_anc=&get("select montant from encaissement where date='$premiere' and devise='USD'","af")+0;
# $montant_xof=int($val_anc*480);
# print "Eur:$val_anc Conversion Xof(480):$montant_xof<br>";
# $total_gen+=$montant_xof;
print "<b>Position Au 31/12/2013:$total_gen</b><br>";
$resultat=$total_gen;
$total_gen=0;
print "<table cellspacing=0 border=1 id=1>";
print "<tr><th>Bordereau</th><th>Date creation</th><th>XOF ";
print "</th><th>Cash</th></tr>";
$query="select distinct (no) from bordereau where date_creation >='$premiere' and date_creation <='$derniere' order by no";
$sth=$dbh->prepare($query);
$sth->execute();
$dev="XOF";
while (($no)=$sth->fetchrow_array){
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

	if ($montant !=0){
		$date_bor=&get("select date_creation from bordereau where no='$no'");
		$date_remise=&get("select date_remise from bordereau where no='$no' and devise='$dev'");
		print "<tr><td>$no</td><td>$date_bor</td><td align=right>$montant</td>";
		if (($dev eq "XOF")&& ($date_remise ne "0000-00-00")){
		  $check=&get("select montant from bordereau where no='$no' and devise='$dev'")+0;
		  $cash=&get("select montant from cash where bordereau='$no' and devise='$dev'")+0;
		  print "<td>$cash</td>";
		  $total_cash+=$cash;
		}
		print "</tr>";
	}
	$total_gen+=$montant;
}
print "</table>";
# print "+ Traitement de la periode XOF:$total_gen <input type=button value='detail o/n' onclick=document.getElementById(\"un\").style.display=\"block\"><br>";
print "+ Traitement de la periode XOF:$total_gen <input type=button value='detail o/n' onclick=on_off(\"1\")><br>";
$resultat+=$total_gen;
print "- Cash:$total_cash<br>";
$resultat-=$total_cash;

print "<table cellspacing=0 border=1 id=2>";
print "<tr><th>Bordereau</th><th>Date creation</th><th>EUR";
print "</th></tr>";
$total_gen=0;
$dev="EUR";
$query="select no,date_creation,ref,montant,montantdev from bordereau where devise='$dev' and date_creation >='$premiere' and date_creation <='$derniere' and (ref like \"D%\" or ref like \"E%\") and montant!=0 order by no";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no,$date_creation,$ref,$montant,$montantdev)=$sth->fetchrow_array){
	print "<tr><td>$no</td><td>$date_creation</td><td align=right>$montant</td>";
	$montant_xof=int($montant*655.957);
	print "<td>$montant_xof</td>";
	$total_gen+=$montant_xof;
	$total_euro+=$montant;
	print "</tr>";
}
print "</table>";
print "+ Montant remis euro:$total_euro Conversion Xof(655.957):$total_gen <input type=button value='detail o/n' onclick=on_off(\"2\")><br>";
$resultat+=$total_gen;
print "<table cellspacing=0 border=1 id=3>";
print "<tr><th>Bordereau</th><th>Date creation</th><th>USD";
print "</th></tr>";
$total_gen=0;
$dev="USD";
$query="select no,date_creation,ref,montant,montantdev from bordereau where devise='$dev' and date_creation >='$premiere' and date_creation <='$derniere' and (ref like \"D%\" or ref like \"E%\") and montant!=0 order by no";
$sth=$dbh->prepare($query);
$sth->execute();
while (($no,$date_creation,$ref,$montant,$montantdev)=$sth->fetchrow_array){
	print "<tr><td>$no</td><td>$date_creation</td><td align=right>$montant</td>";
	$montant_xof=int($montant*480);
	print "<td>$montant_xof</td>";
	$total_gen+=$montant_xof;
	$total_usd+=$montant;
	print "</tr>";
}
print "</table>";
print "+ Montant remis usd:$total_usd Conversion Xof(480):$total_gen <input type=button value='detail o/n' onclick=on_off(\"3\")><br>";
$resultat+=$total_gen;
$total_gen=0;
$val_anc=&get("select montant from encaissement where date='2015-01-01' and devise='XOF'","af")+0;
print "- Position au 31/12/2014:$val_anc<br>";
# print "Xof:$val_anc<br>";
$total_gen+=$val_anc;
# $val_anc=&get("select montant from encaissement where date='2015-01-01' and devise='EUR'","af")+0;
# $montant_xof=int($val_anc*655.957);
# print "Eur:$val_anc Conversion Xof(655.957):$montant_xof<br>";
# $total_gen+=$montant_xof;
# $val_anc=&get("select montant from encaissement where date='2015-01-01' and devise='USD'","af")+0;
# $montant_xof=int($val_anc*480);
# print "Eur:$val_anc Conversion Xof(480):$montant_xof<br>";
# $total_gen+=$montant_xof;
# print "- Position Au 31/12/2014:$total_gen<br>";
$resultat-=$total_gen;
print "<b>Total XOF à remettre:$resultat</b><br>";

print "<h4 style=background-color:lavender>Information Banque</h4>";
print "<table border=1 cellspacing=0 cellpadding=0 id=4><tr><th>Date</th><th>Dev</th><th>Credit</th><th>Reference</th><th>Libelle</th><th><span style=color:red>Devise</span></th></tr>";
$query="select * from releve_bq where date>='$premiere' and date<='$derniere' and montant>0 order by date";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
  print "<tr><td align=right>$date</td><td>$dev</td>";
  $debit=0;
  $credit=0;
  ($montant >0)? $credit=$montant:$debit=$montant;
  $debit=$debit*-1;
  print "<td align=right>$credit</td>";
  $total+=$credit;
  print "<td align=right>$ref</td><td align=right>$desi</td>";
  print "<td>";
  $query="select distinct(devise) from bordereau where ref like '%$ref%'";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($devise)=$sth2->fetchrow_array){
  print "$devise ";
  if ($devise eq "USD"){$total_usd+=$credit;}
  if ($devise eq "EUR"){$total_eur+=$credit;}
  
# 
#   $montant_bor=0;
#   while (($no,$devise,$date_creation,$date_remise,$ref,$montant,$montantdev)=$sth2->fetchrow_array){
#       print "$no,$devise,$date_creation,$date_remise,$ref,$montant,$montantdev";
# 	$cash=&get("select montant from cash where bordereau='$no' and devise='$devise'","af")+0;
# 	$montantdev-=$cash;
# 	if ($cash!=0){print "cash:$cash<br>";}
# 	$montant_bor+=$montantdev;
  }
  print "</td>";
  print "</tr>";
}
print "</table>";
print "<b>Total remise XOF:$total</b> <input type=button value='detail o/n' onclick=on_off(\"4\")><br>";
print "dont change EURO:$total_eur<br>";
print "dont change USD:$total_usd<br>";
$ecart=$resultat-$total;
print "XOF à justifier:$resultat - $total=$ecart<br>";


