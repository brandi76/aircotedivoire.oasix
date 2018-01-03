#!/usr/bin/perl
use CGI;
use DBI();
use CGI::Carp qw(fatalsToBrowser);
$html=new CGI;
print $html->header;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
require "./src/connect.src";
$code=$html->param("code");
$action=$html->param("action");
$prix=$html->param("prix");
$ordre=$html->param("ordre");

# if ($code ne ""){
# &sauv_togo();
# &sauv_camair();
# }

if (($code ne "")&&($action eq "")){
  $query="select pr_cd_pr,pr_desi,pr_sup,pr_stre,page from produit,mag where pr_cd_pr=$code and pr_cd_pr=code";
  $sth=$dbh->prepare($query);
  $sth->execute();
  ($pr_cd_pr,$pr_desi,$pr_sup,$pr_stre,$page)=$sth->fetchrow_array;
   print "$pr_cd_pr $pr_desi - $page -</br>";
    
print "<form>ordre <input type=text name=ordre value=$ordre><br>prix <input type=text name=prix><br><input type=hidden name=action value=maj><input type=submit><input type=hidden name=code value=$code></form>";
# &sauv_togo();
# &sauv_camair();
}
if (($code ne "")&&($action ne "")){

#&save("insert ignore into ordre value ('$ordre','$code','$prix',0)","aff");
&save("update ordre set ord_prix1=$prix*100 where ord_cd_pr='$code'","aff");

$code="";
$ordre_next=$ordre+1;
}

if ($code eq ""){
 print "<table border=1 cellspacing=0><tr><th>Code produit</th><th>Désignation</th><th>ordre</th><th>Stock</th><th>Trolley</th><th>En cde</th><th>Vendu</th></tr>";
	$query="select pr_cd_pr,pr_desi,pr_sup,pr_stre,page from produit,mag where pr_cd_pr=code order by pr_cd_pr";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($pr_cd_pr,$pr_desi,$pr_sup,$pr_stre,$page)=$sth->fetchrow_array){
		
		$res=&get("select count(*) from trolley,lot where tr_cd_pr='$pr_cd_pr' and tr_code=lot_nolot and lot_flag=1")+0;
		$cde=&get("select count(*) from commande where com2_cd_pr='$pr_cd_pr'")+0;	
		$vendu=&get("select count(*) from rotation where ro_cd_pr='$pr_cd_pr'")+0;
		$ordre=&get("select ord_ordre from ordre where ord_cd_pr='$pr_cd_pr'")+0;
		$prix1=&get("select ord_prix1 from ordre where ord_cd_pr='$pr_cd_pr'")+0;
		
# 		if ($ordre!=0){next;}
#  		if ($pr_stre!=0){next;}
#  		if ($cde!=0){next;}
# # 		if ($res!=0){next;}
# # 		if ($vendu!=0){next;}

# 		print "$pr_cd_pr $pr_desi<br>";
		print "<tR><td><a href=?code=$pr_cd_pr&ordre=$ordre>$pr_cd_pr</a></td><td>$pr_desi $page</td>";
		print "<td>&nbsp;";
		print "$prix1<img src=/images/check.png>";
		print "</td>";
		
		print "<td>&nbsp;";
		if ($pr_stre >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "<td>&nbsp;";
		if ($res >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "<td>&nbsp;";
		if ($cde >0){print "<img src=/images/check.png>";}
		print "</td>";
		print "<td>&nbsp;";
		if ($vendu >0){print "<img src=/images/check.png>";}
		print "</td>";
		$desi_togo=&get("select togo.produit.pr_desi from togo.produit where togo.produit.pr_cd_pr=$pr_cd_pr");
		if ($desi_togo eq $pr_desi){print "<td><img src=/images/check.png></td>";}else {print "<td>$desi_togo</td>";}
		$desi_camairco=&get("select camairco.produit.pr_desi from camairco.produit where camairco.produit.pr_cd_pr=$pr_cd_pr");
		if ($desi_camairco eq $pr_desi){print "<td><img src=/images/check.png></td>";}else {print "<td>$desi_camairco</td>";}
 		print "</tr>";
	
}	
 	print "</table><br></form></html>";
}
	
	sub sauv_togo{
	  &save ("insert ignore into togo.produit select * from aircotedivoire.produit where aircotedivoire.produit.pr_cd_pr='$code'");
	  # &save ("update togo.produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0 where togo.produit.pr_cd_pr='$code'");
	  &save ("insert ignore into togo.carton select * from aircotedivoire.carton where aircotedivoire.carton.car_cd_pr='$code'");
	}
	sub sauv_camair{
	  &save ("insert ignore into camairco.produit select * from aircotedivoire.produit where aircotedivoire.produit.pr_cd_pr='$code'");
	  # &save ("update camairco.produit set pr_casse=0,pr_stre=0,pr_stanc=0,pr_diff=0,pr_stvol=0 where camairco.produit.pr_cd_pr='$code'");
	  &save ("insert ignore into camairco.carton select * from aircotedivoire.carton where aircotedivoire.carton.car_cd_pr='$code'");
	}