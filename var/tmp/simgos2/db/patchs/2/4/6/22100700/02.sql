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
-- Dumping structure for table kemkes-ihs.organization
CREATE TABLE IF NOT EXISTS `organization` (
  `id` char(36) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `identifier` json DEFAULT NULL,
  `active` tinyint NOT NULL DEFAULT '1' COMMENT '1 true 0 false',
  `type` json DEFAULT NULL,
  `name` varchar(150) NOT NULL,
  `alias` char(50) NOT NULL DEFAULT '',
  `telecom` json DEFAULT NULL,
  `address` json DEFAULT NULL,
  `partOf` json DEFAULT NULL,
  `refId` char(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Id Ruangan',
  `sendDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `flag` tinyint NOT NULL DEFAULT '0',
  `send` tinyint NOT NULL DEFAULT '1' COMMENT '1 kirim 0 tidak dikirm',
  UNIQUE KEY `refid` (`refId`) USING BTREE,
  KEY `id` (`id`),
  KEY `kirim` (`send`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
