-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk function pembayaran.getTanggalTerakhirPembayaran
DROP FUNCTION IF EXISTS `getTanggalTerakhirPembayaran`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getTanggalTerakhirPembayaran`(
	`PTAGIHAN` CHAR(10),
	`PJENIS` TINYINT
) RETURNS datetime
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	
	SELECT MAX(pt.TANGGAL) INTO VTANGGAL
	  FROM pembayaran.pembayaran_tagihan pt, pembayaran.pembatalan_tagihan pt1
	 WHERE pt.TAGIHAN = PTAGIHAN
	   AND pt.JENIS = PJENIS
		AND pt1.TAGIHAN = pt.TAGIHAN
		AND pt1.JENIS = 1
	   AND pt1.`STATUS` = 1;
	   
	RETURN VTANGGAL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
