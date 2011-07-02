CREATE TABLE `names` (
  `Number` int(11) NOT NULL AUTO_INCREMENT,
  `Gender` varchar(6) NOT NULL,
  `GivenName` varchar(50) NOT NULL,
  `MiddleInitial` varchar(2) NOT NULL,
  `Surname` varchar(50) NOT NULL,
  `StreetAddress` varchar(150) NOT NULL,
  `City` varchar(200) NOT NULL,
  `State` varchar(100) NOT NULL,
  `ZipCode` mediumint(9) NOT NULL,
  `Country` varchar(3) NOT NULL,
  `EmailAddress` varchar(255) NOT NULL,
  `TelephoneNumber` varchar(15) NOT NULL,
  `MothersMaiden` varchar(100) NOT NULL,
  `Birthday` varchar(15) NOT NULL,
  `CCType` varchar(100) NOT NULL,
  `CCNumber` bigint(20) NOT NULL,
  `CVV2` smallint(6) NOT NULL,
  `CCExpires` varchar(12) NOT NULL,
  `NationalID` varchar(255) NOT NULL,
  `description` text,
  PRIMARY KEY (`Number`),
  KEY `Gender` (`Gender`),
  KEY `City` (`City`),
  KEY `State` (`State`),
  KEY `ZipCode` (`ZipCode`),
  KEY `Country` (`Country`),
  KEY `EmailAddress` (`EmailAddress`),
  KEY `CCNumber` (`CCNumber`)
) ENGINE=MyISAM AUTO_INCREMENT=2000 DEFAULT CHARSET=latin1