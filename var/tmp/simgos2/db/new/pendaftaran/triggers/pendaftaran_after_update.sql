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

-- membuang struktur untuk trigger pendaftaran.pendaftaran_after_update
DROP TRIGGER IF EXISTS `pendaftaran_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `pendaftaran_after_update` AFTER UPDATE ON `pendaftaran` FOR EACH ROW BEGIN
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
		
		UPDATE pendaftaran.tujuan_pasien
		   SET STATUS = 0
		 WHERE NOPEN = OLD.NOMOR
	      AND STATUS = 1;
	      
	   
	  UPDATE pendaftaran.reservasi r
	      SET r.STATUS = 0
	    WHERE EXISTS(SELECT 1 FROM pendaftaran.tujuan_pasien tp WHERE tp.NOPEN = OLD.NOMOR AND tp.RESERVASI = r.NOMOR);
			     
	   UPDATE pembayaran.tagihan_pendaftaran
	      SET STATUS = 0
	    WHERE PENDAFTARAN = OLD.NOMOR
	      AND STATUS = 1;
	END IF;
	
	IF NEW.PAKET != OLD.PAKET OR (NEW.PAKET IS NULL AND NOT OLD.PAKET IS NULL) OR (NOT NEW.PAKET IS NULL AND OLD.PAKET IS NULL) THEN
	BEGIN
		DECLARE VTAGIHAN CHAR(10);
		SET VTAGIHAN = pembayaran.getIdTagihan(OLD.NOMOR);
		IF VTAGIHAN != '' THEN
			CALL pembayaran.reStoreTagihan(VTAGIHAN);
		END IF;
	END;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
