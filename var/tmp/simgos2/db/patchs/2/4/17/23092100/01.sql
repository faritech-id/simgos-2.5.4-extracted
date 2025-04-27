-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
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

-- membuang struktur untuk event pembayaran.onStoreRincianTagihan
DROP EVENT IF EXISTS `onStoreRincianTagihan`;
DELIMITER //
CREATE EVENT `onStoreRincianTagihan` ON SCHEDULE EVERY 15 MINUTE STARTS '2015-11-19 14:11:23' ON COMPLETION PRESERVE ENABLE DO BEGIN
	
	BEGIN
		DECLARE VNOMOR CHAR(19);
		DECLARE AKOMODASI_NOT_FOUND TINYINT DEFAULT FALSE;
		DECLARE CR_AKOMODASI CURSOR FOR
			SELECT NOMOR
			  FROM pendaftaran.kunjungan
			 WHERE STATUS = 1
			   AND KELUAR IS NULL
			   AND RUANG_KAMAR_TIDUR > 0
			   AND master.isRawatInap(RUANGAN) = 1;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET AKOMODASI_NOT_FOUND = TRUE;
		
		OPEN CR_AKOMODASI;
		EOF: LOOP
			FETCH CR_AKOMODASI INTO VNOMOR;
			
			IF AKOMODASI_NOT_FOUND THEN
				UPDATE temp.temp SET ID = 0 WHERE ID = 0;
				LEAVE EOF;
			END IF;
			
			CALL pembayaran.storeAkomodasi(VNOMOR);
		END LOOP;
		CLOSE CR_AKOMODASI;
	END;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
