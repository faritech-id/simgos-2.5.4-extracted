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
-- Dumping structure for table kemkes-ihs.specimen
CREATE TABLE IF NOT EXISTS `specimen` (
  `id` char(36) DEFAULT NULL,
  `identifier` json DEFAULT NULL COMMENT 'code_reference = 50',
  `accesssionIdentifier` json DEFAULT NULL,
  `status` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'type_code_reference type = 51',
  `type` json NOT NULL,
  `subject` json NOT NULL COMMENT 'kemkes-ihs patient',
  `receivedTime` varchar(30) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL DEFAULT '' COMMENT 'layanan.tindakan_medis TANGGAL',
  `parent` json DEFAULT NULL,
  `request` json DEFAULT NULL COMMENT 'kemkes-ihs.service_request id',
  `collection` tinyint DEFAULT NULL,
  `processing` varchar(150) DEFAULT NULL,
  `container` json DEFAULT NULL,
  `condition` json DEFAULT NULL,
  `note` json DEFAULT NULL,
  `refId` char(11) NOT NULL,
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
