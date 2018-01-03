#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
use Spreadsheet::Read;
use Spreadsheet::XLSX;
use Math::Round;
$html=new CGI;
print $html->header();
$dbh = DBI->connect("DBI:mysql:host=195.114.27.208:database=aircotedivoire;","web","admin",{'RaiseError' => 1});
require "../oasix/outils_perl2.pl";
my $book  = ReadData ("/var/www/cgi-bin/aircotedivoire.oasix/planning.xlsx");
$action=$html->param("action");
$id=$html->param("id");
$date_sql=$html->param("date_sql");
$trol=2119;
($an,$mois,$jour)=split(/-/,$date_sql);
$date=&nb_jour($jour,$mois,$an);
 
if ($action eq "add"){
  $query="select jour,vol,li,col,dest,dep,arr from im_plan where id=$id";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($jour,$vol,$li,$col,$dest,$dep,$arr)=$sth->fetchrow_array;
  if ($col>24){$trol=2119;}
  $tridep=uc(substr($dest,0,3));
  $triarr=uc(substr($dest,3,3));
  print "$date,$jour,$vol,$tridep,$triarr,$dep,$arr<br>";
  print "$date,$vol,11,$date,$vol,$dep,$arr,$tridep,$triarr,<br>";

  $volanc=$vol;
  $jouranc=$jour;
   &save("insert ignore into flyhead value ('$date','$vol','200','1','$trol','0','0','0','1','0','$date_sql')","aff");
   &save("insert ignore into flybody value ('$date','$vol','11','$date','$vol','$dep','$arr','$tridep','$triarr','')","aff");
  $li++;
  $dest="";
  while ($dest eq ""){
    $query="select jour,vol,li,col,dest,dep,arr from im_plan where col='$col' and li='$li'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($jour,$vol,$li_n,$col_n,$dest,$dep,$arr)=$sth->fetchrow_array;
    $li++;
   }
  $tridep=uc(substr($dest,0,3));
  $triarr=uc(substr($dest,3,3));
  $datevol=$date;
  if ($jour ne $jouranc){$datevol++;}
  print "$date,$volanc,12,$datevol,$vol,$dep,$arr,$tridep,$triarr<br>";
   &save("insert ignore into flybody value ('$date','$volanc','12','$datevol','$vol','$dep','$arr','$tridep','$triarr','')","aff");
}
if ($action eq "add4"){
  $query="select jour,vol,li,col,dest,dep,arr from im_plan where id=$id";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($jour,$vol,$li,$col,$dest,$dep,$arr)=$sth->fetchrow_array;
  $tridep=uc(substr($dest,0,3));
  $triarr=uc(substr($dest,3,3));
  print "$date,$jour,$vol,$tridep,$triarr,$dep,$arr<br>";
  print "$date,$vol,11,$date,$vol,$dep,$arr,$tridep,$triarr,<br>";
  $volanc=$vol;
  $jouranc=$jour;
   &save("insert ignore into flyhead value ('$date','$vol','200','1','$trol','0','0','0','1','0','$date_sql')","aff");
   &save("insert ignore into flybody value ('$date','$vol','11','$date','$vol','$dep','$arr','$tridep','$triarr','')","aff");
  $li++;
  $dest="";
  while ($dest eq ""){
    $query="select jour,vol,li,col,dest,dep,arr from im_plan where col='$col' and li='$li'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($jour,$vol,$li_n,$col_n,$dest,$dep,$arr)=$sth->fetchrow_array;
    $li++;
  }
  $tridep=uc(substr($dest,0,3));
  $triarr=uc(substr($dest,3,3));
  $datevol=$date;
  if ($jour ne $jouranc){$datevol++;}
  print "$date,$volanc,12,$datevol,$vol,$dep,$arr,$tridep,$triarr<br>";
  &save("insert ignore into flybody value ('$date','$volanc','12','$datevol','$vol','$dep','$arr','$tridep','$triarr','')","aff");
  $dest="";
  while ($dest eq ""){
    $query="select jour,vol,li,col,dest,dep,arr from im_plan where col='$col' and li='$li'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($jour,$vol,$li_n,$col_n,$dest,$dep,$arr)=$sth->fetchrow_array;
    $li++;
   }
  $tridep=uc(substr($dest,0,3));
  $triarr=uc(substr($dest,3,3));
  $datevol=$date;
  if ($jour ne $jouranc){$datevol++;}
  print "$date,$volanc,21,$datevol,$vol,$dep,$arr,$tridep,$triarr<br>";
   &save("insert ignore into flybody value ('$date','$volanc','21','$datevol','$vol','$dep','$arr','$tridep','$triarr','')","aff");
  
  $dest="";
  while ($dest eq ""){
    $query="select jour,vol,li,col,dest,dep,arr from im_plan where col='$col' and li='$li'";
    $sth=$dbh->prepare($query);
    $sth->execute();
    ($jour,$vol,$li_n,$col_n,$dest,$dep,$arr)=$sth->fetchrow_array;
    $li++;
   }
  $tridep=uc(substr($dest,0,3));
  $triarr=uc(substr($dest,3,3));
  $datevol=$date;
  if ($jour ne $jouranc){$datevol++;}
  print "$date,$volanc,22,$datevol,$vol,$dep,$arr,$tridep,$triarr<br>";
   &save("insert ignore into flybody value ('$date','$volanc','22','$datevol','$vol','$dep','$arr','$tridep','$triarr','')","aff");
  
}

$nb_feuille=$book->[0]{sheets};
for ($i=2;$i<=$nb_feuille-1;$i++){
  $nb_col=$book->[$i]{maxcol};
  $nb_ligne=$book->[$i]{maxrow};
  print $i." ".$book->[$i]{label}."<br>";
  print "<table border=1 cellspacing=0 cellpadding=0>";
  for ($l=1;$l<=$nb_ligne;$l++){
#     if ($book->[$i]{cell}[1][$l] eq ""){next};
   if (grep /rank/,$book->[$i]{cell}[2][$l]){$color2="orange"};
   if ($book->[$i]{cell}[2][$l]==1){
    if ($color2 eq "white"){$color2="lavender";}else{$color2="white";}
    }
   print "<tr bgcolor=$color2>";
    for ($j=1;$j<=$nb_col;$j++){
      $color="";
      if ($book->[$i]{cell}[1][$l] eq "Lun."){$date_sql="2015-03-02";}
      if ($book->[$i]{cell}[1][$l] eq "Mar."){$date_sql="2015-03-03";}
      if ($book->[$i]{cell}[1][$l] eq "Mer."){$date_sql="2015-03-04";}
      if ($book->[$i]{cell}[1][$l] eq "Jeu."){$date_sql="2015-03-05";}
      if ($book->[$i]{cell}[1][$l] eq "Ven."){$date_sql="2015-03-06";}
      if ($book->[$i]{cell}[1][$l] eq "Sam."){$date_sql="2015-03-07";}
      if ($book->[$i]{cell}[1][$l] eq "Dim."){$date_sql="2015-03-08";}
      
      $cellule=$book->[$i]{cell}[$j][$l];
      $color3="";
      if (grep /Hf/,$cellule){
	if (grep /^Abj/,$book->[$i]{cell}[$j+1][$l]){$color3="lightgreen";}
      }
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Lun.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-02' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     } 
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Mar.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-03' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     }
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Mer.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-04' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     }
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Jeu.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-05' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     }
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Ven.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-06' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     }
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Sam.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-07' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     }
     if (($color3 eq "lightgreen")&&($book->[$i]{cell}[1][$l] eq "Dim.")&& (grep /Hf/,$cellule) ){
	$check=&get("select count(*) from flyhead where fl_date_sql='2015-03-08' and fl_vol='$cellule'")+0;
	if ($check) {$color3="lightblue"};
     }
     if (grep /^Abj/,$cellule){
      $color="green";
     }
      if (grep /Abj$/,$cellule){$color="red";}
      $hor=0;
      if (($cellule<1)&&($cellule>0)){
	$heure=int($cellule*24);
	$minute=round(($cellule*24 - $heure)*60);
	$hor=1;
      }
      print "<td bgcolor=$color3>";
      print "<span style=color:$color>";
      if ($hor){print "$heure:$minute";}
      else {
      if ($cellule eq ""){$cellule="&nbsp;";}
      $cellule=~s/\[//;
      $cellule=~s/\]//;
      if (($color2 eq "orange")&&(grep /vol/,$cellule)){$cellule="No vol";}
      print "$cellule";
      }
      print "</span>";
       if ((grep /Hf/,$cellule)&&($book->[$i]{cell}[1][$l] ne "")){
	$jour=$book->[$i]{cell}[1][$l];
	$vol=$cellule;
	$dest=$book->[$i]{cell}[$j+1][$l];
	$cellule=$book->[$i]{cell}[$j+2][$l];
	$heure=int($cellule*24);
	$minute=round(($cellule*24 - $heure)*60);
	$dep=$heure*100+$minute;
	$cellule=$book->[$i]{cell}[$j+3][$l];
	$heure=int($cellule*24);
	$minute=round(($cellule*24 - $heure)*60);
	$arr=$heure*100+$minute;

# 	&save("insert ignore into im_plan (jour,li,col,vol,dest,dep,arr) value('$jour','$l','$j','$vol','$dest','$dep','$arr')");
# 	$im_id=&get("SELECT LAST_INSERT_ID() FROM im_plan");
	$im_id++;
	$leg=1;
	if (grep /^Abj/,$dest){
	  $savol=1;
	  $li_i=$l+1;
	  while ($savol) {
	    $query="select dest from im_plan where col='$j' and li='$li_i'";
# # 	    print $query;
	    $sth=$dbh->prepare($query);
	    $sth->execute();
	    ($dest_n)=$sth->fetchrow_array;
	    $leg++;
	    $li_i++;
	    if (grep /Abj$/,$dest_n){$savol=0;}
	  }
	  print "*$leg";
	  if ($leg<4){
	    print "<a href=http://aircotedivoire.oasix.fr/cgi-bin/lire_excel_planning.pl?action=add&id=$im_id&date_sql=$date_sql>add</a>";
	  }
	  if ($leg==4){
	    print "<a href=http://aircotedivoire.oasix.fr/cgi-bin/lire_excel_planning.pl?action=add4&id=$im_id&date_sql=$date_sql>add</a>";
	  }

	}  
      }
      print "</td>";
    }  
    print "</tr>";
  }
  print "</table>";
}

;1