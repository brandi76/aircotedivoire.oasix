#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
print $html->header;
require "../oasix/outils_perl2.pl";
require "./src/connect.src";

$trolley=$html->param("trolley");
$trolley2=$html->param("trolley2");
$cours_dollars=&get("select cours from devise where id=840");
$cours_cve=&get("select cours from devise where id=132");
$cours_xaf=&get("select cours from devise where id=950");
$cours_xof=&get("select cours from devise where id=952");

# if ($cours_xaf!=0){$cours_xaf=659;}

$pays_ref="XOF";
if ($trolley eq ""){
	print "<form>";
	print "Trolley euro <input type=text name=trolley size=5> <br>Trolley cfa (optionnel)  <input type=text name=trolley2 size=5 ><br><input type=submit></form>";
}
else
{
  $ok=1;
  $mag=&get("select lot_mag from lot where lot_nolot='$trolley'");
  &save("create temporary table ordre_temp (famille int(3),desi varchar(15),code int(10),code_court int(5))"); 
  $query = "select tr_cd_pr from trolley where tr_code='$trolley'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    &famille($code);
	$desi_tpe=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $desi_tpe=lc($desi_tpe);
    $desi_tpe=ucfirst($desi_tpe);
    $desi_tpe=~s/\&//g;
    &save ("insert into ordre_temp values ('$fa_cat','$desi_tpe','$code','$code_court')");
  }
    print  "<?xml version=\"1.0\" encoding=\"UTF-8\" ?><br>";
	
    print  "<Sk20list><br>";
	  $query="select famille,desi,code,code_court from ordre_temp order by famille,desi";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($famille,$desi,$code,$code_court)=$sth->fetchrow_array){
		print  "<Prod><br>";
		$pr_prix=&get("select tr_prix/100 from trolley where tr_code='$trolley' and tr_cd_pr='$code'")+0; 
		$pr_prix=int($pr_prix);
		$pr_prix0=$pr_prix;
		$pr_prix1=&get("select tr_prix/100 from trolley where tr_code='$trolley2' and tr_cd_pr='$code'")+0;
		$pr_prix1=int($pr_prix1);
		if ($pr_prix1==0){
			if ($base_dbh eq "tacv") {
				$pr_prix1=int($pr_prix*$cours_cve/100)*100;
				if (($pr_prix*$cours_cve%100)>=50){$pr_prix1+=50;}
			}
			else {
				$pr_prix1=int($pr_prix*$cours_xof/1000)*1000;
			}
		}	
		print   "<Pr_cd_pr>$code</Pr_cd_pr><br>";
		print  "<Pr_desi>$desi</Pr_desi><br>";
		print  "<Pr_prix0>$pr_prix0</Pr_prix0><br>";
		print   "<Pr_prix1>$pr_prix1</Pr_prix1><br>";
		print   "<Cat>$famille</Cat><br>";
		print   "<Pr_barre>$code_court</Pr_barre><br>";
		print  "</Prod><br>";
	}
	
 	
    print   "</Sk20list><br>";
	}	
;1