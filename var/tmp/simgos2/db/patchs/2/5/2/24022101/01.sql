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

-- Dumping structure for procedure medicalrecord.grafikSkalaMorse
DROP PROCEDURE IF EXISTS `grafikSkalaMorse`;
DELIMITER //
CREATE PROCEDURE `grafikSkalaMorse`(
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
		 sm.TANGGAL WAKTU_PEMERIKSAAN
		 , DATE_FORMAT(sm.TANGGAL, '%Y-%m-%d %H:00') JAM
		 , IFNULL(rj.SCORING, 0) + 
		 IFNULL(dg.SCORING, 0) + 
		 IFNULL(ab.SCORING, 0) + 
		 IFNULL(hr.SCORING, 0) + 
		 IFNULL(gb.SCORING, 0) + 
		 IFNULL(ks.SCORING, 0) SKOR
		FROM medicalrecord.penilaian_skala_morse sm
		LEFT JOIN pendaftaran.kunjungan k ON k.NOMOR = sm.KUNJUNGAN
		LEFT JOIN `master`.referensi rj ON rj.ID = sm.RIWAYAT_JATUH AND rj.JENIS = 186
		LEFT JOIN `master`.referensi dg ON dg.ID = sm.DIAGNOSIS AND dg.JENIS = 187
		LEFT JOIN `master`.referensi ab ON ab.ID = sm.ALAT_BANTU AND ab.JENIS = 188
		LEFT JOIN `master`.referensi hr ON hr.ID = sm.HEPARIN AND hr.JENIS = 189
		LEFT JOIN `master`.referensi gb ON gb.ID = sm.GAYA_BERJALAN AND gb.JENIS = 190
		LEFT JOIN `master`.referensi ks ON ks.ID = sm.KESADARAN AND ks.JENIS = 191
		LEFT JOIN pendaftaran.pendaftaran pen ON pen.NOMOR = k.NOPEN
		WHERE sm.`STATUS` = 1
		AND pen.NORM = PNORM AND
		IF(PJENIS = 1, sm.TANGGAL BETWEEN CONCAT(PTANGGAL_AWAL,' 00:00:00') AND CONCAT(PTANGGAL_AKHIR,' 23:59:59')
		, sm.KUNJUNGAN IN(PK_AWAL, PK_AKHIR)
		)
		ORDER BY sm.TANGGAL DESC
	) ttd GROUP BY JAM ORDER BY ttd.WAKTU_PEMERIKSAAN ASC;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
