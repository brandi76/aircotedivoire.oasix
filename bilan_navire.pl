#!/usr/bin/perl
use CGI;
use DBI();
require "../oasix/outils_perl2.lib";

$html=new CGI;
print $html->header;
$navire=$html->param("navire");
$action=$html->param("action");
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$texte=$html->param('texte');
$save=$html->param('save');
$type=$html->param('type');

require "./src/connect.src";

	$sth = $dbh->prepare("select * from navire2,comcli,infoco2 wherenav_nom from navire");
    	$sth->execute;
        print "</h1><font color=red>mise a jour <input type=checkbox checked name=save></font>";
   	print "<br><select name=type>\n";
    	print "<option value=0>0 stock commercial";
    	print "<option value=1>1 inventaire";
    	print "<option value=2 selected>2 vendu par semaine";
  	print "<option value=4>4 vendu par mois";
  	print "<option value=7>7 temporaire";
       	print "</select><br>\n";
   
   	print "<br><select name=navire>\n";
    	while (my @tables = $sth->fetchrow_array) {
       		print "<option value=\"$tables[0]\"";
       		print ">$tables[0]\n";
       	}
    	print "</select><br>\n";
   	&select_date();
	print "<br><textarea name=texte cols=80 rows=50>";
	print "</textarea>";

    	print "<br><input type=hidden name=action value=import><input type=submit value=importer></form><a href=#haut>haut</a></body>";
}
	

if ($action eq "import"){
	if ($mois<10){$mois='0'.$mois;}
	if ($jour<10){$jour='0'.$jour;}
	$date=$an.'-'.$mois.'-'.$jour;
	print $date."<br>";
  	
       
	(@tab)=split(/\n/,$texte);
	$ok=0;
	foreach $ligne (@tab){
		if (grep /TOTALE PER/,$ligne){
			print "<font color=green size=+5>FIN DE FICHIER</font>";
		}
		while($ligne=~s/^ //){};
		while($ligne=~s/^\t//){};
		if ((grep -/^Navire/,$ligne)||(grep -/^Nave/,$ligne)){
			($null,$navire_ex)=split(/ : /,$ligne);
			$navire_ex=~ s/^ //;
			if (grep /^MARINA/,$navire_ex){$navire_ex="MARINA";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /1/,$navire_ex)){$navire_ex="MEGA 1";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /2/,$navire_ex)){$navire_ex="MEGA 2";}
			if ((grep /^MEGA/,$navire_ex)&&(grep /3/,$navire_ex)){$navire_ex="MEGA 3";}
			if (grep /^REGINA/,$navire_ex){$navire_ex="REGINA";}
			if (grep /^VICTORIA/,$navire_ex){$navire_ex="VICTORIA";}
			if ((grep /^EXPRESS II/,$navire_ex)&&(!grep /^EXPRESS III/,$navire_ex)){$navire_ex="EXPRESS 2";}
			if (grep /^EXPRESS III/,$navire_ex){$navire_ex="EXPRESS 3";}
			if (grep /^VERA/,$navire_ex){$navire_ex="VERA";}
			if (grep /^S EXPRESS/,$navire_ex){$navire_ex="SARDINIA EXPRESS";}
			if (grep /^SERENA II/,$navire_ex){$navire_ex="SERENA II";}
		
			print "<b>$navire_ex</b><br>";
			if ($navire_ex eq $navire){$ok=1;}
		}	
		if ((grep /^P E R I O D /,$ligne)||(grep /^PERIOD/,$ligne)){
			if ($ok==0){					
				print "<font color=red><h1>BATEAU INVALIDE </h1>";
				exit;
			}
			($null,$date_ex)=split(/au   /,$ligne);
			($jour_ex,$mois_ex,$an_ex)=split(/\//,$date_ex)  ;
			$an_ex+=2000;
			$date_ex=$an_ex."-".$mois_ex."-".$jour_ex;
			print "<b>$date_ex</b><br>";
			if ($date_ex eq $date){$ok=2;}
			  			
			if ($save eq "on"){
				if ($ok==2){				
					&save ("delete from navire2 where nav_nom='$navire' and nav_date='$date' and nav_type=$type","aff");
				}
				else
				{
					print "<font color=red><h1> DATE INVALIDE </h1>";
					exit;
				}
			}
		}
		if ((! grep /PUBLIC/,$ligne)&&(! grep /EQUIPAGE/,$ligne)&&(! grep /OFFICIERS/,$ligne)){next;}
		if (($save eq "on")&&($ok !=2)){
			print "<font color=red><h1> FORMAT FICHIER INVALIDE </h1>";
			exit;
		}	
		$ligne=~s/([A-Z])/ ;$1/;	
		$ligne=~s/PUBLIC/PUBLIC ;/;	
		$ligne=~s/EQUIPAGE/EQUIPAGE ;/;	
		$ligne=~s/OFFICIERS/OFFICIERS ;/;	
		# print "$ligne <br>";		
		($neptune,$part1,$part2)=split(/ ;/,$ligne);
		$part2=~s/\t/;/g;	
		($null,$null,$qte)=split(/;/,$part2);

		if ($navire_ex eq "nullEXPRESS 3"){
			while($ligne=~s/\t/;/){};
			# print $ligne;
			($null,$null,$null,$null,$neptune,$null,$null,$null,$null,$null,$null,$qte)=split(/;/,$ligne);
			# print "$neptune*$part1*$part2<br>"
			#print "<font color=green>;$neptune;</font>";

			#($a,$b,$c,$d)=split(/\t/,$neptune);
		#	print "<font color=green>$a;$b;$c,$d;$neptune</font>";

		}
		$pr_desi=&get("select pr_desi from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_sup=&get("select pr_sup from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		$pr_type=&get("select pr_type from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  

		$pr_cd_pr=&get("select pr_cd_pr from produit,neptune where pr_cd_pr=nep_codebarre and nep_cd_pr='$neptune'");  
		if (($pr_sup==0)||($pr_sup==5)||($pr_sup==3)){ $color="black";}
		else {$color="blue";}
		if ($pr_desi eq ''){
			$color="red";
			$pr_desi=$part1;
		}	
		print "<font color=$color>$neptune;$pr_cd_pr;$pr_desi;<b>$qte</b>;$pr_sup</font>;$pr_type<br>";
 		if (($pr_desi ne $part1)&&($save eq "on")){
			$qte+=&get("select nav_qte from navire2 where nav_nom='$navire' and nav_cd_pr='$pr_cd_pr' and nav_date='$date' and nav_type=$type")+0;			 
			$query="replace into navire2 values ('$navire','$pr_cd_pr','$date','$type','$qte','9999')";
			print "$query<br>";		
		 	$sth=$dbh->prepare($query);
			$sth->execute();
		}
	
	}
	if ($type==7){
			print "<hr></hr><br><table>";
			$query="select nav_cd_pr,nav_qte from navire2,produit where nav_nom='$navire' and nav_date='$date' and nav_type=$type and nav_cd_pr=pr_cd_pr and (pr_type=1 or pr_type=5)";			 
		 	print $query;
		 	$sth=$dbh->prepare($query);
		 	$sth->execute;
			while (($pr_cd_pr,$qte)=$sth->fetchrow_array){
			print "<tr><td>$pr_cd_pr</td><td>$qte</td></tr>";
			}
			print "</table>";
	}
	

}

sub datesimple {
	($an,$mois,$jour)=split(/-/,$_[0]);
	$an=substr($an,2,2);
	return("1".$an.$mois.$jour);
}

# -E analyse des mouvement produits armement ->desarmement navire (non termin�) 06/09