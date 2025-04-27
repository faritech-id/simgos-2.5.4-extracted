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
-- Dumping structure for table kemkes-ihs.code_reference
CREATE TABLE IF NOT EXISTS `code_reference` (
  `id` int NOT NULL AUTO_INCREMENT,
  `resources` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
  `entity` varchar(150) NOT NULL,
  `system` varchar(150) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `status` (`status`),
  KEY `resources` (`resources`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;

-- Dumping data for table kemkes-ihs.code_reference: ~8 rows (approximately)
/*!40000 ALTER TABLE `code_reference` DISABLE KEYS */;
INSERT INTO `code_reference` (`id`, `resources`, `entity`, `system`, `status`) VALUES
	(1, 'Encounter', 'class', 'http://terminology.hl7.org/CodeSystem/v3-ActCode', 1),
	(2, 'Encounter', 'participan', 'http://terminology.hl7.org/CodeSystem/v3-ParticipationType', 1),
	(3, 'Encounter', 'identifier', 'https://sys-ids.kemkes.go.id/encounter', 1),
	(4, 'Encounter', 'diagnosis.use', 'https://terminology.hl7.org/CodeSystem/diagnosis-role', 1),
	(5, 'Condition', 'category', 'http://terminology.hl7.org/CodeSystem/condition-category', 1),
	(6, 'Condition', 'code', 'http://hl7.org/fhir/sid/icd-10', 1),
	(7, 'Condition', 'clinicalStatus', 'http://terminology.hl7.org/CodeSystem/condition-clinical', 1),
	(8, 'Organization', 'type', 'http://terminology.hl7.org/CodeSystem/organization-type', 1),
	(9, 'Observation', 'category', 'http://terminology.hl7.org/CodeSystem/observation-category', 1),
	(10, 'Observation', 'code', 'http://loinc.org', 1);
/*!40000 ALTER TABLE `code_reference` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
