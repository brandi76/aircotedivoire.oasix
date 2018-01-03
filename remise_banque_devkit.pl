print "<title>Gestion des bordereaux de remise en banque</title>";

require "./src/connect.src";
$dev=$html->param("dev");
$no=$html->param("no");
$action=$html->param("action");
$montant=$html->param("montant");
$montantdev=$html->param("montantdev");
$dev=$html->param("dev");
$ref=$html->param("ref");
$ref=~s/'//g;
$date_remise=$html->param("date_remise");
if (grep(/\//,$date_remise)) {
        ($jj,$mm,$aa)=split(/\//,$date_remise);
        $date_remise=$aa."-".$mm."-".$jj;
}
print "<center>";
if ($action eq "go")
{
	$ok=1;
	if ($dev eq $base_dev1){
		$query="select no from bordereau where date_remise='0000-00-00' and devise='$dev' order by no";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$bon=0;
		while (($no)=$sth->fetchrow_array){
			if ($html->param("$no") eq "on"){$bon=1;}
		}
		if ($bon==0){ print "<p class=erreur>Merci de choisir au moins un bordereau</p>";$ok=0;}
	}
	if ($date_remise eq ""){ print "<p class=erreur>Merci de mettre une date</p>";$ok=0;}
	if (($montant eq "")&&($dev ne $base_dev1)){ print "<p class=erreur>Merci de mettre un montant</p>";$ok=0;}
	if (($dev eq "USD")&&($montantdev eq "")){ print "<p class=erreur>Merci de mettre une contre valeur </p>";$ok=0;}
	$action="phase1";
	if (($dev ne $base_dev1)&&($ok==1)){
		$no=&get("select max(no) from bordereau ")+1;
		if ($no==1){$no=1000;}
		if ($dev eq "EUR"){ $montantdev=$montant*655;}
		if ($dev eq $base_dev2){ $montantdev=$montant;}
		&save("insert into bordereau value ('$no','$dev','$date_remise','$date_remise','$ref','$montant','$montantdev')");
		print "Remise no: $no pour un montant de $montantdev $base_dev1 Enregistr�e<br>";
		$ok=0;
		$action="";
	}
	if (($dev eq $base_dev1)&&($ok==1)){
		$query="select no from bordereau where date_remise='0000-00-00' and devise='$dev' order by no";
		$sth=$dbh->prepare($query);
		$sth->execute();
		$total=0;
		while (($no)=$sth->fetchrow_array){
			if ($html->param("$no") eq "on"){
				#$montant=&montant_bordereau("$no",$base_dev1)+0;
				$montant=$html->param("mont_$no")+0;
				$lib=$html->param("lib_$no");
				$montantdev=$montant;
				&save("update bordereau set montant='$montant',montantdev='$montantdev',date_remise='$date_remise',ref='$lib' where no='$no' and devise='$dev'");
				print "Bordereau $no pour un montant de $montant Enregistr�<br>";
				$total+=$montant;
			}
		}
		print "<b>Total:$total $base_dev1</b><br>";
		$action="";
	}
}
if ($action eq ""){
	print "<h2>Gestion des remise en banque</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	$query="select distinct devise from bordereau where date_remise='0000-00-00' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "Choisir une devise<br>";	
	print "<select name=dev>";
	while (($dev)=$sth->fetchrow_array)
	{
		print "<option value=$dev>$dev</option>";	
	}
	print "</select><br>";
	print "<input type=hidden name=action value=phase1>";
	print "<br><input type=submit>";
	print "</form>";
}

if ($action eq "in_cash"){
    $montant_cash=$html->param("montant_cash");
    $date_cash=$html->param("date_cash");
    if (grep(/\//,$date_cash)) {
	    ($jj,$mm,$aa)=split(/\//,$date_cash);
	    $date_cash=$aa."-".$mm."-".$jj;
    }

    $destination_cash=&addslashes($html->param("destination_cash"));
    if ($montant_cash==0){
	 &save("delete from cash where bordereau='$no' and devise='$dev' limit 1");
    }
    else {
      &save("replace into cash value ('$no','$dev','$date_cash','$montant_cash','$destination_cash')");
    }
    
    $action="phase1";
    
}

if ($action eq "cash"){
    print "<div class=titre>Bordereau no:$no</div>";
    print "<form style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
    &form_hidden();
    $query="select date,montant,destination from cash where bordereau='$no' and devise='$dev'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($date_cash,$montant_cash,$destination_cash)=$sth->fetchrow_array;
    print "<div style=float:left;width:150px;>Montant</div><input type=text name=montant_cash value='$montant_cash'>XOF<br>";
    print "<div style=float:left;width:150px;>Date</div><input type=text id=datepicker name=date_cash value='$date_cash'><br>";
    print "<div style=float:left;width:150px;>Destination</div><input type=text name=destination_cash size=30 value='$destination_cash'><br>";
    print "<input type=hidden name=action value=in_cash>";
    print "<input type=hidden name=dev value='$dev'>";
    print "<input type=hidden name=no value='$no'>";
    print "<input type=submit>";
    print "</form>";
    print "<form style=margin-top:100px;>";
    &form_hidden();
    print "<input type=hidden name=action value=phase1>";
    print "<input type=hidden name=dev value='$dev'>";
    print "<input type=submit value=retour>";
    print "</form>";
}    

if (($action eq "phase1")&&($dev eq $base_dev1)){
	print "<script>";
	print "function recalcul() {";
	print "var total_selection=0;";
	print "var total_remise=0;";
	print " for (var i=5;i<document.maform.length-5;i=i+3){
		//alert(document.maform.elements[i].value);
		if (document.maform.elements[i].checked==true){
			total_selection=eval(document.maform.elements[i-1].value)+total_selection;
		}
	}";
	print "total_remise=total_selection-eval(document.maform.montant_cash.value);";
	
	print "document.getElementById('total_remise').innerHTML=total_remise;";
	print "document.getElementById('total_selection').innerHTML=total_selection;";

	print "}";
	print "</script>";
	print "<h2>Gestion des remise en banque $dev (d)</h2><br>";
	print "<form name=maform method=POST>";
	require ("form_hidden.src");
	$query="select no from bordereau where date_remise='0000-00-00'  and devise='$dev' order by no";
	# $query="select no,montant from bordereau where devise='$dev' order by no";
	# attention 180772 c'est a partir de celui la que le togo a �t� ger� par daniel 
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "Choisir les bordereaux concern�s</br>";	
	print "<table border=1 cellspacing=0><tr><th>Bordereau</th><th>Montant</th><th> </th></tr>";
	$total=0;
	$total_selection=0;
	$total_remise=0;
	while (($no,$montant_rem)=$sth->fetchrow_array)
	{
		$montant=&montant_bordereau("$no",$base_dev1);
		$montant_prop=$montant-$montant_rem;
		if ($montant_prop==0){next;}
		if ($dev eq "XOF"){$cash=&get("select montant from cash where bordereau='$no' and devise='$dev'")+0;}
		# $montant_prop=$montant-$cash;}
		if ($montant ==0){next;}
		print "<tr><td>$no</td><td align=right><input type=hidden name=hid_$no value=$montant >$montant</td><td><input type=checkbox name=$no onchange=recalcul()>";
# 		print "</td><td><input type=text name=mont_$no value=$montant_prop size=5 onchange=recalcul()></td><td><input type=text name=lib_$no size=20>";
# 		if ($dev eq "XOF"){
# 		  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=cash&no=$no&dev=$dev>cash";
# 		  if ($cash !=0){print "($cash)";}
# 		  print "</a>";
# 		}
		print "</td></tr>";	
		$total+=$montant;
	}
	print "</table>";
	# print "Reference banque - justificatif  <input type=text name=ref size=20><br>";
	print "<br>Montant en attente de remise:$total<br><br>";
	print "Montant selectionn�:<span id=total_selection>$total_selection</span><br><br>";
	print "Pr�levement cash (XOF) <input type=text name=montant_cash value='$montant_cash' size=6 onchange=recalcul()> ";
	print "Destination <input type=text name=destination_cash size=30 value='$destination_cash'><br><br>";
	print "<b>Total de la remise:<span id=total_remise>$total_remise</span></b><br><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=hidden name=dev value='$dev'>";
	print "<br><input type=submit>";
	print "</form>";
}
if (($action eq "phase1")&&($dev eq "EUR")){
	print "<h2>Gestion des remise en banque $dev (a)</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	print "Montant EUR <input type=text name=montant ><br>";
	print "Reference banque - justificatif  <input type=text name=ref size=20><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=hidden name=dev value='$dev'>";
	print "<br><input type=submit>";
	print "</form>";
}
if (($action eq "phase1")&&($dev eq "USD")){
	print "<h2>Gestion des remise en banque $dev (b)</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	print "Montant USD <input type=text name=montant ><br>";
	print "Conre valeur $base_dev1 <input type=text name=montantdev ><br>";
	print "Reference banque - justificatif  <input type=text name=ref size=20><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=hidden name=dev value='$dev'>";
	print "<br><input type=submit>";
	print "</form>";
}
if (($action eq "phase1")&&($dev eq $base_dev2)){
	print "<h2>Gestion des remise en banque $dev (c)</h2><br>";
	print "<form>";
	require ("form_hidden.src");
	print "Montant $base_dev2 <input type=text name=montant ><br>";
	print "Reference banque - justificatif  <input type=text name=ref size=20><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br>";
	print "<input type=hidden name=action value=go>";
	print "<input type=hidden name=dev value='$dev'>";
	print "<br><input type=submit>";
	print "</form>";
}

sub montant_bordereau{
	my $no=$_[0];
	$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
	my $sth=$dbh->prepare($query);
	$sth->execute();
	my $total_xof,$total_dol,$total_eur,$total_stim,$total_stim,$total_cb=0;
	while (($ca_code,$ca_rot,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth->fetchrow_array){
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
	my $montant=0;
	if ($_[1] eq $base_dev2) { $montant=$total_xaf;}
	if ($_[1] eq $base_dev1) { $montant=$total_xof;}
	if ($_[1] eq "USD") { $montant=$total_dol;}
	if ($_[1] eq "EUR") { $montant=$total_eur;}
	my($cash)=0;
	# if ($_[1] eq "XOF") {$cash=&get("select montant from cash where bordereau='$no'")+0;$montant-=$cash;}
	return($montant);
}

;1
