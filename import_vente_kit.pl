print "<div class=titre>Importation des ventes du tpe</div><br>";
$date=$html->param("date");
$vol=$html->param("vol");
$action=$html->param("action");


if ($action eq ""){
  $query="select distinct date from dfc.sk20 where vol like '%ABJ:%' order by date desc limit 50";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($date,$rot,$vol)=$sth->fetchrow_array){
    ($annee,$heure)=split(/ /,$date);
    $query="select distinct vol from dfc.sk20 where date='$date' and vol like '%ABJ:%' order by vol,rot";
    $sth2=$dbh->prepare($query);
    $sth2->execute();
    while (($vol)=$sth2->fetchrow_array){
      ($novol,$null)=split(/:/,$vol);
      $appro=&get("select v_code from vol where v_date_sql='$annee' and v_vol='$novol'");
      print "<a href=?onglet=$onglet&sous_onglet=$sous_onglet&sous_sous_onglet=$sous_sous_onglet&action=visu&date=$annee+$heure&vol=$vol>vol:$vol</a> $date ";
      print " Appro:$appro ";
      if ($appro ne ""){
	$montant=&get("select infr_caisseth from inforetsql where infr_code=$appro")+0;
	$montant_tpe=&get("select sum(ap_prix)/100 from appro,dfc.sk20 where ap_cd_pr=ref and sk20.date='$date' and sk20.vol='$vol' and ap_code=$appro")+0; 
	print "Montant appro:$montant Mntant tpe:$montant_tpe";
	if ($montant==$montant_tpe){print " ok";}
      }
      print "<br>";
     }
  }
} 
if ($action eq "visu"){
  print "<p style=color:orange;font-size:1.2em>$date $vol</p>";
  $query="select * from dfc.sk20 where date='$date' and vol='$vol' order by rot,indecs";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($date,$rot,$vol,$indecs,$ticket,$type,$ref)=$sth->fetchrow_array){
    if ($ticket != $ticket_anc){
      print "<strong>Ticket:$ticket</strong><br> ";
      $ticket_anc=$ticket;
      }
    $mess=$type;
    if ($type eq "E"){$mess="Especes";}
    if ($type eq "CB"){$mess="CB";}
    if ($type eq "CH"){$mess="Cheque";}
    if ($type eq "F"){$mess="Fin de caisse";}
    if ($type eq "R"){$mess="Rendu";}
    if ($type eq "P"){
      $desi=&get("select pr_desi from produit where pr_cd_pr=$ref");
      $mess="$ref $desi";
    }
    print "$mess<br>";
  }
}
;1
