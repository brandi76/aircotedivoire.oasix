#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";
require "./src/connect.src";
print "<table border=1><tr><th>Appro</th><th>Date</th><th>Destination</th><th>Trolley type</th><th>Ca type</th><th>Ca embarqué</th><th>Ca réalisé</th><th>Manquant</th></tr>";
$query="select v_code,v_date,v_dest,v_troltype from vol where   v_date%10000>=714 and v_date%1000<=714 and v_date%100=14 and v_rot=1  order by v_code ";
$sth=$dbh->prepare($query);
$sth->execute();
while (($v_code,$v_date,$v_dest,$v_troltype)=$sth->fetchrow_array){
	print "<tr><td>$v_code</td><td align=right>$v_date</td><td align=right>$v_dest</td><td align=right>$v_troltype</td><td align=right>";
	$ca_type=&get("select sum(tr_qte*tr_prix)/10000 from trolley where tr_code=$v_troltype")+0;
	print "$ca_type</td><td align=right>";
	$ca_embarque=&get("select sum(ap_qte0*ap_prix)/10000 from appro where ap_code=$v_code")+0;
	print "$ca_embarque</td><td align=right>";
	$ca_real=&get("select sum((ret_qte-ret_retour)*ret_prix) from retoursql where ret_code=$v_code")+0;
	$pour=0;
	if ($ca_embarque!=0){$pour=int($ca_real*100/$ca_embarque);}
	print "$pour%</td><td align=right>";
	$manquant=&get("select count(*) from appro where ap_qte0=0 and ap_code=$v_code")+0;
	$nb=&get("select count(*) from appro where ap_code=$v_code")+0;
	$pour=0;
	if ($nb!=0){$pour=int($manquant*100/$nb);}
	print "$pour%</td>";
	print "</tr>";
}
print "</table>";


