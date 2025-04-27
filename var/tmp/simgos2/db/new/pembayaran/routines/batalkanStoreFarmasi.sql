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

-- membuang struktur untuk procedure pembayaran.batalkanStoreFarmasi
DROP PROCEDURE IF EXISTS `batalkanStoreFarmasi`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `batalkanStoreFarmasi`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PLAYANAN_FARMASI` CHAR(11),
	IN `PFARMASI` SMALLINT,
	IN `PJUMLAH` DECIMAL(60,2)

)
BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2) DEFAULT 0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VTANGGAL DATETIME;

	SELECT k.NOPEN, p.PAKET, k.MASUK
	  INTO VNOPEN, VPAKET, VTANGGAL
	  FROM pendaftaran.kunjungan k	  		 
	  		 , pendaftaran.pendaftaran p
	 WHERE k.NOMOR = PKUNJUNGAN
		AND p.NOMOR = k.NOPEN
		AND k.`STATUS` = 1;
	
	IF FOUND_ROWS() > 0 THEN
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
		BEGIN			
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 2, PFARMASI, VQTY, VPAKET_DETIL);
				
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PLAYANAN_FARMASI, VTANGGAL, 0, 0);
				END IF;
			END IF;
			
			IF VTAGIHAN != '' THEN
				CALL pembayaran.batalRincianTagihan(VTAGIHAN, PLAYANAN_FARMASI, 4);
			END IF;
		END;
		END IF;	
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
