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

-- membuang struktur untuk trigger pendaftaran.tujuan_pasien_after_update
DROP TRIGGER IF EXISTS `tujuan_pasien_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tujuan_pasien_after_update` AFTER UPDATE ON `tujuan_pasien` FOR EACH ROW BEGIN
	DECLARE RKT INT;
	IF NOT OLD.RESERVASI IS NULL OR OLD.RESERVASI != '' THEN
		SELECT RUANG_KAMAR_TIDUR INTO RKT FROM pendaftaran.reservasi WHERE NOMOR = OLD.RESERVASI;
		
		IF FOUND_ROWS() > 0 THEN
			IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 0 THEN
				UPDATE master.ruang_kamar_tidur SET STATUS = 1 WHERE ID = RKT;
			END IF;
		END IF;
	END IF;
	
	
	IF NEW.STATUS != OLD.STATUS THEN
		
		UPDATE pendaftaran.antrian_ruangan
		   SET STATUS = NEW.STATUS
		 WHERE JENIS = 1
		   AND RUANGAN = OLD.RUANGAN
		   AND REF = OLD.NOPEN;
		
		UPDATE pendaftaran.panggilan_antrian_ruangan par
		   SET par.STATUS = NEW.STATUS
		 WHERE EXISTS(
				SELECT 1 
				  FROM pendaftaran.antrian_ruangan ar 
				 WHERE ar.JENIS = 1
		   	   AND ar.RUANGAN = OLD.RUANGAN
		   		AND ar.REF = OLD.NOPEN
					AND ar.ID = par.ANTRIAN_RUANGAN);		
	END IF;
	
	
	IF NEW.RUANGAN != OLD.RUANGAN THEN
		
		UPDATE pendaftaran.antrian_ruangan
		   SET STATUS = 0
		 WHERE JENIS = 1
		   AND RUANGAN = OLD.RUANGAN
		   AND REF = OLD.NOPEN;
		   
		INSERT INTO pendaftaran.antrian_ruangan(RUANGAN, JENIS, REF)
		VALUES(NEW.RUANGAN, 1, OLD.NOPEN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
