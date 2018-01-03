$firstdate=$html->param("firstdate");
$lastdate=$html->param("lastdate");
if (grep(/\//,$firstdate)) {
	($jj,$mm,$aa)=split(/\//,$firstdate);
	$firstdate=$aa."-".$mm."-".$jj;
}
if (grep(/\//,$lastdate)) {
	($jj,$mm,$aa)=split(/\//,$lastdate);
	$lastdate=$aa."-".$mm."-".$jj;
}

if ($action eq "") {
  print "<form>";
  &form_hidden();
  print "<br> <br>Premiere date <input id=\"datepicker\" type=text name=firstdate size=12>";
  print "<br> <br>Derniere date <input id=\"datepicker2\" type=text name=lastdate size=12>";
  print "<br> <input type=hidden name=action value=go><br><input type=submit value='envoie'></form>";
}
if ($action eq "go"){ 
	open(FILE,">/var/www/aircotedivoire.oasix/doc/tmp.csv");
	#print "<table border=1 cellspacing=0>"; 
 # print "<tr><th>Appro</th><th>Date</th><th>Vol</th><th>Destination</th><th>Code</th><th>Designation</th><th>Qte</th></tr>";
	$query="select ro_code,v_dest,v_date_sql,ro_cd_pr,pr_desi,ro_qte,v_vol,pr_douane from rotation,vol,produit where ro_code=v_code and ro_cd_pr=pr_cd_pr and v_rot=ro_rot and v_date_sql>'$firstdate' and v_date_sql<'$lastdate' order by v_code,ro_cd_pr  ";
  $sth=$dbh->prepare($query);
  $sth->execute();
  while (($ro_code,$v_dest,$v_date_sql,$ro_cd_pr,$pr_desi,$qte,$v_vol)=$sth->fetchrow_array){
	$qte/=100;
    # print "<tr><td>$ro_code;$v_date_sql;$v_vol;$v_dest;$ro_cd_pr;$pr_desi;$qte</td></tr>";
	print FILE "$ro_code;$v_date_sql;$v_vol;$v_dest;$ro_cd_pr;$pr_desi;$pr_douane;$qte;\n";
  
  }
  # print "</table>";
  close (FILE);
  print "<a href=http://aircotedivoire.oasix.fr/doc/tmp.csv> File</a>";
}  
;1
