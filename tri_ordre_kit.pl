$action=$html->param("action");
if ($html->param("action") ne ""){
    &save ("truncate table newordre");
    &save ("insert into newordre select * from ordre");
    $query="select ordre.*  from ordre,produit where ord_cd_pr=pr_cd_pr order by ord_ordre";
    $sth=$dbh->prepare($query);
    $sth->execute();
    while (($ord_ordre,$ord_cd_pr,$ord_prix1,$ord_prix2)=$sth->fetchrow_array){
      if ($html->param("$ord_ordre")!=$ord_cd_pr){
	$ord_cd_pr=$html->param("$ord_ordre");
	&save("update newordre set ord_ordre='$ord_ordre' where ord_cd_pr='$ord_cd_pr'","af");
      }
    }
    &save ("truncate table ordre");
    &save ("insert into ordre select * from newordre");
}

print <<EOF;

<style>
.drop1 {width:600px;height:30px;margin:0;border:1px solid #aaaaaa;background-color:white;margin:auto;}
.drop2 {width:600px;height:30px;margin:0;border:1px solid #aaaaaa;background-color:#efefef;margin:auto;}
</style>
<script>
function allowDrop(ev) {
    ev.preventDefault();
}

function drag(ev) {
    ev.dataTransfer.setData("Text", ev.target.id);
}

function drop(ev) {
    ev.preventDefault();
    var x=eval(ev.target.id);
    var source = ev.dataTransfer.getData("Text");
    var y=eval(source);
    var mem=document.getElementById(ev.target.id).innerHTML;
    var mem_form=document.maform.elements[x].value;
    
    document.getElementById(ev.target.id).innerHTML=document.getElementById(source).innerHTML;
    document.maform.elements[x].value=document.maform.elements[y].value;
    for (i=x+1;i<=y;i++){
      var data_suivant=document.getElementById(i).innerHTML;
      document.getElementById(i).innerHTML=mem;
      mem=data_suivant;
      
      var data_suivant_form=document.maform.elements[i].value;
      document.maform.elements[i].value=mem_form;
      mem_form=data_suivant_form;
    } 
   document.getElementById("maform").style.background="pink";
    
 }
</script>
EOF
print "Fond rose -> modifications non prisent en compte -> il faut valider (bouton en bas de page)";
print "<form name=maform id=maform style=width:100%;text-align:center;>";
$query="select ord_ordre,ord_cd_pr,pr_desi  from ordre,produit where ord_cd_pr=pr_cd_pr order by ord_ordre";
$sth=$dbh->prepare($query);
$sth->execute();
$i=0;
$pair=1;
while (($ord_ordre,$ord_cd_pr,$pr_desi)=$sth->fetchrow_array)
{
  print "<div class=drop$pair id=\"$i\" ondrop=\"drop(event)\" ondragover=\"allowDrop(event)\" draggable=\"true\" ondragstart=\"drag(event)\">$ord_cd_pr $pr_desi</div>\n";
  print "<input type=hidden name=$ord_ordre value=$ord_cd_pr>\n";
  $i++;
  if ($pair==1){$pair=2;}else{$pair=1;}
}
print "<input name=action type=submit>";
&form_hidden();
print "</form>";
 
;1