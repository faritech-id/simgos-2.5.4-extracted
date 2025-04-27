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

-- membuang struktur untuk procedure pembayaran.storePenjaminTagihan
DROP PROCEDURE IF EXISTS `storePenjaminTagihan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storePenjaminTagihan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PPENJAMIN` SMALLINT,
	IN `PKELAS_KLAIM` TINYINT)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM pembayaran.penjamin_tagihan WHERE TAGIHAN = PTAGIHAN AND PENJAMIN = PPENJAMIN) THEN
	BEGIN
		DECLARE VKE SMALLINT;
		
		SELECT MAX(KE) + 1 INTO VKE 
		  FROM pembayaran.penjamin_tagihan 
		 WHERE TAGIHAN = PTAGIHAN;
		 
		IF VKE IS NULL || FOUND_ROWS() = 0 THEN
			SET VKE = 1;
		END IF;
		
		INSERT INTO pembayaran.penjamin_tagihan(TAGIHAN, PENJAMIN, KE, KELAS_KLAIM)
		VALUES(PTAGIHAN, PPENJAMIN, VKE, PKELAS_KLAIM);
	END;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
