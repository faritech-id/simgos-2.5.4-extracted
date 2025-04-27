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

-- membuang struktur untuk trigger layanan.petugas_tindakan_medis_after_insert
DROP TRIGGER IF EXISTS `petugas_tindakan_medis_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `petugas_tindakan_medis_after_insert` AFTER INSERT ON `petugas_tindakan_medis` FOR EACH ROW BEGIN
	DECLARE VKUNJUNGAN CHAR(19);				
	
	
	IF NEW.JENIS = 1 AND NEW.KE = 1 THEN
		
		SELECT tm.KUNJUNGAN INTO VKUNJUNGAN
		  FROM layanan.tindakan_medis tm,
		  		 pendaftaran.kunjungan k,
				 master.ruangan r		  		 
		 WHERE tm.ID = NEW.TINDAKAN_MEDIS
		   AND k.NOMOR = tm.KUNJUNGAN
			AND r.ID = k.RUANGAN
			AND r.JENIS_KUNJUNGAN = 4;
		 
		IF FOUND_ROWS() > 0 THEN
			
			INSERT INTO aplikasi.automaticexecute(PERINTAH)
			VALUES(CONCAT("INSERT INTO layanan.petugas_tindakan_medis
				SELECT tm.ID, 1, ", NEW.MEDIS, ", 1, 1
				  FROM layanan.tindakan_medis tm
				  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON ptm.TINDAKAN_MEDIS = tm.ID
				 WHERE tm.KUNJUNGAN = '", VKUNJUNGAN, "'
				 	AND tm.STATUS = 1
				 	AND NOT tm.ID = '", NEW.TINDAKAN_MEDIS, "'
				   AND ptm.TINDAKAN_MEDIS IS NULL"));
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
