# ************************************************************
# Sequel Pro SQL dump
# Version 4541
#
# http://www.sequelpro.com/
# https://github.com/sequelpro/sequelpro
#
# Host: 127.0.0.1 (MySQL 5.5.5-10.4.11-MariaDB-1:10.4.11+maria~bionic)
# Database: site
# Generation Time: 2020-01-03 09:25:33 +0000
# ************************************************************


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `appbuilder-admin`;

# Dump of table site_tenant
# ------------------------------------------------------------

DROP TABLE IF EXISTS `site_tenant`;

CREATE TABLE `site_tenant` (
  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `properties` longtext COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `uuid` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ;

LOCK TABLES `site_tenant` WRITE;
/*!40000 ALTER TABLE `site_tenant` DISABLE KEYS */;

INSERT INTO `site_tenant` (`id`, `uuid`, `key`, `properties`)
VALUES
  (1,'admin','admin','{ \"title\":\"Tenant Admin\", \"authType\":\"login\" }');

/*!40000 ALTER TABLE `site_tenant` ENABLE KEYS */;
UNLOCK TABLES;


# Dump of table site_user
# ------------------------------------------------------------

DROP TABLE IF EXISTS `site_user`;

CREATE TABLE `site_user` (
  `uuid` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'NULL',
  `created_at` datetime DEFAULT NULL,
  `updated_at` datetime DEFAULT NULL,
  `properties` text COLLATE utf8_unicode_ci DEFAULT NULL,
  `failedLogins` int(11) DEFAULT 0,
  `lastLogin` datetime DEFAULT NULL,
  `isActive` tinyint(1) DEFAULT NULL,
  `sendEmailNotifications` tinyint(1) DEFAULT NULL,
  `image_id` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  `username` varchar(255) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'NULL',
  `password` longtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `salt` varchar(255) COLLATE utf8_unicode_ci DEFAULT 'NULL',
  `email` longtext COLLATE utf8_unicode_ci DEFAULT NULL,
  `languageCode` varchar(255) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`uuid`),
  UNIQUE KEY `site_user_username` (`username`),
  KEY `site_user_languageCode` (`languageCode`),
  CONSTRAINT `site_user_languageCode` FOREIGN KEY (`languageCode`) REFERENCES `site_multilingual_language` (`language_code`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


LOCK TABLES `site_user` WRITE;
/*!40000 ALTER TABLE `site_user` DISABLE KEYS */;

INSERT INTO `site_user` (`uuid`, `created_at`, `updated_at`, `properties`, `failedLogins`, `lastLogin`, `isActive`, `sendEmailNotifications`, `image_id`, `username`, `password`, `salt`, `email`, `languageCode`)
VALUES
  ('admin-uuid','2020-11-02 18:23:36','2020-11-02 18:30:25',NULL,NULL,NULL,1,1,'','admin','0bf75b6319583009d266670e47b03d777d0bfa0ffcdcbec8b6f7ab46e6caf1a924b90ff32b9e0cc0f2def46ddf826f6c60f772bdf5379fac089355ecec58bf5eb9231d2d05b60d942e076923aca425c0e1aeff1993c9c59421f5569f09aabf5b33e169d10e8eda3c578d6a0818f41daf6896bfffb0c363b2558f2ed63ca0e08c106c5614fee97d7dc63f7234d8064fc57d901699ec95a051cb94eecccf112671404ab210b612f3b5205623fe304f86027724094f0b925496c4d1057e56f32d4ded8f6dfc2c3e46fb6eca2cc924eee2ee3a671360020ea77310fbf3f13d4780fc74ae76bcfea3bacb090a2deff2543a46a95d86707ab63c8eace65e356c0661862338a5523debe038792d9bf5e255df2fea7f8ca4a237a96a3cb7ce1e2f7ef5d5e17b03411f4a29bc441716c61c17b0555309759d402ee708600bb64f9daac11e226e89e76fd0de0e8c8203e79fae8c14824908f697ff09e1f1f687dc4e878a9c5e37370ba4b0695c904daa4c1db4f9f166744c266469063d32a2bf2d5dd9fca09dd0fc013c902ec879fff6871b459ea74c4ab26d06e6bc52f6819e4becafa1655f163bb4e6389ea80d52db922ccf135171e73c054c60fff0670477c057ca9247b93937d28db2a0209197538cc549ecf2db9bf48587052d86728960165998ae01131fb3896c4194b49fecbbe4b3f2dd041ede6c883fae8dd5a8708a80e381c7d4','984313ce106178c8374d374f869e3464dbbe9ca36de88bea87530449bbfbab3d','admin@email.com','en');


/*!40000 ALTER TABLE `site_user` ENABLE KEYS */;
UNLOCK TABLES;

/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
