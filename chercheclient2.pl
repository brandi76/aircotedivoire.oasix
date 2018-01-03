#!/usr/bin/perl

use CGI;
$html = new CGI;
print $html->header;

require "../oasix/outils_perl.lib";
$fichier=$html->param('fichier');     # fichier a ouvrir
$lien=$html->param('lien');
$nbelement=$html->param('nbelement'); # nb de colonne dans le fichier

# receperation des colonnes a traiter
for ($i=0;$i<=$nbelement;$i++)
{
        if ($html->param("check$i") eq "on")
        {
        	push(@col_selection,$i);  # table des colonnes selectionnées
        }
}	

# recuperation des criteres saisies

for($i=0;$i<=$#col_selection;$i++)
{       
	
	@critere[$i]=$html->param("critere@col_selection[$i]"); # table critere conteient les criteres correspondant a chaque collonne du fichier
}

# ouverture des fichiers data et description
open (FILE,"/home/var/spool/uucppublic/client2.txt");
@data=<FILE>;
close(FILE);
open (FILE,"/home/var/spool/uucppublic/client2.dsc");
@desc=<FILE>;
close(FILE);


#   BEGIN 


print "<html>\n";
print "<LINK rel=\"stylesheet\" href=\"/intranet.css\" type=\"text/css\">\n";
&body();
&tete("Resultat de la recherche","","");
#print "<a href=http://intranet.dom><img src=http://intranet.dom/home.jpg align=right border=0></a><br>";
print "<br>\n<font size=2 color=red >Affiner la recherche :</font>\n<br><br>";
print "<table width=100% border=1 cellspacing=0 cellpadding=0>";
print "<tr>";

# affichage des entetes de colonne

@desc_item=split(/;/,$desc[0]);
for($i=0;$i<=$#col_selection;$i++)
{
	print "<td align=center><font size=2><b>&nbsp;$desc_item[$col_selection[$i]]</b></td>";
}
print "</tr>";


# gestion des variable pour la demande suivante

print "<form name=recherche action=../cgi-bin/chercheclient2.pl>";
print "<input type=hidden name=lien value=$lien>";
print "<tr>";

 for($i=0;$i<=$nbelement;$i++)
{
	if ($html->param("check$i") eq "on")
        {
        	print "<td align=center><font size=2><input type=texte size=10 name=critere$i value=",$html->param("critere$i"),"></td>";
                print "<input type=hidden name=check$i value=on>";
	}
}
print "<td><font size=2><input type=submit value=Actualiser></td></tr>";
print "<input type=hidden name=fichier value=$fichier>";
print "<input type=hidden name=nbelement value=$nbelement>";
print "</form>";

# pour les elements du fichier on test si les criteres correspondent afin de d'alimenter @TAB 

foreach $data_var (@data)
{ 
	@data_item=split(/;/,$data_var);
	$true=1;
	for ($i=0;$i<=$#critere;$i++)
	{
		while ($critere[$i] =~ s/  / /g){};
		
		if (($critere[$i] ne "indifferent")  && (length($critere[$i]) > 1))
		{
			$comp=uc($critere[$i]);
			if (! grep  /$comp/,uc($data_item[$col_selection[$i]]))
			{
				$true=0;
			}
		}
			
				
	}
	if ($true)
	{
		push (@TAB,$data_var);
		}
}

# une fois la table cree on affiche les lignes du tableau

foreach(@TAB)
{
	@data_item=split(/;/,$_);
	print "<tr>";
		for($i=0;$i<=$#col_selection;$i++)
        {
		print "<td><font size=2>&nbsp;@data_item[@col_selection[$i]]</td>";
        }
        if ($lien ne ""){
        	($nul,$lien_en_clair)=split(/cgi-bin\//,$lien);
        	($lien_en_clair)=split(/\./,$lien_en_clair);
        	print "<td><font size=2><a href=$lien@data_item[@col_selection[0]]>$lien_en_clair</a></td>";
        	}
        print "</tr>\n";
}

print "</table></body></html>";

# -E recherche dans un fichier

