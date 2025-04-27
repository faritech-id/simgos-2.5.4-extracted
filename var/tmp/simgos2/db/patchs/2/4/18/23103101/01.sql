-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
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

-- Dumping structure for procedure medicalrecord.getTotalBallancerCairan
DROP PROCEDURE IF EXISTS `getTotalBallancerCairan`;
DELIMITER //
CREATE PROCEDURE `getTotalBallancerCairan`(
	IN `PNOPEN` CHAR(15)
)
BEGIN
	DECLARE THARIINI, TNOPEN DECIMAL(10,2);
	SELECT 
		IFNULL(SUM(pbc.SKOR_BALLANCER_CAIRAN), 0) 
	INTO 
		THARIINI
	FROM medicalrecord.penilaian_ballance_cairan pbc
	LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = pbc.KUNJUNGAN
	WHERE DATE(pbc.WAKTU_PEMERIKSAAN) = DATE(NOW()) 
		AND k.NOPEN = PNOPEN
		AND pbc.`STATUS` = 1;
	
	SELECT 
		IFNULL(SUM(pbc.SKOR_BALLANCER_CAIRAN), 0) 
	INTO
		TNOPEN
	FROM medicalrecord.penilaian_ballance_cairan pbc
	LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = pbc.KUNJUNGAN
	WHERE k.NOPEN = PNOPEN 
		AND pbc.`STATUS` = 1;
	
	SELECT THARIINI HARI_INI, TNOPEN SELAMA_DIRAWAT;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
