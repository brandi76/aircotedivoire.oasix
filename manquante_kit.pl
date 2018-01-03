$code=$html->param("code");
$rot=$html->param("rot");
$montant=$html->param("montant");

if ($action eq "go"){
	&save("replace into manquante values ('$code','$rot','$montant')","af");
	print "<p style=background:lightgreen>Mise a jour effectuee</p>";
	$action="";
}

if ($action eq ""){
	print "<form>";
	&form_hidden();
	print "Code <input type=text name=code ><br><br>"; 	
	print "Rotation <input type=text name=rot  size=2><br><br>";
	print "Montant <input  type=text name=montant> <br><br>";
 	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</form>";
}
;1