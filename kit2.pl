#!/usr/bin/perl
require "../oasix/outils_perl2.pl";

use CGI;
use DBI();
use CGI::Session;

$html=new CGI;
$ip = $ENV{"REMOTE_ADDR"};
print $html->header;
$onglet=$html->param("onglet");
$sous_onglet=$html->param("sous_onglet");
$sous_sous_onglet=$html->param("sous_sous_onglet");
$module=$html->param("module");
$action=$html->param("action");
$mess_index=$html->param("mess_index");
$cookie = $html->cookie(-name => "session");
 if ($cookie) {
  CGI::Session->name($cookie);
}
$session = new CGI::Session("driver:File",$cookie,{'Directory'=>"/tmp/apache"}) or die "$!";
$status = $session->param('status');
if (($status eq "")&&($onglet>1)){$onglet=1;}


print "<script>
function verif(message,lien){
	if (confirm(message)){document.location.href=lien;}
}
</script>";
@data=<DATA>;
open(FIC,"../public_html/kit/html_part1_af.src");
while (<FIC>){print;}	        
close(FIC);
require("onglet.src");
open(FIC,"../public_html/kit/html_part2_1.src");
while (<FIC>){print;}	        
close(FIC);
# menu gauche
$index=-1;
$sous_index=-1;
$sous_sous_index=-1;
require "./src/connect.src";

foreach (@data)
{        
	# if (($onglet==1)&&($sous_onglet eq "")){$sous_onglet=0;}
	if (! grep (/^\t/,$_)){$index++;}
	if (($index == $onglet) && (grep (/^\t/,$_))&&(! grep (/^\t\t/,$_))){
		$sous_index++;
		if ($sous_onglet eq ""){
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
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
							$ancien="http://ibs.oasix.fr/cgi-bin/".$mod;
						}
						else{
							$ancien="http://ibs.oasix.fr/".$mod;
						}
				        }
				}		
				else{$module=$mod;$ancien="";}
			}
			print "<tr><td class=\"menu2\">&nbsp;&nbsp;&nbsp;<img src=\"/kit/images/fleche.gif\" width=\"4\" height=\"7\">&nbsp;&nbsp; ";
			print "<a href=?onglet=$onglet&sous_onglet=$sous_index&sous_sous_onglet=$sous_sous_index>$desi</a>";
			print "</td></tr><tr><td><img src=\"/kit/images/separateurMenu.gif\" width=\"185\" height=\"3\"></td></tr>";
		}
	}
}
if ($status ne ""){
	$query="select * from accespnc where ac_login='$status'",
	$sth=$dbh->prepare($query);
	$sth->execute();
	($ac_login,$ac_pwd,$ac_tri,$ac_cd_cl)=$sth->fetchrow_array;
	$query="select hot_nom from hotesse where hot_tri='$ac_tri' and hot_cd_cl='$ac_cd_cl'",
	$sth=$dbh->prepare($query);
	$sth->execute();
	($hot_nom)=$sth->fetchrow_array;
	print "<div class=session>Bonjour $hot_nom</div>";
}
else
{
	print "<div class=session>Vous n'êtes pas connecté</div>";

}
open(FIC,"../public_html/kit/html_part2_2.src");
while (<FIC>){print;}	        
close(FIC);
chop ($module);
if (($module ne "")&&($ancien eq "")) {
# print "<script>alert(\"$module\");</script>";
require ($module);}
if ($ancien ne "") {
	 # print "<center><a href=$ancien target=\"$ancien\" onclick=\"window.open('popup.htm','$ancien','width=800,height=600,toolbar=yes,location=yes,directories=yes,status=yes,adress=yess,scrollbars=yes,left=20,top=30')\">$ancien</a>";
	  print "<center><a href=$ancien target=_blank>$ancien</a>";
	  print "<title>$ancien</title>";

}
if ((($onglet eq "")||($onglet==0))&&($sous_onglet eq "")){ print "<title>oasix</title>";require ("accueilpnc.src");}

open(FIC,"../public_html/kit/html_part3.src");
while (<FIC>){print;}	        
close(FIC);
__DATA__
Accueil
Connexion
	Connexion
		Identification;session_kit.pl
	Inscription	
		Inscription;inscription_kit.pl
	Deconnexion	
		Deconnexion;deconnexion_kit.pl
Vol
	Commission
		Commission;commission_kit.pl
	Liste
		Liste;recapvol_kit.pl
Information
	Manuel ovb
		Manuel;manuel_kit.pl
	Faq 
		Faq;faq_kit.pl
	Contact
		Contact;contact_kit.pl
	Prochainement
		A venir;avenir_kit.pl
_
_
_ 
		