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

-- Dumping structure for table kemkes-ihs.medication_dispanse
CREATE TABLE IF NOT EXISTS `medication_dispanse` (
  `id` char(36) DEFAULT NULL,
  `identifier` json DEFAULT NULL,
  `partOf` json DEFAULT NULL,
  `status` varchar(150) NOT NULL,
  `category` json DEFAULT NULL,
  `medicationReference` json DEFAULT NULL,
  `subject` json DEFAULT NULL,
  `context` json DEFAULT NULL,
  `performer` json DEFAULT NULL,
  `location` json DEFAULT NULL,
  `authorizingPrescription` json DEFAULT NULL,
  `quantity` json DEFAULT NULL,
  `daysSupply` json DEFAULT NULL,
  `whenPrepared` varchar(50) NOT NULL,
  `whenHandedOver` varchar(50) NOT NULL,
  `dosageInstruction` json DEFAULT NULL,
  `substitution` json DEFAULT NULL,
  `refId` char(21) NOT NULL COMMENT 'id table farmasi',
  `barang` int NOT NULL DEFAULT '0',
  `group_racikan` tinyint NOT NULL DEFAULT '0',
  `nopen` char(10) NOT NULL,
  `status_racikan` tinyint(1) NOT NULL DEFAULT '0',
  `sendDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `send` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`refId`,`barang`,`group_racikan`),
  KEY `id` (`id`),
  KEY `nopen` (`nopen`),
  KEY `send` (`send`),
  KEY `status_racikan` (`status_racikan`)
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
