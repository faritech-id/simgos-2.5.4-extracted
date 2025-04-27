USE `inventory`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for function inventory.adaItemObatYangTervalidasiStok
DROP FUNCTION IF EXISTS `adaItemObatYangTervalidasiStok`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `adaItemObatYangTervalidasiStok`(`PKUNJUNGAN` CHAR(50)) RETURNS int(11)
    DETERMINISTIC
BEGIN
	
	IF EXISTS(SELECT 1 FROM aplikasi.properti_config p WHERE p.ID = 66 AND p.VALUE = 'TRUE') THEN	
		IF EXISTS(SELECT 1 FROM (
			SELECT (SELECT inventory.getStokBarangRuangan(f.FARMASI, k.RUANGAN) - (f.JUMLAH - f.BON)) SELISIH
			FROM pendaftaran.kunjungan k, layanan.farmasi f
			where f.KUNJUNGAN = k.NOMOR AND k.NOMOR = PKUNJUNGAN
		) record WHERE record.SELISIH < 0) THEN
			RETURN 1;
		END IF;
	END IF;
	
	RETURN 0;
	
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;