#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
require "../oasix/../oasix/outils_corsica.pl";

use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
$CGI::LIST_CONTEXT_WARN = 0;
$ip =$ENV{"REMOTE_ADDR"};
$server_name=$ENV{"SERVER_NAME"};
$domaine=$ENV{"DOCUMENT_ROOT"};
$user=$html->param("user");
if ($user eq ""){$user=$ENV{"REMOTE_USER"};}
if ($user eq "desirea"){exit;}
if ((grep /dfc/,$domaine)&&(! grep /dfca/,$domaine)){ 
  print "<body onload='window.location.href=\"http://dfc.oasix.fr/index.htm\"'>";
  exit;
}
$onglet=$html->param("onglet");
$sous_onglet=$html->param("sous_onglet");
$sous_sous_onglet=$html->param("sous_sous_onglet");
$module=$html->param("module");
$action=$html->param("action");
$mess_index=$html->param("mess_index");
require("../oasix/jquery_marron.pl");
@data=<DATA>;
open(FIC,"./src/html_part1_af.src");
while (<FIC>){print;}	        
close(FIC);
require("./src/onglet.src");
open(FIC,"./src/html_part2_1.src");
while (<FIC>){print;}	        
close(FIC);
# menu gauche
$index=-1;
$sous_index=-1;
$sous_sous_index=-1;
require("./src/connect.src");
foreach (@data)
{
	if ((grep /Admin/,$_)&&($user ne "sylvain")&&($user ne "philippe")&&($user ne "daniel")){last;}
	if (! grep (/^\t/,$_)){$index++;}
	if (($index == $onglet) && (grep (/^\t/,$_))&&(! grep (/^\t\t/,$_))){
		$sous_index++;
		if ($sous_onglet eq ""){
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			$prg=$_;
			while($prg=~s/\t//){};
			while($prg=~s/\n//){};
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index>$_</a>";
			print "</td></tr><tr><td><img src=\"/kit/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";
		}
        }
        if ($sous_onglet ne ""){
		if (($index == $onglet) && ($sous_index == $sous_onglet) &&( grep (/^\t\t/,$_))){
			$sous_sous_index++;
			($desi,$mod,$option)=split(/;/,$_);
			if (($sous_sous_index==0)||($sous_sous_index==$sous_sous_onglet)){
				# print "*$sous_sous_index*$sous_sous_onglet*$_*$option";
				if ($option==1){
					$ancien=$mod;
					if (!grep /http/,$mod){
						if (grep /\.pl/,$mod){
							$ancien="http://$server_name/cgi-bin/".$mod;
						}
						else{
							$ancien="http://$server_name/".$mod;
						}
				        }
				}		
				else{$module=$mod;$ancien="";}
			}
			
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			$color="#848692";
			if ($option==2){
			  $color="#DDDDDD";
			}
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index&sous_sous_onglet=$sous_sous_index><span style=color:$color>$desi</span></a>";
			print "</td></tr><tr><td><img src=\"/kit/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";

		}	

	}
}
$trigramme=&get("select trigramme from user where nom='$user'");
print "<h4>$trigramme</h4>";
open(FIC,"./src/html_part2_2.src");
while (<FIC>){print;}	        
close(FIC);
chop ($module);
if (($module ne "")&&($ancien eq "")) {
print "<title>$module</title>";	
require ($module);}
if ($ancien ne "") {
	 # print "<center><a href=$ancien target=\"$ancien\" onclick=\"window.open('popup.htm','$ancien','width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,adress=yess,scrollbars=yes,left=20,top=30')\">$ancien</a>";
	  print "<center><a href=$ancien target=_blank>$ancien</a>";
	  print "<title>$ancien</title>";

}
if (($onglet eq "")&&($sous_onglet eq "")){ 
# uire ("./src/acces_rapide.src");
}
if (($onglet eq "")&&($sous_onglet eq "")){ 
  # $dernier=&get("select max(oa_date_import) from oasix");
  # print "<center>Date du dernier déchargement front-office:$dernier</center>";
  $first=1;
  $query="select ns_code from non_sai,inforetsql where ns_code=infr_code and infr_date!=curdate()";
  $sth2=$dbh->prepare($query);
  $sth2->execute();
  while (($ns_code)=$sth2->fetchrow_array){
    if ($first){print "<div style=background:pink;font-size:1.2em> Bon d'appro en attente du saiappauto , merci de faire le necessaire<br>";$first=0;}
    print "$ns_code<br>";
  }
  if (! $first){print "</div>";}

  require ("./src/accueil.src");
}

open(FIC,"./src/html_part3.src");
while (<FIC>){print;}	        
close(FIC);
__DATA__
Fichier
	Produit
		Consultation;fiche_produit_kit.pl
		Listing produit;listing_prod.pl;1
		Inventaire journalier;inventaire_jour_kit.pl
		Inventaire mensuel;inventaire_mois_kit.pl
		Valeur;valeur_stockcomptable.pl;1
		Trace ecart;trace_ecart_kit.pl
		Vente;vte_produit_kit.pl
		Suivi mouvement;mouvement_produit_kit.pl
		Consultation;fiche_client.pl;1
		Listing prix;listing_prix.pl;1
		Statistique;statvente_AAAA.pl;1
		Statistique new;statvente_AA_kit.pl
		Ecart inventaire;ecart_inv_kit.pl
		Stock multicolor;stock_multicolor_kit.pl
		Rotation stock;rotation_stock_kit.pl
		Transfert;switch_kit.pl
		Stock sac;stock_sac_kit.pl
	Fournisseur
		Consultation;fiche_four_kit.pl
		Stock alerte;stock_alerte_kit.pl
		Commande;commande_kit.pl
		concours guerlain;concours_guerlain.pl;1
	Caisse	
		Saisie;saicaisse.pl;1
		Equipages;equipage_kit.pl
		Recap de caisse;recap_kit.pl
		Commissions;commission_kit.pl
		Stim;stim.pl;1
		Saisie Remise;remise_banque_kit.pl
		Saisie Remise ancien;remise_banque_kitn.pl
		Comptage coffre;coffre_kit.pl
		Recap annuelle;recap_an.pl;1
		Impaye;impaye_kit.pl
		Caisse manquante;manquante_kit.pl
	Douane
		Reedition saiappauto;saiappautom.pl;1
		Saiappauto;saiappauto.pl;1
		Bon en attente;liste_non_sai_kit.pl
		Bon en l'air;liste_enlair_kit.pl
		Compta matiere;list_compta_kit.pl
		Entree douane;nd_entree_kit.pl
		Sortie douane;nd_export_kit.pl
		Sortie lta;vendu_lta_date.pl;1
	Trolley
		Gestion des lots;lot_kit.pl
		Trolley type;gestrolley_kit.pl
		Pas touché;pastouche_kit.pl
		Verification des prix;verif_prix_kit.pl
		Verification des codes douanes;verif_ndp_kit.pl
		Statistique;stat_trol_kit.pl
	Tpe
		Importation des ventes;import_vente_kit.pl
		Voir les ventes;import_oasix_kit.pl
		Numerotation tpe;oasix_tpe_kit.pl
		Liste produit;sk20xml_v3_kit.pl
		Verif Liste;verif_tpe_kit.pl
	Hotesse
		Consultation;fiche_hotesse.pl;1
	Client 
		Fiche client;fiche_client.pl;1
	Appro
		Debug;debug_appro.pl;1
		Destination;modifdest_kit.pl
		Commentaire;commentaire_kit.pl
		Statistique;stat_bon_pie.pl
		Etude marche;stat_bon_pie2.pl
		Manquant;stat_manquant_pie.pl
		Ajout rotation;ajout_rot_kit.pl
		Reedition appro;edite_appro.pl;1
		Mise à jour apres saiappauto;modif_retour_kit.pl
	Devise
		Cours;devise_kit.pl
		Choix devise;choixdevise_kit.pl
	Famille
		Gestion;fiche_famille_kit.pl
	Passager
		Gestion;fiche_passager_kit.pl
	Mag
		Gestion;mag_kit.pl
		Prix visuel;fiche_pubmag_kit.pl
		Comparaison;compare_mag_kit.pl
		Verif Pre-order;verif_preorder_kit.pl
		Mag actif;mag_actif_kit.pl
Planning
	Consultation
		Consultation;planningfly_kit.pl
		Planning journalier;planning_jour_kit.pl
		Saisie trigramme;planning_saisie_kit.pl
	Vol regulier
		Recopier;copie_planning_kit.pl
		Vol regulier;calendrier.pl;1
		Suppression de vols;supvol_kit.pl
			Consultation
	Saisie
		saisie;saisie_planning.pl;1
Achat
	Commande
		Commande;commande_kit.pl
		Adresse Livraison;fiche_adresse_liv_kit.pl
	Entrée
		Entrée;entree_kit.pl
		Historique;histo_entree_kit.pl
		Statistique;stat_entree_kit.pl
		Node de detail entree;nd_entree_kit.pl
		Saisie document;lta_local_kit.pl
	Stock alerte
		Stock alerte new;stock_alertep_kit.pl
		Mise en place;mise_en_place_kit.pl
	Suivi fournisseur
		suivi fournisseur;suivi_four_kit.pl
	planning
		planning livraison;planning_liv_kit.pl
Depart
	Preparation
		Preparation;preparation.pl;1
		Saisie des ecarts;saisie_ecart_kit.pl
	Bordereau de livraison
		Bordereau;prise_en_compte_kit.pl
	Commande
		Saisie;commande_client_kit.pl
		Facture;facture.pl;1
		Note de detail;saisie.pl;1
	Commande Web
		Liste;commande_web_kit.pl
		CA;commande_web_ca_kit.pl
	Avis de depart
		Avis de depart;avis_sortie_kit.pl
Retour
	Saisie
		Saisie;saiapp_kit.pl
		Tpe;import_oasix_kit.pl
		Saisie rotation;saisie_vendu_rotation.pl;1
	Avis de retour
		Saisie prise en compte;saisie_prise_en_compte.pl;1
		Avis de retour;avisret_kit.pl
		Liste des retours;info_ret_kit.pl
		Avis de retour new;avis_retour_kit.pl
	Statistique
		Ranking;statistique_kit.pl
		Qualite;qualite_retour.php;1
		Concours;concours_kit.pl
		Valeur Achat;ca_achat.pl;1
Admin
	Mouchard
		Traceur;traceur_kit.pl
	Compta
		Situation;situation_kit.pl
		Controle des ecarts de caisse;recap_justif2.pl;1
		Controle des ecarts de caisse v2;recap_justif3.pl;1
		Saisie Remise dev;remise_banque_devkit.pl
		Edition Bordereau;bordereau_edition2_kit.pl
		Ecart commission;ecart_commission_kit.pl
		Controle des dates de remise;recap_date_kit.pl
		suivi des encaissements;suivi_encaissement_v1_kit.pl
		Relevé de banque;import_releve_kit.pl
		Suivi Cb;suivi_remisecb_kit.pl
		Recap Ecart Commision;recap_ecart_commission_kit.pl
		Chargement;compta_chargement_kit.pl
