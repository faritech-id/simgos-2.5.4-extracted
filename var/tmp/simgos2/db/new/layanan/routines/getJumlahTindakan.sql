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

-- membuang struktur untuk function layanan.getJumlahTindakan
DROP FUNCTION IF EXISTS `getJumlahTindakan`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getJumlahTindakan`(
	`PNOMOR` VARCHAR(19),
	`PTINDAKAN` SMALLINT,
	`PTIPE` ENUM('PENDAFTARAN','KUNJUNGAN')) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VJML SMALLINT DEFAULT 0;
	
	IF PTIPE = 'PENDAFTARAN' THEN
		SELECT COUNT(tm.ID) INTO VJML
		  FROM pendaftaran.pendaftaran p
		  		 , pendaftaran.kunjungan k
		  		 , layanan.tindakan_medis tm
		 WHERE p.NOMOR = PNOMOR
		   AND k.NOPEN = p.NOMOR
		   AND k.`STATUS` IN (1,2)
		   AND tm.KUNJUNGAN = k.NOMOR
		   AND tm.TINDAKAN = PTINDAKAN
		   AND tm.`STATUS` = 1;
	ELSEIF PTIPE = 'KUNJUNGAN' THEN
		SELECT COUNT(tm.ID) INTO VJML
		  FROM pendaftaran.kunjungan k
		  		 , layanan.tindakan_medis tm
		 WHERE k.NOMOR = PNOMOR
		 	AND k.`STATUS` IN (1,2)
		   AND tm.KUNJUNGAN = k.NOMOR
		   AND tm.TINDAKAN = PTINDAKAN
		   AND tm.`STATUS` = 1;		
	END IF;
	
	IF FOUND_ROWS() = 0 THEN
		SET VJML = 0;
	END IF;
	
	RETURN VJML;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
