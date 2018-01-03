$trolley=$html->param("trolley");
$trolley2=$html->param("trolley2");

@categorie=('Parfum Femme','Parfum Homme','Cosmetique','Accessoire','Tabac','Alimentation');

&save("create temporary table sk20_temp (cat int(11),ordre int(11),pr_cd_pr int(11),pr_prix0 int(11),pr_prix1 int(11), PRIMARY KEY (cat,ordre))");

if ($trolley eq ""){
	print "<form>";
	&form_hidden();
	$query="select distinct v_troltype from vol order by v_code desc limit 10";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "10 derniers trolleys utilisés<br>";
	while (($troltype)=$sth->fetchrow_array){
	  print "$troltype<br>";
	}
	print "<br>";
	print "Trolley euro <input type=text name=trolley size=5> <br>Trolley cfa (optionnel)  <input type=text name=trolley2 size=5 ><br><input type=submit></form>";
}
else
{
  print "En rouge les produits posant un problème, double désignation prix eronné <br>";
  $query="select produit.pr_cd_pr,left(pr_desi,15), tr_prix/100,pr_famille,tr_ordre,pr_codebarre from produit,trolley,produit_plus  where tr_code='$trolley' and tr_cd_pr=produit.pr_cd_pr and produit.pr_cd_pr=produit_plus.pr_cd_pr order by pr_type,tr_ordre";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($pr_cd_pr,$pr_desi,$pr_prix,$cat,$ordre,$barre)=$sth->fetchrow_array){
	  &desi_court($pr_cd_pr);
	  $pr_desi=$desi_tpe;
	  $pr_desi=lc($pr_desi);
	  $pr_desi=ucfirst($pr_desi);
	  $pr_desi=~s/\&//g;
	  $pr_famille=$cat;
    #0 farmum f
    #1 parfum h
    #2 cosmetique
    #3 Accessoire
    #4 tabac
    #5 alimentation
    
	      
	  $pr_prix=int($pr_prix);
	  if ($cat==9){$cat=4;}
	  elsif ($cat==3){$cat=1;}
	  elsif ($cat==5){$cat=2;}
	  elsif ($cat==4){$cat=3;}
	  elsif ($cat==6){$cat=3;}
	  elsif ($cat==0){$cat=3;}
	  elsif ($cat==1){$cat=0;}
	  elsif ($cat==15){$cat=4;}
	  elsif ($cat==22){$cat=5;}
	  elsif ($cat==21){$cat=3;}
	  elsif ($cat==24){$cat=5;}
	  elsif ($cat==16){$cat=5;}
	  else {$cat=3;}
	  $pr_prix0=$pr_prix;
	  $pr_prix1=&get("select tr_prix/100 from trolley where tr_code='$trolley2' and tr_cd_pr=$pr_cd_pr")+0;
	  if ($pr_prix1==0) {
		  $pr_prix1=int($pr_prix*659/1000)*1000;
	  }
	  &save("insert into sk20_temp values ('$cat','$ordre','$pr_cd_pr','$pr_prix0','$pr_prix1')");
  }
  $cat_temp=-1;
  $query="select * from sk20_temp order by cat,ordre";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($cat,$ordre,$pr_cd_pr,$pr_prix0,$pr_prix1)=$sth->fetchrow_array){
    if ($cat != $cat_temp){
    if ($nb>0){print "</table>";}
    print "<h3>$categorie[$cat]</h3>";
    print "<table><tr><th>Code</th><th>Designation</th><th>Prix euro</th><th>Prix Xof</th></tr>";
    $nb=0;
    $cat_temp=$cat;
    }
#     $pr_desi=&get("select prt_desi from produit_tpe where prt_cd_pr='$pr_cd_pr'");
    &desi_court($pr_cd_pr);
    $pr_desi=$desi_tpe;
    
    $color="white";
    if ($pr_desi eq ""){
      $pr_desi_tpe=&get("select pr_desi from produit where pr_cd_pr='$pr_cd_pr'");
#       $query="select avant,apres from remplace";
#       $sth2=$dbh->prepare($query);
#       $sth2->execute();
#       while (($avant,$apres)=$sth2->fetchrow_array){
# 	$pr_desi_tpe=~s/$avant/$apres/;
#       }
#       $pr_desi_tpe=substr("$pr_desi_tpe",0,15);
#       $pr_desi_tpe=lc($pr_desi_tpe);
#       $pr_desi_tpe=ucfirst($pr_desi_tpe);
#       $pr_desi_tpe=~s/\&//g;
#       &save("replace into produit_tpe values ('$pr_cd_pr','$pr_desi_tpe')");
    }
    $pr_desi=lc($pr_desi);
    $pr_desi=ucfirst($pr_desi);
    if (grep /$pr_desi/,@desi){$color="pink";}
    if (($pr_prix0==0)||($pr_prix0==0)){$color="pink";}
    push(@desi,$pr_desi);
    print  "<tr bgcolor=$color><td><a href=?onglet='0'&sous_onglet='0'&sous_sous_onglet=''&pr_cd_pr=$pr_cd_pr&action=visu>$pr_cd_pr</a></td><td>$pr_desi</td><td align=right>$pr_prix0</td><td align=right>$pr_prix1</td><td></tr>";
    $nb++;
  }
  if ($nb>0){print "</table>";}
   
}
;1