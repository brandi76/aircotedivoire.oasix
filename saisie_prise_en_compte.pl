#!/usr/bin/perl
use CGI::Carp qw(fatalsToBrowser);
use CGI;
use DBI();
require "../oasix/outils_perl2.pl";
require "./src/connect.src";
$html=new CGI;
print $html->header();
$action=$html->param("action");
$appro=$html->param("appro");
$date_depart=$html->param("date_depart");
$depart=$html->param("depart");
$date_retour=$html->param("date_retour");
$retour=$html->param("retour");
$pnc=$html->param("pnc");
$dfc=$html->param("dfc");

if ($action eq "depart"){
	&save("replace into prise_en_compte values ('$appro','-2','$date_depart','$depart','$pnc','$dfc')","af");
	$action="go";
}
if ($action eq "retour"){
	&save("replace into prise_en_compte values ('$appro','-1','$date_retour','$retour','$pnc','$dfc')","af");
	$action="go";
}
if ($action eq "caisse"){
	&save("delete from prise_en_compte where appro='$appro' and rot>0","af");
	$query="select vol.* from vol where v_code='$appro' order by v_rot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_date_sql)=$sth->fetchrow_array){
		$caisse=$html->param("e_$v_rot");
		$manquante=$html->param("m_$v_rot");
		&save("insert into prise_en_compte values ('$appro','$v_rot',curdate(),'','$caisse','$manquante')","af");
		if ($manquante eq "on"){
		$mail="yomiedwigeorsy\@yahoo.fr";
		$copie="pp\@dufreeconept.com";
		# $mail="sylvainbrandicourt\@gmail.com";
		# $copie="";
		 system("/var/www/cgi-bin/aircotedivoire.oasix/send_caisse_manquante.pl '$mail' '$copie' '$appro' &");
		# send_manquante
		}
	}
	$action="go";
}

print <<EOF;
<!DOCTYPE html>
<html>
<head>
    <title></title>
    <link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
    <link href="/css/bootstrap-datetimepicker.min.css" rel="stylesheet" media="screen">
	<script type="text/javascript" src="/js/jquery.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/bootstrap.min.js"></script>
	<script type="text/javascript" src="/js/bootstrap-datetimepicker.js" charset="UTF-8"></script>
	<script type="text/javascript" src="/js/locales/bootstrap-datetimepicker.fr.js" charset="UTF-8"></script>
</head>
<body>
<div class="container">
	<div class="row">
		<div class="col-lg-12">
EOF
if ($action eq ""){
print <<EOF;
			<div class="alert alert-info" >
			<h3>Gestion Prise en compte</h3>
			</div>
			<form role="form">
				<fieldset>
					<div class="form-group">
						<label for="dtp_input2" class="control-label">Saisir un No de bon d'appro</label>
						<input type="text" id="dtp_input2" value="" name=appro /><br/>
						<input type="hidden" name=action value="go" />
					</div>
				</fieldset>
			<button type="submit" class="btn btn-info">Submit</button>
			</form>
		</div>
	</div>
</div>
EOF
}
if ($action eq "go"){
	print "<div class=well><h3>";
	$pnc="";
	$dfc="";
	($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_pax,$v_date_sql)=&get("select vol.* from vol where v_code='$appro' and v_rot=1");
	($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=&get("select * from flybody where flb_date='$v_date_jl' and flb_vol='$v_vol' order by flb_rot","af");
	 $depart=substr($flb_depart,0,2).':'.substr($flb_depart,2,2);
	 $date_depart=$v_date_sql;
 	print "$v_code $v_vol $v_date $v_date_sql";
	($date_p,$heure_p,$pnc_p,$dfc_p)=&get("select date,heure,info1,info2 from prise_en_compte where appro='$appro' and rot=-2");
	$color="red";
	if ($date_p ne ""){
		$color="black";
		$date_depart=$date_p;
		$depart=$heure_p;
		$pnc=$pnc_p;
		$dfc=$dfc_p;
	}
	print "</h3></div>";
		
print <<EOF;
		$date_depart*$depart*
		<h3>Depart</h3>
		<form style="border:1px solid $color" >
			<div class="form-group" >
				Date livraison:
				<div class="input-group date form_date" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd" style=width:200px> 
					<input class="form-control" type="text" value="$date_depart" readonly>
					<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
				</div>
				<input type="hidden" id="dtp_input2"  name=date_depart value="$date_depart" />
				Heure de Livraison
				<div class="input-group date form_time" data-date="" data-date-format="hh:ii" data-link-field="dtp_input3" data-link-format="hh:ii" style=width:100px> 
					<input class="form-control" type="text" value="$depart" readonly>
					<span class="input-group-addon"><span class="glyphicon glyphicon-time"></span></span>
				</div>
				<input type="hidden" id="dtp_input3" value="$depart" name=depart />
				Trigramme PNC 
				<input type="text"  value="$pnc" name=pnc /><br/>
				Trigramme DFC
				<input type="text"  value="$dfc" name=dfc /><br/>
				<button type=submit class=\"btn btn-success btn-sm\" name=option >Submit</button>
				<input type="hidden" name=action value=depart />
				<input type="hidden" name=appro value=$appro />
			</div>
		</form>
EOF
	($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_pax,$v_date_sql)=&get("select vol.* from vol where v_code='$appro' order by v_rot desc");
	($flb_date,$flb_vol,$flb_rot,$flb_datetr,$flb_voltr,$flb_depart,$flb_arrivee,$flb_tridep,$flb_triret,$flb_nolot)=&get("select * from flybody where flb_date='$v_date_jl' and flb_vol='$v_vol' order by flb_rot desc","af");
	$retour=substr($flb_arrivee,0,2).':'.substr($flb_arrivee,2,2);
	$date_retour=$v_date_sql;
	$pnc="";
	$dfc="";
	($date_p,$heure_p,$pnc_p,$dfc_p)=&get("select date,heure,info1,info2 from prise_en_compte where appro='$appro' and rot=-1");
	$color="red";
	if ($date_p ne ""){
		$color="black";
		$date_retour=$date_p;
		$retour=$heure_p;
		$pnc=$pnc_p;
		$dfc=$dfc_p;
	}
	

print <<EOF;		
		<h3>Retour</h3>
		<form style="border:1px solid $color">
			<div class="form-group">
				Date retour:
				<div class="input-group date form_date" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input4" data-link-format="yyyy-mm-dd" style=width:200px> 
					<input class="form-control" type="text" value="$date_retour" readonly>
					<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
				</div>
				<input type="hidden" id="dtp_input4"  name=date_retour value="$date_retour" />
				Heure de dechargement
				<div class="input-group date form_time" data-date="" data-date-format="hh:ii" data-link-field="dtp_input5" data-link-format="hh:ii" style=width:100px> 
					<input class="form-control" type="text" value="$retour" readonly>
					<span class="input-group-addon"><span class="glyphicon glyphicon-time"></span></span>
				</div>
				<input type="hidden" id="dtp_input5" value="$retour" name=retour />
				Trigramme PNC 
				<input type="text"  name=pnc value='$pnc' /><br/>
				Trigramme DFC
				<input type="text"  name=dfc value='$dfc'/><br/>
				<button type=submit class=\"btn btn-success btn-sm\" name=option >Submit</button>
				<input type="hidden" name=action value=retour />
				<input type="hidden" name=appro value=$appro />
			</div>
		</form>
EOF
	$color="red";
	($check)=&get("select count(*) from prise_en_compte where appro='$appro' and rot>0")+0;
	if ($check >0){$color="black";}

print <<EOF;			
		<h3>Caisse</h3>
		<form style="border:1px solid $color">
			<div class="form-group">
EOF
	$query="select vol.* from vol where v_code='$appro' order by v_rot";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($v_code,$v_rot,$v_vol,$v_date,$v_type,$v_pnc,$v_ca,$v_dest,$v_cd_cl,$v_nom,$v_dest2,$v_retour,$v_troltype,$v_date_jl,$v_date_sql)=$sth->fetchrow_array){
		$caisse="";
		$manquante="";
		($caisse,$manquante)=&get("select info1,info2 from prise_en_compte where appro='$appro' and rot='$v_rot'");
		print "Rotation $v_rot: No enveloppe: <input type='text'  value='$caisse' name=e_$v_rot /> caisse manquante <input type=checkbox name=m_$v_rot ";
		if ($manquante eq "on"){print " checked";}
		print "><br/>";
	}
print <<EOF;			
	
			<button type=submit class=\"btn btn-success btn-sm\" name=option >Submit</button>
			<input type="hidden" name=action value=caisse />
			<input type="hidden" name=appro value=$appro />
			</div>
		</form>
		
EOF
}
 
print <<EOF;
<script type="text/javascript">
   \$('.form_date').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 2,
		minView: 2,
		forceParse: 0
    });
	\$('.form_time').datetimepicker({
        language:  'fr',
        weekStart: 1,
        todayBtn:  1,
		autoclose: 1,
		todayHighlight: 1,
		startView: 1,
		minView: 0,
		maxView: 1,
		forceParse: 0
    });
</script>
</body>
EOF


