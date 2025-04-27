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


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.getPersentaseDiagnosaKeperawatan
DROP PROCEDURE IF EXISTS `getPersentaseDiagnosaKeperawatan`;
DELIMITER //
CREATE PROCEDURE `getPersentaseDiagnosaKeperawatan`(
	IN `PSUBJECT` TEXT,
	IN `POBJECT` TEXT
)
BEGIN
	DECLARE VCONIND TEXT;
	DECLARE VIN TEXT;
	
	SET VIN = IF(PSUBJECT != '' AND POBJECT != '', CONCAT('AND (
		(a.JENIS = 1 AND a.INDIKATOR IN(',PSUBJECT,')) 
		OR 
		(a.JENIS = 2 AND a.INDIKATOR IN(',POBJECT,')))'),
		IF(PSUBJECT != '', CONCAT(' AND (a.JENIS = 1 AND a.INDIKATOR IN(',PSUBJECT,')) '), IF(POBJECT != '', CONCAT(' AND (a.JENIS = 2 AND a.INDIKATOR IN(',POBJECT,'))'), '') ) 
	);
	
	SET VCONIND = IF(PSUBJECT != '' AND POBJECT != '', CONCAT(PSUBJECT, ', ',POBJECT), IF(PSUBJECT != '', PSUBJECT, IF(POBJECT != '', POBJECT, '')));
	
	SET @sqlText = CONCAT('SELECT dk.*,  ROUND((diagnosa.JMLIND / COUNT(*)) * 100, 2) AS PERSENTASE 
	FROM( 
		SELECT 
			a.DIAGNOSA 
			, a.INDIKATOR
			, IF(a.INDIKATOR IN (',VCONIND,'), SUM(1), 0) JMLIND 
		FROM medicalrecord.mapping_diagnosa_indikator a
		WHERE a.`STATUS` = 1 ',VIN,'
		GROUP BY a.DIAGNOSA
	) diagnosa
	LEFT JOIN medicalrecord.mapping_diagnosa_indikator b ON b.DIAGNOSA = diagnosa.DIAGNOSA
	LEFT JOIN medicalrecord.diagnosa_keperawatan dk ON dk.ID = diagnosa.DIAGNOSA 
	WHERE b.JENIS IN (1, 2) AND b.`STATUS` = 1 GROUP BY b.DIAGNOSA');
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt; 
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
