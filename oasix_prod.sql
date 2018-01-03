 Serveur: localhost   Base de données: oasix   Table: oasix_prod 
-- phpMyAdmin SQL Dump
-- version 3.2.1
-- http://www.phpmyadmin.net
--
-- Serveur: localhost
-- Généré le : Mer 31 Mars 2010 à 09:18
-- Version du serveur: 5.1.37
-- Version de PHP: 5.2.10

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Base de données: `oasix`
--

-- --------------------------------------------------------

--
-- Structure de la table `oasix_prod`
--

CREATE TABLE IF NOT EXISTS `oasix_prod` (
  `oa_cd_pr` bigint(16) DEFAULT NULL,
  `oa_desi` varchar(17) DEFAULT NULL
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

--
-- Contenu de la table `oasix_prod`
--

INSERT INTO `oasix_prod` (`oa_cd_pr`, `oa_desi`) VALUES
(1000, 'Pepsi light 33cl'),
(100, 'Evian 33cl'),
(1100, 'Cafe expresso'),
(1200, 'Chocolat'),
(1300, 'The nature'),
(1400, 'Capuccino'),
(1500, 'Sandwich poulet'),
(1600, 'Sandwich bagnat'),
(1700, 'Sandwich baguett'),
(1800, 'Sandwich tortill'),
(1900, 'Guanaja chocolat'),
(2000, 'Pain chocolat'),
(200, 'Tropicana 25cl'),
(2100, 'Madeleine pure b'),
(2200, 'Kinder bueno'),
(2300, 'Twix'),
(2400, 'Kit kat ball'),
(2500, 'Sachet biscuits'),
(2600, 'Compote gourde'),
(2700, 'Pomme emball'),
(2700, 'Pomme emball'),
(2700, 'Pomme emball'),
(2800, 'Dessert pomme ca'),
(2900, 'Pringles'),
(3000, 'Chipster'),
(300, 'Jus de tomate 15'),
(3100, 'Pik croq'),
(400, 'Smoothie 25cl'),
(500, 'Biere 1664 25cl'),
(600, 'Dark dog 25cl'),
(700, 'Ice tea peche li'),
(800, 'Orangina 33cl'),
(850, 'San pellgrino 50'),
(900, 'Pepsi 33cl'),
(110, 'Badoit 50cl'),
(510, '1/4 Vin blanc'),
(520, '1/4 Vin rouge'),
(2310, 'm et ms 100gr'),
(2320, 'Muffin 80gr'),
(2330, 'na framboise'),
(530, 'Mini martini roug'),
(540, 'Mini vodka'),
(550, 'Mini wisky'),
(2340, 'Petit ecolier'),
(2350, 'Smoothie 25cl'),
(1310, 'The noir'),
(120, 'Thonon 50cl'),
(2360, 'Toblerone 100gr'),
(130, 'Badoit 50cl');
 