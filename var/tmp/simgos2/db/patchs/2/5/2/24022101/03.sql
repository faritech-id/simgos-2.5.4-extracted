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

-- Dumping structure for procedure medicalrecord.grafikTandaVital
DROP PROCEDURE IF EXISTS `grafikTandaVital`;
DELIMITER //
CREATE PROCEDURE `grafikTandaVital`(
	IN `PJENIS` INT,
	IN `PTANGGAL_AWAL` DATE,
	IN `PTANGGAL_AKHIR` DATE,
	IN `PNORM` INT,
	IN `PK_AWAL` CHAR(20),
	IN `PK_AKHIR` CHAR(20)
)
BEGIN
	SELECT 
	* 
	FROM(
		SELECT 
		 tv.WAKTU_PEMERIKSAAN
		 , DATE_FORMAT(tv.WAKTU_PEMERIKSAAN, '%Y-%m-%d %H:00') JAM
		 , tv.SISTOLIK
		 , tv.DISTOLIK
		 , tv.FREKUENSI_NADI
		 , tv.FREKUENSI_NAFAS
		 , tv.SUHU
		 , tv.SATURASI_O2
		 , tv.EYE
		 , tv.MOTORIK
		 , tv.VERBAL
		 , tv.GCS
		 , tv.EWSS
		FROM medicalrecord.tanda_vital tv
		LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = tv.KUNJUNGAN
		LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = k.NOPEN
		WHERE tv.`STATUS` = 1
		AND pen.NORM = PNORM AND
		IF(PJENIS = 1, tv.WAKTU_PEMERIKSAAN BETWEEN CONCAT(PTANGGAL_AWAL,' 00:00:00') AND CONCAT(PTANGGAL_AKHIR ,' 23:59:59')
		, tv.KUNJUNGAN IN(PK_AWAL, PK_AKHIR)
		)
		ORDER BY tv.WAKTU_PEMERIKSAAN DESC
	) ttd GROUP BY JAM ORDER BY ttd.WAKTU_PEMERIKSAAN ASC;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
