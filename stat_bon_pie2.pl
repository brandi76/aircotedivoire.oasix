print "<title>Statitique par bon</title>";
$devise="Eu";
$appro_1=$html->param("appro_1");
$appro_2=$html->param("appro_2");
$dest=$html->param("dest");
$type=$html->param("type");
$famille=$html->param("famille");
$avecliste=$html->param("avecliste");
$marge=$html->param("marge");


if ($type eq "") {$type="v_troltype";}
if ($famille eq ""){$famille=-1;}

if ($appro_2 eq $appro_1){$appro_2=$appro_1;}
print "<center>Etude sur les parfums<br><form> <table border=1 cellspacing=0 cellpadding=10 style=font-size:9pt;><tr><th>Premier bon d'appro</th><th>Dernier bon d'appro</th><th>Destination(facultatif)</th><th>Trolley type (facultatif)</th>";
print "</tr> ";
print "<tr><td><input type=texte name=appro_1 size=5 value='$appro_1'></td><td><input type=texte name=appro_2 size=5  value='$appro_2'></td><td><input type=texte name=dest size=5  value='$dest'></td><td><input type=texte name=type size=5 ";
if ($type ne "v_troltype"){print " value='$type'";}
print "></td>";
print "</tr> ";
print "</table>";
require ("form_hidden.src");

print "Avec la liste <input type=checkbox name=avecliste> Marge <input type=checkbox name=marge><input type=hidden name=action value=go ><input type=submit ></form>";
$query="select * from etude";
$sth = $dbh->prepare($query);
$sth->execute;
while (($et_cd_pr) = $sth->fetchrow_array) {
	print &get("select pr_desi from produit where pr_cd_pr=$et_cd_pr"),"<br>";
}


if ($appro_1 ne "") {
	$query="select distinct v_code from vol where v_code>='$appro_1' and v_code<='$appro_2' and v_dest like \"%$dest%\" and v_troltype= $type";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code)=$sth->fetchrow_array){
		push (@liste,$v_code);
		$nb_de_vol++;
		$query="select ro_cd_pr,sum(ro_qte),pr_type,ap_prix from rotation,produit,appro where ro_code='$v_code'  and ro_cd_pr=pr_cd_pr and ap_cd_pr=pr_cd_pr and ap_code=ro_code group by ro_cd_pr";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		$pass=0;
		while (($ro_cd_pr,$ro_qte,$pr_type,$ap_prix)=$sth2->fetchrow_array){
			$pr_prac=&get("select pr_prac from produit where pr_cd_pr=$ro_cd_pr");
			if ($marge ne "on"){$pr_prac=0;}
			$pr_famille=&get("select pr_famille from produit_plus where pr_cd_pr='$ro_cd_pr'")+0;
			if (($pr_famille !=1)&& ($pr_famille !=3)){next;}
			$pr_famille=&get("select count(*) from etude where et_cd_pr='$ro_cd_pr'")+0;
			$vente{$pr_famille}+=int($ro_qte/100);
			$total_qte+=int($ro_qte/100);
			# $ca{$pr_famille}+=int($ro_qte*$ap_prix/10000);
			$ca{$pr_famille}+=int($ro_qte*($ap_prix-$pr_prac)/10000);
			# $total_ca+=int($ro_qte*$ap_prix/10000);
			$total_ca+=int($ro_qte*($ap_prix-$pr_prac)/10000);
			if (($pass==0)&&($ap_prix!=0)){$pass++;$nb_avec_ca++;}
		}
	}
	$ca_moyen=0;
	if ($nb_avec_ca!=0) {$ca_moyen=int($total_ca/$nb_avec_ca);}
	$nb_zero=$nb_de_vol-$nb_avec_ca;
	print " Nombre de bon traite:$nb_de_vol Nombre de bon a zero:$nb_zero Moyenne:$ca_moyen <br><br>";
	$query="select cl_cd_cl,cl_nom,cl_trilot from client ";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($cl_cd_cl,$cl_nom,$cl_trilot)=$sth->fetchrow_array)
	{
		$client_dat{$cl_cd_cl}=$cl_nom.";".$cl_trilot;
	}	
	print " <div id=\"chart_div\" ></div><br>";
	print " <div id=\"chart2_div\"></div><br>";

	if ($marge eq "on"){
		print "<table><tr><th>Code</th><th>Designation</th><th>Marge</th></tr>";
		foreach $cle (keys(%ca)){
			if ($cle>0){
				$desi="etude";
			}
			else
			{
					$desi="autres";
			}
			print "<tr><td>$cle</td><td>$desi</td><td>$ca{$cle}</td></tr>";
		}
		print "</table>";
	}
	if ($avecliste eq "on"){
	print  "<table id=\"petit\" border=1 cellspacing=0 cellpadding=0><tr bgcolor=#5580ab><th>Compagnie</th><th>Vol</th><th>Trolley type</th><th>Troncon</th></tr>";
	foreach $v_code (@liste){
		$query="select v_date_jl,v_vol,v_cd_cl,v_troltype,v_dest, v_troltype from vol where v_code='$v_code' and  v_rot=1";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($v_date,$v_vol,$v_cd_cl,$v_troltype,$v_dest,$v_troltype)=$sth2->fetchrow_array ;
		$datef=&julian($v_date,"yyyy/mm/dd");
		print  "<tr><td><b>";
		($cl_nom)=split(/;/,$client_dat{$v_cd_cl});
		print  $cl_nom;
		print  "</td>";
		$query="select lot_conteneur from lot where lot_nolot=$v_troltype";
		$sth3=$dbh->prepare($query);
		$sth3->execute();
		($lot_conteneur)=$sth3->fetchrow_array;
		print  "<td align=center><font>$v_code $v_vol $datef</a></td><td align=center>$v_troltype $lot_conteneur</td>";
		print "<td >";
		print "$v_dest $v_troltype ";
		print &get("select v_vol from vol where v_code='$v_code' and v_rot=2");
		print " ";
		print &get("select v_vol from vol where v_code='$v_code' and v_rot=3");
		print "</td></tr>";
		print  "</tr>\n";
	}
	print "</table>";
	}
	print "fin";
	
print "
	 <script type=\"text/javascript\" src=\"https://www.google.com/jsapi\"></script>
    <script type=\"text/javascript\">

      // Load the Visualization API and the piechart package.
      google.load('visualization', '1.0', {'packages':['corechart']});

      // Set a callback to run when the Google Visualization API is loaded.
      google.setOnLoadCallback(drawChart);

      function drawChart() {

        // Create the data table.
        var data = new google.visualization.DataTable();
       data.addColumn('string', 'Topping');
	data.addColumn('number', 'Slices');
        data.addRows([";
foreach $cle (sort(keys(%vente))){
		if ($cle>0){
				$desi="etude";
			}
			else
			{
					$desi="autres";
			}
		
	print "['$desi', $vente{$cle}],";
}
print "
        ]);

        // Set chart options
	
        var options = {'title':'Repartition par famille total qte:$total_qte',
			legend:{position: 'right', textStyle: {fontSize: 10}},
			chartArea:{left:5,top:20,width:\"100%\",height:\"95%\"},
			backgroundColor:{strokeWidth:2},
                       'width':800,
                       'height':400};

        // Instantiate and draw our chart, passing in some options.
        var chart = new google.visualization.PieChart(document.getElementById('chart_div'));
        data.sort({column:1,desc:true});
        chart.draw(data, options);
       
	var data2 = new google.visualization.DataTable();
	data2.addColumn('string', 'Topping');
	data2.addColumn('number', 'Slices');
	data2.addRows([";
foreach $cle (keys(%ca)){
		if ($cle>0){
				$desi="etude";
			}
			else
			{
					$desi="autres";
			}
		
	print "['$desi', $ca{$cle}],";
}
$mess="chiffre d affaire ca";
if ($marge eq "on"){$mess="marge";}
print "
        ]);

        // Set chart options
        var options = {'title':'Repartition par $mess:$total_ca',
			legend:{position: 'right', textStyle: {fontSize: 10}},
			chartArea:{left:5,top:20,width:\"100%\",height:\"95%\"},
			backgroundColor:{strokeWidth:2},
                       'width':800,
                       'height':400};

        // Instantiate and draw our chart, passing in some options.
        var chart2 = new google.visualization.PieChart(document.getElementById('chart2_div'));
        data2.sort({column:1,desc:true});
       chart2.draw(data2, options);
        
        
      }
</script>";

print "</center>";
	
}
;1
