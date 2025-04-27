-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk trigger pendaftaran.onAfterUpdatePenjamin
DROP TRIGGER IF EXISTS `onAfterUpdatePenjamin`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdatePenjamin` AFTER UPDATE ON `penjamin` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	
	IF NEW.JENIS != OLD.JENIS THEN
		SET VTAGIHAN = pembayaran.getIdTagihan(OLD.NOPEN);
		
		DELETE FROM pembayaran.penjamin_tagihan
		 WHERE TAGIHAN = VTAGIHAN
			AND PENJAMIN = OLD.JENIS;
		IF NEW.JENIS > 1 THEN
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF VTAGIHAN != '' THEN
					CALL pembayaran.storePenjaminTagihan(VTAGIHAN, NEW.JENIS, NEW.KELAS);
				END IF;
			END IF;
		END IF;
		
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", VTAGIHAN, "')"), 1);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
