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

-- membuang struktur untuk trigger kemkes.reservasi_antrian_before_insert
DROP TRIGGER IF EXISTS `reservasi_antrian_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `reservasi_antrian_before_insert` BEFORE INSERT ON `reservasi_antrian` FOR EACH ROW BEGIN
	DECLARE VJML_ANTRI SMALLINT DEFAULT 0;
	DECLARE VJAM TIME;
	
		
	SELECT COUNT(*), MAX(JAM) INTO VJML_ANTRI, VJAM
	  FROM kemkes.reservasi_antrian ra
	 WHERE ra.TANGGAL_KUNJUNGAN = NEW.TANGGAL_KUNJUNGAN;
	
	SET NEW.NOMOR = generator.generateNoAntrian(NEW.TANGGAL_KUNJUNGAN);		
	 
	IF VJML_ANTRI > 0 THEN
		SET NEW.JAM = ADDTIME(VJAM, '00:05:00');
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
