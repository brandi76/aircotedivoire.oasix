#!/usr/bin/perl
use CGI;
use DBI;

$html=new CGI;
require "../oasix/manip_table.lib";
require "../oasix/outils_perl.lib";
print $html->header;
require "./src/connect.src";
$action=$html->param("action");
$date_ref=$html->param("date");

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
	<form role="form">
				<fieldset>
					<div class="form-group">
						<label for="dtp_input2" class="control-label">Date</label>
						<div class="input-group date form_date col-md-3" data-date="" data-date-format="dd MM yyyy" data-link-field="dtp_input2" data-link-format="yyyy-mm-dd"> 
							<input class="form-control" size="16" type="text" value="$date" readonly>
							<span class="input-group-addon"><span class="glyphicon glyphicon-calendar"></span></span>
						</div>
						<input type="hidden" id="dtp_input2" value="" name=date /><br/>
						<input type="hidden" name=action value="go" />
					</div>
				</fieldset>
			<button type="submit" class="btn btn-info">Submit</button>
	</form>
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
}


else {
	$query="select date,montant from coffre where devise='XOF' and date >='$date_ref' order by date";
	$sth=$dbh->prepare($query);
	$sth->execute();
	($date,$montant)=$sth->fetchrow_array;
	print "Coffre:$date $montant<br>";
	$query="select no,montant,date_creation,date_remise from bordereau where date_creation >='$date_ref' and devise='XOF'";
	$sth=$dbh->prepare($query);
	$sth->execute();
	while (($no,$montant,$date_creation,$date_remise)=$sth->fetchrow_array){
		$t_xof_1,$t_xof_2,$t_xof_3,$t_xof_4,$t_xof_5,$t_xaf_1,$t_xaf_2,$t_xaf_3,$t_xaf_4,$t_dol_1,$t_dol_2,$t_dol_3,$t_dol_4,$t_dol_5,$t_dol_6,$t_eur_1,$t_eur_2,$t_eur_3,$t_eur_4,$t_eur_5,$t_eur_6=0;
		$total_xof=$total_xaf=$total_dol=$total_eur=$total_stim=$total_cb=0;
		$query="select ca_code,ca_rot,ca_xof,ca_xaf,ca_dol,ca_eur,ca_cb,ca_papi from caissesql where ca_border='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		while (($ca_code,$ca_rot,$ca_xof,$ca_xaf,$ca_dol,$ca_eur,$ca_cb,$ca_papi)=$sth2->fetchrow_array){
			# $date_vol=&get("select v_date from vol where v_code=$ca_code and v_rot=$ca_rot");
			# $date_vol=&date(&daten($date_vol));
			# $date_vol="20".$date_vol;
			# $date_vol=~s/\//-/g;
			# $ecart=&get("select datediff('$date_vol','$date_ref')")+0;
			# if ($ecart <0){next;}
		
			($xof_1,$xof_2,$xof_3,$xof_4,$xof_5)=split(/:/,$ca_xof);
			($xaf_1,$xaf_2,$xaf_3,$xaf_4,$xaf_5)=split(/:/,$ca_xaf);
			($dol_1,$dol_2,$dol_3,$dol_4,$dol_5,$dol_6)=split(/:/,$ca_dol);
			($eur_1,$eur_2,$eur_3,$eur_4,$eur_5,$eur_6)=split(/:/,$ca_eur);
			$total_xof+=$xof_1*10000+$xof_2*5000+$xof_3*2000+$xof_4*1000+$xof_5*500;
			$total_xaf+=$xaf_1*10000+$xaf_2*5000+$xaf_3*2000+$xaf_4*1000+$xaf_5*500;
			$total_dol+=$dol_1*50+$dol_2*20+$dol_3*10+$dol_4*5+$dol_5*2+$dol_6;
			$total_eur+=$eur_1*100+$eur_2*50+$eur_3*20+$eur_4*10+$eur_5*5+$eur_6;
			$total_cb+=$ca_cab;
			$total_stim+=$ca_papi;
		}
		print "Encaissé:$no $date_creation :".$total_xof."<br>";
		$montant=int($montant);
		print "Remise:$no $date_remise :".$montant."<br>";
		$query="select montant,date from cash where bordereau='$no'";
		$sth2=$dbh->prepare($query);
		$sth2->execute();
		($cash,$date)=$sth2->fetchrow_array;
		print "Cash:$cash $date <br>";
	}
}	
=pod
	# $val_anc=&get("select montant from encaissement where date='$date_ref' and devise='$devise'","af")+0;
	# $val_ent=$total{"$devise"};
	# $val_sor=&get("select sum(montant) from bordereau where date_remise >='$date_ref' and date_creation>'$date_ref' and devise='$devise'")+0;
	$cash_encours=&get("select cash.montant from cash,bordereau where bordereau.date_remise='0000-00-00' and cash.bordereau=bordereau.no and cash.devise=bordereau.devise and bordereau.devise='$devise'")+0;
	#cash_encours c'est le montant pris dans la caisse mais avant la remise
	$val_res=$val_anc-$val_sor+$val_ent-$cash_encours;
	$ecart=$montant-$val_res;
	$ecart_reel=$ecart;
	$ecart_enregistre=&get("select sum(ecart) from coffre where devise='$devise' and date>='$date_ref'")+0;
	print "Ancien:$val_anc ent:$val_ent sor:$val_sor cash encours:$cash_encours reste:$val_res <br>";
 
}	
