#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/outils_perl2.lib";
print $html->header;
require "./src/connect.src";

$query="SELECT ref,montant,count(*) FROM `releve_bq` group by ref,montant ORDER BY count(*)  DESC";
$sth=$dbh->prepare($query);
$sth->execute();

while (($ref,$montant,$nb)=$sth->fetchrow_array)
{	
      if ($nb==2){
      $query="select id,date from releve_bq where montant='$montant' and ref='$ref'";
      &save ("delete from releve_bq where id=0 and ref='$ref' and montant='$montant'","aff");
#       $sth2=$dbh->prepare($query);
#       $sth2->execute();
#       while (($id,$ref)=$sth2->fetchrow_array){
# 	print "$id $date $montant $ref<br>";
#       }
       }	
}      

