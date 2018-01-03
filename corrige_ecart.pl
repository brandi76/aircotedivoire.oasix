#!/usr/bin/perl
use CGI;
use DBI();

# probleme sur les XOF car ilfaut un numero de bordereau

$html=new CGI;
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param('action');
$dev=$html->param('dev');

require "./src/connect.src";
print <<EOF;
<link type="text/css" href="http://tool.oasix.fr/css/humanity/jquery-ui-1.9.1.custom.css" rel="stylesheet" />	
	<script type="text/javascript" src="http://tool.oasix.fr/js/jquery-1.4.4.min.js"></script>
	<script type="text/javascript" src="http://tool.oasix.fr/js/jquery-fr.js"></script>
	<script type="text/javascript" src="http://tool.oasix.fr/js/jquery-ui-1.8.7.custom.min.js"></script>
	<script type="text/javascript">
	\$(function() {
		\$( "#datepicker" ).datepicker();
		\$( "#datepicker2" ).datepicker();
	});

	</script>
EOF

if ($action eq ""){
	print "<h2>Gestion des ecarts</h2><br>";
	print "<form>";
	$query="select distinct devise from bordereau where date_remise='0000-00-00' and devise!='XOF' ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	print "Choisir une devise<br>";	
	print "<select name=dev>";
	while (($dev)=$sth->fetchrow_array)
	{
		print "<option value=$dev>$dev</option>";	
	}
	print "</select><br>";
	print "<input type=hidden name=action value=phase1>";
	print "<br><input type=submit>";
	print "</form>";
}
if ($action eq "sup"){
	$query="select * from coffre where devise='$dev' order by date desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$devise,$montant,$ecart,$justif)=$sth->fetchrow_array){
	    if ($html->param($date) eq "on"){
	     &save("update coffre set ecart=0 where date='$date' and devise='$devise'");
	     # print "update coffre set ecart=0 where date='$date' and devise='$devise'";
	   
	     }
	}
	$action="phase1";
}

if ($action eq "phase2"){
	print "Selectionner les ecarts concernés<br>";
	print "<form>";
	print "<table><tr><th>Date</th><th>Devise</th><th>Montant</th><th>Ecart</th><th>Justificatif</th></tr>";
	$query="select * from coffre where devise='$dev' order by date desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$devise,$montant,$ecart,$justif)=$sth->fetchrow_array){
	    if ($html->param($date) eq "on"){
	      print "<input type=hidden name='$date' value=on>";
	      print "<tr><td>$date</td><td align=right>$devise</td><td align=right>$montant</td><td align=right>$ecart</td><td>$justif</td></tr>";
	      $total+=$ecart;
	    }
	}
	print "</table>";
	print "Montant $dev : $total <br>";
	print "<input type=hidden name=montant value='$total'>";
	print "Justificatif  <input type=text name=ref size=20><br>";
	print "Date (AAAA-MM-JJ) <input type=text id=datepicker name=date_remise><br>";
	print "<input type=hidden name=action value=phase3>";
	print "<input type=hidden name=dev value='$dev'>";
	print "<br><input type=submit>";
	print "</form>";

}
if ($action eq "phase3"){
	$montant=$html->param("montant");
	$date_remise=$html->param("date_remise");
	if (grep(/\//,$date_remise)) {
	  ($jj,$mm,$aa)=split(/\//,$date_remise);
	  if ($aa<30){$aa+=2000;}
	  if (($aa>=30)&&($aa<100)){$aa+=1900;}
	  $date_remise=$aa."-".$mm."-".$jj;
	}

	$ref=$html->param("ref");
	$no=&get("select max(no) from bordereau ")+1;
	if ($no==1){$no=1000;}
	$montant*=-1;
	if ($dev eq "EUR"){ $montantdev=$montant*655;}
	&save("insert ignore into bordereau value ('$no','$dev','$date_remise','$date_remise','$ref','$montant','$montantdev')");
	# print "insert ignore into bordereau value ('$no','$dev','$date_remise','$date_remise','$ref','$montant','$montantdev')<br>";

	print "Remise no: $no pour un montant de $montant $dev Enregistrée<br>";
	$query="select * from coffre where devise='$dev' order by date desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$devise,$montant,$ecart,$justif)=$sth->fetchrow_array){
	    if ($html->param($date) eq "on"){
	      # &save("update coffre set ecart=0 where date='$date' and devise='$dev'");
	      print "update coffre set ecart=0 where date='$date' and devise='$dev'<br>";
	     print "ecart de $ecart $dev  du $date mis à zero<br>";
	     }
	}
	$action="phase1";
}

if ($action eq "phase1"){
	print "<form name=maform>";
	print "<table><tr><th>Date</th><th>Devise</th><th>Montant</th><th>Ecart</th><th>Justificatif</th></tr>";
	$query="select * from coffre where devise='$dev' order by date desc";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($date,$devise,$montant,$ecart,$justif)=$sth->fetchrow_array){
	    print "<tr><td>$date</td><td align=right>$devise</td><td align=right>$montant</td><td align=right>$ecart</td><td>$justif</td><td><input type=checkbox name=$date></td></tr>";
	}
	print "</table>";
	print "<input type=hidden name=action value=phase2>";
	print "<input type=hidden name=dev value=$dev>";
	print "<input type=submit value='Regulariser'>";
	print "<input type=button value='Supprimer' style=background-color:pink;margin-left:100px onclick=document.maform.action.value='sup';document.maform.submit();>";
	print "</form>";
	
}