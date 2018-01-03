#!/usr/bin/perl
use CGI;
use DBI();

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl2.lib";

print $html->header;

$action=$html->param('action');
require "./src/connect.src";

# print "<h1> Prevenir sylvain , merci</h1>";
# exit;

print "<form>
<input name=prod>
<input type=submit>
</form>";
$prod=$html->param("prod");
if ($prod ne ""){
%stock=&stock($prod);
print "*",$stock{"pr_stre"};
$val=&get("select sum(es_qte_en-es_qte) from enso where es_cd_pr=$prod and es_dt>'2015-01-01'")+0;
print "*$val";
$stock=$stock{"pr_stre"}-$val/100;
print "Stock:$stock";
$vendu=&get("select sum(es_qte)/100 from enso where es_cd_pr=$prod and datediff(curdate(),es_dt)<120")+0;
print " vendu:$vendu";
$saler=&get("select sum(es_qte)/100 from enso where datediff(curdate(),es_dt)<120")+0;
print " sailer:$saler";

}
