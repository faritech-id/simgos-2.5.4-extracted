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

-- Dumping structure for table kemkes-ihs.medication_request
CREATE TABLE IF NOT EXISTS `medication_request` (
  `id` char(36) DEFAULT NULL,
  `identifier` json DEFAULT NULL,
  `status` varchar(150) NOT NULL,
  `statusReason` json DEFAULT NULL,
  `intent` varchar(150) NOT NULL,
  `category` json DEFAULT NULL,
  `priority` varchar(150) NOT NULL,
  `reportedBoolean` tinyint NOT NULL DEFAULT '1' COMMENT '1 : true, 2 : false',
  `medicationReference` json DEFAULT NULL,
  `subject` json DEFAULT NULL,
  `encounter` json DEFAULT NULL,
  `authoredOn` varchar(150) NOT NULL,
  `requester` json DEFAULT NULL,
  `performer` json DEFAULT NULL,
  `performerType` json DEFAULT NULL,
  `recorder` json DEFAULT NULL,
  `reasonCode` json DEFAULT NULL,
  `reasonReference` json DEFAULT NULL,
  `basedOn` json DEFAULT NULL,
  `courseOfTherapyType` json DEFAULT NULL,
  `insurance` json DEFAULT NULL,
  `note` json DEFAULT NULL,
  `dosageInstruction` json DEFAULT NULL,
  `dispenseRequest` json DEFAULT NULL,
  `substitution` json DEFAULT NULL,
  `refId` char(21) NOT NULL,
  `barang` int NOT NULL DEFAULT '0',
  `group_racikan` tinyint NOT NULL DEFAULT '0',
  `nopen` char(10) NOT NULL,
  `status_racikan` tinyint(1) NOT NULL DEFAULT '0',
  `sendDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `send` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`refId`,`barang`,`group_racikan`),
  KEY `id` (`id`),
  KEY `send` (`send`),
  KEY `nopen` (`nopen`),
  KEY `status_racikan` (`status_racikan`)
) ENGINE=InnoDB;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
