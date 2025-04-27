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


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for procedure medicalrecord.grafikSkalaNyeri
DROP PROCEDURE IF EXISTS `grafikSkalaNyeri`;
DELIMITER //
CREATE PROCEDURE `grafikSkalaNyeri`(
	IN `PJENIS` INT,
	IN `PTANGGAL` DATE,
	IN `PNORM` INT,
	IN `PK_AWAL` CHAR(20),
	IN `PK_AKHIR` CHAR(20)
)
BEGIN
	SELECT 
	* 
	FROM(
		SELECT 
		 py.TANGGAL WAKTU_PEMERIKSAAN
		 , DATE_FORMAT(py.TANGGAL, '%H:00') JAM
		 , py.SKALA
		FROM medicalrecord.penilaian_nyeri py
		LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = py.KUNJUNGAN
		LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = k.NOPEN
		WHERE py.`STATUS` = 1
		AND pen.NORM = PNORM AND
		IF(PJENIS = 1, py.TANGGAL BETWEEN CONCAT(PTANGGAL,' 00:00:00') AND CONCAT(PTANGGAL,' 23:59:59')
		, py.KUNJUNGAN IN(PK_AWAL, PK_AKHIR)
		)
		ORDER BY py.TANGGAL DESC
	) ttd GROUP BY JAM ;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
