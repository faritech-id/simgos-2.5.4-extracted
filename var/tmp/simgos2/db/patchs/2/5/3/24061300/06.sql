-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.6.0.6765
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for kemkes-ihs
USE `kemkes-ihs`;

-- Dumping structure for table kemkes-ihs.allergy_intolerance
CREATE TABLE IF NOT EXISTS `allergy_intolerance` (
  `id` char(36) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `identifier` json DEFAULT NULL,
  `clinicalStatus` json DEFAULT NULL,
  `verificationStatus` json DEFAULT NULL,
  `category` json DEFAULT NULL,
  `code` json DEFAULT NULL,
  `patient` json DEFAULT NULL,
  `encounter` json DEFAULT NULL,
  `recordedDate` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `recorder` json DEFAULT NULL,
  `refId` int NOT NULL,
  `nopen` char(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `sendDate` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `send` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`refId`) USING BTREE,
  KEY `id` (`id`) USING BTREE,
  KEY `nopen` (`nopen`) USING BTREE,
  KEY `send` (`send`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
