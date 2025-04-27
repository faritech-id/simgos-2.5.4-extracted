-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
USE `kemkes-ihs`;
-- Dumping structure for table kemkes-ihs.procedure
CREATE TABLE IF NOT EXISTS `procedure` (
  `id` char(36) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `identifier` json DEFAULT NULL,
  `basedOn` json DEFAULT NULL,
  `partOf` json DEFAULT NULL,
  `status` char(50) DEFAULT NULL,
  `statusReason` json DEFAULT NULL,
  `category` json DEFAULT NULL,
  `code` json DEFAULT NULL,
  `subject` json DEFAULT NULL,
  `encounter` json DEFAULT NULL,
  `performedPeriod` json DEFAULT NULL,
  `recorder` json DEFAULT NULL,
  `asserter` json DEFAULT NULL,
  `performer` json DEFAULT NULL,
  `location` json DEFAULT NULL,
  `reasonCode` json DEFAULT NULL,
  `reasonReference` json DEFAULT NULL,
  `bodySite` json DEFAULT NULL,
  `outcome` json DEFAULT NULL,
  `report` json DEFAULT NULL,
  `complicationDetail` json DEFAULT NULL,
  `followUp` json DEFAULT NULL,
  `note` json DEFAULT NULL,
  `focalDevice` json DEFAULT NULL,
  `usedReference` json DEFAULT NULL,
  `usedCode` json DEFAULT NULL,
  `refId` int NOT NULL,
  `nopen` char(10) NOT NULL DEFAULT '',
  `sendDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `send` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`refId`),
  KEY `id` (`id`),
  KEY `nopen` (`nopen`),
  KEY `send` (`send`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
