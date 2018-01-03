#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
require "./src/connect.src";
$vendredi_reference="2017-10-20";
#$nb_sem=&get("select datediff(curdate(),'$vendredi_reference')")/7;
#$curdate="2017-11-17";
$nb_sem=&get("select datediff(curdate(),'$vendredi_reference')")/7;
if (&Odd(int($nb_sem))){
	$nb_sem=int($nb_sem)+1;
}
else{
	$nb_sem=int($nb_sem)+2;
}
$prochain_depart=&get("select adddate('$vendredi_reference',interval $nb_sem WEEK)");
# print $prochain_depart;
$message="Prochain départ le $prochain_depart<br>";
$nb_jour=&get("select datediff('$prochain_depart',curdate())");
print " dans $nb_jour jours";
$query="select distinct pr_four from mag,produit,mag_run where mag=mag_actif and code=pr_cd_pr";
my ($sth)=$dbh->prepare($query);
$sth->execute();
while (($pr_four)=$sth->fetchrow_array){
	($fo2_add,$fo_minicde,$fo2_delai,$fo2_identification)=&get("select fo2_add,fo_minicde,fo2_delai,fo2_identification from fournis where fo2_cd_fo='$pr_four'");
	if ($fo2_identification==1){next;}
	($fo_nom)=split(/\*/,$fo2_add);
	if ($fo2_delai==21){$fo2_delai=11;}
	if ($fo2_delai==$nb_jour){
		$message.="$pr_four $fo_nom<br>";
	}	
}	
print $message;
	  


sub Odd() {
 my($value) = @_;
 return ($value & 1) == 1;
} 