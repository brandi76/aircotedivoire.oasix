$trolley=$html->param("trolley");
$trolley2=$html->param("trolley2");
$cours_dollars=&get("select cours from devise where id=840");

if ($trolley eq ""){
	print "<form>";
	&form_hidden();
	print "Trolley euro <input type=text name=trolley size=5> <br>Trolley cfa (optionnel)  <input type=text name=trolley2 size=5 ><br><input type=submit></form>";
}
else
{
  $ok=1;
  &save("create temporary table ordre_temp (famille int(3),desi varchar(15),code int(10))","af"); 
  $query = "select tr_cd_pr from trolley where tr_code='$trolley'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    &famille($code);
    &desi_court($code);
    $desi_tpe=lc($desi_tpe);
    $desi_tpe=ucfirst($desi_tpe);
    if ($desi_tpe eq ""){
      print "<span background-color:pink>$code n a pas de designation tpe</span><br>";
      $ok=0;
    }  
    $desi_tpe=~s/\&//g;
    &save ("insert into ordre_temp values ('$fa_cat','$desi_tpe','$code')");
  }
  if ($ok==0){print "merci de corrigé le probleme";exit;}
  $query="select famille,desi,code from ordre_temp order by famille,desi";
  $sth=$dbh->prepare($query);
  $sth->execute();
  $ok=1;
  while (($famille,$desi,$code)=$sth->fetchrow_array){
    $check=&get("select count(*) from ordre_temp where desi='$desi'");
    if ($check!=1){
      print "<span style=background-color:pink><a href=http://dfc.oasix.fr/cgi-bin/kit.pl?onglet=0&sous_onglet=0&sous_sous_onglet=0&pr_cd_pr=$code&action=visu target=_blank>Doublon $code</a> $desi</span><br>";
      $ok=0;
    }
  }
  if ($ok==0){ print "<br>Il y a des doublons merci de corrigé le probleme</br>";}
  else {
  
    print "Fichier Tpe mis à jour, pret pour l'importation<br>";
    open (FILE,">/var/www/togo.oasix/sk20.xml");
    print  "<pre>&lt;?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
    print FILE "<?xml version=\"1.0\" encoding=\"UTF-8\" ?>\n";
    print  "&lt;Sk20list>\n";
    print FILE "<Sk20list>\n";
    $query="select famille,desi,code from ordre_temp order by famille,desi";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($famille,$desi,$code)=$sth->fetchrow_array){
      print  "&lt;Prod>\n";
      print FILE "<Prod>\n";
      $pr_prix=&get("select tr_prix/100 from trolley where tr_code='$trolley' and tr_cd_pr='$code'")+0; 
      $pr_prix=int($pr_prix);
      $pr_prix0=$pr_prix;
      $pr_prix1=&get("select tr_prix/100 from trolley where tr_code='$trolley2' and tr_cd_pr='$code'")+0;
      $pr_prix1=int($pr_prix1);
      if ($pr_prix1==0) {
	$pr_prix1=int($pr_prix*659/1000)*1000;
      }
      print  "&lt;Pr_cd_pr>$code&lt;/Pr_cd_pr>\n";
      print  FILE "<Pr_cd_pr>$code</Pr_cd_pr>\n";
      print  "&lt;Pr_desi>$desi&lt;/Pr_desi>\n";
      print FILE "<Pr_desi>$desi</Pr_desi>\n";
      print  "&lt;Pr_prix0>$pr_prix0&lt;/Pr_prix0>\n";
      print FILE "<Pr_prix0>$pr_prix0</Pr_prix0>\n";
      print  "&lt;Pr_prix1>$pr_prix1&lt;/Pr_prix1>\n";
      print  FILE "<Pr_prix1>$pr_prix1</Pr_prix1>\n";
      print  "&lt;Cat>$famille&lt;/Cat>\n";
      print  FILE "<Cat>$famille</Cat>\n";
      print  "&lt;Pr_barre>0&lt;/Pr_barre>\n";
      print  FILE "<Pr_barre>0</Pr_barre>\n";
      print  "&lt;/Prod>\n";
      print FILE "</Prod>\n";
    }
    print FILE "<Dev>\n";
    print FILE "<Dev_id>0</Dev_id>\n";
    print FILE "<Dev_desi>Euro</Dev_desi>\n";
    print FILE "<Dev_tri>EUR</Dev_tri>\n";
    print FILE "<Dev_cours>1</Dev_cours>\n";
    print FILE "</Dev>\n";
    print FILE "<Dev>\n";
    print FILE "<Dev_id>1</Dev_id>\n";
    print FILE "<Dev_desi>XOF</Dev_desi>\n";
    print FILE "<Dev_tri>XOF</Dev_tri>\n";
    print FILE "<Dev_cours>659</Dev_cours>\n";
    print FILE "</Dev>\n";
    print FILE "<Dev>\n";
    print FILE "<Dev_id>2</Dev_id>\n";
    print FILE "<Dev_desi>XAF</Dev_desi>\n";
    print FILE "<Dev_tri>XAF</Dev_tri>\n";
    print FILE "<Dev_cours>659</Dev_cours>\n";
    print FILE "</Dev>\n";
    print FILE "<Dev>\n";
    print FILE "<Dev_id>3</Dev_id>\n";
    print FILE "<Dev_desi>Dollars</Dev_desi>\n";
    print FILE "<Dev_tri>USD</Dev_tri>\n";
    print FILE "<Dev_cours>$cours_dollars</Dev_cours>\n";
    print FILE "</Dev>\n";
    
     print  "&lt;Dev>\n";
    print  "&lt;Dev_id>0</Dev_id>\n";
    print  "&lt;Dev_desi>Euro</Dev_desi>\n";
    print  "&lt;Dev_tri>EUR</Dev_tri>\n";
    print  "&lt;Dev_cours>1</Dev_cours>\n";
    print  "&lt;/Dev>\n";
    print  "&lt;Dev>\n";
    print  "&lt;Dev_id>1</Dev_id>\n";
    print  "&lt;Dev_desi>XOF</Dev_desi>\n";
    print  "&lt;Dev_tri>XOF</Dev_tri>\n";
    print  "&lt;Dev_cours>659</Dev_cours>\n";
    print  "&lt;/Dev>\n";
    print  "&lt;Dev>\n";
    print  "&lt;Dev_id>2</Dev_id>\n";
    print  "&lt;Dev_desi>XAF</Dev_desi>\n";
    print  "&lt;Dev_tri>XAF</Dev_tri>\n";
    print  "&lt;Dev_cours>659</Dev_cours>\n";
    print  "&lt;/Dev>\n";
    print  "&lt;Dev>\n";
    print  "&lt;Dev_id>3</Dev_id>\n";
    print  "&lt;Dev_desi>Dollars</Dev_desi>\n";
    print  "&lt;Dev_tri>USD</Dev_tri>\n";
    print  "&lt;Dev_cours>$cours_dollars</Dev_cours>\n";
    print  "&lt;/Dev>\n";
   
    print  "&lt;/Sk20list>\n";
    print  FILE "</Sk20list>\n";
    close(FILE);
  }
}  
;1