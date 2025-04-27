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

USE `informasi`;

-- membuang struktur untuk procedure informasi.executeTempatTidurDipesanTapiDigunakan
DROP PROCEDURE IF EXISTS `executeTempatTidurDipesanTapiDigunakan`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `executeTempatTidurDipesanTapiDigunakan`()
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_TEMPAT_TIDUR_DIPESAN;

	CREATE TEMPORARY TABLE TEMP_TEMPAT_TIDUR_DIPESAN ENGINE = MEMORY
	SELECT rkt.ID, r.NOMOR
	  FROM master.ruang_kamar_tidur rkt
	  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.`STATUS` = 1
	 WHERE NOT rkt.`STATUS` IN (0)
	   AND rkt.`STATUS` = 2
	   AND INSTR(r.ATAS_NAMA, ' - ') > 0
		AND TIMEDIFF(NOW(), r.TANGGAL) > '00:59:59';
	
	# Bed yang sudah di pesan lewat pendaftaran & mutasu tetapi tidak digunakan dalam waktu 1 jam maka akan dibatalkan
	UPDATE pendaftaran.reservasi r, TEMP_TEMPAT_TIDUR_DIPESAN ttt
	   SET r.`STATUS` = 0
	 WHERE r.NOMOR = ttt.NOMOR
	   AND r.`STATUS` = 1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
