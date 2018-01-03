#!/usr/bin/perl
use CGI;
use DBI();
use Math::Round;
$html=new CGI;
use CGI::Carp qw(fatalsToBrowser);
require "../oasix/outils_perl2.pl";
$date=`/bin/date +%d';'%m';'%Y`;
($jour,$mois,$an)=split(/;/, $date, 3); 
chop($an);
$today=&nb_jour($jour,$mois,$an);
$datesimple="1".substr($an,2,2).$mois.$jour;
print $html->header;
print "<html><head>
<Meta http-equiv=\"Pragma\" content=\"no-cache\">
<style type=\"text/css\">
<!--
#saut { page-break-after : right }         
-->
</style></head>";
require "./src/connect.src";
$action=$html->param('action');
$nodepart=$html->param('nodepart');
$printer=$html->param('printer');
$controleur=	$html->param("controleur");
$devise_id=&get("select dt_no from atadsql where dt_cd_dt=20");
$devise_tri=&get("select trigramme from devise where id='$devise_id'");

print "<body>";

if ($action eq "raz"){
@listef=("atadsql","listevol","flyhead","geslot","produit","sortie","vol","appro","ecartrol_arch","pick");
foreach(@listef){
&save("truncate table $_");
&save("insert into $_ select * from aircotedivoire.$_","aff");
}
}


if ($action eq "plombs"){
		&modifplombs();
		$action="";
}

if ($action eq ""){
	# affectation des numeros d'appro et numero de lot , creation des bons d'appro
	# boucle sur listevol
	$nb_necessaire=&get("select count(*) from listevol,flyhead where liv_dep='$nodepart' and liv_nolot=0 and fl_date=liv_date and fl_vol=liv_vol");
	$nb_dispo=&get("select count(*) from geslot where gsl_ind=0 and gsl_nolot<300");
	if ($nb_dispo <$nb_necessaire){
		print "<font color=red>lot necessaire:$nb_necessaire disponible:$nb_dispo <br>";
		print "<br>AVIS DE DEPART IMPOSSIBLE</br>";
		exit;
	}
	$query="select liv_vol,liv_date,liv_aprec,liv_nolot from listevol where liv_dep='$nodepart' and liv_nolot=0";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$pass=0;
	while (($liv_vol,$liv_date,$liv_aprec,$liv_nolot)=$sth->fetchrow_array)
	{
		# pour chaque vol de listevol
		$query="select fl_troltype,fl_cd_cl from flyhead where fl_date='$liv_date' and fl_vol='$liv_vol' limit 1";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($fl_troltype,$fl_cd_cl)=$sth2->fetchrow_array;
		#si un lot a été affecté soit il à déja été traiter ->next s 
		&save("update atadsql set dt_desi=dt_desi+1 where dt_cd_dt=210");  # numero appro
		($appro)=&get("select dt_desi from atadsql where dt_cd_dt=210");
		($no_lot)=&get("select gsl_nolot from geslot where gsl_nolot<300 and gsl_ind=0 order by gsl_nolot limit 1");
		$query="select flb_arrivee,flb_datetr,flb_tridep,flb_triret from flybody where flb_vol='$liv_vol' and flb_date='$liv_date' order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$trajet_long="";
		# boucle sur flybody pour avoir le trajet
		while ((@flb)=$sth2->fetchrow_array){
			$flb_arrivee=$flb[0];
			$flb_datetr=$flb[1];
			$flb_tridep=$flb[2];
			$flb_triret=$flb[3];
			$trajet_long=$trajet_long.$flb_tridep."/";
		}
		$trajet_long=$trajet.$flb_triret;
		$query="select flb_datetr,flb_rot,flb_voltr,flb_tridep,flb_triret from flybody where flb_vol='$liv_vol' and flb_date='$liv_date' order by flb_rot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$rot_run=-1;
		$trajet="";
		while (($flb2_datetr,$flb2_rot,$flb2_voltr,$flb_tridep,$flb_triret)=$sth2->fetchrow_array){
			$rot=int($flb2_rot/10);	
			if ($rot ne $rot_run){$trajet="$flb_tridep/$flb_triret";$rot_run=$rot;$date_trajet=$flb2_datetr;}
			else {$trajet.='/'.$flb_triret;}
			$date=&julian($date_trajet,"DDMMYY");
			$date_sql=&julian($date_trajet,"YYYY-MM-DD");
			&save("replace into vol values ('$appro','$rot','$flb2_voltr','$date','','','','$trajet','$fl_cd_cl','','','','$fl_troltype','$flb2_datetr','0','$date_sql')","ff");
			&save("replace into caisse values ('$appro','$rot','0','0','0','0','0','0','0','0','','0','0','','')","ff");
		}
		&save("update listevol set liv_nolot='$no_lot' where liv_date='$liv_date' and liv_vol='$liv_vol' and liv_dep='$nodepart'","ff");
		&save("update flyhead set fl_apcode='$appro',fl_nolot=$no_lot where fl_date='$liv_date' and fl_vol='$liv_vol'","ff");
		# new recuperation des infos trolley type
		$query="select lot_conteneur,lot_nbplomb,lot_nbcont from lot where lot_nolot='$fl_troltype'";
		$sth_n=$dbh->prepare($query);
		$sth_n->execute();
		($lot_conteneur,$lot_nbplomb,$lot_nbcont)=$sth_n->fetchrow_array;
		&save("update geslot set gsl_apcode='$appro',gsl_ind=3,gsl_nodep='$nodepart',gsl_noret=0,gsl_novol='$liv_vol',gsl_dtvol='$liv_date',gsl_troltype='$fl_troltype',gsl_hrret='$flb_arrivee',gsl_dtret='$flb_datetr',gsl_triret='$flb_triret',gsl_trajet='$trajet_long',gsl_alc='$qte_alc',gsl_tab='$qte_cig',gsl_nb_cont='$lot_nbcont',gsl_desi='$lot_conteneur',gsl_nbpb='$lot_nbplomb' where gsl_nolot='$no_lot'");
		$troltype{$fl_troltype}++;
		$tiroir=$fl_troltype."_".$troltype{$fl_troltype};
		&save("replace into etatap values('$appro',2,'$datesimple',0,'','$tiroir','$nodepart','','$no_lot')");
		&save("replace into apjour values('$datesimple','$appro')","","trace");
		$cree=0;
		$query="select ecr_cd_pr,ecr_qte from ecartrol where ecr_cdtrol='$fl_troltype'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ecr_cd_pr,$ecr_qte)=$sth2->fetchrow_array){
			%stock=&stock($ecr_cd_pr);
			$ecr_stock=$stock{"stock"};
			&save("insert ignore into ecartrol_arch values ('$appro','$ecr_cd_pr','$ecr_qte','$ecr_stock')");
		}
		$query="select tr_ordre,tr_cd_pr,tr_qte,tr_prix from trolley where tr_code='$fl_troltype' order by tr_ordre";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		# boucle sur trolley
		while (($tr_ordre,$tr_cd_pr,$tr_qte,$tr_prix)=$sth2->fetchrow_array){
			($ecr_qte)=&get("select ecr_qte from ecartrol where ecr_cdtrol='$fl_troltype' and ecr_cd_pr='$tr_cd_pr'");
			if ($ecr_qte ne ''){$tr_qte=$ecr_qte;}
			if ($tr_qte==0){next;}
			&save("replace into appro values('$appro','$tr_ordre','$tr_cd_pr','$tr_prix','$tr_qte','2','$fl_cd_cl')");
			$cree++;
			&save("update produit set pr_stvol=pr_stvol+$tr_qte where pr_cd_pr='$tr_cd_pr'");
			&save("replace into sortie values('$tr_cd_pr','$appro','$tr_qte')");
		}
		$mag="lemag".substr($fl_troltype,0,2);
		$manquant=&get("select sum(prix) from mag where mag='$mag' and code not in (select ap_cd_pr from appro where ap_code='$appro')","af")+0;
		&save("update vol set v_retour='$manquant' where v_code='$appro'");

		### PRE ORDER	
		$query="select cde_id from infocmd_web where vol_date='$liv_date' and vol_vol='$liv_vol'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($cde_id)=$sth2->fetchrow_array){
			$ordre=1200;
			$query="select produit_id,qte*100,prix*100 from panier_web where cde_id='$cde_id' and produit_id>0";
			$sth3=$dbh->prepare($query);
			$sth3->execute();
			while (($pr_cd_pr,$qte,$prix)=$sth3->fetchrow_array){
				&save("replace into appro values('$appro','$ordre','$pr_cd_pr','$prix','$qte','2','$fl_cd_cl')");
				&save("update produit set pr_stvol=pr_stvol+$qte where pr_cd_pr='$pr_cd_pr'");
				&save("insert ignore into sortie values('$pr_cd_pr','$appro','0')");
				&save("update sortie set so_qte=so_qte+'$qte' where so_cd_pr='$pr_cd_pr' and so_appro='$appro'");
				$ordre++;
			}
		}
		if ($cree==0){print "<font color=red> Attention bon d appro vierge : appro=$appro pastouche=$pastouche approprec=$liv_aprec trol_type=$tl_troltype</font><br>";}
		&maj_pick();
	}
	# fin boucle sur listevol

	# boucle sur geslot pour verifier si tous les plombs ont ete saisie
	$query="select gsl_nolot,gsl_desi,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7 from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	$plombsok=1;
	while(($gsl_nolot,$gsl_desi,$gsl_nbpb,@tabplombs)=$sth->fetchrow_array){
		for ($i=0;$i<$gsl_nbpb;$i++){
			if ($tabplombs[$i]+0==0){$plombsok=0;}
		}
	}
	if ($plombsok==0){
		&saiplombs();
	}
	else{
		&avisdep();
	}
} 

sub saiplombs(){
	# ***********saisie des plombs ********
	print "\n<script>";
	print "function auto(variable){\n";
	print "var j=1;\n";
	print "if (document.plomb.recopie.checked==false){return;}";
	print "	for (i=variable;i<document.plomb.elements.length-5;i++){";
	print "		document.plomb.elements[i].value=(parseInt(document.plomb.elements[i-1].value)+1);";
	print "		if (j++==9) break;";
	
	# print "alert(i+\" document.plomb.elements[i].value=(parseInt(document.plomb.elements[i-1].value)+1)\");";
	print "	}";
	print "}";
	print "</script>\n";
	
	$query="select gsl_nolot,gsl_desi,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7 from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print  "<form name=plomb method=GET><table border=1 cellspacing=0><tr bgcolor=yellow><th>Lot</th><th>Désignation</th><th>Plombs 1</th><th>Plombs 2</th><th>Plombs 3</th><th>Plombs 4</th><th>Plombs 5</th><th>Plombs 6</th><th>Plombs 7</th></tr>";
	$j=0;
	$ok=1;
	while(($gsl_nolot,$gsl_desi,$gsl_nbpb,@tabplombs)=$sth->fetchrow_array){
		print "<tr><td>$gsl_nolot</td><td>$gsl_desi</td>";
		for ($i=0;$i<$gsl_nbpb;$i++){
			$ref=$gsl_nolot.'_'.$i;
			$j++;
			print "\n<td><input type=text name=$ref value=$tabplombs[$i] Onchange=auto($j)></td>";
			$nbplombs++;
		}
		print "</tr>";
	}
	print "</table><br>Nombre de plombs necessaire:$nbplombs <br>recopie incrementé <input type=checkbox name=recopie checked>";
	print "<input type=hidden name=action value=plombs>";
	print "<input type=hidden name=nodepart value=$nodepart>";
	print "<input type=hidden name=printer value=$printer><input type=submit value=\"avis de depart et bon d\'appro\">";
	print "<br>Trigramme Controleur <input type=text size=3 name=controleur>";
	print "</form>";
}


sub modifplombs {
	$query="select gsl_nolot,gsl_desi,gsl_nbpb,gsl_pb1,gsl_pb2,gsl_pb3,gsl_pb4,gsl_pb5,gsl_pb6,gsl_pb7 from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while(($gsl_nolot,$gsl_desi,$gsl_nbpb,@tabplombs)=$sth->fetchrow_array){
		$query="select * from geslot where gsl_nolot=$gsl_nolot";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		(@table)=$sth2->fetchrow_array;
		for ($i=0;$i<$gsl_nbpb;$i++){
			$ref=$gsl_nolot.'_'.$i;
			$table[$i+6]=$html->param("$ref");
		}
  		$query="replace into geslot values(";
	 	for ($z=0;$z<=$#table;$z++)
		{
			$query.="'$table[$z]',";
		}
  		chop($query);
  		$query.=")";
	  	 # print "$query<br>";;
		 $sth2=$dbh->prepare($query);
		 $sth2->execute();
	}
}

sub avisdep {
	print "<div style=\"font-family:Courrier; font-size:11pt\"><pre>";
	$query="select geslot.* from geslot,listevol where liv_dep='$nodepart' and gsl_nolot=liv_nolot";
	$sth=$dbh->prepare($query);
	$sth->execute();

	$jour=&taillefixen($jour,2);
	$mois=&taillefixen($mois,2);
	$an=&taillefixen($an,4);
	$br="<br>";

	# boucle sur listevol
	while (($gsl_nolot,$gsl_ind,$gsl_dtret,$gsl_novol,$gsl_dtvol,$gsl_troltype,$gsl_pb1,$gsl_pb2,$gsl_pb3,$gsl_pb4,$gsl_pb5,$gsl_pb6,$gsl_pb7,$gsl_hrret,$gsl_triret,$gsl_apcode,$gsl_nb_cont,$gsl_desi,$gsl_trajet,$gsl_alc,$gsl_tab,$gsl_nodep,$gsl_noret,$gsl_nbpb,$gsl_tpe)=$sth->fetchrow_array)
		{
		$query="select cl_nom,cl_trilot from client,vol where cl_cd_cl=v_cd_cl and v_code='$gsl_apcode' and v_rot=1";

		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($cl_nom,$cl_trilot)=$sth2->fetchrow_array;
		$cl_nom=&taillefixen($cl_nom,24);
		$nolot=$gsl_nolot;
		$nolot=&taillefixen($nolot,3);
		$query="select vol.* from vol where v_code='$gsl_apcode' order by v_rot";
		$sth3=$dbh->prepare($query);
		$sth3->execute();

		########## BOUCLE SUR VOL #############

		while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_zatt)=$sth3->fetchrow_array)
		{
			if (($v_troltype <99)&& ($v_rot!=1)){next;} # economie de papier
			&save("update vol set v_nom='$controleur' where v_code='$v_code' and v_rot='$v_rot'");
			$v_vol=&taillefixen($v_vol,10);
			$v_dest=&taillefixen($v_dest,18);
			$gsl_desi=&taillefixen($gsl_desi,8);
			$query="select flb_depart from flybody,flyhead where fl_apcode='$gsl_apcode' and fl_vol=flb_vol and fl_date=flb_date and flb_rot=11";
			#print $query;
			$sth2=$dbh->prepare($query);
			$sth2->execute();
			($flb_depart)=$sth2->fetchrow_array;
			$flb_depart=&taillefixen($flb_depart,4);
			$depart=substr($flb_depart,0,2).'.'.substr($flb_depart,2,2);
			$at_type=&get("select at_type from etatap where at_code='$gsl_apcode'");
			# edition des bon d'appro
			&bon_appro();
			&mise_a_bord();
			&fiche_de_caisse();
			&remise_de_caisse();
			&saut_de_page();
			&bon_appro();
			&mise_a_bord();
			&fiche_de_caisse();
			&remise_de_caisse();
			&saut_de_page();

		} # fin boucle vol
	} # fin boucle listevol

	print "</div></pre></body></html>";
}

sub maj_pick {
	my($troltype,$tr_cd_pr,$nb,$qte,$sth2,$sth3,$sth,$query);
	# suppression des valeurs pour aujourdui
	&save("delete from pick where pi_date=curdate()","ff");
	# selection des trolleys en vol 
	$query="SELECT v_troltype,count(*) from apjour,vol where aj_date=$datesimple and aj_code=v_code and v_rot=1 group by v_troltype";
# 	$query="select gsl_troltype,count(*) from geslot where gsl_ind=3 group by gsl_troltype";
	$sth=$dbh->prepare($query);
	$sth->execute();
	
	# pour chaque trolley type en enregistre la quantité theorique dans pick
	while (($troltype,$nb)=$sth->fetchrow_array){
		$query="select tr_cd_pr,tr_qte/100 from trolley where tr_code='$troltype'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($tr_cd_pr,$qte)=$sth2->fetchrow_array){
			$qte*=$nb;
	 	 	$qte+=&get("select pi_qte from pick where pi_date=curdate() and pi_cd_pr='$tr_cd_pr'");
		 	&save("replace into pick values (curdate(),'$tr_cd_pr','$qte')");
		}
	}

}

sub saut_de_page(){
	if ($printer==11){print "\f";}else {print "<div id=saut></div>";}
}

############### BON APPRO ########################
sub bon_appro{
	&cartouche_appro();

		$query="select appro.*,pr_desi,pr_type,tr_tiroir,pr_pdb from appro,produit,trolley where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr and tr_code='$v_troltype' and ap_cd_pr=tr_cd_pr and ap_ordre<1200 order by tr_tiroir,ap_ordre";
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		# boucle sur appro
		$val=0;
		$total=0;
		$poids=690;
		while (($ap_code,$ap_ordre,$ap_cd_pr,$ap_prix,$ap_qte0,$ap_cd_pos,$ap_cd_cl,$pr_desi,$pr_type,$tr_tiroir,$pr_pdb)=$sth4->fetchrow_array)
		{
			if ($tr_tiroir != $tiroir){
			 	if ($total!=0){print " -->Nombre de Produit tiroir $tiroir :$total $br";}
			 	$total=0;
			 	$poids=690;
			 	$tiroir=$tr_tiroir;
				#if ($tr_tiroir==4){
				#	&saut_de_page();
				#	&cartouche_appro();
				#}
				
			}
			 
			$pr_desi=&taillefixen($pr_desi,25);
			$ap_qte0=$ap_qte0-$tr_qte;
			$total+=int($ap_qte0/100);
			$poids+=int($ap_qte0/100)*$pr_pdb;
			$ap_qte0=&taillefixen($ap_qte0/100,3);
			$ap_prix=&taillefixen($ap_prix/100,5);
			print "$pr_desi!";
			#if ($v_rot==1){print $ap_qte0;}else {print"___";}
			print $ap_qte0;
			$val=$val+$ap_prix*$ap_qte0;
			print "!___! - !___! = !____ *$ap_prix  = ______! !______!$br";
		} # fin boucle appro
 		if ($total!=0){print " -->Nombre  de Produit tiroir $tiroir :$total$br";}
		$total=0;
		$query="select appro.*,pr_desi,pr_pdb from appro,produit where ap_code='$gsl_apcode' and ap_cd_pr=pr_cd_pr and ap_ordre>=1200";
		$sth4=$dbh->prepare($query);
		$sth4->execute();
		while (($ap_code,$ap_ordre,$ap_cd_pr,$ap_prix,$ap_qte0,$ap_cd_pos,$ap_cd_cl,$pr_desi,$pr_pdb)=$sth4->fetchrow_array)
		{
			$pr_desi=&taillefixen($pr_desi,25);
			$ap_qte0=$ap_qte0-$tr_qte;
			$total+=int($ap_qte0/100);
			$poids+=int($ap_qte0/100)*$pr_pdb;
			$ap_qte0=&taillefixen($ap_qte0/100,3);
			$ap_prix=&taillefixen($ap_prix/100,5);
			print "$pr_desi!";
			print $ap_qte0;
			$val=$val+$ap_prix*$ap_qte0;
			print "!___! - !___! = !____ *$ap_prix  = ______! !______!$br";
		}
		if ($total!=0){print " -->Nombre de Produit Pre-Order :$total$br";}
		

print "
                                        TOTAL VENTES      :  _______ $devise_tri
valeur du bon d'appro:$val


------------------------------------------------------------------------------
No Plombs            Visa DOUANE
Depart   !Escale 1 ! Escale 2 ! Escale 3 ! Escale 4 ! Arrivée ABJ ! ACI/DFC     
";
		for ($i=1;$i<=$gsl_nbpb;$i++){
			$var="gsl_pb".$i;
			print "${$var}     !         !          !          !          !             !$br";
		}

}


sub cartouche_appro {
print "

******************************************************************************
*$cl_nom CONTROLE QUALITE    No $gsl_apcode edition du $jour/$mois/$an*
*                                                                            *";
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print " $at_type $depart*
*----------------------------------------------------------------------------*";
print "
! C/C:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
! PNC:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
------------------------------------------------------------------------------
Designation             stock check   stock   vendus  prix   montant!  Stock
                        depart  PNC    retour                        !ACI/DFC
------------------------------------------------------------------------------
";
}


sub mise_a_bord {

	print "$br$br";
print "                                BON DE MISE A BORD ";
print "
*----------------------------------------------------------------------------*
*   Lot No    !           No VOL     DESTINATION        DATE      HEURE CHARG*
*   $cl_trilot $nolot   ! rot no:$v_rot :$v_vol$v_dest";
print &julian($v_date_jl,"DD/MM/YY");
print " $at_type $depart*
*----------------------------------------------------------------------------*$br";
print "1ER EXEMPLAIRE POUR DFC / 2E EX C/C ACI  
------------------------------------------------------------------------------- 
VISA ACI DEP  !VISA DFC DEPART   VISA RETOUR DFC  VISA ACI RET   ! 
                 !                     !          	       !                   ! 
                 !                     !                   !                   !
                 !                     !                   !                   !
                 !                     !                   !                   !
                 !                     !                   !                   !  

ECARTS OU SUGGESTION DEPART ";
}

sub fiche_de_caisse {

print "
------------------------------------------------------------------------------

$cl_cd_cl $cl_nom     FICHE DE CAISSE    bon d'appro No:$gsl_apcode

ROT No  $v_rot :$v_vol      $v_dest   ";
print &julian($v_date_jl,"DD/MM/YY");
print " C/C:
------------------------------------------------------------------------------
! C/C:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
! PNC:          ! PNC:         ! PNC:          ! PNC:          ! PNC:        !
------------------------------------------------------------------------------

Le premier exemplaire dans l'enveloppe de caisse, le deuxième pour le C/C

Nb    XOF    Total  Nb    XAF    Total  Nb    USD    Total  Nb     EUR   Total
------------------  ------------------  ------------------  ------------------

!  !10000 XOF!      !  !10000 XAF!      !  ! 50 USD !    !  !    ! 100€ !    !

------------------  ------------------  ------------------  -------------------		
!  ! 5000 XOF!      !  ! 5000 XAF!      !  ! 20 USD !    !  !    !  50€ !    !

------------------  ------------------  ------------------  -------------------		
!  ! 2000 XOF!      !  ! 2000 XAF!      !  ! 10 USD !    !  !    !  20€ !    !

------------------  ------------------  ------------------  -------------------		
!  ! 1000 XOF!      !  ! 1000 XAF!      !  !  2 USD !    !  !    !   5€ !    !

------------------                      ------------------  -------------------		
!  !  500 XOF!                          !  !  1 USD !    !  !    !   1€ !    !      

-----------------   ------------------  ------------------  -------------------
     TOTAL XOF           TOTAL XAF         TOTAL USD            TOTAL EUR";
$cour_usd=&get("select cours from devise where trigramme='USD'");
&save("insert ignore into cours_vol values ('$gsl_apcode','USD','$cour_usd')");
$cour_cfa=&get("select cours from devise where trigramme='XAF'");
$cour_euro=int(10000/$cour_usd)/10000;
$cour_cfa=round($cour_cfa*$cour_euro/10)*10;
print "
<b>1 DOLLAR EGALE $cour_cfa CFA OU 1 DOLLAR= $cour_euro €</b>"; 
print "
 Nombre de carte bancaire:____ Total:_____
  
                                         MONTANT CAISSE    :";
print "

                                         TOTAL VENTES      :

                                         DIFFERENCE        :____________
ENVELOPPE DE CAISSE No:
SIGNATURE DU CHEF DE CABINE:
";
}


sub remise_de_caisse {
print "

BON DE REMISE DE CAISSE DE CAISSE

Num d.enve  Num appro  date des vols  NOM+TRIGRAM C/C  ACI NOM AGENT DFC               
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 
           !          !             !                 !                     ! 


Date  de la remise  $br$br$br$br$br$br";
}

# FONCTION : taillefixen
# affichage en taille fixe
sub taillefixen {
		my ($char)=$_[0];
		my ($len)=$_[1];
		my ($i)=0;
		my ($chaine)="";
		$_=$char;
		if (! /[a-z,A-Z]/) # astuce test si numerique
		{ # numerique
			while ($char=~s/ //g){};
			for ($i=($len-length($char));$i>0;$i--){
				$chaine=$chaine." ";
			}
			$chaine=$chaine.$char;
			
		}
		else
		{ # non numerique
			for ($i=0;$i<=$len;$i++){
				$car=substr($char,$i,1);
				if ($car eq " "){$car=" ";}
				if ($car eq ""){$car=" ";}
				$chaine=$chaine.$car;
			}
		}
		return($chaine);
}
