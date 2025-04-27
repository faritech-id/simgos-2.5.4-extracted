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

-- membuang struktur untuk trigger master.onAfterInsertRuangan
DROP TRIGGER IF EXISTS `onAfterInsertRuangan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertRuangan` AFTER INSERT ON `ruangan` FOR EACH ROW BEGIN
	IF NEW.JENIS_KUNJUNGAN > 0 AND NEW.JENIS = 5 THEN
		INSERT INTO master.jenis_kunjungan_ruangan(JENIS_KUNJUNGAN, RUANGAN)
		VALUES(NEW.JENIS_KUNJUNGAN, NEW.ID);
		
		IF NEW.JENIS_KUNJUNGAN = 3 THEN 
			INSERT INTO master.ruangan_mutasi(RUANGAN, MUTASI)
			VALUES(0, NEW.ID);
			
			INSERT INTO master.batas_ruangan_vip(RUANGAN, KELAS)
			VALUES(NEW.ID, 4);
		ELSEIF NEW.JENIS_KUNJUNGAN = 4 THEN 
			INSERT INTO master.ruangan_laboratorium(RUANGAN, LABORATORIUM)
			VALUES(0, NEW.ID);
		ELSEIF NEW.JENIS_KUNJUNGAN = 5 THEN 
			INSERT INTO master.ruangan_radiologi(RUANGAN, RADIOLOGI)
			VALUES(0, NEW.ID);
		ELSEIF NEW.JENIS_KUNJUNGAN = 11 THEN 
			INSERT INTO master.ruangan_farmasi(RUANGAN, FARMASI)
			VALUES(0, NEW.ID);
		ELSE
			IF NEW.JENIS_KUNJUNGAN != 0 THEN 
				INSERT INTO master.ruangan_konsul(RUANGAN, KONSUL)
				VALUES(0, NEW.ID);
				
				IF NEW.JENIS_KUNJUNGAN = 6 THEN 
					INSERT INTO master.ruangan_operasi(RUANGAN, OPERASI)
					VALUES(0, NEW.ID);
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
