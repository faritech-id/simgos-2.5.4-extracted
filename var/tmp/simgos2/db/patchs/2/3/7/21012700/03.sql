-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.22 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk kemkes
USE `kemkes`;

-- membuang struktur untuk procedure kemkes.updateKamarSIMRSOnline
DROP PROCEDURE IF EXISTS `updateKamarSIMRSOnline`;
DELIMITER //
CREATE PROCEDURE `updateKamarSIMRSOnline`()
BEGIN
	# Insert jika belum terdaftar
	INSERT INTO kemkes.kamar_simrs_rs_online(ruang_kamar)
	SELECT rk.ID
	  FROM `master`.ruang_kamar rk       
	       LEFT JOIN kemkes.kamar_simrs_rs_online k ON k.ruang_kamar = rk.ID,
	       `master`.ruangan r
	 WHERE rk.`STATUS` = 1
	   AND k.id IS NULL
	   AND r.ID = rk.RUANGAN
	   AND r.JENIS_KUNJUNGAN = 3
	   AND r.JENIS = 5;
	   
	# Non aktifkan jika ruang kamar simrs non aktif
	UPDATE `master`.ruang_kamar rk,
	       kemkes.kamar_simrs_rs_online k
	   SET k.`status` = 0
	 WHERE k.ruang_kamar = rk.ID
	   AND k.`status` = 1
	   AND rk.`STATUS` = 0;
	   
	# Aktifkan jika ruang kamar simrs aktif
	UPDATE `master`.ruang_kamar rk,
	       kemkes.kamar_simrs_rs_online k
	   SET k.`status` = 1
	 WHERE k.ruang_kamar = rk.ID
	   AND k.`status` = 0
	   AND rk.`STATUS` = 1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
