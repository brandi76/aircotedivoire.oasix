#### VERSION FACTURE PAR MARQUE  """""""""""""""""

use PDF::API2;
use constant mm => 25.4 / 72;
use constant in => 1 / 72;
use constant pt => 1;
use OpenOffice::OOCBuilder;
use File::Copy qw(copy);
# use Text::Levenshtein qw(distance);
use String::Similarity;
use LWP::UserAgent;
$mag=$html->param("mag");	
$code=$html->param("code");	
$code_pub=$html->param("code_pub");	
$cases=$html->param("cases");	
$page=$html->param("page");
$info=$html->param("info");
$contact=$html->param("contact");
$prix=$html->param("prix");
$prix_xof=$html->param("prix_xof");
$desi=$html->param("desi");
$action_prev=$html->param("action_prev");	
$option=$html->param("option");	
$four=$html->param("four");
$focus=$html->param("focus");
$sous_tot=$html->param("sous_tot");
# $mag_texte=$html->param("mag_texte");
 
$desi=~s/'/ /g;
$info=~s/'/ /g;
$contact=~s/'/ /g;

$query="select cl_nom,cl_magazine from client where cl_cd_cl='$base_client'";
$sth=$dbh->prepare($query);
$sth->execute();
($cl_nom,$cl_magazine)=$sth->fetchrow_array;
	
$pub=$new;$texte=$visuel=0;
if ($html->param("pub") eq "on"){$pub=1;$pubcheck="checked";}
if ($html->param("new") eq "on"){$new=1;$newcheck="checked";}
if ($html->param("texte") eq "on"){$texte=1;$textecheck="checked";}
if ($html->param("visuel") eq "on"){$visuel=1;$visuelcheck="checked";}
$visuelprix=$html->param("visuelprix");
$pubprix=$html->param("pubprix");
$desi_pub=$html->param("desi_pub");
$desi_pub=~s/'/ /g;
$marque=$html->param("marque");
$marque=~s/'/ /g;
@liste_fragrance=("EDT","EDP","eau de cologne","parfum","eau fraiche","soie de parfum","eau tonique","coffret");

print "<style>";
print "li:nth-child(odd) { background-color:#efefef;width:600px;}";
print "li {list-style-type:none;}";
print "a.textemag span{display:none;}";
print "a.textemag:hover span{display:inline;position:relative;top:-20px;left:20px;background-color:yellow;}";
print "a.nodeco {text-decoration:none;color:black;}";
print "a.nodeco:hover {background-color:orange;}";
 
print ".cache{display:none;}";
print "</style>";

# if ($action eq "maj"){
#   $query = "select * from mag_import";
#   $sth=$dbh->prepare($query);
#   $sth->execute();
#   while (($code,$prix,$prix_xof,$texte,$visuel,$pub,$info,$contact)=$sth->fetchrow_array){
#     &save("update mag set prix='$prix',prix_xof='$prix_xof',visuel='$visuel',texte='$texte',pub='$pub',info='$info',contact='$contact' where code='$code'","aff");
#   }
# }

print "<div style=\"width:670px;height:6000px;position:absolute;background-color:white;\">";  # debut de la boite cellule principale


if ($action eq "copier"){
    $new_mag=$html->param('new_mag');;
    if (($new_mag ne "")&&($new_mag!~m/ /)){
     &save("insert into mag select '$new_mag', `page`, `cases`, `code`, `prix`, `prix_xof`, `texte`, `visuel`, `pub`, `new`, `info`, `contact`, `desi`, `visuelprix`, `pubprix`, `desi_pub`, `marque` from mag where mag='$mag'");
      $mag=$new_mag;
    }
    $action="go";
}  
if ($action eq "decaler+"){
  &save("create temporary table chemin_temp (page int(8),cases int(8))");
  &save("insert into chemin_temp select page,cases from mag where mag='$mag' and page>='$page'");
  $query="select * from chemin_temp order by cases,page desc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($page,$cases)=$sth->fetchrow_array){
    &save("update mag set page=page+1 where mag='$mag' and page='$page' and cases='$cases'","af");
  }
  $action="go";
}  
if ($action eq "decaler-"){
  &save("create temporary table chemin_temp (page int(8),cases int(8))");
  &save("insert into chemin_temp select page,cases from mag where mag='$mag' and page<='$page'");
  $query="select * from chemin_temp order by cases,page asc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($page,$cases)=$sth->fetchrow_array){
    &save("update mag set page=page-1 where mag='$mag' and page='$page' and cases='$cases'","af");
  }
  $action="go";
}  

if ($action eq "deplacer"){
  $newpage=$html->param("newpage");
  $check=&get("select count(*) from mag where mag='$mag' and page='$newpage'")+0;
  if ($check!=0){
    print "<span style=color:red>Impossible page existante</span><br>";
    $action="modif_page";
  }
  else
  {
    &save("update mag set page='$newpage' where page='$page' and mag='$mag'");
    $action="go";
  }
}  

if ($action eq "modif_page"){
    print "<form>";
    &form_hidden();
    print "Page:$page<br>";
    print "<input type=submit name=action value='decaler+'>Toutes les pages vont être incrémentées de 1 à partir de la page:$page<br>";
    print "<input type=submit name=action value='decaler-'>Toutes les pages vont être décrémentées de 1 à partir de la page:$page<br>";
    print "<input type=text name=newpage size=3> <input type=submit name=action value='deplacer'>Seule la $page va être modifiée <br>";
    print "<input type=hidden name=mag value='$mag'>";
    print "<input type=hidden name=page value='$page'>";
    print "</form>";
}  
if ($action eq "modif_adresse"){
    print "<form>";
    &form_hidden();
    print "Mag:$mag<br>";
    $adresse=&get("select adresse from mag_info where mag='$mag'");
    print "Lien: (mettre que la fin ex cc03i ou c15-i)<input type=text name=adresse value='$adresse' size=50>";
    print "<input type=hidden name=mag value='$mag'>";
    print "<input type=hidden name=action value=modif_adresse_save>";
    print "<input type=submit>";
    print "</form>";
}  
if ($action eq "modif_adresse_save"){
     $adresse=$html->param("adresse");
     &save("replace into mag_info (mag,adresse) values('$mag','$adresse')");
     $action="go";
}   

if ($action eq "sendpdf"){
    $fich=$html->param('fichier');;
    $mail=$html->param('email');
    $mail=~s/@/\@/;
    system("/var/www/cgi-bin/$base_rep/sendpdf_pub.pl $mail $fich &");
    print "<div class=titre>Mail envoyé</div>";
    print "Merci d'utiliser le bouton retour de votre navigateur pour revenir à la page precedente"
}  

if ($action eq "modif_import"){
  $nb_ligne=&get("select max(cases) from mag where mag='$mag'");
  for ($i=1;$i<=$nb_ligne;$i++){
    if ($html->param("$i") eq "on"){
      $desi=&get("select desi from mag where mag='$mag' and cases='$i'");
      print "$desi code 0<br>";
      &save("update mag set code=0 where mag='$mag' and cases='$i'");
    }
  }
  $action="go";
}

if ($action eq "modif_save"){
  $newpage=$html->param("newpage");
  $newposition=$html->param("newposition");
  $check=&get("select code from mag where cases='$cases' and page='$page' and mag='$mag'","af");
  if ($check != $code){
    &save("update mag set code='$code' where cases='$cases' and page='$page' and mag='$mag'","af");
  }
  &place();
  if (($newpage!=$page)||($newposition!=$position)){
    $index=0;
    $cases_tamp=$cases;
    $query="select cases from mag where mag='$mag' and page='$newpage' order by cases";
    $sth=$dbh->prepare($query);
    $sth->execute();
    $newcases=-1;
    while (($mcases)=$sth->fetchrow_array){
      $index++;
      if ($index>=$newposition){$newcases=$mcases;last;}
    }
    if ($index==0){
      $newcases=10;#page inexistante
    } 
    else {
      if ($newcases==-1){$newcases=&get("select max(cases) from mag where mag='$mag' and page='$newpage'")+1;} # derniere position
      else {
	$query="select cases from mag where mag='$mag' and page='$newpage' and cases>='$newcases' order by cases desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($mcases)=$sth->fetchrow_array){
	    if (($mcases==$cases)&&($newpage==$page)){$cases_tamp=$cases+1;} # cas particulier
	    &save("update mag set cases=cases+1 where mag='$mag' and page='$newpage' and cases='$mcases'","af");
	}
      }
    } 
    # newcases c'est la nouvelle cases
    $cases=$cases_tamp;
    &save("update mag set page='$newpage',cases='$newcases' where mag='$mag' and page='$page' and cases='$cases'","af");
    $page=$newpage;
    $cases=$newcases;
  }
  $pagepub=$html->param("pagepub");
  if ($pagepub ne ""){
    $code_neg=$code*-1;
    $check=&get("select page from mag where code='$code_neg'");
    if ($check ne $pagepub){
      if ($check eq ""){
	  $casepub=&get("select max(cases) from mag where mag='$mag' and page='$pagepub'")+1;
	  $textepub=&get("select desi_pub from mag where mag='$mag' and code='$code'");
	  &save("insert into mag values ('$mag','$pagepub','$casepub','$code_neg','','','','','','','','','$desi_pub','','','','')","af");
      }  
    }
   }
#   $action="ins";
}

if (($action eq "modif_save")||($action eq "modif_save_verif1")||($action eq "modif_save_verif2")||($action eq "modif_save_verif3")){
    if ($cases eq ""){
      $cases=&get("select max(cases) from mag where mag='$mag' and page='$page'")+1;
      &save("insert into mag values ('$mag','$page','$cases','$code','$prix','$prix_xof','$texte','$visuel','$pub','$new','$info','$contact','$desi','$visuelprix','$pubprix','$desi_pub','$marque')","af");
    }
    else {
      &save("update mag set code='$code',prix='$prix',prix_xof='$prix_xof',texte='$texte',visuel='$visuel',pub='$pub',new='$new',info='$info',contact='$contact',desi='$desi',visuelprix='$visuelprix',pubprix='$pubprix',desi_pub='$desi_pub',marque='$marque' where mag='$mag' and cases='$cases' and page='$page'","af");
    }
    $focus=$code;
    if ($action eq "modif_save") {$action="ins";}
    if ($action_prev ne "") {$action=$action_prev;}
    
}

if ($action eq "importer"){
      print "<form>";
      &form_hidden();
      &save ("delete from mag where mag='$mag'");
      $fic=$html->param("fichier");
      while (read($fic, $data, 4192)){
	      $texte=$texte.$data;
      }
      while ($texte=~s/'//){};
      print "Cocher les lignes avec l'auto codification erroné<br>";
      print "<table cellspacing=0 border=1>";
      (@ligne)=split(/\n/,$texte);
      foreach $ligne (@ligne){
	   chop($ligne);
	   $cases++;
	   (@cell)=split(/\t/,$ligne);
	   if ($cell[4] eq ""){next;}
	   if ($cell[1] eq ""){next;}
	   if ($cell[5] eq ""){next;}
	   if (grep/[a-z,A-Z]/,$cell[1]){next;}
	   $chaine='%'.$cell[5].'%';
	   $chaine=~s/ /%/g;
	   # attention c'est transitoire
	   $code=&get("select code from camairco.mag where desi like '$chaine'","af");
	   $page=$cell[1];
	   $prix=$cell[9];
	   $prix_xof=$cell[11];
	   $desi=$cell[5];
	   $marque=$cell[4];
	   $prix_xof=~s/,//;
	   $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
	   ($marque_pr,$null)=split(/ /,$pr_desi);
	   $ecart=similarity $pr_desi,$desi;
	   $color="white";
	   if ($ecart <0.5){$color="pink";}
# 	   $ecart_marque=distance("$marque","$marque_pr");
	   $texte=0;
	   if (($cell[14] eq "OK")||($cell[14] eq "OUI")){$texte=1;}
	   $visuel=1;
	   $pub=0;
	   if (($cell[16] eq "OK")||($cell[14] eq "OUI")){$pub=1;}
	   $info=$cell[17];
	   $contact=$cell[18];
	   if (($marque ne $marque_pr)&&($code ne "")){$color="pink";}
 	   if (($ecart>20)&&($code ne "")){$color="pink";}
 	   $new=0;
 	   if (grep /nouveau/i,$info){$new=1;}
 	   if (grep /new/i,$info){$new=1;}
 	   print "<tr><td>$page</td><td>$code</td><td bgcolor=$color><span style=color:blue>$marque</span> $desi<br><span style=color:blue>$marque_pr</span> $pr_desi</td><td>$prix</td><td>$prix_xof</td><td><input type=checkbox name=$cases></tr>";
 	   &save("insert ignore into mag values ('$mag','$page','$cases','$code','$prix','$prix_xof','$texte','$visuel','$pub','$new','$info','$contact','$desi','$visuelprix','$pubprix','$desi_pub','$marque')","af");
#  	    &save("update mag set marque='$marque' where cases='$cases'");
         } 
      print "</table>";
      print "<input type=hidden name=action value=modif_import>";
      print "<input type=hidden name=mag value='$mag'>";
      print "<input type=submit>";
      print "</form>";
}

if (($action eq "ins")&&($code eq "")){
  print "<form name=maform>";
  print "Code produit ? (0 si c'est une creation) <input type=text name=code><br>";
  &form_hidden();
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=page value=$page>";
  print "<input type=hidden name=action value=ins>";
  print "<input type=submit>";
  print "</form>";
  print "<form>";
  print "Recherche <input type=text name=recherche><br>";
  &form_hidden();
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=hidden name=page value=$page>";
  print "<input type=hidden name=action value=ins>";
  print "<input type=submit>";
  print "</form>";
  $recherche=$html->param("recherche");
  if ($recherche ne ""){
    print "<table>";
    $query="select pr_cd_pr,pr_desi,pr_pdn from produit where pr_desi like '%$recherche%'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($pr_cd_pr,$pr_desi,$pr_pdn)=$sth->fetchrow_array){
	$pr_fragrance=&get("select pr_fragrance from produit_plus where pr_cd_pr='$pr_cd_pr'");
	$fragrance=$liste_fragrance[$pr_fragrance];
# 	print "<tr><td>$pr_cd_pr</td><td>$pr_desi</td><td>$fragrance</td><td>$pr_pdn ML</td></tr>";
 	print "<tr><td><a href=# onclick=document.maform.code.value=$pr_cd_pr>$pr_cd_pr</a></td><td>$pr_desi</td></tr>";
    }
    print "</table>";
   }
 }

if (($action eq "ins")&&($code ne "")){
     &get_mag();
    if ($pub){$pubcheck="checked";}
    if ($new){$pubnew="checked";}
    
    if ($texte){$textecheck="checked";}	
    if ($visuel){$visuelcheck="checked";}
    print "<form name=maform style=\"text-align:left;margin-top:40px;width:80%;background-color:#efefef;padding:10px;border-radius:10px;box-shadow:1px 1px 12px black\";>";
    print "<div class=titre><input type=text name=code value=\"$code\" size=6> $pr_desi</div>";
   
   &form_hidden();
    if ($code>10000){
      $pr_prac=&get("select pr_prac from produit where pr_cd_pr='$code'")+0;
      $pr_prac/=100;
    }  
    print "Prix Achat<span style=position:absolute;left:300px>$pr_prac</span><br />";
    $coef=0;
    $style=0;
    if ($pr_prac>0){$coef=$prix/$pr_prac;}
    $coef=int($coef*100)/100;
    if (($coef<2)||($coef>3)){$style="background-color:red;";}
    print "Prix Vente<input type=text name=prix value=\"$prix\" size=4 style=position:absolute;left:300px;$style> $coef<br />";
    $conv=$prix*655.957;
    $coef=0;
    $style=0;
    if ($prix>0){$coef=$prix_xof/$prix;}
    $coef=int($coef);
    if (($coef<600)||($coef>700)){$style="background-color:red;";}
    print "Prix XOF ($conv) <input type=text name=prix_xof value=\"$prix_xof\" size=4 style=position:absolute;left:300px;$style> $coef<br />";
    if ($code==0){
      print "Designation<br><input type=text name=desi value=\"$desi\"  size=50><br />";
    }
    print "Marque<br><input type=text name=marque value=\"$marque\" size=40><br/>";
    print "Texte <input type=checkbox name=texte $textecheck style=position:absolute;left:300px><br />";
    print "Visuel <input type=checkbox name=visuel $visuelcheck style=position:absolute;left:300px><span style=position:absolute;left:350px>Prix</span><input type=text name=visuelprix value='$visuelprix' style=position:absolute;left:400px size=5><br />";
    print "Pub <input type=checkbox name=pub $pubcheck style=position:absolute;left:300px><span style=position:absolute;left:350px>Prix</span><input type=text name=pubprix value='$pubprix' style=position:absolute;left:400px size=6><br />";
    print "Designation Pub<br><input type=text name=desi_pub value=\"$desi_pub\" size=40>";
    $code_neg=$code*-1;
    $pagepub=&get("select page from mag where code=$code_neg");
    print " Page <input type=text name=pagepub value='$pagepub' size=3>";
    print "<br>";
    print "Nouveau <input type=checkbox name=new $newcheck style=position:absolute;left:300px><br />";
    &place();
    print "Page:<input type=texte name=newpage value='$page' size=3> Position:<input type=texte name=newposition value='$position' size=3><br>";
    print "Info<br><input type=text name=info value=\"$info\"  size=50><br />";
    print "Contact<br><input type=text name=contact value=\"$contact\" size=50><br />";
    print "<input type=hidden name=mag value=$mag>";
    print "<input type=hidden name=cases value=$cases>";
    print "<input type=hidden name=page value=$page>";
    print "<input type=hidden name=action_prev value=$action_prev>";
    print "<input type=hidden name=action value=modif_save>";
    print "<br ><input type=submit>";
    &save("create temporary table similarity (code bigint(20),rank decimal(4,2))");

    if (($code==0)&&($desi ne "")){
      print "<br>Proposition de produit<br>";
      $query="select pr_cd_pr,pr_desi from produit limit 1000";
      $sth=$dbh->prepare($query);
      $sth->execute();
      while (($code,$pr_desi)=$sth->fetchrow_array){
	  $ecart= similarity $pr_desi,$desi;
	  if ($ecart>=0.5){ 
	    &save("insert into similarity values ('$code','$ecart')");
	    
	  }
      }
      if ($marque ne ""){
	$query="select pr_cd_pr from produit where pr_desi like '%$marque%'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($code)=$sth->fetchrow_array){
	    $check=&get("select count(*) from similarity where code='$code'")+0;
	    if ($check==0){
	      &save("insert into similarity values ('$code','0')");
	    }
	}
      }
      $query="select pr_cd_pr,pr_desi,rank*100 from produit,similarity where code=pr_cd_pr order by rank desc";
      $sth=$dbh->prepare($query);
      $sth->execute();
      while (($code,$pr_desi,$rank)=$sth->fetchrow_array){
	 $rank=int($rank);
         print "<a href=# onclick=document.maform.code.value=$code>$code</a> $pr_desi $rank%<br>";
     }
    }
    print "</form>";
    print "<form>";
    &form_hidden();
    print "<input type=hidden name=mag value='$mag'>";
    print "<input type=hidden name=focus value='$code'>";
    print "<input type=hidden name=action value=go>";
    print "<input type=submit value=retour>";
    print "</form>";
      
  }

if ($action eq "modif_desi_pub"){
  $query = "select code from mag where mag='$mag' order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($code)=$sth->fetchrow_array){
    $desi_pub=$html->param("desi_pub$code");  
    if ($desi_pub ne ""){
        $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
        $desi_pub.=" $pr_desi";
    	&save("update mag set desi_pub='$desi_pub' where mag='$mag' and code=$code","af");
     }
   }
  $action="pub";
}

if ($action eq "modif"){
#   print $html->param("a220246");
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
#   print $query;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$visuelprix,$pubprix)=$sth->fetchrow_array){
    ($newpage,$newcases,$newcode)=split(/:/,$html->param("a$code"));  
#     print "$code $newcode<br>";
  
    if ($newcode!=$code){
      $query="select cases from mag where mag='$mag' and page='$newpage' and cases>='$newcases' order by cases desc";
#       print "$query";
      $sth2=$dbh->prepare($query);
      $sth2->execute();
      while (($mcases)=$sth2->fetchrow_array){
	&save("update mag set cases=cases+1 where mag='$mag' and page='$newpage' and cases='$mcases'","af");
      }
      if (($cases >$newcases)&&($page==$newpage)){$cases++;}
      &save("update mag set page='$newpage',cases='$newcases' where mag='$mag' and page='$page' and cases='$cases'","af");
      $focus=$code;
    }
  }
  $action="go";
}

if ($action eq ""){
  print "<form style=margin-left:100px;>";
  print "Choisir un magazine<br>";
  &form_hidden();
  $query = "select distinct mag from mag order by mag desc ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($mag)=$sth->fetchrow_array){
    print "<input type=submit name=mag value=$mag>";
  }
  print "<input type=hidden name=action value=go>";
  print "</form>";
  print "<hr></ht>";
  print "Ou importation<br>";
  print "<form method=POST enctype=multipart/form-data style=margin-left:100px;>";
  print "Choisir un fichier csv<br>";
  &form_hidden();
  print " <input type=hidden name=MAX_FILE_SIZE value=2097152> ";
  print "<input type=file name=fichier accept=text/* maxlength=2097152>";
  print "<br>Nom ? (sans espace ni accent) <input type=texte name=mag>";
  print "<input type=submit name=action value=importer>";
  print "</form>";
}
if ($action eq "sup"){
  &save("delete from mag where code='$code' and page='$page' and mag='$mag' limit 1","af");
  print "<div class=red>Supprimé<div>";
  $action="go";
}

if ($action eq "verif1"){
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    
    print "<div $style>";
    print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif1&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
    
    if ($new){print " <img src=../../images/new.png>";}
    print "<span style=position:absolute;left:450px>$prix</span>";
    print "<span style=position:absolute;left:500px>$prix_xof</span>";
    if ($prix!=0){$ratio=int($prix_xof/$prix);}else{$ratio=999999;}
    print "<span style=position:absolute;left:550px;";
    if (($ratio>700)||($ratio<649)){print "background-color:red;"}
    print ">$ratio</span></div>";
  }
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
}

if ($action eq "verif2"){
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_prac=&get("select pr_prac/100 from produit where pr_cd_pr='$code'")+0;
    
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    print "<div $style>";
    print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif2&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
    
    if ($new){print " <img src=../../images/new.png>";}
    print "<span style=position:absolute;left:450px>$pr_prac</span>";
    print "<span style=position:absolute;left:500px>$prix</span>";
    if ($pr_prac!=0){$ratio=int($prix*100/$pr_prac)/100;}else{$ratio=999999;}
    print "<span style=position:absolute;left:550px;";
    if (($ratio>3)||($ratio<2)){print "background-color:red;"}
    print ">$ratio</span></div>";
  }
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
}

if ($action eq "verif3"){
  print "stock et commande en cours<br>";
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $i=0;
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_stre=&get("select pr_stre/100 from produit where pr_cd_pr='$code'")+0;
    $cde=&get("select sum(com2_qte)/100 from commande where com2_cd_pr='$code'")+0;
    
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    $en_cours=$pr_stre+$cde;
    if ($en_cours<12){   $style=" style=color:red;";}
   
    print "<div $style>";
    print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif3&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
    
    if ($new){print " <img src=../../images/new.png>";}
    print "<span style=position:absolute;left:450px>$pr_stre</span>";
    print "<span style=position:absolute;left:500px>$cde</span>";
    print "</div>";
  }
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
}
# if ($action eq "verif4"){
#   print "prix d'achat enregistré et prix d'achat ficher excel<br>";
#   
#   $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
#   $i=10;
#   $sth=$dbh->prepare($query);
#   $sth->execute();
#    $query="select prac from Feuille1 order by cases";
#   $sth2=$dbh->prepare($query);
#   $sth2->execute();
#    
#   
#   while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
#     if ($page ne $page_tamp){
#       print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
#       print "</div>";
#       $page_tamp=$page;
#     }
#     $style="";
#     if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
#     $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
#     $pr_prac=&get("select pr_prac/100 from produit where pr_cd_pr='$code'")+0;
#     ($pr_prac_new)=$sth2->fetchrow_array;  
#     $pr_prac_new=int($pr_prac_new*100)/100;
#     if (($pr_desi eq "")||($code==0)){
#       $pr_desi=$desi;
#       $style=" style=color:red;";
#     }
#     print "<div $style>";
#     print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=verif3&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
#     
#     if ($new){print " <img src=../../images/new.png>";}
#     print "<span style=position:absolute;left:450px>$pr_prac</span>";
#     print "<span style=position:absolute;left:500px>$pr_prac_new</span>";
#     if ($pr_prac!=0){$ratio=int($pr_prac_new*100/$pr_prac)/100;}else{$ratio=999999;}
#     print "<span style=position:absolute;left:550px;";
#     if ((($ratio>1.2)||($ratio<0.8))&&($pr_prac!=0)&&($pr_prac_new!=0)){print "background-color:red;"}
#     print ">$ratio</span>";
#      print "</div>";
#     $i++;
#   }
#    if ($focus ne ""){
#     print "<script>location.href='#$focus';</script>";
#    }
#   
# }
if ($action eq "majprix"){
    $query = "select code from mag,produit where pr_cd_pr=code and mag='$mag' and pr_four='$four'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code)=$sth->fetchrow_array){
      $fa_id=&get("select pr_famille from produit_plus  where pr_cd_pr='$code'");
      $prixv=&get("select prix from mag_pub where famille='$fa_id' and type='V' and four='$four'")+0;
      $prixp=&get("select prix from mag_pub where famille='$fa_id' and type='P' and four='$four'")+0;
      if ($prixv!=0){
	  &save("update mag set visuelprix='$prixv' where mag='$mag' and code='$code'","af");
      }
      if ($prixv!=0){
	  &save("update mag set pubprix='$prixp' where mag='$mag' and code='$code'");
      }
    }
    print "Mise à jour effectuée<br>";
    $action="pub";
}    
if ($action eq "modif_prix_pub"){
    $query = "select code from mag,produit where pr_cd_pr=code and mag='$mag' and pr_four='$four'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code)=$sth->fetchrow_array){
      $prixv=$html->param("visuel$code")+0;
      $prixp=$html->param("pub$code")+0;
      &save("update mag set visuelprix='$prixv' where mag='$mag' and code='$code'","af");
      &save("update mag set pubprix='$prixp' where mag='$mag' and code='$code'","af");
    }
    print "Mise à jour effectuée<br>";
    $action="pub";
}    

if ($action eq "pub"){
    $marque_tamp="null";
    print "Libelle:$cl_magazine<br>";
    print "<p style=color:blue>Les prix peuvent être mis à jour:<br>";
    print "-Individuellement en cliquant sur le code produit </br>";
    print "-Individuellement en modifiant le prix dans les cases ci-dessous (bouton modifier en bas du fournisseur)</br>";
    print "-En mettant à jour les prix par défaut (lien prix visuel dans le cadre gauche), puis le lien 'mise à jour des prix par defaut' en bas de chaque marque</br>";
    print "Les prix en négatif appraissent comme offerts dans la facture<br></p>";
    print "<form name=maform>";
    &form_hidden();
    print "Premier no de facture <input type=texte name=facture><br>";
    print "<input type=hidden name=action value=facture_pub>";
    print "<input type=hidden name=mag value=$mag>";
    print "<input type=submit value=Facture><br>";
    print "<input type=hidden name=four value='nul'>";

    $query = "select code,pr_desi,pr_four,visuel,pub,visuelprix,pubprix,desi_pub,marque,cases,page from mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' order by pr_four,marque,pr_desi";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($code,$pr_desi,$pr_four,$visuel,$pub,$visuelprix,$pubprix,$desi_pub,$marque,$cases,$page)=$sth->fetchrow_array){
#       if ($marque eq ""){
# 	($marque)=split(/ /,$pr_desi);
#         &save("update mag set marque='$marque' where code='$code'","aff");
#       }
#       if (($marque >0)&&($marque<15)){
# 	($marque)=split(/ /,$pr_desi);
#         &save("update mag set marque='$marque' where code='$code'","aff");
#       }
      if ($marque_tamp eq "null") {$marque_tamp=$marque;}
      if ($pr_four ne $fo2_cd_fo){
	  if ($fo2_cd_fo ne ""){
	  if ($afacture==1){
	    print "<input type=hidden name=afac_$fo2_cd_fo"."_"."$marqueindex value='on'>";
# 	    print "</br>**** on *****</br>";
	  }
	  $afacture=0;
	  $marqueindex=0;
# 	  print "<input type=submit value=modifier onclick=\"document.maform.four.value='$fo2_cd_fo';document.maform.action.value='modif_prix_pub'\">"; 	 
# 	  print "*$afacture*";
   
 	  print "<input type=submit value=modifier onclick=document.maform.action.value='modif_prix_pub';document.maform.four.value='$fo2_cd_fo'>"; 	    
	 
	  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";

# 	    print "No de facture <input type=texte name=facture> Sous_totaux <input type=checkbox name=sous_tot><br>";
# 	    print "<input type=hidden name=four value=$fo2_cd_fo>";
# 	    print "<input type=hidden name=action value=facture_pub>";
# 	    print "<input type=hidden name=mag value=$mag>";
#  	    print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";
#   	    print "</form>";
	  }
	  ($fo2_add)=split('\*',&get("select fo2_add from fournis where fo2_cd_fo='$pr_four'"));
	  $sous_tot=0;
	  if ($pr_four==1260){$sous_tot=1;} #distrimark
	  if ($pr_four==1290){$sous_tot=1;} #iom
	  print "<hr></hr><span style=font-size:1.1em;font-weight:bold;>$pr_four $fo2_add</span>";
	  if ($sous_tot){print " <span style=font-size:1.1em;color:blue;>$marque</span>";}
	  print "<br>";
	  $fo2_cd_fo=$pr_four;
	  $marque_tamp=$marque;
      } 
      if (($marque ne $marque_tamp)&&($sous_tot)){
# 	  print "No de facture <input type=texte name=facture> Sous_totaux <input type=checkbox name=sous_tot><br>";
# 	  print "<input type=hidden name=four value=$fo2_cd_fo>";
# 	  print "<input type=hidden name=marque value='$marque'>";
# 	  print "<input type=hidden name=action value=facture_pub>";
# 	  print "<input type=hidden name=mag value=$mag>";
# 	  print "<input type=submit>";
# 	  print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";
# 	  print "</form>";
	  if ($afacture==1){
	    print "<input type=hidden name=afac_$fo2_cd_fo"."_"."$marqueindex value='on'>";
# 	    print "</br>****$pr_four on *****</br>";
	    $afacture=0;
	  }
  	  $marqueindex++;
 	  $marque_tamp=$marque;
	  print "<br><span style=font-size:1.1em;font-weight:bold;>$pr_four $fo2_add</span>";
	  print " <span style=font-size:1.1em;color:blue;>$marque</span>";
	  print "<br>";
      } 
      
      if ($visuel==1) {
	  print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&action_prev=pub&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a>";
          print " PACKSHOTS $pr_desi <input type=text name=visuel$code value='$visuelprix' size=3 style=position:absolute;left:500px><br>";
          if ($visuelprix!=0){$afacture=1;}
      }
      if ($pub==1) {
	if ($desi_pub eq ""){
	  $desi_pub="PLEINE PAGE $pr_desi";
	}
	if (($option eq "modif_pub")&&($code==$code_pub)){
	  print "<select name=desi_pub$code>";
	  $query = "select produit.pr_cd_pr,pr_desi from produit,produit_plus where produit.pr_cd_pr=produit_plus.pr_cd_pr and produit_plus.pr_famille=99";
	  $sth2=$dbh->prepare($query);
	  $sth2->execute();
	  while (($code_pub,$pr_desi_pub)=$sth2->fetchrow_array){
	    print "<option value='$pr_desi_pub' ";
	    if ($pr_desi_pub eq $desi_pub) {print "selected";}
	    print ">$code_pub $pr_desi_pub</option>";
	  }
	  print "</select>";  
# 	  print "<input type=text name=desi_pub$code value='$desi_pub' size=60>"
	  print "<input type=submit onclick=document.form$pr_four.action.value='modif_desi_pub'>";
	}
	else {
	  print "<span style=color:blue>$desi_pub</span>";
	  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=pub&option=modif_pub&mag=$mag&page=$page&code_pub=$code><img border=0 src=../../images/b_edit.png title='Modifier'></a>";
	}
	print "<input type=text name=pub$code value='$pubprix' size=3 style=position:absolute;left:500px><br>";
	if ($pubprix!=0){$afacture=1;}
      }
    }
    # sortie de boucle
    if ($afacture==1){
	    print "<input type=hidden name=afac_$fo2_cd_fo"."_"."$marqueindex value='on'>";
# 	    print "</br>****$pr_four on *****</br>";
	    $afacture=0;
    }
    print "<input type=submit value=modifier onclick=document.maform.action.value='modif_prix_pub';document.maform.four.value='$fo2_cd_fo'>"; 	    
    print " <a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&four=$fo2_cd_fo&mag=$mag&action=majprix style=margin-left:100px;>Mise à jour des prix par défaut</a>";
    print "</form>";
}


if ($action eq "excel"){
# en cours
  $sheet=new OpenOffice::OOCBuilder();
  $ligne=1;
  $col=1;
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $i=0;
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    $pr_refour=&get("select pr_refour from produit where pr_cd_pr='$code'");
    $pr_four=&get("select pr_four from produit where pr_cd_pr='$code'");
    $query="select * from fournis where fo2_cd_fo='$pr_four'";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth2->fetchrow_array;
    ($nom,$rue,$ville)=split(/\*/,$fo2_add);
    $sheet->set_data_xy ($col, $ligne, "$code");
    $col++;
    $ligne++;
    $col=1;
    print "$page;$pr_refour;$code;$marque;$pr_desi;;$prix;$prix_xof;$nom;$texte;$visuel;$info;$contact<br>";
  }
  $sheet->generate("$mag");
  copy "/var/www/cgi-bin/camairco.oasix/$mag.sxc","/var/www/camairco.oasix/doc/$mag.sxc";
  print "<br><a href=http://camairco.oasix.fr/doc/$mag.sxc>Fichier Openoffice</a>";

}

if ($action eq "facture_pub"){
  $facture=$html->param("facture");
  if ($facture eq ""){print "merci de mettre un numero de facture<br>";$action="pub";}
  else {
    $query = "select distinct pr_four from mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($four)=$sth->fetchrow_array){
      $sous_tot=0;
      if ($four==1260){$sous_tot=1;} #distrimark
      if ($four==1290){$sous_tot=1;} #iom
      $ref="afac_".$four."_0";
      %tot=();
      if (($html->param("$ref") eq "on")||($sous_tot==1)){
	$total_fo=0;
        &create_pdf();
	print "<div style=\"border:1px solid black;\"><form>$nom Email:<input type=text name=email size=30 value='$fo2_email'>";
	&form_hidden();
	print "<input type=hidden name=action value=sendpdf>";
	print "<input type=submit value='Envoyer le courrier'>";
	print "<input type=hidden name=fichier value='$fich'>";
	if ($sous_tot==1){
	  foreach $cle (keys(%tot)){
	    print "$cle ".$tot{"$cle"}." Euros<br>";
	  }
	}
	print "<figure><a href=http://$base_rep.fr/doc/$fich><img src=/images/pdf.jpg /></a><figcaption>$fich $total_fo Euros</figcaption></figure>";
	$total_gen+=$total_fo;
	print "</form></div>";
	$facture++;
      }
    }
  print "<stong> Total:$total_gen Euros</strong>";  
  }
}


sub create_pdf{  
  $sous_total=0;
  $total=0;
  $file="/var/www/$base_rep/doc/pub_".$facture.".pdf";
  $fich="pub_".$facture.".pdf";
  if (-f $file){unlink ($file);}
  $pdf = PDF::API2->new(-file => $file);
    # $page->cropbox  (7.5/mm, 7.5/mm, 97.5/mm, 140.5/mm);
  %font = (
  Helvetica => {
  Bold   => $pdf->corefont( 'Helvetica-Bold',    -encoding => 'latin1' ),
  Roman  => $pdf->corefont( 'Helvetica',         -encoding => 'latin1' ),
  Italic => $pdf->corefont( 'Helvetica-Oblique', -encoding => 'latin1' ),
  },
  Times => {
	  Bold   => $pdf->corefont( 'Times-Bold',   -encoding => 'latin1' ),
	  Roman  => $pdf->corefont( 'Times',        -encoding => 'latin1' ),
	  Italic => $pdf->corefont( 'Times-Italic', -encoding => 'latin1' ),
  },
  );
  $date_du_jour=`/bin/date +%d'/'%m'/'%Y`;
  $index=0;
  $query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque from mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four' order by pr_desi";
  $sous_tot=0;
  if ($four==1260){$sous_tot=1;} #distrimark
  if ($four==1290){$sous_tot=1;} #iom
  $marqueindex=0;
  if ($sous_tot==1){
    $query = "select code,pr_desi,visuel,pub,visuelprix,pubprix,marque from mag,produit where pr_cd_pr=code and (pub=1 or visuel=1) and mag='$mag' and pr_four='$four'  order by marque,pr_desi ";
  }
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  $first=0;
  $marque_tamp="null";
  while (($code,$pr_desi,$visuel,$pub,$prix,$pubprix,$marque)=$sth->fetchrow_array){
    
    if ($marque_tamp eq "null"){$marque_tamp=$marque;}
    if ($marque ne $marque_tamp){$marqueindex++;$marque_tamp=$marque;}
    $ref="afac_".$four."_".$marqueindex;
    # print "$four $code $pr_desi $prix $ref".$html->param("$ref")."<br>";
    if (($sous_tot==1)&&($html->param("$ref") ne "on")){next;}
#        print "$pr_desi $prix <br>";
    if ($prix!=0){
      $nb++;
#       if ($nb>21) {
# 	$nb=0;
# 	$tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
# 	$tete_text->translate( 40/mm, $ligne/mm );
# 	$tete_text->text("Suite .... ");
# 	$index++;
# 	if (($sous_tot==1)&&($marque ne $marque_tamp)){
# 	  $facture++;
# 	  $marque_tamp=$marque;
# 	  
# 	}
# 	&facture_suite();
#       }
      if ($first==0){$marque_facture=$marque;&facture_suite();}
      $first=1;
      if (($sous_tot==1)&&($marque ne $marque_facture)) {
	$nb=0;
	#print "la $marque_facture $marque-";
	&total();
	$index++;
	$facture++;
	$marque_facture=$marque;
	&facture_suite();
      }
      if ($prix <0){
	$prix=$prix*-1;
	$pr_desi="$pr_desi $prix Euros";
	$prix="Offert";
      }
      $tete_text->translate( 20/mm, $ligne/mm );
      $tete_text->text("PACKSHOT $pr_desi");
      $tete_text->translate( 150/mm, $ligne/mm );
      $tete_text->text("$prix");
      
      if ($prix ne "Offert"){
	$total+=$prix;
	$sous_total+=$prix;
	$tete_text->translate( 170/mm, $ligne/mm );
	$tete_text->text("Euros");
      }
       $ligne-=5;
    
    }
    $prix=$html->param("pub$code");
    if ($prix!=0){
      if ($first==0){$marque_facture=$marque;&facture_suite();}
      $first=1;
      $nb++;
      if ($nb>21) {
	      $nb=0;
	      $tete_text->font( $font{'Helvetica'}{'Bold'}, 10/pt );
	      $tete_text->translate( 40/mm, $ligne/mm );
	      $tete_text->text("Suite .... ");
	      $index++;
	      &facture_suite();
      }

      $tete_text->translate( 20/mm, $ligne/mm );
      if ($prix <0){
	$prix=$prix*-1;
	$tete_text->text("$pr_desi $prix Euros");
	$prix="Offert";
      }
      else{
      	$tete_text->text("$pr_desi");
      }
      if ($prix >999){
      	$tete_text->translate( 146/mm, $ligne/mm );
      }
      else {
	if ($prix >100){
	  $tete_text->translate( 148/mm, $ligne/mm );
	}
	else {
	  $tete_text->translate( 150/mm, $ligne/mm );
	}
      }
      $tete_text->text("$prix");
      if ($prix ne "Offert"){
	$total+=$prix;
	$sous_total+=$prix;
	$tete_text->translate( 170/mm, $ligne/mm );
	$tete_text->text("Euros");
      }
      $ligne-=5;
    }
  }
#   for ($i=0;$i<15;$i++){
# 	$tete_text->translate( 170/mm, $ligne/mm );
# 	$tete_text->text("Euros");
# 	$ligne-=5;
# }	
  
  $marque=$marque_facture;
  &total();
  $pdf->save();
}


if ($action eq "go"){
print <<EOF;

<script>
function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function drop(ev) {
    ev.preventDefault();
    var x=eval(ev.target.id);
    var cible='h'+ev.target.id;
    var source = ev.dataTransfer.getData("Text");
    var y=eval(source);
    document.getElementById(cible).innerHTML=document.getElementById(source).innerHTML;
    document.getElementById(source).innerHTML="";
    document.maform.elements[y].value=document.maform.elements[x].value;
    document.maform.submit();
 }
</script>
EOF

  print "<span style=\"font-size:1.1em;background-color:#56739A;color:white;border-radius:0px 0px 10px 00px;padding:5px;font-weight:bold;\">$mag</span>";
  print "<form style=margin-top:25px>";
  &form_hidden();
  print "<input type=hidden name=action value=copier>";
  print "<input type=hidden name=mag value=$mag>";
  print "Nom <input type=texte name=new_mag size=3>";
  print "<input type=submit value=copier><br>";
  $adresse=&get("select adresse from mag_info where mag='$mag'");
  print "Lien web:";
  print "<a href=http://issuu.com/renaut/docs/$adresse style=color:blue;>http://issuu.com/renaut/docs/$adresse</a> ";
  if ($adresse ne ""){
    my $ua  = LWP::UserAgent->new();
    my $req = HTTP::Request->new( GET => "http://issuu.com/renaut/docs/$adresse" );
    my $res=$ua->request($req);
    if (! $res->is_success){print " <span style=background-color:red;color:white>Lien invalide !</span>";}
  }  
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modif_adresse&mag=$mag><img border=0 src=../../images/b_edit.png title='Modifier' width=18px></a>";
  print "</form>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif1&mag=$mag>Verifier prix XOF</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif2&mag=$mag>Verifier prix EUR</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif3&mag=$mag>Verifier Stock</a><br>";
#   print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=verif4&mag=$mag>Verifier prix achat du ficher excel</a><br>";
  print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=excel&mag=$mag>Export fichier</a><br>";
  print "<form>";
  &form_hidden();
  print "<input type=hidden name=action value=pub>";
  print "<input type=hidden name=mag value=$mag>";
  print "<input type=submit value=Facture></form>";
#   print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=pub&mag=$mag>Facture pub</a><br>";
  
  print "<form name=maform id=maform>";
  $query = "select mag,page,cases,code,prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix from mag where mag='$mag' order by mag,page,cases";
  $sth=$dbh->prepare($query);
  $i=0;
  $sth->execute();
  while (($null,$page,$cases,$code,$prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix)=$sth->fetchrow_array){
    if ($page ne $page_tamp){
      print "<div style=color:orange;font-size:1.2em;font-weight:bold;>Page:$page ";
      print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&mag=$mag&page=$page><img border=0 src=../../images/pop.png title='Inserer' width=18px></a>";
      print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=modif_page&mag=$mag&page=$page><img border=0 src=../../images/b_edit.png title='Modifier' width=18px></a>";
      
      # print "<span style=position:absolute;right:400px>Pv</span>";
      print "</div>";
      $page_tamp=$page;
    }
    $style="";
    $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
    if (($pr_desi eq "")||($code==0)){
      $pr_desi=$desi;
      $style=" style=color:red;";
    }
    if ($code<0){
      $pr_desi=$desi;
      $style=" style=background-color:greenyellow;";
    }
    print "<li id=\"h$i\" class=cache></li>";
    if (($code eq $focus)&&($style eq "")){$style=" style=background-color:yellow;";}
    
    print "<li id=\"$i\" ondrop=\"drop(event)\" ondragover=\"allowDrop(event)\" draggable=\"true\" ondragstart=\"drag(event)\" $style>";
    if ($code<0){
      print "$pr_desi";
      print "<span style=position:absolute;left:450px>";
      $code_pos=$code*-1;
      print &get("select pubprix from mag where mag='$mag' and code='$code_pos'");
      print "</span>";
    }
    else {
      print "<a id=$code href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=ins&mag=$mag&page=$page&code=$code&cases=$cases class=nodeco>$code</a> $pr_desi";
      if ($new){print " <img src=../../images/new.png>";}
      print "<span style=position:absolute;left:450px>$prix</span>";
      print "<span style=position:absolute;left:500px>$prix_xof</span>";
      if ($texte==1){print "<a class=textemag style=position:absolute;left:550px;><span>Texte</span>T</a>";}
      $couleur="";
      $visuelprix+=0;
      if ($visuelprix==0){$couleur="color:red;";}
      if ($visuel==1){print "<a class=textemag style=position:absolute;left:570px;$couleur><span>Visuel</span>V</a>";}
      $couleur="";
      $pubprix+=0;
      if ($pubprix==0){$couleur="color:red;";}
      if ($pub==1){print "<a class=textemag style=position:absolute;left:590px;$couleur><span>Pub</span>P</a>";}
    }
    print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=sup&mag=$mag&page=$page&code=$code  style=position:absolute;left:620px><img border=0 src=../../images/b_drop.png title='Supprimer'></a>";
    print "</span>";
    print "</li>";
    $value="$page:$cases:$code";
    print "<input type=hidden name=a$code value=$value>\n";
    $i++;
 
   }
   print "<input type=hidden name=action value=modif>";
   print "<input type=hidden name=mag value=$mag>";
   print "<input type=submit>";
   if ($focus ne ""){
    print "<script>location.href='#$focus';</script>";
   }
  
   &form_hidden();
   print "</form>";
 
}
print "</div>"; # fin de la boite cellule principale

sub facture_suite{
  $page[$index] = $pdf->page();
  $page[$index]->mediabox('A4');
  $tete_text = $page[$index]->text;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->fillcolor('navy');
  
  my $logo1 = $page[$index]->gfx;
  my $logo1_file = $pdf->image_png('./logoDFC.png');
  $logo1->image( $logo1_file, 20/mm, 260/mm, 113, 88 );

#   $tete_text->translate( 20/mm, 280/mm );
#   $tete_text->text("DutyFree Concept");
#   $tete_text->translate( 20/mm, 275/mm );
#   $tete_text->text("1 Passage du grand cerf");
#   $tete_text->translate( 20/mm, 270/mm );
#   $tete_text->text("75002 Paris");
#   $tete_text->translate( 20/mm, 265/mm );
#   $tete_text->text("Tel 06 98 37 94 94");
#   $tete_text->fillcolor('black');
  $query="select * from fournis where fo2_cd_fo='$four'";
  my($sth)=$dbh->prepare($query);
  $sth->execute();
  ($fo2_cd_fo,$fo2_add,$fo2_telph,$fo2_fax,$fo2_contact,$fo2_identification,$fo2_delai,$fo2_transp,$fo2_livraison,$fo2_transport,$fo2_deb,$fo2_freq,$fo2_email)=$sth->fetchrow_array;
  ($nom,$rue,$ville)=split(/\*/,$fo2_add);
  $ligne=245;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$nom");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$rue");
  $ligne-=5;
  $tete_text->translate( 110/mm, $ligne/mm );
  $tete_text->text("$ville");
  $ligne-=10;
  $tete_text->font( $font{'Helvetica'}{'Bold'}, 14/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("FACTURE N° $facture");
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Le:$date_du_jour");
  $ligne-=10;
  $tete_text->translate( 20/mm, $ligne/mm );
  $adresse=&get("select adresse from mag_info where mag='$mag'");
  $tete_text->text("Magazine:$cl_magazine N°:$mag Lien web: http://issuu.com/renaut/docs/$adresse");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Compagnie $cl_nom");
  if ($sous_tot==1){
    $tete_text->translate( 80/mm, $ligne/mm );
    $tete_text->text("Marque $marque");
  }  
  $tete_text->fillcolor('navy');
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
  $ligne=60;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Coordonnées bancaires");
  $ligne-=5;
  $tete_text->font( $font{'Helvetica'}{'Bold'}, 12/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Domiciliation:Bred Paris Opera Bic:BREDFRPPXXX Iban:FR76 1010 7001 7500 2150 4596 342");
  $ligne-=9;
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 10/pt );
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Paiement à réception de facture");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("TVA payée sur les encaissements");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Tout litige ou contestation sont exclusivement du ressort du tribunal de commerce du siège de l'entreprise.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("Aucun mode de règlement ou mode de livraison ne peuvent modifier cette clause.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("2 - Conformément à la loi du 12 mai 1980, nos produits restent notre propriété jusqu'à complet règlement.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("3 - Le non-retour de ccette facture dans un délai de huit jours implique acceptation de cette facturation. Toute somme");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("non réglée à la date d'échéance donnera lieu à la perception d'une indemnité de retard au taux minimum de 1,3%.");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("DUTY FREE CONCEPT 1 passage du Grand Cerf 75002 PARIS");
  $ligne-=5;
  $tete_text->translate( 20/mm, $ligne/mm );
  $tete_text->text("TVA intracommunautaire FR09 524 057 049 - RCS PARIS 524 057 049 00016");
  $tete_text->fillcolor('black');
  $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $ligne=195;
  &boite(15,203,200,65);
 }
 
sub get_mag{
  $query = "select prix,prix_xof,texte,visuel,pub,new,info,contact,desi,visuelprix,pubprix,desi_pub,marque from mag where mag='$mag' and cases='$cases' and code='$code'";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($prix,$prix_xof,$texte,$visuel,$pub,$new,$info,$contact,$desi,$visuelprix,$pubprix,$desi_pub,$marque)=$sth->fetchrow_array;
  $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
} 

sub place{
  $page= &get("select page from mag where mag='$mag' and cases='$cases' and code='$code'","af");
  $position= &get("select count(*) from mag where mag='$mag' and page='$page' and cases<='$cases'");
}  

sub boite() {
	$a=$_[0];
	# x gauche
	$b=$_[1];
	# y haut
	$c=$_[2];
	# x droit
	$d=$_[3];
	# y bas
	# y bas
	my $line = $page[$index]->gfx;
	$line->strokecolor('black');

	# horizontale 
	$line->move( $a/mm, $b/mm );
	$line->line( $c/mm, $b/mm );
	$line->stroke;
	$line->move( $a/mm, $d/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;

	# verticale 	
	$line->move( $a/mm, $b/mm );
	$line->line( $a/mm, $d/mm );
	$line->stroke;
	$line->move( $c/mm, $b/mm );
	$line->line( $c/mm, $d/mm );
	$line->stroke;
}
sub total(){
 $tete_text->font( $font{'Helvetica'}{'Roman'}, 12/pt );
  $tete_text->translate( 100/mm, ($ligne-10)/mm );
  $tete_text->text("TOTAL HT:");
  $tete_text->translate( 148/mm, ($ligne-10)/mm );
  $tete_text->text("$total");
  $tete_text->translate( 170/mm, ($ligne-10)/mm );
  $tete_text->text("Euros");
  
  $tete_text->translate( 100/mm, ($ligne-15)/mm );
  $tete_text->text("TVA:");
  $tete_text->translate( 155/mm, ($ligne-15)/mm );
  $tete_text->text("0");
  $tete_text->translate( 170/mm, ($ligne-15)/mm );
  $tete_text->text("Euros");
  
  $tete_text->translate( 100/mm, ($ligne-20)/mm );
  $tete_text->text("TOTAL TTC:");
  $tete_text->translate( 148/mm, ($ligne-20)/mm );
  $tete_text->text("$total");
  $tete_text->translate( 170/mm, ($ligne-20)/mm );
  $tete_text->text("Euros");
  $total_fo+=$total;
  if ($sous_tot==1){$tot{"$marque_facture"}=$total;
#    print "**$marque_facture $total**<br>"
  }
  $total=0;
} 
;1 

