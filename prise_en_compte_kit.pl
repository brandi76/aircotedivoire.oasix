use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;

if ($action eq ""){
		print "<form>";
		&form_hidden();
		print "Bon d'appro ";
		print "<input name=appro>";
		print "<input type=hidden name=action value=go>";
		print "<input type=submit>";
		print "</form>";
}
if ($action eq "go"){
	$appro=$html->param("appro");
	($cl_nom,$cl_trilot)=&get("select cl_nom,cl_trilot from client,vol where cl_cd_cl=v_cd_cl and v_code='$appro' and v_rot=1");
	($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=&get("select vol.* from vol where v_code='$appro' and v_rot=1");
	($flb_depart)=&get("select flb_depart from flybody,flyhead where fl_apcode='$appro' and fl_vol=flb_vol and fl_date=flb_date and flb_rot=11");	
	($flb_retour)=&get("select flb_arrivee from flybody,flyhead where fl_apcode='$appro' and fl_vol=flb_vol and fl_date=flb_date order by flb_rot desc");	
	$retour=substr($flb_retour,0,2).'.'.substr($flb_retour,2,2);
	($lot_desi)=&get("select lot_conteneur from lot where lot_nolot='$v_troltype'");
	$depart=substr($flb_depart,0,2).'.'.substr($flb_depart,2,2);
	($at_type,$nolot)=&get("select at_type ,at_nolot from etatap where at_code='$appro'");
	$file="/var/www/aircotedivoire.oasix/doc/livraison_piste.pdf";
	if (-f $file){unlink ($file);}
	$pdf = PDF::API2->new(-file => $file);
	%font = (
		Helvetica => {
		Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
		Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
		Italic => $pdf->corefont( 'Helvetica-Oblique', -encoding => 'latin1' ),
		},
		Times => {
			Bold   => $pdf->corefont( 'Times-Bold',   -encoding => 'latin1' ),
			Roman  => $pdf->corefont( 'Times',        -encoding => 'latin1' ),
			Italic => $pdf->corefont( 'Times-Italic', -encoding => 'latin1' ),
	}
	);

	$index=0;
	$page[$index] = $pdf->page();
	$page[$index]->mediabox('A4');
	$tete_text = $page[$index]->text;
	$ligne=280;
	# for ($i=10;$i<200;$i=$i+10){
		# $tete_text->font( $font{'Helvetica'}{'Roman'}, 6/pt );
		# $tete_text->translate( $i/mm, 285/mm );
		# $tete_text->text($i);
	# }
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );

	$tete_text->translate( 15/mm, $ligne/mm );
	$tete_text->text("DUTY FREE CONCEPT");
	$ligne-=5;
	$tete_text->translate( 40/mm, $ligne/mm );
	$tete_text->text("BON DE LIVRAISON ET DECHARGEMENT DU BON D'APPRO no:");
	$tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
	$tete_text->translate( 180/mm, $ligne/mm );
	$tete_text->text("$appro");
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	$ligne-=10;
	$tete_text->translate( 100/mm, $ligne/mm );
	$tete_text->text("DEPART");
	&boite(15,$ligne-5,200,$ligne-65);
	$ligne-=10;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Lot no:$cl_trilot $nolot $lot_desi");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("No VOL:$v_vol rot no:$v_rot");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Destination:$v_dest");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Heure chargement:".&julian($v_date_jl,"DD/MM/YY")." $depart");
	$ligne-=5;
	# $tete_text->translate( 20/mm, $ligne/mm );
	# $tete_text->text( "1ER EXEMPLAIRE POUR DFC / 2E EX C/C ACI");  
	# $ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Visa ACI depart:Trigramme + Signature C/C ");
	$tete_text->translate( 113/mm, $ligne/mm );
	$tete_text->text("Visa DFC depart:Trigramme + Signature AGENT ");
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	&boite(18,$ligne-3,110,$ligne-35);
	&boite(112,$ligne-3,197,$ligne-35);

	($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=&get("select vol.* from vol where v_code='$appro' order by v_rot desc");
	$ligne-=50;
	$tete_text->translate( 100/mm, $ligne/mm );
	$tete_text->text("RETOUR");
	&boite(15,$ligne-5,200,$ligne-65);
	$ligne-=10;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Lot no:$cl_trilot $nolot $lot_desi");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("No VOL:$v_vol rot no:$v_rot");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Destination:$v_dest");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Heure dechargement:".&julian($v_date_jl,"DD/MM/YY")." $retour");
	$ligne-=5;
	# $tete_text->translate( 20/mm, $ligne/mm );
	# $tete_text->text( "1ER EXEMPLAIRE POUR DFC / 2E EX C/C ACI");  
	# $ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Visa ACI retour:Trigramme + Signature C/C ");
	$tete_text->translate( 113/mm, $ligne/mm );
	$tete_text->text("Visa DFC retour:Trigramme + Signature AGENT ");
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	&boite(18,$ligne-3,110,$ligne-35);
	&boite(112,$ligne-3,197,$ligne-35);

	$ligne-=50;
	$tete_text->translate( 70/mm, $ligne/mm );
	$tete_text->text("BON DE REMISE DE CAISSE DE CAISSE");
	&boite(15,$ligne-5,200,10);
	$ligne-=10;

	$query="select vol.* from vol where v_code='$appro' order by v_rot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$ligne_tamp=$ligne;
	$col=20;
	while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=$sth->fetchrow_array){
		$ligne=$ligne_tamp;
		$tete_text->translate( $col/mm, $ligne/mm );
		$tete_text->text("No VOL:$v_vol rot no:$v_rot");
		$ligne-=5;
		$tete_text->translate( $col/mm, $ligne/mm );
		$tete_text->text("Etape:");
		$ligne-=5;
		$tete_text->translate( $col/mm, $ligne/mm );
		$tete_text->text("Enveloppe de caisse No:");
		$ligne-=5;
		$col+=60;
	}
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Date de recuperation:");
	$ligne-=5;
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Nombre de caisse:");
	$ligne-=5;
	# $tete_text->translate( 20/mm, $ligne/mm );
	# $tete_text->text( "1ER EXEMPLAIRE POUR DFC / 2E EX C/C ACI");  
	# $ligne-=5;
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
	$tete_text->translate( 20/mm, $ligne/mm );
	$tete_text->text("Visa ACI retour:Trigramme + Signature C/C ");
	$tete_text->translate( 113/mm, $ligne/mm );
	$tete_text->text("Visa DFC retour:Trigramme + Signature AGENT ");
	$tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
	&boite(18,$ligne-3,110,$ligne-35);
	&boite(112,$ligne-3,197,$ligne-35);
	$pdf->save();
	print "<a href=/doc/livraison_piste.pdf><img src=/images/pdf.jpg /></a><br>";
						
} 


 
sub boite() {
	$a=$_[0];
	# x gauche
	$b=$_[1];
	# y haut
	$c=$_[2];
	# x droit
	$d=$_[3];
	# y bas
	# y bas
	my $line = $page[$index]->gfx;
	$line->strokecolor('black');

	# horizontale 
	$line->move( $a/mm, $b/mm );
	$line->line( $c/mm, $b/mm );
	$line->stroke;
	$line->move( $a/mm, $d/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;

	# verticale 	
	$line->move( $a/mm, $b/mm );
	$line->line( $a/mm, $d/mm );
	$line->stroke;
	$line->move( $c/mm, $b/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
}
;1 

