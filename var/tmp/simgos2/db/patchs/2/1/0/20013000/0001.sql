-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk informasi
USE `informasi`;

-- membuang struktur untuk procedure informasi.executeTempatTidurTerisiTapiKosong
DROP PROCEDURE IF EXISTS `executeTempatTidurTerisiTapiKosong`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `executeTempatTidurTerisiTapiKosong`()
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_TEMPAT_TIDUR;

	CREATE TEMPORARY TABLE TEMP_TEMPAT_TIDUR ENGINE = MEMORY
	SELECT rkt.ID
	  FROM master.ruang_kamar_tidur rkt
	  		 LEFT JOIN pendaftaran.kunjungan k ON k.RUANG_KAMAR_TIDUR = rkt.ID AND k.STATUS = 1
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = k.NOPEN
	  		 LEFT JOIN master.pasien ps ON ps.NORM = p.NORM  		 
	 WHERE NOT rkt.`STATUS` IN (0)
	   AND rkt.`STATUS` = 3
	   AND pendaftaran.ikutRawatInapIbu(k.NOPEN, k.REF) = 0
	   AND k.KELUAR IS NULL
		AND ps.NORM IS NULL;
		
	UPDATE master.ruang_kamar_tidur rkt, TEMP_TEMPAT_TIDUR ttt
	   SET rkt.`STATUS` = 1
	 WHERE rkt.ID = ttt.ID
	   AND rkt.`STATUS` = 3;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
