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
  $stock=&get("select pr_stre from produit where pr_cd_pr=$code")/100;

#   $stock=$stanc;
  $first=1;
  &save("CREATE TEMPORARY TABLE `enso_tmp` (sommier int(11),`es_no_do` int(11),`es_dt` date ,`es_qte` int(11))");
  $query="select * from enso where es_cd_pr='$code' and es_type=10 and es_qte_en!=0 order by es_dt desc";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth->fetchrow_array){
    $entree=$es_qte_en/100;
    $sommier=$es_no_do;
#     print "$es_cd_pr,$es_no_do,$es_dt <b>$entree</b> stock:$stock<br>";
    if (($entree<=$stock)&&($stock!=0)){$stock=$stock-$entree;next;}
    $query="select * from enso where es_cd_pr='$code' and es_type!=10 order by es_dt desc";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type)=$sth2->fetchrow_array){
      $es_qte/=100;
#       print "<span style=color:green>$es_cd_pr,$es_no_do,$es_dt,$es_qte,$es_qte_en,$es_type</span>$entree $stock<br>";
      &save("insert into enso_tmp values ('$sommier','$es_no_do','$es_dt','$es_qte')");
      $entree-=$es_qte;
      if ($entree==$stock){$stock=0;last;}
     }
  }
  $query="select es_no_do,es_qte_en,es_dt from enso where es_cd_pr='$code' and es_type=10 and es_qte_en!=0 order by es_dt";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($sommier,$entree,$date)=$sth->fetchrow_array){
    $entree/=100;
    print "<br><hr></hr><br><div style=\"display:inline-block;width:250px\">DUTY FREE CONCEPT<br>
    N° RCCM: 524 057 049<br>
    SAS au capital de 100 000 euro<br>
    TVA FR 09524057049<br>
    </div>";
    $valeur_caf=int($pr_prac*$entree*659/100);
    print "<div style=\"display:inline-block;width:200px;text-align:center\"><h4>Etat d'apurement no:$sommier</h4></div>";
    print "<div style=\"display:inline-block;width:230px\">Abbidjan le ";
    print &date_fr($date);
    print "</div>";
    print "<div style=\"width:600px;margin-left:100px\">IM7 N°:<br>
    ESPECE TARIFAIRE:<br>
    DESIGNATION:<span style=margin-right:65px>$pr_desi</span><br>
    Qte:<span style=margin-right:65px>$entree</span><br>
    VALEUR CAF:$valeur_caf<br>
    FOURNISSEUR:$fo_nom<br>
    </div>";
    print "<table border=1 cellspacing=0><tr><th>Document</th><th>Date</th><th>Qte appurée</th><th>Valeur appurée</th><th>Destination</th></tr>";
#     print "<b>$sommier $entree $date</b><br>";
    $query="select es_no_do,es_dt,es_qte from enso_tmp where sommier='$sommier' order by es_dt ";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($es_no_do,$es_dt,$es_qte)=$sth2->fetchrow_array){
      $v_dest=&get("select v_dest from vol where v_code='$es_no_do' and v_rot=1");
      $valeur=int($es_qte*$pr_prac*659/100);
      print "<tr><td>$es_no_do</td><td>$es_dt</td><td align=right>$es_qte</td><td align=right>$valeur</td><td>$v_dest</td></tr>";
      $entree-=$es_qte;
    }
    print "</table>";
    print "reste:$entree<br>";
  }  
}
