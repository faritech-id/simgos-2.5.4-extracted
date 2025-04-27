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

-- Dumping structure for table kemkes-ihs.composition
CREATE TABLE IF NOT EXISTS `composition` (
  `id` char(36) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `identifier` json DEFAULT NULL,
  `status` char(50) NOT NULL,
  `type` json DEFAULT NULL,
  `category` json DEFAULT NULL,
  `subject` json DEFAULT NULL,
  `encounter` json DEFAULT NULL,
  `date` varchar(50) DEFAULT NULL,
  `author` json DEFAULT NULL,
  `title` varchar(150) DEFAULT NULL,
  `confidentiality` json DEFAULT NULL,
  `attester` json DEFAULT NULL,
  `custodian` json DEFAULT NULL,
  `relatesTo` json DEFAULT NULL,
  `event` json DEFAULT NULL,
  `section` json DEFAULT NULL,
  `refId` int NOT NULL,
  `nopen` char(10) NOT NULL,
  `sendDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `send` tinyint(1) NOT NULL DEFAULT '1',
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
