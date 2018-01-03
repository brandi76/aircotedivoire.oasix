$troltype=$html->param("troltype")+0;
if ($troltype ==0){
	print "<form class=form-group>";
	&form_hidden();
	print "<label for=troltype> Trolley type </label>";
	print "<input name=troltype class=form-control>";
	print "<input type=submit class='btn btn-info' value=submit>"; 
	print "</form>";
}
else {
$montant_base=&get("select sum(tr_qte*tr_prix)/10000 from trolley where tr_code='$troltype'")+0;
print "Montant théorique  $montant_base Euro;<br>";
$query="select ap_code,sum(ap_qte0*ap_prix)/10000 from appro,vol where v_code=ap_code and v_rot=1 and v_troltype='$troltype' group by ap_code";
$sth=$dbh->prepare($query);
$sth->execute();
 while (($ap_code,$val)=$sth->fetchrow_array){
 $pour=0;
 if ($val!=0){
	$pour=100*$val/$montant_base;
}	
	#print "$ap_code $val $pour<br>";
	$tab[int($pour/10)]++;
	$nb++;
}
 if ($nb==0){exit;}
for ($i=0;$i<$#tab+1;$i++){
	#print "$i $tab[$i] <br>";
}	




print <<EOF;
  <script type="text/javascript" src="../bower_components/jquery/dist/jquery.js"></script>
<script type='text/javascript'>

\$(function () {
Highcharts.chart('container', {
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: 0,
            plotShadow: false
        },
        title: {
            text: '$troltype ratio de manquant',
            align: 'center',
            verticalAlign: 'middle',
            y: 40
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                dataLabels: {
                    enabled: true,
                    distance: -50,
                    style: {
                        fontWeight: 'bold',
                        color: 'white'
                    }
                },
                startAngle: -90,
                endAngle: 90,
                center: ['50%', '75%']
            }
        },
        series: [{
            type: 'pie',
            name: '',
            innerSize: '50%',
            data: [
EOF
for ($i=0;$i<$#tab+1;$i++){
	$tab[$i]+=0;
	if ($tab[$i]==0){next;}
	$pour=100*$tab[$i]/$nb;
	$debut=$i*10;
	$fin=$debut+10;
	$champ="Entre $debut et $fin %";
	print "['$champ',$pour],";
}	

print <<EOF;			
                {
                    name: '',
                    y: 0.2,
                    dataLabels: {
                        enabled: false
                    }
                }
            ]
        }]
    });
});


</script>

  

  <script src="../bower_components/highcharts/highcharts.js"></script>
<script src="../bower_components/highcharts/modules/exporting.js"></script>
<script src="../bower_components/highcharts/highcharts-more.js"></script>
<script src="../bower_components/highcharts/modules/diti.js"></script>

<div id="container" style="min-width: 310px; max-width: 100%; margin: 0 auto"></div>
EOF
}
;1
