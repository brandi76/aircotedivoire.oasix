$dbh_un = DBI->connect("DBI:mysql:host=195.114.27.208:database=camairco;","web","admin",{'RaiseError' => 1});
$dbh_bis = DBI->connect("DBI:mysql:host=195.114.27.208:database=togo;","web","admin",{'RaiseError' => 1});
$dbh_ter = DBI->connect("DBI:mysql:host=195.114.27.208:database=aircotedivoire;","web","admin",{'RaiseError' => 1});

print "
	<link type=\"text/css\" href=\"http://togo.oasix.fr/js/jquery-ui-1.8.7.custom.css\" rel=\"stylesheet\" />	
	<script type=\"text/javascript\" src=\"http://togo.oasix.fr/js/jquery-1.4.4.min.js\"></script>
	<script type=\"text/javascript\" src=\"http://togo.oasix.fr/js/jquery-fr.js\"></script>
	<script type=\"text/javascript\" src=\"http://togo.oasix.fr/js/jquery-ui-1.8.7.custom.min.js\"></script>
	<script type=\"text/javascript\">
		jQuery( function()
	{
		jQuery('#date-picker').datePicker().val(new Date().asString()).trigger('change');
	}
);

</script>";

	
$four=$html->param("four");
$famille=$html->param("famille");
$action=$html->param("action");
if ($four eq ""){$four="pr_four";}
if ($famille eq ""){$famille="produit_plus.pr_famille";}
print "<center>";
if ($action eq ""){
	print "<div class=titre>Statistique des entr�es</div><br>";
	print "<form>";
	require ("form_hidden.src");
        print "<br>Fournisseur<br><select name=four><option value=''></option>";
	$sth2 = $dbh->prepare("select fo2_cd_fo,fo2_add from fournis,produit where pr_four=fo2_cd_fo group by fo2_cd_fo");
	$sth2->execute;
	while (my @four = $sth2->fetchrow_array) {
		next if $four eq $four[0];
		($four[1])=split(/\*/,$four[1]);
		print "<option value=\"$four[0]\">$four[0] $four[1]\n";
	}
	
	print "</select>";
        print "<br>Famille<br><select name=famille><option value=''></option>";
	 $query="select fa_id,fa_desi from famille where fa_desi not like '' order by fa_id";
	$sth2 = $dbh->prepare($query);
	$sth2->execute;
	while (my @famille = $sth2->fetchrow_array) {
		print "<option value=\"$famille[0]\">$famille[1]\n";
	}
	
	print "</select>";

	print "<br><br>Premiere date ";
	&select_date("premiere");
	print "<br><br>Derniere date ";
	&select_date("derniere");
	print "<br><br><input type=hidden name=action value=go><input type=submit value='Statistique'></form><br><br>"; 
}
else {
	$jour=$html->param("premieredatejour");
	$mois=$html->param("premieredatemois");
	$an=$html->param("premieredatean");
	$prem=$jour."-".$mois."-".$an;
	$premiere=&nb_jour("$jour","$mois","$an");
	$jour=$html->param("dernieredatejour");
	$mois=$html->param("dernieredatemois");
	$an=$html->param("dernieredatean");
	$derniere=&nb_jour("$jour","$mois","$an");
	$dern=$jour."-".$mois."-".$an;
	
	$add=&get("select fo2_add from fournis where fo2_cd_fo='$four'");
	($add)=split(/\*/,$add);
	print "<div class=titre>$four $add periode $prem $dern</div><br>";
	&save("create temporary table if not exists table_entree (`no` int(10),`base` varchar(20),`pr_cd_pr` bigint(16),`pr_desi` varchar(40),`date` varchar(10),`qte` decimal(8,2),`val` decimal (8,2))","af"	);
	
	if ($base_dbh eq "dfc"){
	push(@bases_client,"corsica");
	foreach $client (@bases_client) {
		if ($client eq "dfc"){next;}
		$query="select enh_no,pr_four,produit.pr_cd_pr,pr_desi,enh_date,enb_quantite/100,pr_prac/100 from $client.entbody,$client.produit,$client.enthead,$client.produit_plus where enb_cdpr=produit.pr_cd_pr and enh_no=enb_no and pr_four=$four and produit_plus.pr_famille=$famille and produit_plus.pr_cd_pr=produit.pr_cd_pr and enh_date>='$premiere' and enh_date<='$derniere' order by enb_cdpr "; 
		# print $query;
		$sth=$dbh_un->prepare($query);
		$sth->execute();
		while (($no,$pr_four,$pr_cd_pr,$pr_desi,$enh_date,$qte,$prac)=$sth->fetchrow_array){
			  $date=&julian($enh_date);
			  $total=$prac*$qte;
			  &save("insert into table_entree value ('$no','$client','$pr_cd_pr','$pr_desi','$date','$qte','$total')");
		}
	}	
	}
	else 
	{
		$query="select enh_no,pr_four,produit.pr_cd_pr,pr_desi,enh_date,enb_quantite/100,pr_prac/100 from entbody,produit,enthead,produit_plus where enb_cdpr=produit.pr_cd_pr and enh_no=enb_no and pr_four=$four and produit_plus.pr_famille=$famille and produit_plus.pr_cd_pr=produit.pr_cd_pr and enh_date>='$premiere' and enh_date<='$derniere' order by enb_cdpr "; 
		# print $query;
		$sth=$dbh_un->prepare($query);
		$sth->execute();
		while (($no,$pr_four,$pr_cd_pr,$pr_desi,$enh_date,$qte,$prac)=$sth->fetchrow_array){
			  $date=&julian($enh_date);
			  $total=$prac*$qte;
			  &save("insert into table_entree value ('$no','$base_dbh','$pr_cd_pr','$pr_desi','$date','$qte','$total')");
		}
	}
	$query="select no,base,pr_cd_pr,pr_desi,date,qte,val from table_entree order by pr_cd_pr,no"; 
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "<table border=1 cellspacing=0>";
	print "<tr><th>no ent</th><th>Base</th><th colspan=2>Produit</th><th>Date</th><th>Qte</th><th>Val Achat</th></tr>";
	$total=0;
	$tamp=0;
	while (($no,$base,$pr_cd_pr,$pr_desi,$date,$qte,$val)=$sth->fetchrow_array){
		if (($pr_cd_pr != $tamp)&&($total !=0)){
			print &ligne_tab("","&nbsp;","&nbsp;","&nbsp;","&nbsp;","<b>Total:</b>","<b>$total</b>","<b>$ca</b>");
			$totalf+=$total;
			$caf+=$ca;
			$ca=0;
			$total=0;
		}
		$qte+=0;
		print &ligne_tab("",$no,$base,$pr_cd_pr,$pr_desi,$date,$qte,$val);
		$total+=$qte;
		$ca+=$val;
		$tamp=$pr_cd_pr;
	}
	if (($pr_cd_pr != $tamp)&&($total !=0)){
		print &ligne_tab(""," "," "," "," ","<b>Total:</b>","<b>$total</b>","<b>$ca</b>");
		$totalf+=$total;
		$caf+=$ca;
		
	}

	print "</table>";
	print "Quantit� total:$totalf Montant:$caf";
}
;1	
# -E statistique des entr�es  06/11	
