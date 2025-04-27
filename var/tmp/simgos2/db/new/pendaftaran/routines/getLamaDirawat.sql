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

-- membuang struktur untuk function pendaftaran.getLamaDirawat
DROP FUNCTION IF EXISTS `getLamaDirawat`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getLamaDirawat`(
	`PMASUK` DATETIME,
	`PKELUAR` DATETIME,
	`PNOPEN` CHAR(10),
	`PKUNJUNGAN` CHAR(19),
	`PREF` CHAR(21)
) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VATURAN VARCHAR(50);
	
	SELECT pc.VALUE INTO VATURAN
	  FROM aplikasi.properti_config pc
	 WHERE pc.ID = 14;
	 
	IF FOUND_ROWS() = 0 THEN
		SET VATURAN = '1';
	END IF;
	
	IF VATURAN = '1' THEN
		RETURN pendaftaran.getLamaDirawatAturan1(PMASUK, PKELUAR, PNOPEN, PKUNJUNGAN, PREF);
	END IF;
	
	IF VATURAN = '2' THEN
		RETURN pendaftaran.getLamaDirawatAturan2(PMASUK, PKELUAR, PNOPEN, PKUNJUNGAN, PREF);
	END IF;
	
	RETURN 0;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
