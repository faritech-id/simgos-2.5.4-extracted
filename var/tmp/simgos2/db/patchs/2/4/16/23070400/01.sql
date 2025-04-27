-- --------------------------------------------------------
-- Host:                         192.168.XXX.XXX
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.storePenjaminTagihan
DROP PROCEDURE IF EXISTS `storePenjaminTagihan`;
DELIMITER //
CREATE PROCEDURE `storePenjaminTagihan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PPENJAMIN` SMALLINT,
	IN `PKELAS_KLAIM` TINYINT
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM pembayaran.penjamin_tagihan WHERE TAGIHAN = PTAGIHAN AND PENJAMIN = PPENJAMIN) THEN
	BEGIN
		DECLARE VKE SMALLINT;
		DECLARE VTOTAL DECIMAL(60,2);
		
		SELECT TOTAL
		  INTO VTOTAL
		  FROM pembayaran.tagihan t
		 WHERE t.ID = PTAGIHAN
		 LIMIT 1;
		
		SELECT MAX(KE) + 1 INTO VKE 
		  FROM pembayaran.penjamin_tagihan 
		 WHERE TAGIHAN = PTAGIHAN;
		 
		IF VKE IS NULL || FOUND_ROWS() = 0 THEN
			SET VKE = 1;
		ELSE
			SET VTOTAL = 0;
		END IF;
		
		INSERT INTO pembayaran.penjamin_tagihan(TAGIHAN, PENJAMIN, KE, KELAS_KLAIM, TOTAL)
		VALUES(PTAGIHAN, PPENJAMIN, VKE, PKELAS_KLAIM, VTOTAL);
	END;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
