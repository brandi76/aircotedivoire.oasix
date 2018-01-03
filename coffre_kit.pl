use Net::SMTP;

### ATTENTION DATE EF EN DURE
print "<script>";
	print "function recalcul()
	{	
	      l_10000.innerHTML=eval(document.fiche.nb_10000.value)*10000+0;
	      l_5000.innerHTML=eval(document.fiche.nb_5000.value)*5000+0;
	      l_2000.innerHTML=eval(document.fiche.nb_2000.value)*2000+0;
	      l_1000.innerHTML=eval(document.fiche.nb_1000.value)*1000+0;
	      l_500.innerHTML=eval(document.fiche.nb_500.value)*500+0;
	      l_250.innerHTML=eval(document.fiche.nb_250.value)*250+0;
	      l_200.innerHTML=eval(document.fiche.nb_200.value)*200+0;
	      l_100.innerHTML=eval(document.fiche.nb_100.value)*100+0;
	      l_50.innerHTML=eval(document.fiche.nb_50.value)*50+0;
	      l_25.innerHTML=eval(document.fiche.nb_25.value)*25+0;
	      l_20.innerHTML=eval(document.fiche.nb_20.value)*20+0;
	      l_10.innerHTML=eval(document.fiche.nb_10.value)*10+0;
	      l_5.innerHTML=eval(document.fiche.nb_5.value)*5+0;
	      l_2.innerHTML=eval(document.fiche.nb_2.value)*2+0;
	      l_1.innerHTML=eval(document.fiche.nb_1.value)*1+0;
	      document.fiche.montant.value=eval(document.fiche.nb_10000.value)*10000+eval(document.fiche.nb_5000.value)*5000+eval(document.fiche.nb_2000.value)*2000+eval(document.fiche.nb_1000.value)*1000+eval(document.fiche.nb_500.value)*500+eval(document.fiche.nb_250.value)*250+eval(document.fiche.nb_200.value)*200+eval(document.fiche.nb_100.value)*100+eval(document.fiche.nb_50.value)*50+eval(document.fiche.nb_25.value)*25+eval(document.fiche.nb_20.value)*20+eval(document.fiche.nb_10.value)*10+eval(document.fiche.nb_5.value)*5+eval(document.fiche.nb_2.value)*2+eval(document.fiche.nb_1.value);
	     
	 
	}";

print "</script>";
	
require "./src/connect.src";
$date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
# $date_ref="2013-06-30";
$date_ref="2015-01-01";

$action=$html->param("action");
$option=$html->param("option");
$montant=$html->param("montant");
$devise=$html->param("devise");
$date=$html->param("date");
if (grep(/\//,$date)) {
        ($jj,$mm,$aa)=split(/\//,$date);
        $date=$aa."-".$mm."-".$jj;
}

if ($action eq "justif"){
  $justif=&addslashes($html->param("justif"));
  $ecart=&addslashes($html->param("ecart"));
  &save("update coffre set justificatif='$justif' where date='$date' and devise='$devise'");
  $destinataire="sylvainbrandicourt\@gmail.com;goedraad\@oasix.fr";
  my $smtp = Net::SMTP->new('127.0.0.1',
				Debug => 0,
				Timeout => 30);
  $smtp->mail('info@dutyfreeconcept.com');
  $smtp->to("$destinataire");
  $smtp->data();
  $smtp->datasend("From: info\@dutyfreeconcept.com\n");
  $smtp->datasend("To: $destinataire \n");
  $smtp->datasend("Subject: ecart coffre\n");
  $smtp->datasend("$devise ecart:$ecart $justif\n");
  $smtp->datasend("\n\n");
  $smtp->dataend();
  $smtp->quit();
  
  $action="";
}

if ($action eq "go")
{ 
    $ok=1;
	if ($montant eq ""){
		print "<H3 style=color:red>Erreur  de saisie</h3>";
		$action="";
		$ok=0;
	}
	$check=&get("select count(*) from  coffre where date='$date' and devise='$devise'");
	if  ($check!=0){
		print "<H3 style=color:red>Coffre deja saisie</h3>";
		$action="";
		$ok=0;
	}
	if ($ok) {
	$query="select distinct (no) from bordereau where date_creation >='$date_ref'";
	$sth=$dbh->prepare($query);
	$sth->execute();
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
			$ecart=&get("select datediff('$date_vol','$date_ref')")+0;
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
		$total{"XOF"}+=$total_xof;
		$total{"XAF"}+=$total_xaf;
		# print "$no $total_xaf<br>";
		$total{"USD"}+=$total_dol;
		$total{"EUR"}+=$total_eur;
		

	}
	$val_anc=&get("select montant from encaissement where date='$date_ref' and devise='$devise'","af")+0;
	$val_ent=$total{"$devise"};
	$val_sor=&get("select sum(montant) from bordereau where date_remise >='$date_ref' and date_creation>'$date_ref' and devise='$devise'")+0;
	$cash_encours=&get("select sum(cash.montant) from cash,bordereau where bordereau.date_remise='0000-00-00' and cash.bordereau=bordereau.no and cash.devise=bordereau.devise and bordereau.devise='$devise'")+0;
	#cash_encours c'est le montant pris dans la caisse mais avant la remise
	$val_res=$val_anc-$val_sor+$val_ent-$cash_encours;
	$ecart=$montant-$val_res;
	$ecart_reel=$ecart;
	$ecart_enregistre=&get("select sum(ecart) from coffre where devise='$devise' and date>='$date_ref'")+0;
	$ecart-=$ecart_enregistre;
  	 # print "Ancien:$val_anc ent:$val_ent sor:$val_sor cash encours:$cash_encours reste:$val_res <br>";
  	 # print "Montant saisie:$montant $devise ecart reel:$ecart_reel ecart enregistré:$ecart_enregistre<br>";
	if ($ecart!=0){
	  &save("insert into debug (date,texte) values (now(),\"$date_ref $devise Ancien:$val_anc ent:$val_ent sor:$val_sor cash encours:$cash_encours reste:$val_res Montant saisie:$montant $devise ecart reel:$ecart_reel\")");
	  system("/var/www/cgi-bin/aircotedivoire.oasix/sendbug.pl &");
	  print "<p class=erreur>$devise Ecart $ecart $devise </p>";
	  print "<form>";
	  &form_hidden();
	  print "Justificatif ?<input type=text name=justif> <input type=submit><input type=hidden name=action value=justif><input type=hidden name=devise value=$devise>";
	  print "<input type=hidden name=ecart value=$ecart><input type=hidden name=date value=$date></form>";
	}
	
   	&save("replace into coffre value ('$date','$devise','$montant','$ecart','')");
	$action="";
}	
}

if ($action eq ""){
	print "<center><h2>Saisie du coffre</h2><br>";
	if (($user eq "sylvain")||($user eq "daniel")||($user eq "philippe")||($user eq "edwige")||($user eq "mireille")||($option eq "force")){
	print "<form name=fiche>";
	&form_hidden();
	$query="select distinct devise from bordereau where date_remise='0000-00-00'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<br>Choisir une devise <select name=devise>";
	while (($dev,$desi)=$sth->fetchrow_array)
	{
	  print "<option value=$dev>$dev $desi</option>";	
	}
	print "</select><br><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date value=$date_du_jour><br>";
	print "
		<table border=1>
			<tr><th>Nombre</th><th>Billet</th><th>Total</th></tr>
			<tr><td align=center ><input type=text value=0 name=nb_10000 size=4  Onblur=recalcul();></td><td align=center >10000</td> <td align=center ><div id=l_10000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_5000 size=4 Onblur=\"recalcul();\"></td><td align=center >5000</td> <td align=center ><div id=l_5000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_2000 size=4 Onblur=\"recalcul();\"></td><td align=center >2000</td> <td align=center ><div id=l_2000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_1000 size=4 Onblur=\"recalcul();\"></td><td align=center >1000</td> <td align=center ><div id=l_1000>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_500 size=4 Onblur=\"recalcul();\"></td><td align=center >500</td> <td align=center ><div id=l_500>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_250 size=4 Onblur=\"recalcul();\"></td><td align=center >250</td> <td align=center ><div id=l_250>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_200 size=4 Onblur=\"recalcul();\"></td><td align=center >200</td> <td align=center ><div id=l_200>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_100 size=4 Onblur=\"recalcul();\"></td><td align=center >100</td> <td align=center ><div id=l_100>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_50 size=4 Onblur=\"recalcul();\"></td><td align=center >50</td> <td align=center ><div id=l_50>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_25 size=4 Onblur=\"recalcul();\"></td><td align=center >25</td> <td align=center ><div id=l_25>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_20 size=4 Onblur=\"recalcul();\"></td><td align=center >20</td> <td align=center ><div id=l_20>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_10 size=4 Onblur=\"recalcul();\"></td><td align=center >10</td> <td align=center ><div id=l_10>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_5 size=4 Onblur=\"recalcul();\"></td><td align=center >5</td> <td align=center ><div id=l_5>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_2 size=4 Onblur=\"recalcul();\"></td><td align=center >2</td> <td align=center ><div id=l_2>0</div></td></tr>
			<tr><td align=center ><input type=text value=0 name=nb_1 size=4 Onblur=\"recalcul();\"></td><td align=center >1</td> <td align=center ><div id=l_1>0</div></td></tr>
		</table>	
	";
	print "Montant <input type=text name=montant><br>";
	print "<input type=hidden name=action value=go>";
	print "<br><input type=submit>";
	print "</form>";
	}
	print "<form>";
	&form_hidden();
	$limit=$html->param('limit');
	if ($limit eq ""){$limit=20;}
	print "<br>les <input type=text name=limit value=$limit size=2> Dernières saisies  <input type=submit value='rafraichir'><br>";
	print "<table cellspacing=0 border=1><tr><th rowspan=2>Date</th>";
	@devise=("XOF","XAF","EUR","USD");
	foreach $dev (@devise){
	  print "<th align=center colspan=2>$dev</th>";
	}
	print "</tr>";
	print "<tr>";
	foreach $dev (@devise){
	  print "<th align=right>Montant</th>";
  	  print "<th align=right>Ecart</th>";
	}
	print "</tr>";
	
	$max_date=&get("select max(date) from coffre");
	$query="select distinct(date) from coffre order by date desc limit $limit";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$color="white";
	while (($date)=$sth->fetchrow_array){
	    print "<tr bgcolor=$color><td>$date</td>";
	    foreach $dev (@devise){
	      if ($color eq "white"){$color="lavender";}else{$color="white";}
	      $ecart=&get("select ecart from coffre where date='$date' and devise='$dev'");
    	      $justificatif=&get("select justificatif from coffre where date='$date' and devise='$dev'");
	      $montant=&get("select montant from coffre where date='$date' and devise='$dev'");
	      if (($dev eq "XOF")||($dev eq "XAF")){$ecart=int($ecart);$montant=int($montant);}
	      if ($ecart eq ""){$ecart=".....";}
	      if ($montant eq ""){$montant=".....";}
	      $id=$date.$dev;
	      print "<td align=right bgcolor=$color>$montant</td><td align=right bgcolor=$color>";
	      print "<a onMouseOver=document.getElementById(\"$id\").style.display=\"block\" onMouseOut=document.getElementById(\"$id\").style.display=\"none\">$ecart</a>";
	      if ($justificatif eq ""){$justificatif="...";}
	      print "<div id=\"$id\" style=\"padding:10px;position:absolute;background-color:#ffffb1;box-shadow:2px 2px 10px gray;border:1px solid black;display:none\">$justificatif</div>";
	      print "</td>";
	    }
	    print "</tr>";
# 	    print "<tr bgcolor=$color><td>Montant</td>";
# 	    foreach $dev (@devise){
# 	      $montant=&get("select montant from coffre where date='$date' and devise='$dev'");
# 	      if (($dev eq "XOF")||($dev eq "XAF")){$montant=int($montant);}
# 	      if ($montant eq ""){$montant=".....";}
# 	      print "<td align=right>$montant</td>";
# 	    }
# 	    print "</tr>";
# 	    print "<tr bgcolor=$color><td>Justificatif</td>";
# 	    foreach $dev (@devise){
# 	      $justificatif=&get("select justificatif from coffre where date='$date' and devise='$dev'");
# 	      print "<td align=right>$justificatif</td>";
# 	    }
# 	    print "</tr>";
	}    
	print "</table>";
	print "</center>";
}	


;1
