<?php
$actino=$_POST['actino'];
$rep1c=$_POST['rep1'];
$rep2c=$_POST['rep2'];
$rep3c=$_POST['rep3'];
$rep4c=$_POST['rep4'];
$no=$_POST['no'];
$res=$_POST['res'];
$total=$_POST['total'];
$nom=$_POST['nom'];
$nom2=$_POST['nom2'];
$expli=$_POST['expli'];
if ($nom2 != ""){$nom=$nom2;}
$choix=$_POST['choix'];
$raz=$_POST['raz'];
$raztot=$_POST['raztot'];
$type_query=$_POST['type_query'];
$diff=$_POST['diff'];
$pasglop=$_POST['pasglop'];
$niveau=$_POST['niveau'];

if ($choix == ""){
	$choix=$_POST['choixcheck'];
	if ($choix == "on"){$choix=1;}else {$choix=0;}
	if ($_POST['revoir'] == 'on'){$choix=3;}
	$actino="";
	
}
if ($expli != ""){
	spip_query("replace into info_brevet values '$no','$expli'");
}

if ($raztot == "on"){
	spip_query("delete from pilote2 where nom='$nom' and no like 'Q%'");
}



$query="select count(*) from pilote as ale";
$result = spip_query($query);				
$row = spip_fetch_array($result);
$ale=$row['ale'];
	
if ($nom == ""){
	$affichage_php= "<h3>".htmlentities("Questionnaire specifique à la réglementation aérienne")."</h3><br>";
	$affichage_php.="Pour conserver encore longtemps, la possibilité de contempler d’au dessus, un petit bout de notre planète, de monter en thermique, ou de se déplacer pendant des kilomètres, sous nos ailes complices, il nous appartient, de pouvoir démontrer dès notre initiation, notre capacité à partager le ciel, avec tous les autres usagers.<br>";
	$affichage_php.= "<br>Bonjour entre ton nom, Cela permet de faire des statistiques et d'";
	$affichage_php.=htmlentities("éviter de poser toujours les mêmes questions");
	$affichage_php.= "<form method=POST><input type=hidden name=var_mode value=calcul><br>Nom<br><select name=nom><option value=inconnu SELECTED></option>";
	$affichage_php.= "<option value=Inconnu>Inconnu</option>";
	$query = "SELECT nom,prenom FROM membres order by nom";
	$result = spip_query($query);
	while($row = spip_fetch_array($result)){
	$affichage_php.= "<option value=\"".$row["nom"]."_".$row["prenom"]."\">".$row["nom"]." ".$row["prenom"]."</option>";
	}
	$affichage_php.= "</select>";
	$affichage_php.= "<br> Ou si tu n'es pas un Novolien <br>";
	$affichage_php.= "Nom <input type=text name=nom2>";
	$affichage_php.= "<br><br><br><b>Options facultatives</b>".htmlentities(" (uniquement pour les questions non abordées)");
	$affichage_php.="<br><select name=type_query>";
	$affichage_php.="<option value='Q'>";
	$affichage_php.=htmlentities("Réglementation aerienne (Nouveau)");
	$affichage_php.="</option></select>";
	
$affichage_php.="</br><br>Uniquement les questions sur lesquelles il reste une erreur <input type=checkbox name=choixcheck><br>";
	$affichage_php.= "Liste des questions sur lesquelles il y a le plus d'erreurs <input type=checkbox name=diff><br>";
	$affichage_php.= "Revoir les questions sur lesquelles tu as fait le plus d'erreurs <input type=checkbox name=revoir><br>";
	$affichage_php.= "<br><br><select name=niveau>";
	$affichage_php.= "<option value='I'> Niveau Vert , Brevet initial (10 questions)</option>";
	$affichage_php.= "<option value='P'> Niveau Bleu , Pilote autonome (20 questions)</option>";
	$affichage_php.= "</select>";
	$affichage_php.= "<br><br><input type=submit>";
	$affichage_php.= "</form>";
	}
else
{
	$affichage_php= "<br><br>";
	if (empty($actino)) {
		if ($choix==1){
		$affichage_php.= "Liste des questions avec des erreurs<br><br>";
			$query="select * from brevet_2010  where no like '%$niveau' and no like '$type_query%' and no in (select no from pilote2 where nom='$nom' and ko>0 and ok=0) order by rand($ale) limit 1";
		
		}
		if ($choix==3){
			$affichage_php.= "Liste des questions sur lequelles il y a eu  des erreurs<br><br>";
			$query="select * from brevet_2010  where no like '%$niveau' and no like '$type_query%' and no in (select no from pilote2 where nom='$nom' and ko>0 ) order by rand($ale) limit 1";
		
		}
		if ($choix==0)  {
			if ($diff == "on"){ 
				$affichage_php.= "Liste des questions difficiles<br><br>";
				$result=spip_query("select no,count(*) as qte from pilote2 where ko>0 and no like '%$niveau' and no not in (select no from pilote2 where date=curdate() and nom='$nom' ) group by no order by qte desc limit 1");
				$row = spip_fetch_array($result);
				$no=$row['no'];
				$query="select * from brevet_2010  where no like '%$niveau' and no='$no'";
			}
			else{	
				$affichage_php.= htmlentities("Liste des questions non abordées ")."<br><br>";
				$query="select * from brevet_2010  where no like '$type_query%' and no like '%$niveau' and no not in (select no from pilote2 where nom='$nom') order by rand($ale) limit 1";
			}
		}

		$result=spip_query($query);
		$row = spip_fetch_array($result);
		$type=substr($row['no'],0,1);
		$no=$row['no'];
		$question=$row['question'];
		$question=str_replace("","'",$question);
		$rep1=$row['rep1'];
		$rep1=str_replace("","'",$rep1);
		$val1=$row['val1'];
		$rep2=$row['rep2'];
		$rep2=str_replace("","'",$rep2);
		$val2=$row['val2'];
		$rep3=$row['rep3'];
		$rep3=str_replace("","'",$rep3);
		$val3=$row['val3'];
		$rep4=$row['rep4'];
		$rep4=str_replace("","'",$rep4);
		
		$val4=$row['val4'];
		if ($no == "") {
			if (($choix==0)&&($diff != "on")){
				$affichage_php.= "<br>";
				$affichage_php.=htmlentities("Toutes les questions ont été vue")."<br>" ;
				$affichage_php.= htmlentities("Remise à zéro de ton compte")."<form method=POST><input type=checkbox name=raztot>"."<br> ";
				$affichage_php.= "<input type=hidden name=var_mode value=calcul><input type=hidden name=nom value='$nom'><input type=submit></form>";
				$affichage_php.= "<br><a href=\"/cgi-bin/stat.pl?nom=$name";
				$affichage_php.= "\" target=\"wclose\" onclick=\"window.open('popup.htm','wclose','width=500,toolbar=yes,status=no,scrollbars=yes,left=20,top=30')\">Statistique</a> "; 
		
			}
			else {
				$affichage_php.= "<br> Aucune erreur ".htmlentities("enregistrée pour l'instant")."<br> ";
				$affichage_php.= "<form method=POST><input type=hidden name=type value='$type_query'><input type=hidden name=niveau value='$niveau'><input type=hidden name=var_mode value=calcul><input type=hidden name=nom value='$nom'><input type=submit></form>";
			}
		}
		else
		{
			$type_desi="";
			if ($type == "A") $type_desi="Météo";
			if ($type == "E") $type_desi="Mécavol Général";
			if ($type == "G") $type_desi="Mécavol Parapente";
			if ($type == "H") $type_desi="Mécavol Delta";
			if ($type == "L") $type_desi="Matériel Général";
			if ($type == "N") $type_desi="Matériel Parapente";
			if ($type == "R") $type_desi="Matériel Delta";
			if ($type == "S") $type_desi="Réglementation";
			if ($type == "U") $type_desi="Pilotage Général";
			if ($type == "W") $type_desi="Pilotage Parapente";
			if ($type == "X") $type_desi="Pilotage Delta";
			if ($type == "Q") $type_desi="Réglementation aérienne(nouveau)";

			$nivea=substr("$no",-1);
			if ($nivea =="I"){
				$type_desi.= " Niveau Vert , Brevet initial ";
			}
			if ($nivea =="P"){
				$type_desi.= " Niveau Bleu , Pilote autonome ";
			}
			if ($nivea =="M"){
				$type_desi.= " Niveau Marron , Pilote confirmé ";
			}
			$affichage_php.= htmlentities($type_desi)."<br>";		
			$affichage_php.= "<form method=POST><input type=hidden name=var_mode value=calcul><table>";
			$affichage_php.= "<tr bgcolor=#66CCFF colspan=2><td><b>$no ".htmlentities($question)."</b></td></tr>";
			$affichage_php.= "<tr><td>".htmlentities($rep1)."</td><td><input type=checkbox name=rep1></td></tr>"; 
			$affichage_php.= "<tr><td>".htmlentities($rep2)."</td><td><input type=checkbox name=rep2></td></tr>"; 
			if ($rep3 != ""){
				$affichage_php.= "<tr><td>".htmlentities($rep3)."</td><td><input type=checkbox name=rep3></td></tr>"; 
			}
			if ($rep4 != ""){
				$affichage_php.= "<tr><td>".htmlentities($rep4)."</td><td><input type=checkbox name=rep4></td></tr>"; 
			}
			$affichage_php.= "</table><input type=hidden name=no value='$no'><input type=hidden name=actino value=go><input type=submit>";
			if ($choix==1){$affichage_php.= "<br>".htmlentities("Remettre à zéro le fichier des erreurs")."<input type=checkbox name=raz>";}
			$affichage_php.= "<input type=hidden name=res value='$res'><input type=hidden name=total value='$total'>";
			$affichage_php.= "<input type=hidden name=choix value='$choix'>";
			$affichage_php.= "<input type=hidden name=diff value='$diff'>";
			$affichage_php.= "<input type=hidden name=type_query value='$type_query'><input type=hidden name=niveau value='$niveau'>";
			$affichage_php.= "<input type=hidden name=nom value='$nom'><input type=hidden name=niveau value='$niveau'></form>";
			$name=str_replace("'","",$nom);
			$affichage_php.= "<br><a href=\"/cgi-bin/stat.pl?nom='$name'";
			$affichage_php.= "\" target=\"wclose\" onclick=\"window.open('popup.htm','wclose','width=500,toolbar=yes,status=no,scrollbars=yes,left=20,top=30')\">Statistique</a> "; 
		}
	}
	if ($actino == "go"){
		$result=spip_query("select count(*) as nbq from brevet_2010 where no like '%$niveau' ");
		$row = spip_fetch_array($result);
		$nbq=$row['nbq'];
		$note=0;
		$result=spip_query("select * from brevet_2010 where no like '%$niveau' and no='$no'");
		$row = spip_fetch_array($result);
		$type=substr($row['no'],0,1);
		$no=$row['no'];
		$question=$row['question'];
		$question=str_replace("","'",$question);
		$rep1=$row['rep1'];
		$rep1=str_replace("","'",$rep1);
		$val1=$row['val1'];
		$rep2=$row['rep2'];
		$rep2=str_replace("","'",$rep2);
		$val2=$row['val2'];
		$rep3=$row['rep3'];
		$rep3=str_replace("","'",$rep3);
		$val3=$row['val3'];
		$rep4=$row['rep4'];
		$rep4=str_replace("","'",$rep4);
		$val4=$row['val4'];
		$affichage_php.= "<form method=POST><input type=hidden name=var_mode value=calcul><table>";
		$affichage_php.= "<tr bgcolor=#66CCFF colspan=2><td><b>$no ".htmlentities($question)."</b></td></tr>";
		$color="white";
		if (($val1<0)&&($rep1c=="on")){$color=couleur($val1);$note+=$val1;}
		if (($val1>0)&&($rep1c != "on")){$color=couleur($val1);}
		if (($val1>0)&&($rep1c=="on")){$note+=$val1;}

		$affichage_php.= "<tr bgcolor=$color><td>".htmlentities($rep1)."</td><td align=right>$val1</td></tr>"; 
		$color="white";
		if (($val2<0)&&($rep2c=="on")){$color=couleur($val2);$note+=$val2;}
		if (($val2>0)&&($rep2c != "on")){$color=couleur($val2);}
		if (($val2>0)&&($rep2c=="on")){$note+=$val2;}

		$affichage_php.= "<tr bgcolor=$color><td>".htmlentities($rep2)."</td><td  align=right>$val2</td></tr>"; 
		$color="white";
		if ($rep3 != ""){
			if (($val3<0)&&($rep3c=="on")){$color=couleur($val3);$note+=$val3;}
			if (($val3>0)&&($rep3c != "on")){$color=couleur($val3);}
			if (($val3>0)&&($rep3c=="on")){$note+=$val3;}
		}
		$affichage_php.= "<tr bgcolor=$color><td>".htmlentities($rep3)."</td><td  align=right>$val3</td></tr>"; 
		$color="white";
		if ($rep4 != ""){
			if (($val4<0)&&($rep4c=="on")){$color=couleur($val4);$note+=$val4;}
			if (($val4>0)&&($rep4c != "on")){$color=couleur($val4);}
			if (($val4>0)&&($rep4c=="on")){$note+=$val4;}
			$affichage_php.= "<tr bgcolor=$color><td>".htmlentities($rep4)."</td><td align=right>$val4</td></tr>"; 
		}
		$affichage_php.= "</table><input type=submit value=suivante>";
		
		if ($note<0){$note=0;}
		if ($note==6){ 
			$result=spip_query("select count(*) as existe from pilote2 where nom='$nom' and no='$no'");
			$row = spip_fetch_array($result);
			$existe=$row['existe']+0;
			if ($existe >0){
				spip_query("update pilote2 set ok=ok+1,date=curdate() where nom='$nom' and no='$no'");
				
			}
			else {
				$query="insert into  pilote2 values ('$nom','$no','1','0','0','0',curdate())";
				spip_query($query);
				// echo $query;
			
			} 
		}
		else {
			$result=spip_query("select count(*) as existe from pilote2 where nom='$nom' and no='$no'");
			$row = spip_fetch_array($result);
			$existe=$row['existe']+0;
			if ($existe >0){
				spip_query("update pilote2 set ko=ko+1,date=curdate() where nom='$nom' and no='$no'");
			}
			else {
				spip_query("insert into  pilote2 values ('$nom','$no','0','1','0','0',curdate())");
			} 
			$affichage_php.= "<br>";
		
		}
		$query="select explication from info_brevet where no='$no'";
		$result=spip_query($query);
		$row = spip_fetch_array($result);
		$expli=$row['explication'];
		// $affichage_php.="*$expli $query*";
		if ($expli != "") {
			$affichage_php.= "<br><div style=\"background-color:#cccccc;width:800;text-align:justify\">".htmlentities($expli)."</div>";
		}
	
		$res+=$note;
		$total+=6;
		$valeur=floor($res*2000/$total)/100;
		$affichage_php.= "<br><br>Nombre de point obtenu:<b>$note</b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<font size=+2>$valeur/20</font>";
		$affichage_php.= "<input type=hidden name=res value='$res'><input type=hidden name=total value='$total'>";
		$affichage_php.= "<input type=hidden name=nom value='$nom'><input type=hidden name=no value='$no'>";
		$affichage_php.= "<input type=hidden name=choix value='$choix'>";
		$affichage_php.= "<input type=hidden name=diff value='$diff'>";
		$result=spip_query("select count(*) as nb from pilote2 where nom='$nom' and ok>0 and no like '%$niveau'");
		$row = spip_fetch_array($result);
		$nb=$row['nb']+0;
		if ($diff != "on") {$affichage_php.= "<br>".htmlentities("Nombre de bonne réponse:")."$nb/$nbq"; }
		$reste=$nbq-$nb;
		$query="select count(*) as nb from brevet_2010  where no like '%$niveau' and no like '$type_query%' and no in (select no from pilote2 where nom='$nom')";
		$result=spip_query("$query");
		$row = spip_fetch_array($result);
		$nb=$row['nb']+0;
		$query="select count(*) as nbq from brevet_2010  where no like '%$niveau' and no like '$type_query%' ";
		$result=spip_query("$query");
		$row = spip_fetch_array($result);
		$nbq=$row['nbq']+0;
		if ($choix==1){
			$affichage_php.= "<br>".htmlentities("Reste:")."$reste";
		}
		else
		{
			$affichage_php.= "<br>".htmlentities("Réalisé:")."$nb/$nbq";
		}
		$affichage_php.= "<input type=hidden name=type value='$type_query'><input type=hidden name=niveau value='$niveau'>";
		$affichage_php.= "</form>";
		$name=str_replace("'","",	$nom);
		$affichage_php.= "<br><a href=\"/cgi-bin/stat.pl?nom=$name";
		$affichage_php.= "\" target=\"wclose\" onclick=\"window.open('popup.htm','wclose','width=500,toolbar=yes,status=no,scrollbars=yes,left=20,top=30')\">Statistique</a> "; 
	}

}
function couleur($val)
	{
		$col="white";
		if ($val==1) $col="#FFE5E5";
		if ($val==2) $col="#FFB2B2";
		if ($val==3) $col="#FF8080";
		if ($val==4) $col="#CC6666";
		if ($val==6) $col="#99694C";
		if ($val==-6) $col="#99694C";
		if ($val==-3) $col="#FF8080";
		return($col);
	}
	
?>
