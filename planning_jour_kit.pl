print "<title>planning</title><center>";
print "<div class=titrefixe>Consultation du planning</div>";
$jour=$html->param('datejour');
$mois=$html->param('datemois');
$an=$html->param('datean');
$nbjour=$html->param('nbjour');
$action=$html->param('action');
$vol=$html->param('vol');
$leg=$html->param('leg');
$lot_nolot=$html->param('lot_nolot');
$client=$html->param('client');

$escale=$html->param('escale');
$date=$html->param('date');
if ($html->param('decal') eq "on"){$decal=-7;};
$today=&nb_jour($jour,$mois,$an)+$decal;
$decalheure=0; # heure hivers

if ($an<8){$today=$an;}

$datedujour=&nb_jour(`/bin/date '+%d'`+0,`/bin/date '+%m'`+0,"20".`/bin/date '+%y'`+0);

if ($today==-1){$today=$html->param('today');}

$date_sql=&julian($today,"yyyy-mm-dd");

if ($action eq ""){
	print "<center><br>Choix de la date<br><br><form>";
	require ("form_hidden.src");
	&select_date();
	print "<input type=hidden name=action value=affiche>";
	print "<br><br><input type=submit></form>	";
 }  


if ($action eq "affiche")
{
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}
	print  "<center>";
	print  "<h3>";
	print  &jour($today);
	print  " ";
	print  &julian($today,"");
	print  "</h3>\n";
	print "</center>";
	# print "<h3>Depart</h3>";
	&save("create temporary table table_tmp (sens char(1),vol varchar(12),nolot int(5),dest varchar(30),heure int(8),lot varchar(30),appro int(8))"); 
	($datejour,$datemois,$datean)=split(/\//,&julian($today,""));
	$query="select flb_vol,fl_troltype,fl_apcode,fl_nolot,flb_depart,flb_arrivee,flb_tridep,flb_triret from flyhead,flybody where fl_date='$today' and fl_date=flb_date and fl_vol=flb_vol and flb_rot=11  order by flb_depart";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fl_vol,$fl_troltype,$fl_apcode,$fl_nolot,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret)=$sth->fetchrow_array){
		$lot_conteneur=&get("select lot_conteneur from lot where lot_nolot=$fl_troltype");
		&save("insert ignore into table_tmp values ('d','$fl_vol','$fl_nolot','$flb_tridep $flb_triret','$flb_depart','$lot_conteneur','$fl_apcode')");
		# print "<tr><td>$fl_vol</td><td>$fl_nolot</td><td>$flb_tridep $flb_triret</td><td>$flb_depart</td><td>$lot_conteneur</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
	}	
	# print  "</table>\n";
	# print "<h3>Arrivée</h3>";
	# print  "<table  border=1 cellspacing=0 cellpadding=0 width=100%><tr bgcolor=#5580ab><th>Vol</th><th>Lot</th><th>Troncon</th><th>Heure</th><th>Dotation</th><th>Immat</th><th>Agent 1</th><th>Agent 2</th></tr>";
	($datejour,$datemois,$datean)=split(/\//,&julian($today,""));
	&save("CREATE Temporary tABLE `flybody_tmp` (`flb_date` int(11) NOT NULL DEFAULT '0',`flb_vol` char(10) NOT NULL DEFAULT '',`flb_rot` int(11) NOT NULL DEFAULT '0',`flb_datetr` int(11) NOT NULL DEFAULT '0',`flb_voltr` char(10) NOT NULL DEFAULT '',`flb_depart` int(11) NOT NULL DEFAULT '0',`flb_arrivee` int(11) NOT NULL DEFAULT '0',`flb_tridep` char(3) NOT NULL DEFAULT '',`flb_triret` char(3) NOT NULL DEFAULT '',`flb_nolot` char(6) NOT NULL DEFAULT '',PRIMARY KEY (`flb_date`,`flb_vol`)) ENGINE=MyISAM DEFAULT CHARSET=latin1;");
	$query="select * from flybody where flb_date='$today' order by flb_rot desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=$sth->fetchrow_array){
		&save("insert ignore into flybody_tmp values ('$flb_date','$flb_vol','$flb_rot','$flb_datetr','$flb_voltr','$flb_depart','$flb_arrivee','$flb_tridep','$flb_triret','$flb_nolot')","af");
	}
	$query="select flb_vol,fl_troltype,fl_apcode,fl_nolot,flb_depart,flb_arrivee,flb_tridep,flb_triret from flyhead,flybody_tmp where flb_date='$today' and fl_date=flb_date and fl_vol=flb_vol  order by flb_arrivee";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($fl_vol,$fl_troltype,$fl_apcode,$fl_nolot,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret)=$sth->fetchrow_array){
		$lot_conteneur=&get("select lot_conteneur from lot where lot_nolot=$fl_troltype");
		# print "<tr><td>$fl_vol</td><td>$fl_nolot</td><td>$flb_tridep $flb_triret</td><td>$flb_arrivee</td><td>$lot_conteneur</td><td>&nbsp;</td><td>&nbsp;</td><td>&nbsp;</td></tr>";
		&save("insert ignore into table_tmp values ('r','$fl_vol','$fl_nolot','$flb_tridep $flb_triret','$flb_arrivee','$lot_conteneur','$fl_apcode')");
	}	
	print  "<table  border=1 cellspacing=0 cellpadding=0 width=100%><tr bgcolor=#5580ab><th>Vol</th><th>Lot</th><th>Appro</th><th>Troncon</th><th>Depart</th><th>Retour</th><th>Dotation</th><th>Immat</th><th>Agent 1</th><th>Agent 2</th></tr>";
	$query="select * from table_tmp order by heure";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($sens,$vol,$nolot,$dest,$heure,$lot,$appro)=$sth->fetchrow_array){
		$heure=substr($heure,0,2).':'.substr($heure,2,2);
	    $nolot="&nbsp;" if ($nolot==0);
		$appro="&nbsp;" if ($appro==0);
		if ($sens eq "d"){
			($info1,$info2)=&get("select info1,info2 from prise_en_compte where rot=-2 and appro='$appro' ");
			print "<tr style=height:50px><td>$vol</td><td>$nolot</td><td>$appro</td><td>$dest</td><td>$heure</td><td>&nbsp;</td><td>$lot</td><td>&nbsp;</td><td>$info1</td><td>$info2</td></tr>";
		}
		else{
			($info1,$info2)=&get("select info1,info2 from prise_en_compte where rot=-1 and appro='$appro' ");
			print "<tr style=height:50px><td>$vol</td><td>$nolot</td><td>$appro</td><td>$dest</td><td>&nbsp;</td><td>$heure</td><td>$lot</td><td>&nbsp;</td><td>$info1</td><td>$info2</td></tr>";
		}
	}
	print  "</table>\n";
}	



# FONCTION : nb_jour(jour,mois,annee)
# DESCRIPTION : calcul le nombre de jour depuis 1970
# ENTREE : le jour mois annee (yyyy)
# SORTIE : le nombre de seconde

sub nb_jour{
	my ($jour)=$_[0];
	my ($mois)=$_[1];
	my ($annee)=$_[2];

	my(@nb_mois)=("",0,31,59,90,120,151,181,212,243,273,304,334);
	my($nb)=&nb_jour_an($annee)+$nb_mois[$mois]+ $jour-1 ;
	if (bissextile($annee) && $mois>2){ $nb++;}
	# $nb=$nb*24*60*60;  seconde
	return($nb);
}
sub nb_jour_an
{
	my ($annee)=$_[0];
	my ($n)=0;
	for (my($i)=1970; $i<$annee; $i++) {
		$n += 365; 
		if (&bissextile($i)){$n++;}
	}
	return($n);
}

sub bissextile {
	my ($annee)=$_[0];
	if ( $annee%4==0 && ($annee %100!=0 || $annee%400==0)) {
		return (1);}
	else {return (0);}
}
# FONCTION : julian(seconde,option)
# DESCRIPTION : retourne la date en fonction du format demandé
# ENTREE : le nombre de jours ecoules depuis 1970 et le format ex YY/MM/DD
# SORTIE : la date formatée

sub julian_null {
	my ($val)=$_[0];
	if ($val <8) {return;}
	my ($option)=$_[1];
	$val=$val*60*60*24;
	($null,$null,$null,my($jour),my($mois),my($annee),$null,$null,$null) = localtime($val);    
	$annee=substr($annee,1,2);
	$mois+=1001;
	$jour+=1000;
	$mois=substr($mois,2,2);
	$jour=substr($jour,2,2);

	$option=lc($option);
	if (lc($option) eq "")
	{
		($option = "dd/mm/yyyy");
	}
	$option=~s/mm/$mois/;
	$option=~s/dd/$jour/;
	$option=~s/yyyy/20$annee/;
	$option=~s/yy/$annee/;
 	return($option);
}
# FONCTION : jour(nombre)
# DESCRIPTION : Donne le jour de la semaine 
# ENTREE : Un nombre de jour depuis le 010101
# SORTIE : Un jour de la semaine
sub jour {
	my ($var) = $_[0];
	my (%semaine);
	if ($var <8){ # vol regulier
		%semaine=(1,"Lundi",2,"Mardi",3,"Mercredi",4,"Jeudi",5,"Vendredi",6,"Samedi",0,"Dimanche");
	}
	else {
		%semaine=(4,"Lundi",5,"Mardi",6,"Mercredi",0,"Jeudi",1,"Vendredi",2,"Samedi",3,"Dimanche");
	}
	
	return $semaine{$var%7};
}
sub select_date
{
 	$date=`/bin/date +%d';'%m';'%Y`;
  	(@dates)=split(/;/, $date, 3); 
  	$select_jour[$dates[0]]="selected"; 
  	$select_mois[$dates[1]]="selected"; 
  	$firstyear=$dates[2];
  	print "<select name=datejour>"; 
 	for($i=1;$i<=31;$i++) {print "<option value=\"$i\" $select_jour[$i]>$i</option>\n";} 
 	print "</select>"; 
  	@cal=("","Janvier","Février","Mars","Avril","Mai","Juin","Juillet","Août","Septembre","Octobre","Novembre","Décembre"); 
  	print "<select name=datemois>";
 	for($i=1;$i<=12;$i++) { print "<option value=\"$i\" $select_mois[$i]>$cal[$i]</option>\n"; } 
  	print "</select> <select name=datean>"; 
	for($i=$firstyear-1;$i<=($firstyear+1);$i++) { 
	  print "<option value=$i ";
	  if ($i==$firstyear){print "selected";}
	  print ">$i</option> ";} 
 	print "</select>"; 
} 
sub cal_heure {
	my ($var)=@_[0];
	if ($var eq ""){return;}
	if ($var eq "&nbsp;"){return;}
	
	my ($dec)=@_[1];
	$var=$var+$dec;
	if ($var>24){$var-=24;}
	if ($var<0){$var+=24;}
	return(&deci($var));
}



;1
