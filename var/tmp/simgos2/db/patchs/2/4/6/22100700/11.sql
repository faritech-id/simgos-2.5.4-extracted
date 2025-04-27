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
-- Dumping structure for table kemkes-ihs.type_code_reference
CREATE TABLE IF NOT EXISTS `type_code_reference` (
  `type` int NOT NULL COMMENT 'id code refernce',
  `id` smallint NOT NULL DEFAULT '0',
  `code` char(50) NOT NULL DEFAULT '',
  `display` varchar(200) NOT NULL DEFAULT '',
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`type`,`id`),
  KEY `status` (`status`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table kemkes-ihs.type_code_reference: 19 rows
/*!40000 ALTER TABLE `type_code_reference` DISABLE KEYS */;
INSERT INTO `type_code_reference` (`type`, `id`, `code`, `display`, `status`) VALUES
	(1, 1, 'AMB', 'Ambulatory', 1),
	(1, 2, 'VR', 'Virtual', 1),
	(2, 1, 'ATND', 'attender', 1),
	(7, 1, 'active', 'Active', 1),
	(5, 1, 'encounter-diagnosis', 'Encounter Diagnosis', 1),
	(5, 2, 'problem-list-item', 'Problem List Item', 1),
	(4, 1, 'DD', 'Discharge diagnosis', 1),
	(8, 1, 'prov', 'Healthcare Provider', 1),
	(8, 2, 'dept', 'Hospital Department', 1),
	(8, 3, 'team', 'Organizational team', 1),
	(8, 4, 'govt', 'Government', 1),
	(8, 5, 'ins', 'Insurance Company\r\n', 1),
	(8, 6, 'pay', 'Payer\r\n', 1),
	(8, 7, 'edu', 'Educational Institute\r\n', 1),
	(8, 8, 'reli', 'Religious Institution\r\n', 1),
	(8, 9, 'crs', 'Clinical Research Sponsor\r\n', 1),
	(8, 10, 'cg', 'Community Group\r\n', 1),
	(8, 11, 'bus', 'Non-Healthcare Business or Corporation\r\n', 1),
	(8, 12, 'other', 'Other\r\n', 1),
	(9, 1, 'vital-signs', 'Vital Signs', 1),
	(10, 1, '8867-4', 'Heart rate', 1),
	(10, 2, '9279-1', 'Respiratory rate', 1),
	(10, 3, '8480-6', 'Systolic blood pressure', 1),
	(10, 4, '8462-4', 'Diastolic blood pressure', 1),
	(10, 5, '8310-5', 'Body temperature', 1);
/*!40000 ALTER TABLE `type_code_reference` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
