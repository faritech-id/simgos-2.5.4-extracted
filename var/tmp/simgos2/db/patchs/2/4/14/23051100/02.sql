-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk kemkes-sirs
USE `kemkes-sirs`;

-- membuang struktur untuk trigger kemkes-sirs.rl5-2_before_update
DROP TRIGGER IF EXISTS `rl5-2_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `rl5-2_before_update` BEFORE UPDATE ON `rl5-2` FOR EACH ROW BEGIN
	IF NEW.jumlah != OLD.jumlah THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl5-3_before_update
DROP TRIGGER IF EXISTS `rl5-3_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `rl5-3_before_update` BEFORE UPDATE ON `rl5-3` FOR EACH ROW BEGIN
	IF NEW.`pasien_keluar_hidup_menurut_jenis_kelamin_l` != OLD.`pasien_keluar_hidup_menurut_jenis_kelamin_l`
		OR NEW.`pasien_keluar_hidup_menurut_jenis_kelamin_p` != OLD.`pasien_keluar_hidup_menurut_jenis_kelamin_p`
		OR NEW.`pasien_keluar_mati_menurut_jenis_kelamin_l` != OLD.`pasien_keluar_mati_menurut_jenis_kelamin_l`
		OR NEW.`pasien_keluar_mati_menurut_jenis_kelamin_p` != OLD.`pasien_keluar_mati_menurut_jenis_kelamin_p`
		OR NEW.`total_all` != OLD.`total_all` THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-sirs.rl5-4_before_update
DROP TRIGGER IF EXISTS `rl5-4_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='';
DELIMITER //
CREATE TRIGGER `rl5-4_before_update` BEFORE UPDATE ON `rl5-4` FOR EACH ROW BEGIN
	IF NEW.`kasus_baru_menurut_jenis_kelamin_l` != OLD.`kasus_baru_menurut_jenis_kelamin_l`
		OR NEW.`kasus_baru_menurut_jenis_kelamin_p` != OLD.`kasus_baru_menurut_jenis_kelamin_p`
		OR NEW.`jumlah_kasus_baru` != OLD.`jumlah_kasus_baru`
		OR NEW.`jumlah_kunjungan` != OLD.`jumlah_kunjungan` THEN
		SET NEW.kirim = 1;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
