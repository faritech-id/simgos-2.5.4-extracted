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


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk function pembayaran.getIdTagihan
DROP FUNCTION IF EXISTS `getIdTagihan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getIdTagihan`(
	`PPENDAFTARAN` VARCHAR(150)
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VID CHAR(10);
	
	SELECT tp.TAGIHAN INTO VID 
	  FROM pembayaran.tagihan_pendaftaran tp,
	  		 pembayaran.tagihan t
	  		 LEFT JOIN pembayaran.gabung_tagihan gt ON gt.KE = t.ID
	 WHERE tp.PENDAFTARAN = PPENDAFTARAN
	   AND tp.STATUS = 1
		AND t.ID = tp.TAGIHAN
	 ORDER BY IFNULL(gt.TANGGAL, t.TANGGAL) DESC LIMIT 1;
	
	IF FOUND_ROWS() = 0 THEN
		RETURN '';
	END IF;
	
	RETURN VID;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
