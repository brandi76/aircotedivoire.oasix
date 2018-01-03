#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.pl";
print $html->header;
require "./src/connect.src";
$client="aircotedivoire";
$an=&get("select year(curdate())");
$an_1=$an-1;
$an_2=$an-2;
$mag_run="";
print "*";
&save("create temporary table liste_tmp (code int(8),pick int(8))");
 	 for ($mois=0;$mois<=51;$mois++){
		($trolley,$nb)=&get("select v_troltype,count(*) as nb from $client.vol where  year(v_date_sql)=$an_1 and weekofyear(v_date_sql)='$mois'  order by nb desc","af");
		$mag="lemag".substr($trolley,0,2);
		if ($mag ne $mag_run){
			&save("truncate table liste_tmp");		
			&save("insert into liste_tmp select code,0 from mag where mag='$mag' and code>0");		
			$nb_ref=&get("select count(*) from liste_tmp");
			$mag_run=$mag;
		}	
		$check=&get("select count(*) from dfc.stock_mensuel where base='$client' and year(date)=$an_1 and weekofyear(date)=$mois")+0;
		if ($check !=0){
			 $present=&get("select count(*) from liste_tmp,dfc.stock_mensuel where liste_tmp.code=stock_mensuel.code  and base='$client' and year(date)=$an_1 and weekofyear(date)=$mois and qte>=12")+0;
		}
		print "$mois $mag $nb_ref<br>";
	 }


;1
