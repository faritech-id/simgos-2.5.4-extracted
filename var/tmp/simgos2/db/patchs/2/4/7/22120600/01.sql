-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
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

-- membuang struktur untuk procedure pembayaran.batalkanStoreFarmasi
DROP PROCEDURE IF EXISTS `batalkanStoreFarmasi`;
DELIMITER //
CREATE PROCEDURE `batalkanStoreFarmasi`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PLAYANAN_FARMASI` CHAR(11),
	IN `PFARMASI` SMALLINT,
	IN `PJUMLAH` DECIMAL(60,2)
)
BEGIN
	DECLARE VNOPEN, VRUANGAN CHAR(10);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2) DEFAULT 0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VTANGGAL DATETIME;

	SELECT k.NOPEN, p.PAKET, k.MASUK, k.RUANGAN
	  INTO VNOPEN, VPAKET, VTANGGAL, VRUANGAN
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
				CALL master.inPaket(VPAKET, 2, PFARMASI, VRUANGAN, VQTY, VPAKET_DETIL);
				
				
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

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
