
print "<title>Passager</title>";
print "<center><div class=titrefixe> Constitution du fichier passager<br></div>";
require("./src/connect.src");
$action=$html->param("action");
$appro=$html->param("appro");
$nb=$html->param("nb");

if ($action eq "modifier"){
    $compt=0;
    $query="select v_code,v_rot from vol where v_code >=$appro order by v_code,v_rot limit $nb";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($v_code,$v_rot)=$sth->fetchrow_array){
      $v_pax=$html->param("$compt");
      &save("update vol set v_pax='$v_pax' where v_code='$v_code' and v_rot='$v_rot'");
      $compt++;
    }
    $action="voir";
}

if ($action eq "voir"){
    if ($nb eq "") {$nb=10;}
    if ($nb >50){$nb=50;}
    print "<form>";
    require ("./src/form_hidden.src");
    $compt=0;
    $query="select v_code,v_rot,v_dest,v_vol,v_date,v_pax from vol where v_code >=$appro order by v_code,v_rot limit $nb";
    $sth=$dbh->prepare($query);
    $sth->execute();
    print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Appro</th><th>Rotation</th><th>Trajet</th><th>Date</th><th>Vol</th><th>Passagers</th></tr>";
    while (($v_code,$v_rot,$v_dest,$v_vol,$v_date,$v_pax)=$sth->fetchrow_array){
      $v_pax+=0;
      print "<tr><td>$v_code</td><td>$v_rot</td><td>$v_dest</td><td>$v_date</td><td>$v_vol</td>";
      print "<td><input type=text name=$compt value='$v_pax' size=3 onchange=document.getElementById(\"mess\").style.display=\"block\"></td></tr>";
      $compt++;
    }
    print "</table>";
    print "<input type=hidden name=action value=modifier>";
    print "<input type=hidden name=appro value='$appro'>";
    print "<input type=hidden name=nb value='$nb'>";
    print "<input type=submit value=valider>";
    print "</form>";
    print "<div id=mess style=color:red;display:none>Valider pour prendre en compte la saisie</div>";
}
    
if ($action eq ""){
	print "<form>";
	$color="white";
	require ("./src/form_hidden.src");
	$onglet+=0;
	$sous_onglet+=0;
	$sous_sous_onglet+=0;
	print "Premier numero d'appro <input type=text name=appro><br>";
	print "Nombre d'appro à afficher <input type=text name=nb value=10 size=2><br>";
	print "<input type=hidden name=action value=voir>";
	print "<input type=submit>";
	print "</form>";
}		

;1
