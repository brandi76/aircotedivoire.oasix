use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
print "<title>Liste commande Pre_order</title>";
$no_cde=$html->param("no_cde");
$code=$html->param("code");
$qte=$html->param("qte");
$prix=$html->param("prix");
$fl_date=$html->param("fl_date");
$fl_vol=$html->param("fl_vol");


if ($action eq "mod"){
	&save("replace into panier_web values ('$no_cde','$code','$qte','$prix','')");
	$action="voir";
}
if ($action eq "del"){
	# à forcer dans la barre d'adresse
	&save("update infocmd_web set etat='Sup' where cde_id='$no_cde'");
	$action="voir";
}
	
if ($action eq "affecte"){
	&save("update infocmd_web set vol_date='$fl_date',vol_vol='$fl_vol' where cde_id='$no_cde'");
	$action="voir";
}	
if ($action eq "desaffecte"){
	&save("update infocmd_web set vol_date='',vol_vol='' where cde_id='$no_cde'");
	$action="voir";
}	

if ($action eq ""){
	print "<table>";
	print "<tr><th>No</th><th>Nom</th><th>Prenom</th><th>Reservation</th><th>Depart</th><th>Arrivee</th><th>Date_vol</th><th>No_vol</th><th>Affectation</th><th>Action</th></tr>";
	$query="select * from infocmd_web where datediff(date_vol,curdate())>-2000 and etat!='Sup' order by cde_id desc limit 50";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cde_id,$nom,$prenom,$reservation,$depart,$arrivee,$date_vol,$no_vol,$mail,$etat,$vol_date,$vol_vol,$blabla)=$sth->fetchrow_array){
		print "<tr><td>$cde_id</td><td>$nom</td><td>$prenom</td><td>$reservation</td><td>$depart</td><td>$arrivee</td><td>$date_vol</td><td>$no_vol</td><td align=center>";
		if ($vol_vol ne ""){
			$fl_apcode=&get("select fl_apcode from flyhead where fl_vol='$vol_vol' and fl_date='$vol_date'");
			if ($fl_apcode>0){print $fl_apcode;}else{print "<img src=/images/check.png>";}
		}	
		else{print "<img src=/images/checkr.png>";}
		print "</td><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&no_cde=$cde_id&action=voir>Voir</a></td></tr>";
	}
	print "</tr>";
	print "</table>";
}
if ($action eq "voir"){
	print "<table border=1 cellspacing=0><tr><th colspan=2>Produit</th><th>Qte</th><th>Prix</th><th>Total</th><th>Stock</th></tr>";
	$query="select * from infocmd_web where cde_id='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cde_id,$nom,$prenom,$reservation,$depart,$arrivee,$date_vol,$no_vol,$mail,$etat,$vol_date,$vol_vol,$blabla,$date_saisie)=$sth->fetchrow_array;
	$reglement_bancaire=&get("select trans_id from infopay_web where cde_id='$no_cde'");
	print "No cde:$cde_id<br>Nom:$nom<br>Prenom:$prenom<br>Reservation:$reservation<br>Depart:$depart<br>Arrivée:$arrivee<br>Date:$date_vol<br>";
	print "No vol:$no_vol<br>Date de saisie:$date_saisie<br>$blabla<br>";
	if ($reglement_bancaire ne ""){
	print "<br><strong>Reglé en ligne par carte bancaire, no de transaction:$reglement_bancaire</strong><br>";}
	$query="select pr_cd_pr,pr_desi,qte,prix from produit,panier_web where pr_cd_pr=produit_id and cde_id='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$qte,$prix)=$sth->fetchrow_array){
		$total=$qte*$prix;
		%stock=&stock($pr_cd_pr);
		$pr_stre=$stock{"stock"};
		print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td align=right>$qte</td><td align=right>$prix</td><td align=right>$total</td><td align=right>$pr_stre</td></tr>";
	}
	print "</table>";
	print "<form>";
	&form_hidden();
	print "Code <input name=code><br>";
	print "Qte <input name=qte><br>";
	print "Prix <input name=prix><br>";
	print "<input type=hidden name=action value=mod>";
	print "<input type=hidden name=no_cde value='$no_cde'>";
	print "<input type=submit>";
	print "</form>";
	if ($vol_date==0){
		print "<table>";
		$query="select fl_date,fl_vol,fl_date_sql from flyhead where fl_date_sql>=curdate() and fl_apcode='0' order by fl_date_sql limit 100";
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		# print "$query<br>";
		while (($fl_date,$fl_vol,$fl_date_sql)=$sth->fetchrow_array){
			$parcours="";
			$query="select flb_arrivee,flb_triret,flb_datetr from flybody where flb_date='$fl_date' and flb_vol='$fl_vol' order by flb_rot";
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			while (($arrivee,$triret,$datetr)=$sth2->fetchrow_array){
				$parcours=$parcours."/".$triret;
				$flb_arrivee=$arrivee;
				$flb_triret=$triret;
				$flb_datetr=$datetr;
			}
			print "<tr><td>$fl_date_sql</td><td>$fl_vol</td><td>$parcours</td><td><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&no_cde=$cde_id&action=affecte&fl_date=$fl_date&fl_vol=$fl_vol>Affecter</a></td></tr>";
		}
		print "</table>";
	}
	else {
	 	$query="select fl_date,fl_vol,fl_date_sql,fl_apcode from flyhead where fl_date='$vol_date' and fl_vol='$vol_vol'";
		# print $query;
		$sth=$dbh->prepare($query);
		$sth->execute();
		($fl_date,$fl_vol,$fl_date_sql,$fl_apcode)=$sth->fetchrow_array;
		$parcours="";
		$query="select flb_arrivee,flb_triret,flb_datetr from flybody where flb_date='$fl_date' and flb_vol='$fl_vol' order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($arrivee,$triret,$datetr)=$sth2->fetchrow_array){
			$parcours=$parcours."/".$triret;
			$flb_arrivee=$arrivee;
			$flb_triret=$triret;
			$flb_datetr=$datetr;
		}	
		print "Commande affectée au vol :$fl_vol $parcours du $fl_date_sql ";
		if ($fl_apcode!=0){print "Appro:$fl_apcode";}
		else {print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&no_cde=$cde_id&action=desaffecte>Sup</a>";}
		print "<br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=pdf&no_cde=$no_cde>Document d'accompagnement</a>";
	}
}
############ PDF ###########

if ($action eq "pdf"){
	$index=0;
	$chemin="/var/www/$base_rep/doc/";
	$nom_pdf="pre_order_$no_cde.pdf";
	$file="$chemin$nom_pdf";;
	if (-f $file){unlink ($file);}
	$pdf = PDF::API2->new(-file => $file);
	%font = (Helvetica => {Bold   => $pdf->corefont( 'Helvetica-Bold',-encoding => 'latin1' ),Roman=> $pdf->corefont( 'Helvetica',-encoding => 'latin1' ),});
    $page[$index] = $pdf->page();
    $page[$index]->mediabox('A4');
    $texte = $page[$index]->text;
    $texte->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	$image = $page[$index]->gfx;
	$image_file = $pdf->image_png('./logo_dfc.png');
	$image->image( $image_file, 20/mm, 270/mm, 110/2, 83/2 );
	$image->image( $image_file);
    $texte->fillcolor('black');
	$ligne=260;
    $texte->translate( 20/mm, $ligne/mm );
    $texte->text("Vente à bord Pre-order");
	$query="select * from infocmd_web where cde_id='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($cde_id,$nom,$prenom,$reservation,$depart,$arrivee,$date_vol,$no_vol,$mail,$etat,$vol_date,$vol_vol)=$sth->fetchrow_array;
	$ligne-=5;
	$texte->translate( 20/mm, $ligne/mm );
	$texte->text("No cde:$cde_id");
	$ligne-=5;
	$texte->translate( 20/mm, $ligne/mm );
	$texte->text("Nom:$nom Prenom:$prenom");
	$ligne-=5;
	$texte->translate( 20/mm, $ligne/mm );
	$texte->text("Depart:$depart >Arrivée:$arrivee Date:$date_vol No vol:$no_vol");
	$ligne-=20;
	$query="select pr_cd_pr,pr_desi,qte,prix from produit,panier_web where pr_cd_pr=produit_id and cde_id='$no_cde'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$total=0;
	while (($pr_cd_pr,$pr_desi,$qte,$prix)=$sth->fetchrow_array){
		%stock=&stock($pr_cd_pr);
		$pr_stre=$stock{"stock"};
		$texte->translate( 20/mm, $ligne/mm );
		$texte->text("$pr_cd_pr $pr_desi");
		$texte->translate( 130/mm, $ligne/mm );
		$texte->text("$qte");
		$texte->translate( 160/mm, $ligne/mm );
		$texte->text("$prix");
		$montant=$prix*$qte;
		$texte->translate( 190/mm, $ligne/mm );
		$texte->text("$montant");
		$ligne-=5;
		$total+=$montant;
	}
	$ligne-=5;
	$texte->translate( 130/mm, $ligne/mm );
	$texte->text("Total:$total Euro");
	$montant_cb=&get("select montant from infopay_web where cde_id='$no_cde' and trans_status='AUTHORISED'")+0;
	if ($montant_cb>0){
		$total_remise=0;
		$remise_info="0%";
		if (($total  >30)&&($total<90)){$remise_info='3%'};
		if ($total  >=90){$remise_info='5%'};
		$ligne-=5;
		$texte->translate( 130/mm, $ligne/mm );
		$texte->text("Paiement par carte bancaire remise $remise_info");
		$ligne-=5;
		$texte->translate( 130/mm, $ligne/mm );
		$texte->text("Paiement CB pour un total de :$montant_cb Euro");
		$ligne-=5;
		$texte->translate( 130/mm, $ligne/mm );
		$texte->text("Aucun Reglement ne doit être demandé à bord");
	}
	# &boite_pdf(20,230,200,200);
	$pdf->save();
	print "<a href=http://$base_rep.fr/doc/$nom_pdf><img src=/images/pdf.jpg></a>";
	print "<br><a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&no_cde=$no_cde&action=voir>Retour</a>";
}

sub boite_pdf() {
	$a=$_[0];
	$b=$_[1];
	$c=$_[2];
	$d=$_[3];
	my $line = $page[$index]->gfx;
	$line->strokecolor('black');
	$line->move( $a/mm, $b/mm );
	$line->line( $c/mm, $b/mm );
	$line->stroke;
	$line->move( $a/mm, $d/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
	$line->move( $a/mm, $b/mm );
	$line->line( $a/mm, $d/mm );
	$line->stroke;
	$line->move( $c/mm, $b/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
}

;1
