print "<form>";
&form_hidden();
print "Numero de serie:<input type=text name=serial size=20><br>";
print "<input type=submit>";
print "</form><br>";
$serial=$html->param("serial");
if ($serial ne ""){
  $nb=0;
  $fin=substr($serial,length($serial)-3,3)+1000;
  $debut=substr($serial,0,4);
  while ($debut >10){
    $nb=0;
    for ($i=length($debut);$i>0;$i--){
	$nb+=substr($serial,$i,1);
    }
    $debut=$nb;
  }
  $nb=$debut*100+$fin;
  if ($nb>1000){
    $nb=substr($nb,1,3);
  }
  print "<h3>$serial-> $nb</h3><br>";
}
;1