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
print $html->header();
use Encode;

$cle = $session->param('cle');
$langue= $session->param('langue');
$cde_id=$session->param('cde_id');
$action=$html->param("action");
$page=$html->param("page");
$case=$html->param("case");
$code=$html->param("code");
$prix=$html->param("prix");
$cat=$html->param("cat");

if ($html->param("langue") ne ""){$langue=$html->param("langue");}
$site_retour="http://www.aircotedivoire.com/";
$base_sql="aircotedivoire";
$compagnie="Air Cote d'ivoire";
$base_site="aircotedivoireshop.oasix.fr";
$base_site_cgi="aircotedivoireshop";
$mag="lemag23";
require "../oasix/outils_perl2.pl";
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=$base_sql","web","admin",{'RaiseError' => 1});
&entete();
if ($langue eq ""){$langue="F";}
if ($action eq "langue"){
	$session->param('langue',$langue);
	$langue= $session->param('langue');
	$action="";
}

if ($cle eq ""){
      $session = new CGI::Session("driver:File",undef,{'Directory'=>"/tmp/apache"});
      $cle=&generate_random_string(11);
      # Inscription de la variable dans la session sur le serveur
      $session->param('cle',$cle);
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
      print "<script>document.location.href=\"set_session_cookie.pl?cle=$id&host=$host\"</script>";
}
if ($action eq "plus"){
	&save("update panier set qte=qte+1 where cle='$cle' and code='$code'");
	$action="panier";
}	
if ($action eq "moins"){
	&save("update panier set qte=qte-1 where cle='$cle' and code='$code'");
	$action="panier";
}	
if ($action eq "sup"){
	&save("delete from panier where cle='$cle' and code='$code'");
	$action="panier";
}	
if ($action eq "add"){
	$code+=0;
	if ($code>0){
		$query="select pr_desi,prix,prix_xof from mag,produit where mag='$mag' and produit.pr_cd_pr=code and code='$code'";
		$sth=$dbh->prepare($query);
		$sth->execute();
		($desi,$prix,$prix_xof)=$sth->fetchrow;
		if ($prix >0){&save("insert ignore into panier values('$cle','$code','1','$prix')","af");}
	}
	$action="";
	$modal=1;
	$code_modal=$code;
}
if ($action eq "panier"){
	$action="";
	$cat=1;
	$modal_panier=1;
}

if ($action eq "modal"){
	print <<EOF;
	<div class="modal-header">
	<button type="button" class="close" data-dismiss="modal">&times;</button>
	</div>
	<div class=modal-body>
	<h3>
	Produit mis dans votre panier.
	</h3>
EOF
	$query="select code,pr_desi,prix,prix_xof from mag,produit where mag='$mag' and  produit.pr_cd_pr=code and code='$code'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($code,$desi,$prix,$prix_xof)=$sth->fetchrow_array;
	$query="select texte_f,texte_a,image_s,image_l from dfc.produit_mag where code='$code'";
	$sth2=$dbh->prepare($query);
    $sth2->execute();
    ($texte_f,$texte_a,$image_s,$image_l)=$sth2->fetchrow_array;
	if ($texte_f eq ""){$texte_f="Lorem ipsum dolor sit amet, consectetur adipiscing elit.";}
	if ($image_l eq ""){$image_l="320x150.png";}

	print "
	<img src=/images/$image_s alt=\"\" style=width:150px>
	<h5>$desi $prix €</h5>
	";
	print "</div>";
print <<EOF;
<div class="modal-footer">
        <button class="btn btn-info" data-dismiss="modal">Fermer</button>
</div>	
EOF
	
	exit;
}

if ($action eq "aff_panier"){
	print <<EOF;
	<div class="modal-header">
	<button type="button" class="close" data-dismiss="modal">&times;</button>
	</div>
	<div class="modal-body">
EOF
	print "<div id=apresclick>";
	print "<form name=panier>";
	print "<input type=hidden name=code>";
	print "<input type=hidden name=action>";
	$query="select code,qte,prix from panier where cle='$cle'";
	print "<div>";
	
	print "<h3>";
	&traduit("RÃ©sumÃ© de votre panier");
	print "</h3>";
	print "<table class=\"table table-bordered table-striped table-condensed\"><tr><th>Produit</th><th>Montant</th><th>Qte</th><th>Total</th><th colspan=3>Action</th></tr>";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code,$qte,$prix)=$sth->fetchrow_array){
		$prix=int($prix);
 		$desi=&get("select pr_desi from produit where pr_cd_pr=$code");
		print "<tr><td>$desi</td><td align=right>$prix EUR</td>";
		print "<td align=right>$qte</td>";
		$total_int=$qte*$prix;
		print "<td align=right>$total_int</td>";
		print "<td><span class=\"glyphicon glyphicon-plus\" style=cursor:pointer onclick=document.panier.code.value='$code';document.panier.action.value='plus';document.panier.submit()></span></td>";
		if ($qte>1) {
			print "<td><span class=\"glyphicon glyphicon-minus\" style=cursor:pointer onclick=document.panier.code.value='$code';document.panier.action.value='moins';document.panier.submit()></span></td>";
		}	
		print "<td><span class=\"glyphicon glyphicon-remove\" style=color:red;cursor:pointer onclick=document.panier.code.value='$code';document.panier.action.value='sup';document.panier.submit()></span></td>";
		print "</tr>";
		$total+=$qte*$prix;
	}
	print "</table>";
	print "</form>";
	print "<div id=total><h3>";
	if ($total <1){print "Panier Vide</div>";}
	else {
		print "Total:$total EUR</div></h3></div>";
		print "<form> <input type=hidden name=action value=commander>";
		print "<input type=submit value=commander class=\"btn btn-primary\"></form>";
	}
	print "<br><form>";	
	print "<input type=submit value='continuer mes achats' class=\"btn btn-success\">";
	print "</form>";
	print "</div>";
	print "</div>";
	print "</div>";
	print <<EOF;
<div class="modal-footer">
        <button class="btn btn-info" data-dismiss="modal">Fermer</button>
</div>	
EOF

	exit;
}

if ($action eq "aff_confirm"){
	print <<EOF;
	<div class="modal-header">
	<button type="button" class="close" data-dismiss="modal">&times;</button>
	</div>
	<div class="modal-body">
EOF
	print "<div><h3>";
	&traduit("Votre commande vient d'Ãªtre prise en compte !");
	print "</h3>";
	print "<br><form action=\"$site_retour\"><div>";
	&traduit("Votre commande vient d'Ãªtre enregistrÃ©e par notre systÃ¨me");
	print "<br />";
	&traduit("Vos produits vous seront livrÃ©s par le personnel naviguant Ã Â  bord de l'avion que vous avez indiquÃ© ");
	$mail=$html->param("mail");
	if ($mail ne ""){
	print "<br>";
	  &traduit("Un mail de confirmation Ã  Ã©tÃ© envoyÃ© Ã  l'adresse suivante:");
	  print $mail;
	}
	print "<br><b>Merci d'avoir fait vos achats en ligne avec nous !</b><br>";
	print "<input type=submit value=\"Retour Site $compagnie\">";
	print "</form>";
	print "</div>";
	print "</div>";
print <<EOF;
<div class="modal-footer">
        <button class="btn btn-info" data-dismiss="modal">Fermer</button>
</div>	
EOF
	exit;
}

if ($action eq "envoyer") {
	$reservation=$html->param("reservation");
	$depart=$html->param("depart");
	$arrivee=$html->param("arrivee");
	$date_vol=$html->param("date_vol");
	if (grep(/\//,$date_vol)) {
	  ($jj,$mm,$aa)=split(/\//,$date_vol);
	  $date_vol=$aa."-".$mm."-".$jj;
	}
	$no_vol=$html->param("no_vol");
	$nom=$html->param("nom");
	$prenom=$html->param("prenom");
	$mail=$html->param("mail");
	$blabla=$html->param("bla");
	$nom=~s/\'//g;
	$prenom=~s/\'//g;
	$reservation=~s/\'//g;
	$depart=~s/\'//g;
	$arrivee=~s/\'//g;
	$date_vol=~s/\'//g;
	$no_vol=~s/\'//g;
	$mail=~s/\'//g;
	$blabla=~s/\'//g;
	# &save ("insert into infocmd_web values ('','$nom','$prenom','$reservation','$depart','$arrivee','$date_vol','$no_vol','$mail','New','','')");
	$query="insert into infocmd_web values ('',?,?,?,?,?,?,?,?,'New','','',?)";
	my $sth = $dbh->prepare( $query );
	$sth->execute($nom,$prenom,$reservation,$depart,$arrivee,$date_vol,$no_vol,$mail,$blabla);
	
	$cde_id=&get("SELECT LAST_INSERT_ID() FROM infocmd_web");
	&save("insert into panier_web select '$cde_id',code,qte,prix,qte from panier where cle='$cle'","af");
	&save("delete from panier where cle='$cle'");
	system("/var/www/cgi-bin/$base_site_cgi/sendmail.pl $cde_id &");
	if ($mail ne ""){
	  system("/var/www/cgi-bin/$base_site_cgi/sendmail_client.pl $cde_id &");
	}
	$envoyer=1;
	$action="";
	$cat=1;
}
$query="select count(*),sum(qte*prix) from panier where cle='$cle'";
$sth=$dbh->prepare($query);
$sth->execute();
($item,$total_panier)=$sth->fetchrow_array;
	  
#if ($cat eq ""){$cat=1;}
print <<EOF;
    <!-- Navigation -->
        <nav class="navbar navbar-default" role="navigation">
        <div class="container">
		    <div>
			<img src="http://$base_site/image/logo_aci.png">
			</div>
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
				<a class="navbar-brand" href=?action=><img src="http://$base_site/image/logo_leshop.png"></a>
				<a class="navbar-brand" href=?action=panier><img src="http://$base_site/image/cad.png"></a>
				<span class="navbar-brand"> $item</span>
            </div>
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="navbar-collapse-1">
                <ul class="nav navbar-nav">
EOF
if ($langue ne "A"){
print <<EOF;
                    <li>
                        <a href="?cat=1">Parfums Femmes</a>
                    </li>
                    <li>
                        <a href="?cat=3">Parfums Hommes</a>
                    </li>
                    <li>
                        <a href="?cat=5">Cosmetiques</a>
                    </li>
					<li>
                        <a href="?cat=4">Montres</a>
                    </li>
					<li>
                        <a href="?cat=19">Ecriture</a>
                    </li>
					<li>
                        <a href="?cat=21">Accessoires</a>
                    </li>
					<li>
                        <a href="?cat=6">Bijouterie</a>
                    </li>
					<li><a href=?action=langue&langue=A>English</a></li>

EOF
}
else{
print <<EOF;
                    <li>
                        <a href="?cat=1">Women</a>
                    </li>
                    <li>
                        <a href="?cat=3">Men</a>
                    </li>
                    <li>
                        <a href="?cat=5">Cosmetics</a>
                    </li>
					<li>
                        <a href="?cat=4">Watches</a>
                    </li>
					<li>
                        <a href="?cat=19">Writing</a>
                    </li>
					<li>
                        <a href="?cat=21">Accessories</a>
                    </li>
					<li>
                        <a href="?cat=6">Jewelry</a>
                    </li>
					<li><a href=?action=langue&langue=F>Français</a></li>
EOF
}

print <<EOF;			
			    </ul>
            </div>
            <!-- /.navbar-collapse -->
        </div>
        <!-- /.container -->
    </nav>
EOF
if (($action eq "")&&($cat eq "")){
	&accueil();
}

else{
print <<EOF;			
    <!-- Page Content -->
    <div class="container">

        <div class="row">
            <div class="col-md-12">
EOF
# if ($action eq ""){&carousel();}
print <<EOF;
            <div class="row">
			<!-- <div class="col-md-12"> -->
				<div class="modal fade" id="infos"> 
					<div class="modal-dialog">
						<div class="modal-content"> </div>
					</div>
				</div>
			<!-- </div> -->	
			</div>
EOF

if ($action eq ""){&vignette();}
if ($action eq "commander"){&formulaire();}

print <<EOF;
            </div>

        </div>
    </div>
EOF

&pied();
}

sub traduit
{
	print encode_entities(decode('utf8',"$_[0]"));

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
sub entete
{
print '
<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>Aircotedivoire Shop</title>

	
	 <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
	
    <link href="http://fonts.googleapis.com/css?family=BenchNine:400,700" rel="stylesheet" type="text/css">
	<link href="http://fonts.googleapis.com/css?family=Dorsa" rel="stylesheet" type="text/css">

    <!-- Custom CSS -->
    <link href="http://aircotedivoireshop.oasix.fr/css/shop-aircotedivoire.css" rel="stylesheet">
  </head>
<body>
';
}


sub vignette
{
	print "<div class=\"row\">";
	$cat_group=$cat;
	if ($cat==9){
		$cat_group="9 or pr_famille=22 or pr_famille=15";
	}
	if ($cat==6){
		$cat_group="6 or pr_famille=7";
	}
	
	$query="select code,pr_desi,prix,prix_xof from mag,produit_plus,produit where mag='$mag' and produit_plus.pr_cd_pr=code and (pr_famille=$cat_group) and produit.pr_cd_pr=code";
	# print $query;
	$sth=$dbh->prepare($query);
	$sth->execute();
	while(($code,$desi,$prix,$prix_xof)=$sth->fetchrow){
		$query="select texte_f,texte_a,image_s,image_l from dfc.produit_mag where code='$code'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($texte_f,$texte_a,$image_s,$image_l)=$sth2->fetchrow_array;
		if ($image_l eq ""){next;}
		%stock=&stock($code);
		$pr_stre=$stock{"stock"};
		if ($pr_stre<5){next;}
		$texte=$texte_f;
		if ($langue eq "A"){
			$texte=$texte_a;
		}
		if ($image_l eq ""){$image_l="320x320.png";}
	print "
				
						<div class=\"col-sm-4 col-lg-4 col-md-4\">
							<div class=\"thumbnail\">
								<a href=?action=add&code=$code&cat=$cat><img src=/images/$image_l border=1 alt=\"\" ></a>
								<div class=\"caption\">
									<h5 class=\"pull-right\">$prix €</h5>
									<h5><a href=?action=add&code=$code&cat=$cat>$desi</a>
									</h5>
									<p class=small>$texte</p>
								</div>
							</div>
						</div>
	";
	}
	print "</div>";
}


sub formulaire
{
	print "<div class=\"row\">";
	print "<div class=\"col-6\">";
	print "<p style=font-size:1.3em;color:white>Information Voyage</p>";

	print "<p style=color:white>";
	print "Nous informons notre aimable clientèle qu'elle ne peut acheter des produits hors taxe que si vous voyagez sur un vol à destination d'un pays étranger. Aucune livraison ne sera faite à votre domicile. afin d'enregistrer votre commande, nous demandons de renseigner les informations de vol sur lequel vos produits vous seront remis";
	print "</p>";
print <<EOF;
<script>
	function verifMail(email){
              var myRegex = /^[a-z0-9._-]+@[a-z0-9._-]+\.[a-z]{2,6}\$/;
              if(!myRegex.test(email)){
                return false;
              }
              else{
                return true;
              }
       }
</script>

<script>
function verif_form()
{
		var msg = '';
		if (document.formulaire.nom.value == \"\")	{
			document.formulaire.nom.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre votre nom\\n\";
		}
		else {document.formulaire.nom.style.backgroundColor =\"\";}
		
		if (document.formulaire.prenom.value == \"\")	{
			document.formulaire.prenom.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre votre prénom\\n\";
		}
		else {document.formulaire.prenom.style.backgroundColor =\"\";}
		
		if (document.formulaire.mail.value == \"\")	{
			document.formulaire.mail.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre votre mail\\n\";
		}
		else {document.formulaire.mail.style.backgroundColor =\"\";}
		
		if (document.formulaire.mail.value != \"\")	{
		  if (! verifMail(document.formulaire.mail.value)){
			document.formulaire.mail.style.backgroundColor = \"#F4AAC3\";
			msg += \"Mail invalide\\n\";
		  }
		}
				
		if (document.formulaire.reservation.value == \"\")	{
			document.formulaire.reservation.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un no de reservation\\n\";
		}
		else {document.formulaire.reservation.style.backgroundColor =\"\";}
		
		if (document.formulaire.depart.value == \"\")	{
			document.formulaire.depart.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un aeroport de depart\\n\";
		}
		else {document.formulaire.depart.style.backgroundColor =\"\";}
		
		if (document.formulaire.arrivee.value == \"\")	{
			document.formulaire.arrivee.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un aeroport d arrivee\\n\";
		}
		else {document.formulaire.arrivee.style.backgroundColor =\"\";}
		
		if (document.formulaire.date_vol.value == \"\")	{
			document.formulaire.date_vol.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre une date de vol\\n\";
		}
		else {document.formulaire.date_vol.style.backgroundColor =\"\";}
		
		if (document.formulaire.no_vol.value == \"\")	{
			document.formulaire.no_vol.style.backgroundColor = \"#F4AAC3\";
			msg += \"Merci de mettre un no de vol\\n\";
		}
		else {document.formulaire.no_vol.style.backgroundColor =\"\";}
		if (msg == \"\") return(true);
		else	{
			alert(msg);
			return(false);
		}
}
</script>

<form name=formulaire style="background-color:#CCC;padding:20px" accept-charset="utf-8" onSubmit=return(verif_form()); >
<input type=hidden name=action value=envoyer>
<span class="inputRequirement" >Tous les champs sont obligatoires</span>
EOF

print <<EOF;
    <Legend>Les informations de votre vol</legend>
	<div class="form-group">
		<label for="texte">Nom : </label>
		<input name="nom" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="texte">Pr&eacute;nom : </label>
		<input name="prenom" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="texte">No de r&eacute;servation :</label>
		<input name="reservation" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="texte">A&eacute;roport de d&eacute;part :</label>
		<input name="depart" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="texte">A&eacute;roport d'arriv&eacute;e :</label>
		<input name="arrivee" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="dtp_input2" class="control-label">Date du vol Un d&eacute;lai de 72h est n&eacute;cessaire :</label>
		<div class="input-group date form_date col-md-3" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd"> 
			<input class="form-control" size="16" type="text" value="" readonly>
			<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
		</div>
		<input type="hidden" id="dtp_input2" value="" name=date_vol /><br/>
	</div>				
	
	<div class="form-group">
		<label for="texte">No du vol :</label>
		<input name="no_vol" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="texte">Email :</label>
		<input name="mail" type="text" class="form-control">
	</div>
	<div class="form-group">
		<label for="texte">Message (100 caracteres)</label>
		<input name="bla" type="text" class="form-control">
	</div>
  <input type=submit class="btn btn-primary" value='Valider votre commande'>
  </form>
EOF

print "</div></div>";
}


sub accueil {
	&carousel();
	&scriptfin();
	print "</body></html>";
}

sub carousel
{
print <<EOF;
		<div class="container compagnie" >
			<div class="row carousel-holder ">
				<!-- <div class="col-md-12 text-center" style=margin-bottom:20px;margin-top:10px;>
					<img src=http://$base_site/image/lo_aci.jpg>
				</div> -->
				<br />
                    <div class="col-md-6 col-lg-offset-3">
					    <div id="carousel-example-generic" class="carousel " data-ride="carousel" data-interval="3000" style="padding:0px">
                            <ol class="carousel-indicators">
                                <li data-target="#carousel-example-generic" data-slide-to="0" class="active"></li>
                                <li data-target="#carousel-example-generic" data-slide-to="1"></li>
                                <li data-target="#carousel-example-generic" data-slide-to="2"></li>
                            </ol>
                            <div class="carousel-inner">
                               
EOF
if ($langue eq "A"){
print <<EOF;
								<div class="item active">
                                    <img class="slide-image" src="http://$base_site/image/eSlideA.jpg" alt="" width=514px >
							    </div>
                                <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/eSlideB.jpg" alt="" width=514px >
							    </div>
							    <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/eSlideC.jpg" alt="" width=514px >
							    </div>
                                <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/eSlideD.jpg" alt="" width=514px >
							    </div>
                               <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/eSlideE.jpg" alt="" width=514px >
							    </div>
EOF
}                            
else{
print <<EOF;
								<div class="item active">
                                    <img class="slide-image" src="http://$base_site/image/SlideA.jpg" alt="" width=514px >
							    </div>
                            	<div class="item">
                                    <img class="slide-image" src="http://$base_site/image/SlideB.jpg" alt="" width=514px >
							    </div>
							    <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/SlideC.jpg" alt="" width=514px >
							    </div>
                                <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/SlideD.jpg" alt="" width=514px >
							    </div>
                               <div class="item">
                                    <img class="slide-image" src="http://$base_site/image/SlideE.jpg" alt="" width=514px >
							    </div>
EOF
}                            

print <<EOF;
                            </div>
                            <a class="left carousel-control" href="#carousel-example-generic" data-slide="prev" >
                                <span class="glyphicon glyphicon-chevron-left"></span>
                            </a>
                            <a class="right carousel-control" href="#carousel-example-generic" data-slide="next">
                                <span class="glyphicon glyphicon-chevron-right"></span>
                            </a>
                        </div>
					</div>	
					<div class="col-lg-12">
EOF

if ($langue eq "A"){
print <<EOF;

						<h3>Welcome</h3>
						You can now shop for duty free items offered by Air Cote d'Ivoire before setting off from Abidjan.
						Browse our on-line catalogue from your home. Find the gift, the travel essential or a treat for yourself in our wide range of cosmetics, perfumes, jewels and gift ideas from the biggest brands.
						You will then be able to collect your purchases on-board!
EOF
}
else{
print <<EOF;
					
						<h3>Bienvenue</h3>
						La compagnie Air Cote d'Ivoire vous propose dès à présent de réserver vos produits 
						détaxés avant votre vol au départ d'Abidjan.
						Explorez notre catalogue de produits depuis chez vous. Trouvez le cadeau, l’accessoire 
						indispensable à votre voyage ou faite-vous simplement plaisir grâce à notre large gamme de 
						cosmétiques, de parfums, de bijoux  et d’idées cadeaux des plus grandes marques.<br> 
						Votre commande vous sera ensuite remise à bord
EOF
}
print <<EOF;
					</div>
               </div>
				<p style=text-align:right>Copyright &copy; DutyFree Concept</p>
			</div>
       </div>	
EOF
}


sub pied {
print <<EOF;
    <div class="container">
        <footer>
            <div class="row">
                <div class="col-lg-12">
                    <p>Copyright &copy; DutyFree Concept</p>
                </div>
            </div>
        </footer>
    </div>
EOF
&scriptfin();	
if ($modal){
	print <<EOF;	
	<script>
	\$("#infos").modal({ remote: "/cgi-bin/boutique_resp.pl?action=modal&code=$code_modal" }, "show");			
	</script>
EOF
}
if ($modal_panier){
	print <<EOF;	
	<script>
	\$("#infos").modal({ remote: "/cgi-bin/boutique_resp.pl?action=aff_panier" }, "show");			
	</script>
EOF
}

if ($envoyer){
	print <<EOF;	
	<script>
	\$("#infos").modal({ remote: "/cgi-bin/boutique_resp.pl?action=aff_confirm&mail=$mail" }, "show");			
	</script>
EOF
}
print "</body></html>";
}

sub scriptfin{	
print <<EOF;
<script type="text/javascript">
	var startDate = new Date;
	startDate.setDate(startDate.getDate() +3);
   \$('.form_date').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 2,
		startDate: startDate,
		minView: 2,
		forceParse: 0
    });
   \$('.form_time').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 1,
		minView: 0,
		maxView: 1,
		forceParse: 0
    });
</script>
EOF
}

