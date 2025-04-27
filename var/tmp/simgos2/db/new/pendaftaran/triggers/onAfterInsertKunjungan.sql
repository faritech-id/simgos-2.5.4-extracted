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

-- membuang struktur untuk trigger pendaftaran.onAfterInsertKunjungan
DROP TRIGGER IF EXISTS `onAfterInsertKunjungan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onAfterInsertKunjungan` AFTER INSERT ON `kunjungan` FOR EACH ROW BEGIN
	UPDATE pendaftaran.tujuan_pasien 
	   SET STATUS = 2
	 WHERE NOPEN = NEW.NOPEN
	   AND RUANGAN = NEW.RUANGAN
		AND STATUS = 1;
	
	IF NEW.RUANG_KAMAR_TIDUR > 0 THEN
		UPDATE master.ruang_kamar_tidur SET STATUS = 3 WHERE ID = NEW.RUANG_KAMAR_TIDUR;
	END IF;
		
	IF NOT NEW.REF IS NULL THEN
	BEGIN
		DECLARE VID VARCHAR(2);
		
		SET VID = LEFT(NEW.REF, 2);
		
		CASE VID
			WHEN '10' THEN
				UPDATE pendaftaran.konsul
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
			 WHEN '11' THEN 
				UPDATE pendaftaran.mutasi
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
			WHEN '12' THEN
				UPDATE layanan.order_lab
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
				   
				CALL layanan.storeOrderLabDiTindakan(NEW.REF, NEW.DITERIMA_OLEH);
			WHEN '13' THEN
				UPDATE layanan.order_rad
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
				   
				CALL layanan.storeOrderRadDiTindakan(NEW.REF, NEW.DITERIMA_OLEH);
			WHEN '14' THEN
				UPDATE layanan.order_resep
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
				   
				CALL layanan.storeOrderResepDiFarmasi(NEW.REF, NEW.DITERIMA_OLEH);
		END CASE;
	END;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
