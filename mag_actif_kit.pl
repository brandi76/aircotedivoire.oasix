if ($action eq "go"){
	$mag=$html->param("mag");
	$mag_anc=$html->param("mag_anc");
	&save("update mag_run set mag_actif='$mag',mag_ancien='$mag_anc'");
}

($mag,$mag_anc)=&get("select mag_actif,mag_ancien from mag_run");
print "<h3>Mag actif en cours $mag Mag ancien:$mag_anc</h3>";
print "<form>";
print "Choisir le  magazine actif<br>";
&form_hidden();
print "<select name=mag>";
$query = "select distinct mag from mag order by mag desc ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($mag)=$sth->fetchrow_array){
	print "<option value=$mag>$mag</option>";
}
print "</select ><br>";
print "Choisir le  magazine precedent<br>";
&form_hidden();
print "<select name=mag_anc>";
$query = "select distinct mag from mag order by mag desc ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($mag)=$sth->fetchrow_array){
		print "<option value=$mag>$mag</option>";
}
print "</select><br><input type=submit>";
print "<input type=hidden name=action value=go>";
print "</form>";
;1

