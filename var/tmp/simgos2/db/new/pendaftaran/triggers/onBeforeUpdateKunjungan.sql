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

-- membuang struktur untuk trigger pendaftaran.onBeforeUpdateKunjungan
DROP TRIGGER IF EXISTS `onBeforeUpdateKunjungan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onBeforeUpdateKunjungan` BEFORE UPDATE ON `kunjungan` FOR EACH ROW BEGIN
	IF NEW.STATUS = 2 THEN
		IF NEW.KELUAR IS NULL THEN
		BEGIN			
			DECLARE VMASUK DATETIME;
			
			SET NEW.KELUAR = NOW();
			
			
			SELECT k.MASUK INTO VMASUK
			  FROM pendaftaran.mutasi m, pendaftaran.kunjungan k
			 WHERE m.KUNJUNGAN = OLD.NOMOR
			   AND m.STATUS = 2
				AND k.REF = m.NOMOR;
				
			IF FOUND_ROWS() > 0 THEN
				SET NEW.KELUAR = SUBTIME(VMASUK, '00:00:01');
			END IF;
		END;
		END IF;
	ELSE
		IF OLD.STATUS != NEW.STATUS AND OLD.STATUS = 2 AND NEW.STATUS = 1 THEN
			IF EXISTS(SELECT 1 FROM pembatalan.pembatalan_kunjungan WHERE KUNJUNGAN = OLD.NOMOR AND JENIS = 2 AND STATUS = 1) THEN
				SET NEW.KELUAR = NULL;				
		
				IF NEW.RUANG_KAMAR_TIDUR > 0 AND EXISTS(SELECT 1 FROM layanan.pasien_pulang WHERE KUNJUNGAN = OLD.NOMOR AND STATUS = 1) THEN
					UPDATE layanan.pasien_pulang
					   SET STATUS = 0
					 WHERE KUNJUNGAN = OLD.NOMOR;
				END IF;
		
				UPDATE pembatalan.pembatalan_kunjungan
				   SET STATUS = 2
				 WHERE KUNJUNGAN = OLD.NOMOR
				   AND JENIS = 2
				   AND STATUS = 1;
			ELSE
				UPDATE pembatalan.pembatalan_kunjungan
				   SET STATUS = 2
				 WHERE KUNJUNGAN = OLD.NOMOR
				   AND JENIS = 1
				   AND STATUS = 1;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
