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

-- membuang struktur untuk trigger layanan.onAfterUpdateTindakanMedis
DROP TRIGGER IF EXISTS `onAfterUpdateTindakanMedis`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `onAfterUpdateTindakanMedis` AFTER UPDATE ON `tindakan_medis` FOR EACH ROW BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VKELAS TINYINT DEFAULT 0;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
		SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS
		  FROM pendaftaran.kunjungan k
		  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
				 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
		  		 master.ruangan r
		 WHERE k.RUANGAN = r.ID
		   AND k.NOMOR = NEW.KUNJUNGAN;
		
		IF FOUND_ROWS() > 0 THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF VTAGIHAN != '' THEN
					CALL pembayaran.batalRincianTagihan(VTAGIHAN, OLD.ID, 3);
				END IF;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
