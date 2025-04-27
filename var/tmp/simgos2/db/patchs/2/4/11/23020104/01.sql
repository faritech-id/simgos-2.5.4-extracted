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

-- Membuang struktur basisdata untuk cetakan
USE `cetakan`;

-- membuang struktur untuk trigger cetakan.onAfterInsertKarcisPasien
DROP TRIGGER IF EXISTS `onAfterInsertKarcisPasien`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertKarcisPasien` AFTER INSERT ON `karcis_pasien` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VTANGGAL DATETIME;
	
	SELECT p.TANGGAL INTO VTANGGAL
	  FROM pendaftaran.pendaftaran p
	 WHERE p.NOMOR = PNOPEN;
	 
	IF NOT VTANGGAL IS NULL THEN
		SET VTAGIHAN = pembayaran.getIdTagihan(NEW.NOPEN);
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			CALL pembayaran.storeAdministrasiKarcis(NEW.NOPEN, NEW.ID, NEW.JENIS, VTAGIHAN);
		
			INSERT INTO aplikasi.automaticexecute(PERINTAH)
				VALUES(CONCAT("CALL pendaftaran.updateTanggalAdministrasiDanTagihan('", VTAGIHAN, "', '", VTANGGAL, "')"));
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
