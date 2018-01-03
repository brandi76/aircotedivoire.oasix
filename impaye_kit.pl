$code=$html->param("code");
$rot=$html->param("rot");
$mont=$html->param("mont");

if ($action eq "go"){
	$query="select v_vol,v_date_sql from vol where v_code='$code' and v_rot='$rot'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($v_vol,$v_date_sql)=$sth->fetchrow_array;
    if ($v_vol eq ""){print "<p style=background:pink>Vol inconu</p>";$action="";}
	if ($mont<=0){print "<p style=background:pink>Montant invalide</p>";$action="";}
	$ca_cb=&get("select ca_cb from caissesql where ca_code='$code' and ca_rot='$rot'")+0;
	if ($ca_cb <$mont){print "<p style=background:pink>Montant superieur au montant cb encaissé</p>";$action="";}
	if ($action eq "go"){
		&save("update caissesql  set ca_cb=ca_cb-$mont,ca_total=ca_total-$mont where ca_code='$code' and ca_rot='$rot'","")+0;
		# &save("update caisse  set ca_fly=ca_fly-($mont*100) where ca_code='$code' and ca_rot='$rot'","check")+0;
		print "<br>Modification effectuée<br>";
		$action="";
	}
}	
	

if ($action eq ""){
    print "<h3>Cb impayé</h3>";
	print "<form>";
	&form_hidden();
	print "<div class=form-group>";
	print "Code appro <input type=text name=code value='$code' class=form-control><br><br>"; 	
	print "Rotation <input type=text name=rot value=1 size=2 class=form-control><br><br>"; 	
	print "Montant <input type=text name=mont class=form-control><br><br>"; 	
	print "<input type=hidden name=action value=go>";
	print "<input type=submit>";
	print "</div>";
	print "</form>";
}
;1