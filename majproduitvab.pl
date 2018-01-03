#!/usr/bin/perl
use CGI;
use DBI();
$html=new CGI;
require "../oasix/outils_perl2.pl";
require "../oasix/outils_corsica.pl";
print $html->header;
require("./src/connect.src");

# script qui cr�e automatiquement les produits vab , juin 2010
&save ("ALTER TABLE `oasix_prod` CHANGE `oa_desi` `oa_desi` VARCHAR( 18 ) CHARACTER SET latin1 COLLATE latin1_swedish_ci NULL DEFAULT NULL ");
&save("delete from ordre where ord_cd_pr >=4000 and ord_cd_pr<=4360");
&save("insert into ordre values (4000,4000,46,0)");
&save("insert into ordre values (4010,4010,38,0)");
&save("insert into ordre values (4020,4020,38,0)");
&save("insert into ordre values (4030,4030,39,0)");
&save("insert into ordre values (4040,4040,36,0)");
&save("insert into ordre values (4050,4050,35,0)");
&save("insert into ordre values (4060,4060,39,0)");
&save("insert into ordre values (4070,4070,15,0)");
&save("insert into ordre values (4080,4080,75,0)");
&save("insert into ordre values (4090,4090,85,0)");
&save("insert into ordre values (4100,4100,48,0)");
&save("insert into ordre values (4110,4110,24,0)");
&save("insert into ordre values (4120,4120,20,0)");
&save("insert into ordre values (4130,4130,40,0)");
&save("insert into ordre values (4140,4140,49,0)");
&save("insert into ordre values (4150,4150,36,0)");
&save("insert into ordre values (4160,4160,52,0)");
&save("insert into ordre values (4170,4170,42,0)");
&save("insert into ordre values (4180,4180,43,0)");
&save("insert into ordre values (4190,4190,50,0)");
&save("insert into ordre values (4200,4200,31,0)");
&save("insert into ordre values (4210,4210,31,0)");
&save("insert into ordre values (4220,4220,40,0)");
&save("insert into ordre values (4230,4230,9,0)");
&save("insert into ordre values (4240,4240,9,0)");
&save("insert into ordre values (4250,4250,39,0)");
&save("insert into ordre values (4260,4260,3,0)");
&save("insert into ordre values (4270,4270,58,0)");
&save("insert into ordre values (4280,4280,49,0)");
&save("insert into ordre values (4290,4290,31,0)");
&save("insert into ordre values (4300,4300,59,0)");
&save("insert into ordre values (4310,4310,49,0)");
&save("insert into ordre values (4320,4320,36,0)");
&save("insert into ordre values (4330,4330,22,0)");
&save("insert into ordre values (4340,4340,4,0)");
&save("insert into ordre values (4350,4350,4,0)");
&save("insert into ordre values (4360,4360,4,0)");

&save("delete from oasix_prod where oa_cd_pr >=4000 and oa_cd_pr<=4360");
&save(" insert into oasix_prod values (4000,'Angel de T. Mugl')");
&save(" insert into oasix_prod values (4010,'Aqua Allegoria M')");
&save(" insert into oasix_prod values (4020,'Azzaro pour hom.')");
&save(" insert into oasix_prod values (4030,'Black XS for her')");
&save(" insert into oasix_prod values (4040,'Black XS  lui')");
&save(" insert into oasix_prod values (4050,'Boite Mystere')");
&save(" insert into oasix_prod values (4060,'CK free 50 ml')");
&save(" insert into oasix_prod values (4070,'Creme jeunesse d')");
&save(" insert into oasix_prod values (4080,'Festina men ')");
&save(" insert into oasix_prod values (4090,'Festina women ')");
&save(" insert into oasix_prod values (4100,'Guerlain Homme ')");
&save(" insert into oasix_prod values (4110,'Guerlain Khol ')");
&save(" insert into oasix_prod values (4120,'Hello Kitty 60 m')");
&save(" insert into oasix_prod values (4130,'Hugo de H. Boss ')");
&save(" insert into oasix_prod values (4140,'Hypnose Senses ')");
&save(" insert into oasix_prod values (4150,'Lacoste Booster ')");
&save(" insert into oasix_prod values (4160,'Lancome palette ')");
&save(" insert into oasix_prod values (4170,'L Homme de YSL 6')");
&save(" insert into oasix_prod values (4180,'L Instant  de Gu')");
&save(" insert into oasix_prod values (4190,'Lolita lempicka ')");
&save(" insert into oasix_prod values (4200,'Marlboro gold ')");
&save(" insert into oasix_prod values (4210,'Marlboro red ')");
&save(" insert into oasix_prod values (4220,'Nina de N. Ricci')");
&save(" insert into oasix_prod values (4230,'Nivea men')");
&save(" insert into oasix_prod values (4240,'Nivea women')");
&save(" insert into oasix_prod values (4250,'One Million 50 ')");
&save(" insert into oasix_prod values (4260,'oreiller gonflab')");
&save(" insert into oasix_prod values (4270,'Organza 50 ml')");
&save(" insert into oasix_prod values (4280,'Paris Spring YSL')");
&save(" insert into oasix_prod values (4290,'Terracotta Light')");
&save(" insert into oasix_prod values (4300,'Tresor EDP 50 ml')");
&save(" insert into oasix_prod values (4310,'Very Irresistibl')");
&save(" insert into oasix_prod values (4320,'YSL manucure')");
&save(" insert into oasix_prod values (4330,'YSL mascara')");
&save(" insert into oasix_prod values (4340,'Mini whisky')");
&save(" insert into oasix_prod values (4350,'Mini vodka')");
&save(" insert into oasix_prod values (4360,'Mini martini rouge')");

&save("delete from produit where pr_cd_pr >=4000 and pr_cd_pr<=4360");
&save("insert into produit values (4000, 'Angel de T. Mugl', 0, 0, 0, '0', 0, 0, 1, 4600, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4010, 'Aqua Allegoria M', 0, 0, 0, '0', 0, 0, 1, 3800, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4020, 'Azzaro pour hom.', 0, 0, 0, '0', 0, 0, 1, 3800, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4030, 'Black XS for her', 0, 0, 0, '0', 0, 0, 1, 3900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4040, 'Black XS  lui', 0, 0, 0, '0', 0, 0, 1, 3600, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4050, 'Boite Mystere', 0, 0, 0, '0', 0, 0, 1, 3500, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4060, 'CK free 50 ml', 0, 0, 0, '0', 0, 0, 1, 3900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4070, 'Creme jeunesse d', 0, 0, 0, '0', 0, 0, 1, 1500, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4080, 'Festina men ', 0, 0, 0, '0', 0, 0, 1, 7500, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4090, 'Festina women ', 0, 0, 0, '0', 0, 0, 1, 8500, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4100, 'Guerlain Homme ', 0, 0, 0, '0', 0, 0, 1, 4800, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4110, 'Guerlain Khol ', 0, 0, 0, '0', 0, 0, 1, 2400, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4120, 'Hello Kitty 60 m', 0, 0, 0, '0', 0, 0, 1, 2000, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4130, 'Hugo de H. Boss ', 0, 0, 0, '0', 0, 0, 1, 4000, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4140, 'Hypnose Senses ', 0, 0, 0, '0', 0, 0, 1, 4900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4150, 'Lacoste Booster ', 0, 0, 0, '0', 0, 0, 1, 3600, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4160, 'Lancome palette ', 0, 0, 0, '0', 0, 0, 1, 5200, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4170, 'L Homme de YSL 6', 0, 0, 0, '0', 0, 0, 1, 4200, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4180, 'L Instant  de Gu', 0, 0, 0, '0', 0, 0, 1, 4300, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4190, 'Lolita lempicka ', 0, 0, 0, '0', 0, 0, 1, 5000, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4200, 'Marlboro gold ', 0, 0, 0, '0', 0, 0, 3, 3100, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4210, 'Marlboro red ', 0, 0, 0, '0', 0, 0, 3, 3100, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4220, 'Nina de N. Ricci', 0, 0, 0, '0', 0, 0, 5, 4000, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4230, 'Nivea men', 0, 0, 0, '0', 0, 0, 5, 900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4240, 'Nivea women', 0, 0, 0, '0', 0, 0, 5, 900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4250, 'One Million 50 ', 0, 0, 0, '0', 0, 0, 5, 3900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4260, 'oreiller gonflab', 0, 0, 0, '0', 0, 0, 5, 300, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4270, 'Organza 50 ml', 0, 0, 0, '0', 0, 0, 5, 5800, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4280, 'Paris Spring YSL', 0, 0, 0, '0', 0, 0, 5, 4900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4290, 'Terracotta Light', 0, 0, 0, '0', 0, 0, 5, 3100, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4300, 'Tresor EDP 50 ml', 0, 0, 0, '0', 0, 0, 5, 5900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4310, 'Very Irresistibl', 0, 0, 0, '0', 0, 0, 5, 4900, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4320, 'YSL manucure', 0, 0, 0, '0', 0, 0, 5, 3600, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4330, 'YSL mascara', 0, 0, 0, '0', 0, 0, 5, 2200, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4340, 'Mini whisky', 0, 0, 0, '0', 0, 0, 2, 400, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4350, 'Mini vodka', 0, 0, 0, '0', 0, 0, 2, 400, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");
&save("insert into produit values (4360, 'Mini martini rouge', 0, 0, 0, '0', 0, 0, 2, 400, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, '', 0, 0, '0', 0)");

print "Mise � jour des produits vab effectu�e";