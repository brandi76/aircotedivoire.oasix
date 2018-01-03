$fo2_cd_fo=$html->param("fo2_cd_fo");
$recherche=$html->param("recherche");
$option=$html->param("option");

print "<style>";
print "
.modifier
	{
		background-image:url('/images/b_edit.png');
		background-repeat:no-repeat;
		border:0;
		cursor:pointer;
	}
	";
print "</style>";

if ($action eq "modif"){
    $query="select fa_id,fa_desi from famille order by fa_id";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($fa_id,$fa_desi)=$sth->fetchrow_array){
	$prix_v=$html->param("prix_v$fa_id");
	$prix_p=$html->param("prix_p$fa_id");
	&save("replace into mag_pub values('$fo2_cd_fo','V','$fa_id','$prix_v')","ff");
	&save("replace into mag_pub values('$fo2_cd_fo','P','$fa_id','$prix_p')","ff");
    }	    
    $action="visu";
}
if ($action eq "modifier"){
    $prix_v=$html->param("prix_v");
    $prix_p=$html->param("prix_p");
    $query="select fa_id,fa_desi from famille order by fa_id";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($fa_id,$fa_desi)=$sth->fetchrow_array){
# 	print "$fa_id $prix_v ",$html->param("$fa_id")," <br>";
	if (($prix_v ne "")&&($html->param("$fa_id") eq "on")){
	  &save("replace into mag_pub values('$fo2_cd_fo','V','$fa_id','$prix_v')","af");
	 }
	if (($prix_v ne "")&&($html->param("$fa_id") eq "on")){
	  &save("replace into mag_pub values('$fo2_cd_fo','P','$fa_id','$prix_p')","ff");
	}
    }	    
    $action="visu";
}

if (($action eq "")||(($action eq "visu") && ($recherche ne ""))){
	print "<form>";
	require ("form_hidden.src");
	print "Code fournisseur <input type=text name=fo2_cd_fo size=16><br>";
	print "<br>recherche <input type=text name=recherche size=16><br>";
	print "<input type=hidden name=action value=visu><br>";
	print "<input type=submit class=bouton value=envoie> <br>";
	print "<br><table border=1 cellspacing=0><tr><th>Code fournis</th><th>Désignation</th></tr>";
	$query="select fo2_cd_fo from fournis limit 0";
	if ($recherche ne ""){
		  $query="select fo2_cd_fo,fo2_add from fournis where fo2_add like \"%$recherche%\" order by fo2_cd_fo";
	}
	else {
	    $query="select fo2_cd_fo,fo2_add from fournis order by fo2_add";
	}
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fo2_cd_fo,$fo2_add)=$sth->fetchrow_array){
		print "<tR><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=visu>$fo2_cd_fo</a></td><td><font color=$color>$fo2_add</td></tR>"
	}
	print "</table><br>";
	print "</form>";
	$action="";
}		
if ($action eq "visu"){
	print "Gratuité, mettre le prix en négatif<br>";
	$query="select * from fournis where fo2_cd_fo='$fo2_cd_fo'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($null,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email,$fo_delai_pai,$fo_mode_pai,$fo_iban,$fo_bic)=$sth->fetchrow_array;
	($nom,$rue,$ville)=split(/\*/,$fo2_add);
	print "<div class=titre>$fo2_cd_fo $nom</div>";
		print "<form>";
	$color="white";
	require ("./src/form_hidden.src");
	$onglet+=0;
	$sous_onglet+=0;
	$sous_sous_onglet+=0;

	print "<table border=1 cellspacing=0><tr><th>libelle</th><th>Visuel</th><th>Pub</th><th colspan=2>Action</th></tr>";
	$query="select fa_id,fa_desi from famille order by fa_id";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$check="";
	if ($option eq "coche"){$check="checked";}
	while (($fa_id,$fa_desi)=$sth->fetchrow_array){
		print "<tR bgcolor=$color><td>$fa_desi</td>";
		$prix_v=&get("select prix from mag_pub where four='$fo2_cd_fo' and type='V' and famille='$fa_id'")+0;
		$prix_p=&get("select prix from mag_pub where four='$fo2_cd_fo' and type='P' and famille='$fa_id'")+0;
		print "<td align=right><input type=text name=prix_v$fa_id value=$prix_v size=3 Onchange=this.style.backgroundColor=\"pink\";></td><td align=right><input type=text name=prix_p$fa_id value=$prix_p size=3 Onchange=this.style.backgroundColor=\"pink\";></td>";
		print "<td align=right><input type=checkbox name=$fa_id $check></td>";
		print "<td><input type=submit value=\"\" onclick=this.form.action.value=\"modif\"; class=modifier ></td>";
	}	
	print "</table><br>";
	print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=visu&option=coche>Tout cocher</a> / ";
	print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&fo2_cd_fo=$fo2_cd_fo&action=visu&option=decoche>Tout décocher</a>";
	print "<br>Pour la selection mettre le prix du visuel à:";
	print "<input type=text name=prix_v size=3><br>";
	print "Pour la selection mettre le prix du la pub à:";
	print "<input type=text name=prix_p size=3>";
	print "<input type=hidden name=action value=modifier>";
	print "<input type=hidden name=fo2_cd_fo value=$fo2_cd_fo>";
	print "<br><input type=submit value=modifier>";
	print "</form></html>";

}		
	
;1