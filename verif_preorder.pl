
$mag="lemag23";
$query="select code,pr_desi,prix,prix_xof,pr_famille from mag,produit_plus,produit where mag='$mag' and produit_plus.pr_cd_pr=code  and produit.pr_cd_pr=code";
# print $query;
$sth=$dbh->prepare($query);
$sth->execute();
while(($code,$desi,$prix,$prix_xof ,$pr_famille)=$sth->fetchrow){
	$query="select texte_f,texte_a,image_s,image_l from dfc.produit_mag where code='$code'";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($texte_f,$texte_a,$image_s,$image_l)=$sth2->fetchrow_array;
	print "$code $desi $pr_famille ";
	
	if (($pr_famille==9)||($pr_famille==22)||($pr_famille==15))
	{
		print "<span style=color:purple>Non listé categorie non retenue</span><br>";
		next;
	}
	if ($image_l eq "")
		{
		print "<span style=color:red>Non listé image manquante</span><br>";
		next;
	}
	%stock=&stock($code);
	$pr_stre=$stock{"pr_stre"};
	if ($pr_stre<5){
	print "<span style=color:green>Non listé stock trop faible</span><br>";
	next;
	}
	print "<br>";
}
;1
