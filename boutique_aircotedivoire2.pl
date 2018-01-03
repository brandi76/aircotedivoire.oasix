#!/usr/bin/perl 
use DBI();
use CGI;
use CGI::Session;
use Digest::MD5 qw(md5);

use HTML::Entities;
$html=new CGI;
$cookie = $html->cookie(-name => "session");
 if ($cookie) {
  CGI::Session->name($cookie);
}
$session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
$cle = $session->param('cle');
$client_id = $session->param('client_id');
$cde_id=$session->param('cde_id');

if ($client_id eq ""){$client_id=999999;}
print $html->header();

#  print "<h1><font color=red>*** $action ***</font></h1>";
use Encode;
# my $texte = " a é -v_ bè- nè_- n_è ™ ® ";
# print &traduit($texte);
# print "Sans encode : ", encode_entities($texte),"\n\n";
# print "Avec encode : ", encode_entities(decode('utf8', $texte));
$action=$html->param("action");
$menu=$html->param("menu");
$produit_id=$html->param("produit_id");
$id=$html->param("id");
$pay=$html->param("pay");
$log=$html->param("log");

if (grep /retour_cb/,$ENV{'REQUEST_URI'}){$action="retour_cb";}
 # print "<font color=white>****$client_id***</font>";
# exit;
require "../oasix/outils_perl2.pl";
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=togodev","web","admin",{'RaiseError' => 1});



if ($action eq "apresup"){$action=""};
# if ( ($cle eq "")&& ($action ne "menu")&& ($action ne "click")&& ($action ne "connu")&&($action ne "mdp")&&($action ne "oublier")&&($action ne "nouveau") &&($action ne "nouveau_click")&&($action ne "apresup")){$action="";}

if (($action eq "choix_paiement")&&($pay eq "carte")){
	&save("update cmd_web set paiement='carte' where cde_id='$cde_id'");
	$montant=&get("select sum(products_price) from products,panier where products_id=panier.produit_id and panier.cle='$cle' and panier.client_id='$client_id'","af");
	# print "<script>document.location.href=\"http://boutique.oasix.fr/cgi-bin/call_request.pl?cle=$cle&montant=$montant&order_id=$cde_id&client_id=$client_id\";</script>";
	$action="call_request";
}


if ($action eq "sup") {
		&save("delete from  panier where cle='$cle' and produit_id='$produit_id' and client_id='$client_id' limit 1");
		$action="apresclick";
}

if ($action eq "panier") {
	#session ouverte ou pas ?
	if ($cle eq ""){
		$session = new CGI::Session("driver:File",undef,{'Directory'=>"/tmp/apache"});
		$login=&generate_random_string(11);
		# Inscription de la variable dans la session sur le serveur
		$session->param('cle',$login);
		$session->expire('+2h');
		# Envoi du cookie reliant l'utilisateur ` sa session serveur
		$cle = $session->id();
		$host = $ENV{'HTTP_HOST'};
		# Petit nettoyage du dossier des sessions
		if (int(rand(10)) == 1) {
			# expire old sessions
			$filez = "/tmp/apache/*";
			while ($file = glob($filez)) {
					@stat=stat $file; 
				$days = (time()-$stat[9]) / (60*60*24);
				unlink $file if ($days > 3);
			}
		}
		if ($produit_id >0){&save("insert into panier values ('$login','$client_id','$produit_id')","af");}
		print "<script>document.location.href=\"set_session_cookie.pl?cle=$cle&host=$host&action=apresclick\"</script>";
	}
	else
	{
		if ($produit_id >0){&save("insert into panier values ('$cle','$client_id','$produit_id')","af");}
		$action="apresclick";
	}
}


if ($action eq "login"){
	# Initiation de la session
	$session = new CGI::Session("driver:File",undef,{'Directory'=>"/tmp/apache"});
	
	$login = $html->param('login');
	# Inscription de la variable dans la session sur le serveur
	$session->param('cle',$login);
	$session->expire('+2h');
	# Envoi du cookie reliant l'utilisateur ` sa session serveur
	$id = $session->id();
	$host = $ENV{'HTTP_HOST'};
	# Petit nettoyage du dossier des sessions
	if (int(rand(10)) == 1) {
		# expire old sessions
		$filez = "/tmp/apache/*";
		while ($file = glob($filez)) {
				@stat=stat $file; 
			$days = (time()-$stat[9]) / (60*60*24);
			unlink $file if ($days > 3);
		}
	}
	print "<script>document.location.href=\"set_session_cookie.pl?id=$id&host=$host\"</script>";
}
if ($action eq "logout"){
	# Utilisateur voulant fermer sa session manuellement
	$cookie = $html->cookie(-name => "session");
	if ($cookie) {
	CGI::Session->name($cookie);
	}
	# Expiration de la session serveur
	$session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
	$session->clear();
	$session->expire('+2h');
	print "<script>document.location.href=\"sup_session_cookie.pl?id=$id&host=$host\"</script>";
}
&entete();


if ($action eq "menu"){
	print "<div id=liste>";
	print "<form name=menu method=POST>";
	print "<input type=hidden name=action value=click>";
	print "<input type=hidden name=produit_id >";
  
	$query="select products_name,products_description.products_id from products_description,products_to_categories where products_name not like \"\" and products_description.products_id=products_to_categories.products_id and language_id=4 and categories_id=$menu";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($desi,$produit_id)=$sth->fetchrow_array){
		$query="select products_image ,products_price,products_model from products where products_id=$produit_id";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($img,$prix,$code_produit)=$sth2->fetchrow_array;
		$prix=int($prix);
		print "<div id=vignette><a onclick=document.menu.produit_id.value=$produit_id;document.menu.submit()><img height=80 src=http://boutique.oasix.fr/images/100x100/$code_produit.jpg>$prix.XOF $desi</a></div>";
	}
	print "</form>";
	print "</div>";
}



if ($action eq "click"){
	print "<div id=click>";
	print "<form name=panier method=POST>";
	print "<input type=hidden name=action value=panier>";
	print "<input type=hidden name=produit_id value=$produit_id>";
	$desi=&get("select products_name from products_description where products_description.products_id=$produit_id and language_id=4","af");
	$query="select products_image ,products_price,products_model from products where products_id=$produit_id";
	$sth2=$dbh->prepare($query);
	$sth2->execute();
	($img,$prix,$code_produit)=$sth2->fetchrow_array;
	$prix=int($prix);
	# print $query;
	open (FILE,"ls -r /var/www/boutique/images/300x300/$code_produit"."_*|");
	@liste=<FILE>;
	close(FILE);
	print "<center><h1>$desi</h1>$code_produit<br />";
	$pass=0;
	foreach (@liste){
		($null,$null,$null,$null,$null,$null,$imgls)=split(/\//,$_);
		print "<img src=http://boutique.oasix.fr/images/300x300/$imgls>";
		$pass=1;
	}
	if ($pass==0){
		print "<img src=http://boutique.oasix.fr/images/300x300/$code_produit.jpg>";
	}	
	if (-e "/var/www/boutique/images/texte/$code_produit.txt"){
		require("/var/www/boutique/images/texte/$code_produit.txt");
	}
	print "<br /><h2>$prix XOF </h2><br /> <input type=submit value=\"Ajouter au panier\"></center>";
	print "</form>";
	print "</div>";
}

if ($action eq "apresclick"){
	print "<div id=apresclick>";
	print "<form name=panier method=POST>";
	print "<input type=hidden name=produit_id>";
	print "<input type=hidden name=action value=sup>";
	$query="select products_name,products_description.products_id from products_description,panier where products_description.products_id=panier.produit_id and panier.cle='$cle' and panier.client_id='$client_id' and language_id=4";
	print "<h2>Votre Panier</h2>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($desi,$produit_id)=$sth->fetchrow_array){
		$query="select products_image ,products_price,products_model from products where products_id=$produit_id";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($img,$prix,$code_produit)=$sth2->fetchrow_array;
		$prix=int($prix);
		$total+=$prix;
		print "<div id=image><img  width=100 src=http://boutique.oasix.fr/images/100x100/$code_produit.jpg></div><div id=desi>$desi</div><div id=prix>$prix XOF</div><div id=sup><input type=button value=Supprimer onclick=document.panier.produit_id.value=$produit_id;document.panier.submit()></div>";
	}
	print "</form>";
	print "<div id=total>";
	if ($total <1){print "Panier Vide</div>";}
	else {
		print "Total:$total XOF</div>";
		print "<form method=POST> <input type=hidden name=produit_id> <input type=hidden name=action value=compte>";
		print "<div id=commander><input type=submit value=commander></form>";
	}
	print "</div>";
	
}	
if ($action eq "connu"){
	$email=$html->param("email");
	$password=$html->param("password");

	$password=md5($password);
	$client_id=&get("select client_id from client_web where email='$email' and password='$password'");
	# $client_id=&get("select client_id from client_web where email='$email'");
	
	if ($client_id ne ""){
		$session->param('client_id',$client_id);
		&save("update panier set client_id='$client_id' where client_id=999999 and cle='$cle'","af");
		$action="compte";
	}
	else {	print "<p style=color:red;>";
		$client_id=&get("select client_id from client_web where email='$email'","af");
		if ($client_id ne ""){&traduit("Mail existant mais mot de passe incorrect");}
		else{&traduit("Mail inexistant dans notre base");}
		print "</p>";
		$client_id=999999;
		$action="compte";
	}
}	

if ($action eq "nouveau_click"){
	$gender=$html->param("gender");
	$nom=$html->param("lastname") ;
 	$prenom=$html->param("firstname" );
	$email=$html->param("email_address");
	$rue=$html->param("street_address");
	$complement=$html->param("suburb");
	$codepostal=$html->param("postcode");
	$ville=$html->param("city");
	$pays=$html->param("country");
	$telephone=$html->param("telephone");
	$password=$html->param("password");
	$verif=&get("select count(*) from  client_web where email='$email'")+0;
	if ($verif >0){
		print "<p style=color:red;>";
		&traduit("Mail déjà existant dans notre base , création impossible");
		print "</p>";
		$action="nouveau";
	}
	else
	{	
		$password=md5($password);
		&save("insert ignore into client_web value ('','$gender','$nom','$prenom','$email','$rue','$complement','$codepostal','$ville','$pays','$telephone','$password','$fonction','$organisme',curdate())");
		$client_id=&get("select client_id from client_web where email='$email' and password='$password'");
		$session->param('client_id',$client_id);
		&save("update panier set client_id='$client_id' where client_id=999999 and cle='$cle'","af");
		system("/var/www/cgi-bin/aircotedivoireshop/sendmail_creation.pl $client_id &");
		$action="commander";
		print "<p class=message>";
		&traduit("Votre compte a bien été créé , un mail vous a été envoyé à l'adresse suivante:$email");
		print "</p>";
	}
}

if (($action eq "compte")&&($client_id ==999999)){
	print "<h2>Bienvenue, veuillez ouvrir une session</h2>";
	print "<br><div id=nouveau_client>";
	print "<h3><u>Nouveau Client</u></h3>";
	print "<form name=nouveau method=POST>";
	print "<input type=hidden name=produit_id>";
	print "<input type=hidden name=action value=nouveau>";
	# &traduit("En créant votre compte su AirCotedIvoire Shop vous pourrez faire vos achats plus rapidement, garder votre panier d'une visite à l'autre et suivre vos commandes.");
	print "<br><input type=submit value=Continuer>";
	print "</form>";
	print "</div>";
	print "<div id=client_existant>";
	print "<h3><u>";
	&traduit("Client enregistré");
	print "</u></h3>";
	print "<form name=existe method=POST>";
	print "<input type=hidden name=produit_id>";
	print "<input type=hidden name=action value=connu>";
	&traduit("J'ai déjà commandé.");
	print "<br>";
	print "Adresse email: <input type=text name=email><br>";
	print "Mot de passe: <input type=password name=password><br>";
	print "<input type=submit value=Connexion>";
	# print "</form>";
	# print "<form>";
	# print "<input type=hidden name=action value=oublier>";
	print "<br> <input type=submit value='";
	&traduit("Mot de passe oublié");
	print "' onclick=document.existe.action.value='oublier'>";
	print "</form>";
	print "</div>";
	$action="ouverture_session";
}

if ($action eq "modif_click"){
	$gender=$html->param("gender");
	$nom=$html->param("lastname") ;
 	$prenom=$html->param("firstname" );
	$email=$html->param("email_address");
	$rue=$html->param("street_address");
	$complement=$html->param("suburb");
	$codepostal=$html->param("postcode");
	$ville=$html->param("city");
	$pays=$html->param("country");
	$telephone=$html->param("telephone");
	$password=$html->param("password");
	$fonction=$html->param("fonction");
	$organisme=$html->param("organisme");
	$date=$html->param("date");
	
	&save("replace  into client_web value ('$client_id','$gender','$nom','$prenom','$email','$rue','$complement','$codepostal','$ville','$pays','$telephone','$password','$fonction','$organisme','$date')","af");
	$action="";
	&traduit( "vos informations ont bien été modifié");
	$action="compte";
}

if ($action eq "modif_pass"){
	
	print "<form method=POST >";
	print "<table>";
	print "<tr><td>Mot de passe actuel:</td><td><input type= password name=ancien size=8></td></tr>";
	print "<tr><td>Nouveau mot de passe:</td><td><input type= password name=nouveau1 size=8></td></tr>";
	print "<tr><td>Confirmation du nouveau mot de passe:</td><td><input type=password name=nouveau2 size=8></td></tr>";
	print "</table>";
	print "<input type=submit >";
	print "<input type=hidden name=action value=nouveau_pass>";
	print "</form>";
}
if (($action eq "choix_paiement")&&($pay eq "liv")){
	system("/var/www/cgi-bin/aircotedivoireshop/sendmail.pl $cde_id &");
#	
#	$host = $ENV{'HTTP_HOST'};
	&save("update cmd_web set paiement='livraison' where cde_id='$cde_id'");
#	print "<script>document.location.href=\"sup_session_cookie.pl?cle=$cle&host=$host\"</script>";
	$session->param('order_id','');
	$cle=&generate_random_string(11);
	$session->param('cle',$cle);
	&merci();

}

if ($action eq "apresup"){
	print "<h2>";
	&traduit("Votre commande vient d'être prise en compte !");
	print "</h2>";
	print "<br><form method=POST><div>";
	&traduit("Votre commande vient d'être enregistrée par notre système ! un mail de confirmation vous a été envoyé");
	print "<br />";
	&traduit("Vos produits vous seront livrés par le personnel naviguant à bord de l'avion que vous avez indiqué ");
	print "<br><b>Merci d'avoir fait vos achats en ligne avec nous !</b><br>";
	print "<input type=submit value=Continuer>";
	print "</form>";
	print "</div>";

}

if (($action eq "commander")&&($client_id !=999999)){
	print "<h2>Information Voyage</h2><br />";
	print "<p>";
	&traduit("Nous informons notre aimable clientèle qu’elle ne peut acheter des produits hors taxe que si vous voyagez sur un vol à destination d'un pays étranger. Aucune livraison ne sera faite à votre domicile. afin d'enregistrer votre commande , nous demandons de renseigner les informations de vol");
	print "</p><br />";
print <<EOF;
<script>
function check() {
		var msg = '';
		if (document.formulaire.reservation.value == \"\")	{
			document.formulaire.reservation.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un no de reservation\\n\";
		}
		if (document.formulaire.depart.value == \"\")	{
			document.formulaire.depart.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un aeroport de depart\\n\";
		}
		if (document.formulaire.arrivee.value == \"\")	{
			document.formulaire.arrivee.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un aeroport d arrivee\\n\";
		}
		if (document.formulaire.date_vol.value == \"\")	{
			document.formulaire.date_vol.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre une date de vol\\n\";
		}
		if (document.formulaire.no_vol.value == \"\")	{
			document.formulaire.no_vol.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un no de vol\\n\";
		}
		if (msg == \"\") return(true);
		else	{
			alert(msg);
			return(false);
		}
	}
</script>


<form name=formulaire method=POST onSubmit="return check()";>
<input type=hidden name=produit_id>
<input type=hidden name=action value=info_paie>
<span class="inputRequirement" style="float: right;">* Information requise</span>
    <h2>
EOF
&traduit("Les informations de votre vol");
print <<EOF;
</h2>
  <div class="contentText">
    <table border="0" cellspacing="2" cellpadding="2" width="100%">
     <tr>
        <td class="fieldKey">No de reservation :</td>
        <td class="fieldValue"><input type="text" name="reservation"/>&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr>
        <td class="fieldKey">Aeroport de depart :</td>
        <td class="fieldValue"><input type="text" name="depart" />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr> 
        <td class="fieldKey">Aeroport d arrivee :</td>
        <td class="fieldValue"><input type="text" name="arrivee" />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr>
        <td class="fieldKey">Date du vol (JJ/MM/AAAA):</td>
        <td class="fieldValue"><input type="text" name="date_vol" id=datepicker />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
	    <tr>
        <td class="fieldKey">No du vol </td>
        <td class="fieldValue"><input type="text" name="no_vol" />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
    </table>
  </div>
  <input type=submit value=continuer>
  </form>
EOF
}



if ($action eq "info_paie"){

	print "<h2>Information Paiement</h2><br />";
	print "<h3><u>Mode paiement</u></h3><br />";
 	$cde_id=&get("select cde_id from cmd_web where cle='$cle' and client_id='$client_id'");
	if ($cde_id eq ""){
		&save("insert ignore into cmd_web values ('','$cle','$client_id',curdate(),'')","af");
		&save("update panier set client_id='$client_id' where client_id=999999 and cle='$cle'","af");
		$cde_id=&get("select cde_id from cmd_web where cle='$cle' and client_id='$client_id'");
	}
	$session->param('cde_id',$cde_id);
	&save("delete from panier_web where cde_id='$cde_id'");
	$query="select produit_id from panier where panier.cle='$cle' and panier.client_id='$client_id'";
	# print "$query";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($produit_id)=$sth->fetchrow_array){
		$query="select products_price from products where products_id=$produit_id";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($prix)=$sth2->fetchrow_array;
		&save ("insert ignore into panier_web values ('$cde_id','$produit_id','$prix')","af");
	}
	$reservation=$html->param("reservation");
	$depart=$html->param("depart");
	$arrivee=$html->param("arrivee");
	$date_vol=$html->param("date_vol");
	$no_vol=$html->param("no_vol");

	&save ("replace into infovol_web values ('$cde_id','$reservation','$depart','$arrivee','$date_vol','$no_vol')");
	$montant=&get("select sum(products_price) from products,panier where products_id=panier.produit_id and panier.cle='$cle' and panier.client_id='$client_id'","af")+0;
	print "<div>";
	print "Montant:$montant XOF<br />";
	print "<form method=POST>";
	print "<input type=hidden name=produit_id>";
	print "<input type=hidden name=action value=choix_paiement>";
	&traduit ("Veuillez choisir la méthode de paiement à utiliser pour cette commande"). 
	print "<br />";
	&traduit("Paiement à la livraison ");
	print "<input type=radio name=pay value=liv ><br />";
	&traduit("Paiement par CB ");
	print "<input type=radio value=carte name=pay checked><br />";
	# print "<input type=hidden name=cde_id value='$cde_id'>";
	print "<br><input type=submit value=Continuer>";
	print "</form>";
	print "</div>";
}

if ($action eq "pay"){
	print "<h2>Confirmation de Commande</h2><br />";
	print "<h3><u>Information sur la livraison </u></h3><br />";
	print "<div>";
	print "<input type=hidden name=produit_id>";
	print "<input type=hidden name=action value=confirme>";
	print "<table>";
	print "<tr><td> information livraison et paiement</td><td> Information produit</td>";
	print "</table>";
	print "<br><input type=submit value=Confirmer>";
	print "</form>";
	print "</div>";
}

if ($action eq "retour_cb"){
	$cbon=0;
	print "<h2>";
	&traduit("Votre commande vient d'être prise en compte !");
	print "</h2>";
	print "<br><form method=POST><div>";
	&traduit("Votre commande vient d'être enregistrée par notre système !");
	print "<br />";

	
	$code=$html->param("code");
	$response_code=$html->param("response_code");
	while($response_code=~s/'//){};
	$erreur=$html->param("erreur");
	# print "$code $response_code $erreur $cde_id";
	if (( $code eq "" ) && ( $error eq "" ) )
	{
 	print "<BR><CENTER>erreur appel response</CENTER><BR>";
 	print "executable response non trouve : $path_bin";
    	print "</body></html>";
	};

	if ( $code != 0 )
		{
		print "<BR><CENTER>erreur appel API de paiement</CENTER><BR>";
		print "message erreur : $error";
		print "</body></html>";
	};
	if ($response_code eq "00"){
		$cbon=1;
		$verif=&get("select count(*) from sherlock where cde_id='$cde_id'")+0;
		if ($verif==0){
			&traduit( "Votre paiement par carte semble valide , mais il nous manque la confirmation de la banque , nous vous invitons à contacter nos services ref cde:$cde_id");
			print "<br>";
		}	
		else {
			&traduit( "Votre paiement par carte bancaire à bien été pris en compte, un mail de confirmation vous a été envoyé");
			print "<br \>";
			&traduit("Vos produits vous seront livrés par le personnel de bord pendant votre voyage");
			print "<br \>";
			print "<br \><b>Merci d'avoir fait vos achats en ligne avec nous !</b><br \>";
	
		#	&merci();
		}
	}
	else
	{
		&traduit(&retour_code($response_code));
		print "<br />";
		&traduit( "désolé votre paiement n'a pas été pris en compte");
		print "<br />";
	}
	if ($cbon==1){
		&save("delete from  panier where cle='$cle'  and client_id='$client_id' ");
		print "<script> document.getElementById('panier').style.visibility='hidden';</script>";
		$session->param('order_id','');
		$cle=&generate_random_string(11);
		$session->param('cle',$cle);
	}
	print "<input type=submit value=Continuer>";
	print "</form>";
	print "</div>";
		
}

if ($action eq "call_request"){
	# Affectation des paramètres obligatoires
	
	print "<p>";
	&traduit("Vous allez être rediriger vers le serveur sécurisé de notre partenaire bancaire");
	print "<br>";
	&traduit("Un lien vous permetra de revenir à notre boutique");
	print "</p>";
	$montant=int ($montant*0.0015);
	&traduit("Le montant qui sera débité est obligatoirement en euro son montant est de ");
	print "<b>$montant Euro</b>";
	print "<br>";
	$montant=$montant*100;
	$date=ici
	$date = `/bin/date '+%Y%m%d%H%M%S'`;
	print "<form method=POST action=https://paiement.systempay.fr/vads-payment/>";
	$vads_action_mode="INTERACTIVE";
	$vads_amount=$montant;
	$vads_ctx_mode="TEST";
	$vads_currency="978";
	$vads_page_action="PAYMENT";
	$vads_payment_config="SINGLE";
	$vads_site_id="77360931";
	$vads_trans_date=$date;
	$vads_trans_id=&generate_random_string2(6);
	$vads_version="V2";
	$certificat="3458311677213718";
	$cle=$vads_action_mode."+".$vads_amount."+".$vads_ctx_mode."+".$vads_currency."+".$vads_page_action."+".$vads_payment_config."+".$vads_site_id."+".$vads_trans_date."+".$vads_trans_id."+".$vads_version."+".$certificat;
	$signature=sha1_hex($cle);
	#  print "$cle<br>";
	#  print sha1_hex("INTERACTIVE+100+TEST+978+PAYMENT+SINGLE+77360931+20140301080000+fCikqT+V2+3458311677213718");
	print "<input type=hidden name=vads_action_mode value=$vads_action_mode>";
	print "<input type=hidden name=vads_amount value=$vads_amount> ";
	print "<input type=hidden name=vads_ctx_mode value=$vads_ctx_mode>";
	print "<input type=hidden name=vads_currency value=$vads_currency>";
	print "<input type=hidden name=vads_page_action value=$vads_page_action>";
	print "<input type=hidden name=vads_payment_config value=$vads_payment_config>";
	print "<input type=hidden name=vads_site_id value=$vads_site_id>";
	print "<input type=hidden name=vads_trans_date value=$vads_trans_date>";
	print "<input type=hidden name=vads_trans_id value=$vads_trans_id>";
	print "<input type=hidden name=vads_version value=$vads_version>";
	print "<input type=hidden name=signature value=$signature>";
	print "<input type=submit value=payez>";
	print "</form>";
}
if ($action eq "mdp"){
	$client_id=&get("select client_id from client_web where email='$log' ");
	if ($client_id eq ""){
		&traduit("Désolé il n'y aucun client d'enregistré avec cet email");
		print "<br>";
		$action="oublier";
		$client_id=999999;
	
	}
	else
	{
		print "<p class=message>";
		&traduit("Votre demande a été prise en compte un mail vient de vous être envoyé");
		print "</p>";
		system("/var/www/cgi-bin/aircotedivoireshop/sendmail_pwd.pl $client_id &");
		$client_id=999999;
		&accueil();
	}
}

if ($action eq "oublier"){
	&traduit("Si vous avez oublié votre mot de passe, entrez votre adresse électronique ci-dessous et nous vous enverrons un courrier électronique contenant votre nouveau mot de passe.");
	print "<form method=POST>";
	print "Adresse email <input type=text name=log size=20 value=".$html->param("email").">";
	print "<br> <input type=hidden name=action value=mdp>";
	print "<input type=submit  value=envoyer>";
	print "</form><br>";
	print "<form method=POST>";
	print "<input type=submit  value=retour>";
	print "</form>";
}


if ($action eq "nouveau_pass"){
	$ancien=$html->param("ancien");
	$nouveau1=$html->param("nouveau1");
	$nouveau2=$html->param("nouveau2");
	$message="";
	if ($ancien ne ""){
		$password_c=md5($ancien);
		$check=&get("select count(*) from client_web where client_id='$client_id'  and password='$password_c'","af")+0;
		if ($check==0){$message="Ancien mot de passe invalide<br>";} 
		if ($nouveau1 ne $nouveau2){$message="Mot de passe de confirmation different du nouveau mot de passe<br>";}
		if ($message eq ""){
			$password_c=md5($nouveau1);
			&save("update client_web set password='$password_c' where client_id='$client_id'");
			print "<p class=message>";
			&traduit("Mot de passe mis à jour");
			print "</p>";
			$action="";
		}
		else
		{
			print "<p class=message>$message</p>";
			$action="modif_pass";
		}
	}
}
if ($action eq ""){&accueil();}

if (($action eq "nouveau")||($action eq "compte")){
	if ($action eq "compte"){
		$query="select * from  client_web where client_id='$client_id'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($null,$gender,$nom,$prenom,$email,$rue,$complement,$codepostal,$ville,$pays,$telephone,$password,$fonction,$organisme,$date)=$sth->fetchrow_array;
	}	
print <<EOF;
<script>
function verifmail(mailteste)
{
	var reg = new RegExp('^[a-z0-9]+([_|\.|-]{1}[a-z0-9]+)*@[a-z0-9]+([_|\.|-]{1}[a-z0-9]+)*[\.]{1}[a-z]{2,6}\$', 'i');
	if(reg.test(mailteste))
	{
		return(true);
	}
	else
	{
		return(false);
	}
}	
function check() {
		var msg = '';
		if (document.formulaire.gender.value == \"\")	{
			document.formulaire.gender.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un genre\\n\";
		}
		if (document.formulaire.lastname.value == \"\")	{
			document.formulaire.lastname.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un nom\\n\";
		}
		if (document.formulaire.firstname.value == \"\")	{
			document.formulaire.firstname.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un prenom\\n\";
		}
		if (document.formulaire.email_address.value == \"\")	{
			document.formulaire.email_address.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un mail\\n\";
		}
		if (document.formulaire.street_address.value == \"\")	{
			document.formulaire.street_address.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre une rue\\n\";
		}
		if (document.formulaire.postcode.value == \"\")	{
			document.formulaire.postcode.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un code postal\\n\";
		}
		if (document.formulaire.city.value == \"\")	{
			document.formulaire.city.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre une ville\\n\";
		}
		if (document.formulaire.country.value == \"\")	{
			document.formulaire.country.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un pays\\n\";
		}
		if (document.formulaire.telephone.value == \"\")	{
			document.formulaire.telephone.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un telephone\\n\";
		}
		if (document.formulaire.password.value == \"\")	{
			document.formulaire.password.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un mot de passe\\n\";
		}
		if (document.formulaire.password.value != document.formulaire.confirmation.value)	{
			document.formulaire.confirmation.backgroundColor = \"#F4AAC3\";
			msg += \"Mots de passe differents\\n\";
		}
		if (! verifmail(document.formulaire.email_address.value)){
			document.formulaire.email_address.style.backgroundColor = \"#F4AAC3\";
			msg += \"Mail invalide\\n\";
		}
		if (msg == \"\") return(true);
		else	{
			alert(msg);
			return(false);
		}
	}
</script>
<form name=formulaire method=POST onSubmit="return check()";>
<input type=hidden name=produit_id>
<span class="inputRequirement" style="float: right;">* Information requise</span>
    <h2>
EOF
&traduit("Vos détails personnels");
print <<EOF;
</h2>
  <div class="contentText">
    <table border="0" cellspacing="2" cellpadding="2" width="100%">
     <tr>
        <td class="fieldKey">Genre :</td>
EOF
        print "<td class=\"fieldValue\"><input type=\"radio\" name=\"gender\" value=\"m\""; 
	if ($gender eq "m"){print " checked";}
	print " />&nbsp;&nbsp;Homme&nbsp;&nbsp;<input type=radio name=gender value=\"f\"";
	if ($gender eq "f"){print " checked";}
	print "/>&nbsp;&nbsp;Femme&nbsp;<span class= \"inputRequirement\">*</span></td>";
print <<EOF;

	</tr>
      <tr>
        <td class="fieldKey">Pr&eacute;nom :</td>
        <td class="fieldValue"><input type="text" name="firstname" value='$prenom' />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr> 
        <td class="fieldKey">Nom :</td>
        <td class="fieldValue"><input type="text" name="lastname" value='$nom' />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
     <tr>
        <td class="fieldKey">Adresse email:</td>
        <td class="fieldValue"><input type="text" name="email_address" value='$email'  onfocus=alert("Attention cela va modifier egalement votre login de connexion")>&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
    </table>
  </div>
  <h2>Votre adresse</h2>
  <div class="contentText">
    <table border="0" cellspacing="2" cellpadding="2" width="100%">
      <tr>
        <td class="fieldKey">No et rue :</td>
        <td class="fieldValue"><input type="text" name="street_address" value='$rue' />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr>
        <td class="fieldKey">compl&eacute;ment d'adresse:</td>
        <td class="fieldValue"><input type="text" name="suburb" value='$complement' />&nbsp;</td>
      </tr>
      <tr>
      <td class="fieldKey">Code postal :</td>
        <td class="fieldValue"><input type="text" name="postcode" value='$codepostal' />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr>
        <td class="fieldKey">Ville: </td>
        <td class="fieldValue"><input type="text" name="city" value='$ville' />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr>
        <td class="fieldKey">Pays :</td>
EOF
print "<td class=\"fieldValue\"><select name=\"country\">";
	&liste_pays();
	$i=1;
	foreach (@liste_pays) {
		print "<option value=\"$i\" ";
		if ($i eq $pays){print "selected";}
		print ">$_</option>";
		$i++;
	}
print <<EOF;
	</select>&nbsp;<span class="inputRequirement">*</span></td>
        </tr>
    </table>
  </div>
  <h2>Contact</h2>
  <div class="contentText">
    <table border="0" cellspacing="2" cellpadding="2" width="100%">
      <tr>
        <td class="fieldKey">Num&eacute;ro de t&eacute;l&eacute;phone :</td>
        <td class="fieldValue"><input type="text" name="telephone" value='$telephone' />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      </table>
  </div>
EOF
 if ($action eq "compte"){
print <<EOF;
	<input type=hidden name=password value='$password'>
	<input type=hidden name=action value=modif_click>
	<br /> <input type=submit value="Modifier mes informations"><br />
EOF
# 		$panier_existe=&get("select count(*) from panier where panier.cle='$cle' and panier.client_id='$client_id'")+0;
		if (panier_existe()){print  "<input type=submit value=\"Etape suivante\" Onclick=document.formulaire.action.value=\"commander\">";}
		else
		{print  "<input type=submit value=\"Continuer\" Onclick=document.formulaire.action.value=\"\">";}
	print "</form>
	
	<form method=POST>
	<input type=hidden name=action value='modif_pass'>
	<input type=submit value=\"Modifier mon mot de passe\">
	</form>";
	}
else {
print <<EOF;	 
    <h2>Votre mot de passe</h2>
  <div class="contentText">
    <table border="0" cellspacing="2" cellpadding="2" width="100%">
      <tr>
        <td class="fieldKey">Mot de passe :</td>
        <td class="fieldValue"><input type="password" name="password" maxlength="40" />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
      <tr>
        <td class="fieldKey">Mot de passe de confirmation :</td>
        <td class="fieldValue"><input type="password" name="confirmation" maxlength="40" />&nbsp;<span class="inputRequirement">*</span></td>
      </tr>
    </table>
  </div>
  <input type=hidden name=action value=nouveau_click>
  <input type=submit value=continuer>
  </form>
EOF
}
}
&footer();



sub entete {
print <<EOF;
<head>
	<link rel="stylesheet" media="screen" href="http://openfontlibrary.org/face/open-baskerville" rel="stylesheet" type="text/css"/> 
	<style type="text/css">
	<!--
	body {
		font-size:0.8em;  ;
		color: rgb(50,50,50);
		text-align: center ;
		background: #000 ;
	}
	* 
	{
		margin-top: 0pt;
		margin-right: 0pt;
		margin-bottom: 0pt;
		margin-left: 0pt;
		padding-top: 0pt;
		padding-right: 0pt;
		padding-bottom: 0pt;
		padding-left: 0pt;
		font-family:'Open Baskerville 0.0.53' 'Times New Roman' ;
}
.contentText
	{
		font-size:0.5em;
}
	div#conteneur
	{
		width: 770px ;
		margin: 0 auto ;
		text-align: left ;
		border: 2px solid #F5DCD7 ;
		background: #fff ;
	}
	#liste
	{
		clear:both ;
		background: green ;
	}
	#vignette
	{
		float:left;
		width: 100px;
		height:130px;
		background:#F5DCD7 ;
		color: #000 ;
		font-size:8px;
		text-align: center ;
		border: 1px solid #600 ;
		margin-right: 8px ;
		margin-top: 8px ;
		overflow: hidden;
		border-radius:10px 0 0 0;
	
	}
	#vignette a {
		display: block ;
		color: #000 ;
		line-height: 1em ;
		text-align: center ;
		text-decoration: none ;
		padding: 4px 0 ;
	}
	#vignette  a:hover, #vignette  a:focus, #vignette  a:active {
		display: block ;
		height:120px;
		background: #785341 ;
		color: white ;
		text-decoration: none ;
	}
	
	
	
	#vignette img
	{
		padding-bottom: 2px ;
	}
	
	#contenu
	{
			clear:both;
			 padding: 20px 30px 50px 50px ;
	}
	#header
	{
		height: 230px;
               width: 770px;
		display:block;
		height: 230px;
		background: url(http://aircotedivoireshop.oasix.fr/header.jpg) no-repeat left top;
		text-indent:-99999px;
	}
	
#navigation {
		list-style: none;
		margin-left: 50px ;
		margin-top:20px;
		border-radius:10px;
	}
	#navigation li  {
		float:left;
		width: 100px;
		height:40px;
		/* color: black ;
		text-shadow: 0 -1px black;
		border: 1px solid #600 ;
		box-shadow:2px 2px 2px black; 
		border-radius:10px;
		line-height: 1em ;
		text-align: center ;
		padding: 2px 0 ;*/ 
		margin-right: 8px ;
		display: block ;
		
	}
	#navigation  a {
		width: 100px;
		height:40px;
		/* background: #785341; */
		/* background:linear-gradient(to right, #785341,#785341,#785341, #F5DCD7); */
		 color: black ;
		text-decoration:none;
		text-shadow: 0 -1px black;
		border: 1px solid #600 ;
		box-shadow:2px 2px 2px black; 
		margin-right: 8px ;
		border-radius:10px;
		-moz-border-radius: 10px;
		-webkit-border-radius: 10px;
		border-radius: 10px;
		behavior: url(/PIE.htc);
		line-height: 1em ;
		text-align: center ;
		padding: 2px 0 ; 
		display: block ;
		
	}
	
	#navigation li a:hover, #navigation li a:focus, #navigation li a:active {
		/* display: block ;
		height:40px; */
		background: #F5DCD7 ;
		color: #000 ;
		text-shadow: 0 0;
		/*text-decoration: none ;
		border-radius:10px; */
	}
	#footer
	{
	clear:both;
	width:700px;
	height:100px;
	margin: 0 ;
	}

	p#copyright
	{
	margin: 0 ;
	color:#785341;
	text-align: right ;
	padding-top:60px;
	}
	#panier
	{
	float:left;
	margin: 0 ;
	visibility:hidden;
	padding-top:20px;
	}
	
	#prix
	{
		float:left;
		width:100px;
		text-align:right;
		padding-top: 45px ;
		padding-right: 10px ;
		font-weight:bold; 
	}
	#desi
	{
		width:300px;
		float:left;
		padding-top: 45px ;
		padding-left: 10px ;
		
	}
	#image
	{
		clear:both;
		float:left;
	}
	#sup
	{
		padding-top: 42px ;
		float:left;
	}
	#nouveau_client
	{
		width:300px;
		padding-top: 10px ;
		border-right: 1px dashed #000000;
		float:left;
	}
	#client_existant
	{
		padding-top: 10px ;
		padding-left: 20px ;
	
		float:left;
	}
	
	#sup button
	{
		color:red;
	}
	.inputRequirement
	{
		color:red;
	}
	.message
	{
		background-color:#F5DCD7;
	}

	#total
	{
		clear:both;
		padding-top: 42px ;
		font-weight:bold; 
	}
	-->
	</style>
EOF
require "../oasix/jquery_marron.pl";
print "
</head>
<body>
<div id=conteneur>

<div id=header><a href=http://aircotedivoireshop.oasix.fr id=header>aircotedivoireshop</a></div>
<form name=lien method=POST>
<input type=hidden name=action value=menu>
<input type=hidden name=menu >
<ul id=\"navigation\">
  <li><a href=# onclick=document.lien.menu.value=22;document.lien.submit()>Parfums Femmes</a></li>
  <li><a href=# onclick=document.lien.menu.value=23;document.lien.submit()>Parfums Hommes</a></li>
  <li><a href=# onclick=document.lien.menu.value=25;document.lien.submit()>Cosmetiques</a></li>
  <li><a href=# onclick=document.lien.menu.value=27;document.lien.submit()>Montres</a></li>
  <li><a href=# onclick=document.lien.menu.value=26;document.lien.submit()>Bijouteries</a></li>
 <li><a href=# onclick=document.lien.menu.value=28;document.lien.submit()>Cigares</a></li>
  </ul>
  </form>
  <div id=\"contenu\">";
}
sub footer{
	print "<div id=footer>";
	print "<a href=?action=panier><img id=panier src=http://aircotedivoireshop.oasix.fr/panier.png></a>";
	print "<p id=copyright>";
	&traduit("Copyright © 2012AirCotedIvoire Shop");
	print "</p>";
	print "</div>";
	print "</div></div>";
	if (panier_existe()){print "<script> document.getElementById('panier').style.visibility='visible';</script>";}
	else{print "<script> document.getElementById('panier').style.visibility='hidden';</script>";}
	print "</body>";
}

sub accueil{
 print "<h1> AIR COTE D IVOIRE SHOP </h1><p style=text-align:justify;>";
 &traduit("Bonjour et bienvenue sur le site  AirCotedIvoire  Shop  fournisseur exclusif de votre compagnie aérienne.");
 print "<br />";
 &traduit("Nous avons le plaisir de vous offrir un choix attractif de produits exclusivement vendus hors taxe.");
 print "<br />";
 &traduit("Nous vous proposons de les réserver de chez vous et de les faire livrer en hors taxe à votre siége dans l'avion.");
 print "<br />";
 &traduit("Nous vous informons que seuls les passagers voyageant à destination d'un pays étranger peuvent acheter des produits hors taxe.");
 print "<br />";
 &traduit("En outre et exclusivement vous payez soit en ligne en carte bleue ou soit à la livraison à bord de l'avion dans la devise choisie ( XOF/ XAF/ EURO/ DOLLAR) ET cartes bleues à puce VISA ou MASTERCARD (au taux de change en vigueur le jour de la livraison).");
 print "<br />";
 &traduit("En réservant aujourd'hui vous bénéficiez de la priorité de livraison des marchandises hors taxes par rapport aux passagers voyageant à bord du même avion.");
 print "<br />";
 &traduit("(contenu de la taille restreinte des emplacements le produit peut être indisponible ou pour des raisons de sécurité, les ventes à bord ne peuvent avoir lieu).");
 print "<br />";
 &traduit("Exclusif pour nos clients achetez hors taxe des produits rares et exceptionnels seulement vendus en ligne que nous livrons spécialement à votre siége !");
 print "<br />";
 &traduit("En devenant client, vous bénéficierez de privilèges exclusifs ( tarif promotionnel , offres exclusives , avantage membre ) .");
 print "<br />";
 &traduit("Nous vous rappelons que les tabacs et alcools ne peuvent acheter que par des personnes autorisées.");
 print "<br />";
 &traduit("Si vous possédez un compte vous pourrez au moment de la commande vous connecter, sinon il vous sera demandé de créer un compte ");
 print "<br />";
 print "</p><br /><br />";
 if ($client_id  == 999999){
	&cesame();
 }
 else
 {
		$query ="select nom,prenom from client_web where client_id='$client_id'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($nom,$prenom)=$sth->fetchrow_array;
		print "<p class=message>";
		print "<br><b>Bienvenue  $nom $prenom ";
		print "</p>";
		print "</b><table><tr><td><form method=POST>";
		print "<input type=hidden name=action value=logout>";
		print "<br> <input type=submit value=Deconnexion> ";
		print "</form></td><td>";
		print "<form method=POST>";
		print "<input type=hidden name=action value=compte>";
		print "<br> <input type=submit value='Mon compte'> ";
		print "</form></td></tr></table>";
 }
	
}
sub cesame {
		print "<form method=POST>";
		print "<table>";
		print "<tr><td>login (adresse email)</td><td><input type=text name=log size=20 ></td></tr>";
		print "<tr><td>Mot de passe</td><td> <input type=password name=password size=20 ></td></tr>";
		print "</table>";
		print "<table><tr><td>";
		print "<input type=hidden name=action value=connu>";
		print "<br><input type=submit value='connexion'>";
		print "</form>";
		print "</td><td>";
		print "<form method=POST>";
		print "<input type=hidden name=action value=oublier>";
		print "<br> <input type=submit value='";
		&traduit("Mot de passe oublié");
		print "'>";
		print "</form>";
		print "</td></tr></table>";
		print "<br \>";
}

sub merci {
	print "<h2>";
	&traduit("Votre commande vient d'être prise en compte !");
	print "</h2>";
	print "<br><form method=POST><div>";
	&traduit("Votre commande vient d'être enregistrée par notre système un mail de confirmation vous a été envoyé!");
	print "<br />";
	&traduit("Vos produits vous seront livrés par le personnel de bord pendant votre voyage ");
	print "<br>";
	print "<br><b>Merci d'avoir fait vos achats en ligne avec nous !</b><br>";
	print "<input type=submit value=Continuer>";
	print "</form>";
	print "</div>";
}

sub generate_random_string
{
	my $length_of_randomstring=shift;# the length of 
			 # the random string to generate

	my @chars=('a'..'z','A'..'Z','0'..'9','_');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}
sub traduit
{
	print encode_entities(decode('utf8',"$_[0]"));

}

sub retour_code{
	my $code=$_[0];
	if ($code eq "00"){return("Autorisation acceptée");}
	if ($code eq "02"){return("demande d’autorisation par téléphone à la banque à cause d’un dépassement de plafond d’autorisation sur la carte ");}
	if ($code eq "03"){return("Champ merchant_id invalide, vérifier la valeur renseignée dans la requête Contrat de vente à distance inexistant, contacter votre banque.");}
	if ($code eq "05"){return("Autorisation refusée");}
	if ($code eq "12"){return("Transaction invalide, vérifier les paramètres transférés dans la requête.");}
	if ($code eq "17"){return("Annulation de l’internaute");}
	if ($code eq "30"){return("Erreur de format.");}
	if ($code eq "34"){return("Suspicion de fraude");}
	if ($code eq "75"){return("Nombre de tentatives de saisie du numéro de carte dépassé. ");}
	if ($code eq "90"){return("Service temporairement indisponible");}
}
sub liste_pays{
	@liste_pays=("Afghanistan","Albanie","Algerie","Allemagne","American Samoa","Andorre","Angola","Anguilla","Antarctique","Antigua and Barbuda","Argentine","Armenie","Aruba","Australie","Autriche","Azerbaijan","Bahamas","Bahrain","Bangladesh","Barbados","Belarus","Belgique","Belize","Benin","Bermuda","Bhutan","Bolivia","Bosnie Herzegowine","Botswana","Bouvet Island","Brésil","British Indian Ocean Territory","Brunei Darussalam","Bulgarie","Burkina Faso","Burundi","Cambodje","Cameroun","Canada","Cape Verde","Cayman Islands","Central African Republic","Chad","Chili","Chine","Christmas Island","Chypres","Cocos (Keeling) Islands","Colombie","Comores","Confédération Hélvétique (Suisse)","Congo","Cook Islands","Costa Rica","Cote D&#;Ivoire","Croatie","Cuba","Dannemark","Djibouti","Dominican Republic","Dominique","East Timor","Ecuador","Egypte","El Salvador","Eritrée","Espagne","Estonie","Ethiopie","Falkland Islands (Malvinas)","Faroe Islands","Fiji","Finlande","France","France Corse","Gabon","Gambie","Georgie","
Ghana","Gibraltar","Grèce","Grenade","Groenland","Guadeloupe","Guam","Guatemala","Guinée Equatoriale","Guinea","Guinea-bissau","Guyana","Guyanne Française","Haiti","Heard and Mc Donald Islands","Honduras","Hong Kong","Hongrie","Iceland","India","Indonesia","Iran (Islamic Republic of)","Iraq","Ireland","Israel","Italie","Jamaica","Japan","Jordanie","Kazakhstan","Kenya","Kiribati","Korea, Democratic People&#;s Republic of","Korea, Republic of","Kuwait","Kyrgyzstan","Lao People&#;s Democratic Republic","Latvia","Lebanon","Lesotho","Liberia","Libyan Arab Jamahiriya","Liechtenstein","Lithuanie","Luxembourg","Macau","Macedonia, The Former Yugoslav Republic of","Madagascar","Malawi","Malaysie","Maldives","Mali","Malte","Marshall Islands","Martinique","Mauritanie","Mauritius","Mayotte","Mexico","Micronesia, Federated States of","Moldova, Republic of","Monaco","Mongolia","Montserrat","Morocco","Mozambique","Myanmar","Namibia","Nauru","Nepal","Netherlands (Pays-Bas)","Netherlands Antilles","New Zealand","Nicaragua","
Niger","Nigeria","Niue","Norfolk Island","Northern Mariana Islands","Norvège (Norway)","Nouvelle Calédonie","Oman","Pakistan","Palau","Panama","Papua New Guinea","Paraguay","Peru","Philippines","Pitcairn","Pologne (Poland)","Polynésie Française","Portugal","Puerto Rico","Qatar","République Tchèque","Reunion","Romania","Russian Federation","Rwanda","Saint Kitts and Nevis","Saint Lucia","Saint Pierre et Miquelon","Saint Vincent and the Grenadines","Samoa","San Marino","Sao Tome and Principe","Saudi Arabia","Senegal","Seychelles","Sierra Leone","Singapore","Slovakia (Slovak Republic)","Slovenie","Solomon Islands","Somalie","Soudan","South Africa","South Georgia and the South Sandwich Islands","Sri Lanka","St. Helena","Suriname","Svalbard and Jan Mayen Islands","Swaziland","Sweden","Syrian Arab Republic","Taiwan","Tajikistan","Tanzania, United Republic of","Terres Australes et Antarctiques Françaises","Thailand","Togo","Tokelau","Tonga","Trinidad and Tobago","Tunisia","Turkmenistan","Turks and Caicos Islands","
Turquie","Tuvalu","Uganda","Ukraine","United Arab Emirates","United Kingdom (Royaume Uni)","United States","United States Minor Outlying Islands","Uruguay","Uzbekistan","Vanuatu","Vatican City State (Holy See)","Venezuela","Viet Nam","Virgin Islands (British)","Virgin Islands (U.S.)","Wallis and Futuna Islands","Western Sahara","Yemen","Yugoslavia","Zaire","Zambie","Zimbabwe");
}
sub panier_existe {
	return(&get("select count(*) from panier where panier.cle='$cle' and panier.client_id='$client_id'")+0);
}		

sub generate_random_string2
{
	my $length_of_randomstring=shift;# the length of 
			 # the random string to generate

	my @chars=('0'..'9');
	my $random_string;
	foreach (1..$length_of_randomstring) 
	{
		# rand @chars will generate a random 
		# number between 0 and scalar @chars
		$random_string.=$chars[rand @chars];
	}
	return $random_string;
}

=pod
au premier panier si la session n'est pas initialisé , je la crée
le fichier panier suis la session
au moment de la demande de mode de paiement, je bascule panier dans panier_web et je cré la commande (cmd_web), je modifie client_id dans panier


=cut
