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

-- membuang struktur untuk trigger pendaftaran.perubahan_tanggal_kunjungan_after_insert
DROP TRIGGER IF EXISTS `perubahan_tanggal_kunjungan_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `perubahan_tanggal_kunjungan_after_insert` AFTER INSERT ON `perubahan_tanggal_kunjungan` FOR EACH ROW BEGIN
	DECLARE VFIELD VARCHAR(5);
	
	SET VFIELD = 'MASUK';
	IF NEW.JENIS = 2 THEN
		SET VFIELD = 'KELUAR';
	END IF;
	
	INSERT INTO aplikasi.automaticexecute(PERINTAH)
	     VALUES(CONCAT("UPDATE pendaftaran.kunjungan SET ", VFIELD, " = '", NEW.TANGGAL_BARU, "' WHERE NOMOR = '", NEW.KUNJUNGAN, "'"));
		  
	
	IF NEW.JENIS = 1 THEN
	BEGIN
		DECLARE VMUTASI CHAR(21);
		DECLARE VKUNJUNGAN_SBLM CHAR(19);
		
		SELECT k.REF, m.KUNJUNGAN INTO VMUTASI, VKUNJUNGAN_SBLM
		  FROM pendaftaran.kunjungan k, pendaftaran.mutasi m
		 WHERE k.NOMOR = NEW.KUNJUNGAN
		   AND m.NOMOR = k.REF;
		 
		IF FOUND_ROWS() > 0 THEN
			IF NOT VMUTASI IS NULL THEN
				
				
				
				
	
				
				UPDATE pendaftaran.kunjungan k
				   SET k.KELUAR = SUBTIME(NEW.TANGGAL_BARU, '00:00:01')
				 WHERE k.NOMOR = VKUNJUNGAN_SBLM;
				 
				CALL pembayaran.storeAkomodasi(VKUNJUNGAN_SBLM);
			END IF;
		END IF;
	END; 
	END IF; 	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
