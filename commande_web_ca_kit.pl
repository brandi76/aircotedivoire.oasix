print <<EOF;
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
print "<table class=\"table table-condensed table-bordered table-striped table-hover \">";
print "<thead>";
print "<tr class=\"success\"><th>No</th><th>Nom</th><th>Prenom</th><th>Date_vol</th><th>Appro</th><th>Montant</th></tr>";
print "</thead>";
$query="select * from infocmd_web where vol_vol !='' ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($cde_id,$nom,$prenom,$reservation,$depart,$arrivee,$date_vol,$no_vol,$mail,$etat,$vol_date,$vol_vol,$blabla)=$sth->fetchrow_array){
	$fl_apcode=&get("select fl_apcode from flyhead where fl_vol='$vol_vol' and fl_date='$vol_date'");
	if ($fl_apcode eq ""){next;}
	$montant=0;
	$query="select produit_id,prep,prix from panier_web where cde_id=$cde_id";  
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	while (($pr_cd_pr,$qte,$prix)=$sth2->fetchrow_array){
		$check=&get("select ret_retour from retoursql where ret_code=$fl_apcode and ret_ordre>=1000 and ret_cd_pr='$pr_cd_pr'","af");
		if ($check eq ""){$check=-1;}
		if ($check==0){$montant+=$qte*$prix;}
	}	
	if ($montant==0){next;}
	print "<tr><td>$cde_id</td><td>$nom</td><td>$prenom</td><td>$date_vol</td><td>$fl_apcode</td><td>$montant</td></tr>";
	$total+=$montant;
}
print "<tr><td colspan=5><strong>Total</strong><td><strong>$total</strong></td></tr>";
print "</table>";	
print "</div></div>";
;1
	
