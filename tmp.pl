#!/usr/bin/perl
require "../oasix/../oasix/outils_perl2.pl";
require "../oasix/../oasix/outils_corsica.pl";
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
$html=new CGI;
print $html->header();
require("./src/connect.src");

$query="select id,montant,date from releve_bq";
$sth=$dbh->prepare($query);
$sth->execute();
while (($id,$montant,$date)=$sth->fetchrow_array){
	# $check=&get("select count(*) from releve_bq2 where id='$id' and montant='$montant' and date='$date'")+0;
	# if ($check==0){
	# &save("delete from releve_bq where id='$id' and montant='$montant' and date='$date' limit 1","aff");
	# }
	$check=&get("select count(*) from mouvement_tmp where id='$id' and montant='$montant' and date='$date'")+0;
	if ($check==1){
		 &save("delete from releve_bq where id='$id' and montant='$montant' and date='$date' limit 1","aff");
	}
}

