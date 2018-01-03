$query="select * from releve_bq order by date";
print "<table border=1 cellspacing=0 cellpadding=0><tr><th>Date</th><th>Dev</th><th>Debit</th><th>Credit</th><th>Reference</th><th>Libelle</th></tr>";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$montant,$dev,$date,$ref,$desi)=$sth->fetchrow_array){
  print "<tr><td align=right>$date</td><td>$dev</td>";
  $debit=0;
  $credit=0;
  ($montant >0)? $credit=$montant:$debit=$montant;
  $debit=$debit*-1;
  print "<td align=right>$debit</td><td align=right>$credit</td>";
  print "<td align=right>$ref</td><td align=right>$desi</td></tr>";
}
print "</table>";
;1