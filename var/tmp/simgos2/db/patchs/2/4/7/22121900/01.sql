-- --------------------------------------------------------
-- Host:                         192.168.137.8
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
-- Dumping structure for table kemkes-ihs.service_request
CREATE TABLE IF NOT EXISTS `service_request` (
  `id` char(36) DEFAULT NULL,
  `identifier` json DEFAULT NULL COMMENT 'code_reference = 45',
  `basedOn` json DEFAULT NULL,
  `replaces` json DEFAULT NULL,
  `requisition` json DEFAULT NULL,
  `status` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'code_reference = 46',
  `intent` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'code_reference = 47',
  `category` json DEFAULT NULL COMMENT 'code_reference = 48',
  `priority` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'code_reference = 49',
  `doNotPerform` tinyint(1) DEFAULT NULL,
  `code` json DEFAULT NULL,
  `orderDetail` json DEFAULT NULL,
  `quantity` json DEFAULT NULL,
  `subject` json DEFAULT NULL,
  `encounter` json DEFAULT NULL,
  `occurence` json DEFAULT NULL,
  `asNeeded` json DEFAULT NULL,
  `occurrenceDateTime` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '',
  `authoredOn` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT '',
  `requester` json DEFAULT NULL,
  `performerType` json DEFAULT NULL,
  `performer` json DEFAULT NULL,
  `locationCode` json DEFAULT NULL,
  `locationReference` json DEFAULT NULL,
  `reasonCode` json DEFAULT NULL,
  `reasonReference` json DEFAULT NULL,
  `insurance` json DEFAULT NULL,
  `supportingInfo` json DEFAULT NULL,
  `specimen` json DEFAULT NULL,
  `bodySite` json DEFAULT NULL,
  `note` json DEFAULT NULL,
  `patientInstruction` json DEFAULT NULL,
  `relevantHistory` json DEFAULT NULL,
  `refId` char(11) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `nopen` char(10) NOT NULL,
  `sendDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
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
