#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
print $html->header;

$action=$html->param("action");
$code=$html->param("code");

if ($action eq ""){
  print "<form>";
  &form_hidden();
  print "Code produit <input type=text name=code><br>";
  print "<input type=submit>";
  print "<input type=hidden name=action value=go>";
  print "</form>";
}
if ($action eq "go"){
  $pr_four=&get("select pr_four from produit where pr_cd_pr='$code'");
  $pr_desi=&get("select pr_desi from produit where pr_cd_pr='$code'");
  
  ($fo_nom,$null)=split(/\*/,&get("select fo2_add from fournis where fo2_cd_fo='$pr_four'"));
  $pr_prac=&get("select pr_prac from produit where pr_cd_pr='$code'")/100;
  $stanc=&get("select pr_stanc from produit where pr_cd_pr='$code'")/100;
#   $stock=$stanc;
  $first=1;
  $query="select * from enso where es_cd_pr='$code' order by es_dt";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){
    if (($es_type==10)&&($es_qte_en==0)){next;}
    $es_qte/=100;
    $es_qte_en/=100;
    if (($es_type==10)||($first)){
      $valeur_report=int($stock*$pr_prac*659);
      if ($table){print "</table>";$table=0;
        print "Nouveau Stock:$stock Valeur:$valeur_report CAF<br>";
      }
      if ($first){$es_no_do=0;$es_qte_en=$stanc;}
      print "<br><hr></hr><br><div style=\"display:inline-block;width:250px\">DUTY FREE CONCEPT<br>
      N° RCCM: 524 057 049<br>
      SAS au capital de 100 000 euro<br>
      TVA FR 09524057049<br>
      </div>";
      $valeur_caf=int($pr_prac*$es_qte_en*659);
      print "<div style=\"display:inline-block;width:200px;text-align:center\"><h4>Etat d'apurement no:$es_no_do</h4></div>";
      print "<div style=\"display:inline-block;width:230px\">Abbidjan le ";
      print &date_fr($es_dt);
      print "</div>";
      print "<div style=\"width:600px;margin-left:100px\">IM7 N°:<br>
      ESPECE TARIFAIRE:<br>
      DESIGNATION:<span style=margin-right:65px>$pr_desi</span><br>
      Qte:<span style=margin-right:65px>$es_qte_en</span><br>
      VALEUR CAF:$valeur_caf<br>
      FOURNISSEUR:$fo_nom<br>
      </div>";
      $table=1;
      if ($stock ne ""){print "Report stock:$stock valeur:$valeur_report CAF<br>";}
      print "<table border=1 cellspacing=0><tr><th>Document</th><th>Date</th><th>Qte appurée</th><th>Valeur appurée</th><th>Destination</th></tr>";
      }
    else{  
      $v_dest=&get("select v_dest from vol where v_code='$es_no_do' and v_rot=1");
      $valeur=int($es_qte*$pr_prac*659);
      print "<tr><td>$es_no_do</td><td>$es_dt</td><td align=right>$es_qte</td><td align=right>$valeur</td><td>$v_dest</td></tr>";
    }
    $first=0;
    $stock-=$es_qte;
    $stock+=$es_qte_en;
  }
if ($table){print "</table>";$table=0;
    print "Nouveau Stock:$stock Valeur:$valeur_report CAF<br>";
}

#   $errdep=&get("select sum(erdep_qte) from errdep where erdep_cd_pr=$code");
#   $casse=&get("select pr_casse from produit where pr_cd_pr=$code")/100;
#   $diff=&get("select pr_diff from produit where pr_cd_pr=$code")/100;
#   $ecart=$diff+$errdep-$casse;
#   print "stock sommier:$stock<br>";
#   $pr_stre=&get("select pr_stre from produit where pr_cd_pr=$code")/100;
#   print "controle:$pr_stre<br>";
#   print "ecart:$ecart<br>";
#   $pr_st_ent=$pr_stre+$ecart;
#   print "Stock entrepot:$pr_st_ent<br>";
# #   $mvt=&get("select sum(es_qte_en-es_qte) from enso where es_cd_pr='$code'");
#   print "mouvement:$mvt<br>";
  

  		
}    
