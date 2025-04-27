-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk trigger pembayaran.onAfterUpdateTagihanPendaftaran
DROP TRIGGER IF EXISTS `onAfterUpdateTagihanPendaftaran`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateTagihanPendaftaran` AFTER UPDATE ON `tagihan_pendaftaran` FOR EACH ROW BEGIN
	/* Batal Pendaftaran */
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
	BEGIN
		DECLARE VKARCISID CHAR(11);
		DECLARE VJML TINYINT;
		
		/* Batal tagihan jika tagihan pendafataran tidak ada yg bergabung */
		SELECT COUNT(*) INTO VJML
		  FROM pembayaran.tagihan_pendaftaran
		 WHERE TAGIHAN = OLD.TAGIHAN
		   AND STATUS = 1;
		   
		IF VJML = 0 THEN
			UPDATE pembayaran.tagihan
			   SET STATUS = 0
			 WHERE ID = OLD.TAGIHAN
			   AND STATUS = 1;
		END IF;
						
		/* Batal Rincian Tagihan */
		/* administrasi */
		SELECT ID INTO VKARCISID
		  FROM cetakan.karcis_pasien
		 WHERE NOPEN = OLD.PENDAFTARAN;
		 
		IF FOUND_ROWS() > 0 THEN
			CALL pembayaran.batalRincianTagihan(OLD.TAGIHAN, VKARCISID, 1);
		END IF;
		/* akomodasi */
		/* tindakan */
		/* farmasi */
		CALL pembayaran.reStoreTagihan(OLD.TAGIHAN);
		#INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		#VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", OLD.TAGIHAN, "')"), 1);
	END;
	END IF;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 1 THEN
	BEGIN
		CALL pembayaran.reStoreTagihan(OLD.TAGIHAN);
		#INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		#VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", OLD.TAGIHAN, "')"), 1);
	END;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
