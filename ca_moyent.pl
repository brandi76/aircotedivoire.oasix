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

print <<EOF;	
 <script type="text/javascript"
          src="https://www.google.com/jsapi?autoload={
            'modules':[{
              'name':'visualization',
              'version':'1',
              'packages':['corechart']
            }]
          }"></script>

    <script type="text/javascript">
      google.setOnLoadCallback(drawChart);

      function drawChart() {
EOF

 # print "        var data = google.visualization.arrayToDataTable([['Mois','camairco','aircotedivoire'],['0',555.6494,571.325],['1',525.5833,755.9721]]);\n";

&run();

print <<EOF;
        var options = {
          title: 'CA moyen par vol $client',
		  hAxis: {textStyle: { fontSize: 8}},
		  legend: { position: 'bottom' }
        };

        var chart = new google.visualization.LineChart(document.getElementById('graph'));
        chart.draw(data, options);
EOF

	
print "}</script>";

print "<div id=\"graph\" style=\"width: 900px; height: 500px\"></div>";

sub run(){
	$ca=0;
	 #print "        //var data = google.visualization.arrayToDataTable([['Semaine','a,'b'],";
	 print "        var data = google.visualization.arrayToDataTable([['Semaine','2015','2016','2017'],";
	 $semaine_run=&get("select weekofyear(curdate())");
 	 for ($mois=0;$mois<=51;$mois++){
		$mois_aff=$mois++;
		print "['$mois_aff'";
		$ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_2 and weekofyear(v_date_sql)='$mois' and ca_total!=0","af")+0;
		 print ",$ca";
		 $ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_1 and weekofyear(v_date_sql)='$mois' and ca_total!=0","af")+0;
		 print ",$ca";
		 $ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an and weekofyear(v_date_sql)='$mois' and ca_total!=0","af")+0;
		 if ($mois>=$semaine_run){$ca="null";}
		 print ",$ca";
		 print "],";
	 }
	 $mois_aff++;
	 print "['$mois_aff'";
	 $ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_2 and weekofyear(v_date_sql)='$mois' and ca_total!=0","af")+0;
	 print ",$ca";
	 $ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an_1 and weekofyear(v_date_sql)='$mois' and ca_total!=0","af")+0;
	 print ",$ca";
	 $ca=&get("select avg(ca_total) from $client.vol,$client.caissesql where v_code=ca_code and v_rot=ca_rot and year(v_date_sql)=$an and weekofyear(v_date_sql)='$mois' and ca_total!=0","af")+0;
	 print ",$ca";
	 print "]]);\n";
}	


;1
