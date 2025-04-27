USE `layanan`;
-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure layanan.executeBatalOrderResep
DROP PROCEDURE IF EXISTS `executeBatalOrderResep`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executeBatalOrderResep`(IN `PTANGGAL` DATETIME)
BEGIN
	/*
	UPDATE layanan.order_resep o, pendaftaran.kunjungan k, master.ruangan r
	SET o.`STATUS` = 0
	WHERE r.ID = k.RUANGAN AND r.JENIS_KUNJUNGAN = 1 AND k.NOMOR = o.KUNJUNGAN AND o.`STATUS` = 1 AND o.TANGGAL < PTANGGAL;
	*/
	UPDATE layanan.order_resep o
	SET o.`STATUS` = 0
	WHERE o.`STATUS` = 1 AND o.TANGGAL < PTANGGAL;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;