#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$firstdate="2016-01-01";
$lastdate="2016-12-31";
$query="select pr_cd_pr,pr_desi from produit ";
$sth2=$dbh->prepare($query);
$sth2->execute();
while (($pr_cd_pr,$pr_desi)=$sth2->fetchrow_array){
  $prix=&get("select floor(avg(ap_prix)/100)  from appro,vol where ap_code=v_code and ap_cd_pr='$pr_cd_pr' and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_rot=1 and ap_prix<45000 ") ; 
  if ($prix <=0){next;}
  $query="select floor(sum(ro_qte)/100) from rotation,vol where ro_code=v_code and ro_cd_pr='$pr_cd_pr' and v_date_sql>='$firstdate' and v_date_sql<='$lastdate' and v_rot=1 " ; 
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($qte)=$sth->fetchrow_array;
  $qte+=0;
  if ($qte==0){next;}
  $ca=$prix*$qte;
  &save("insert ignore into produit_ca values('$pr_cd_pr','$ca')");
 }
 print "fin;";
 
   