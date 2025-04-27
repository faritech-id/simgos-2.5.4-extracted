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

-- membuang struktur untuk function master.getTempatLahir
DROP FUNCTION IF EXISTS `getTempatLahir`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getTempatLahir`(`PKODE` CHAR(10)) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTEMPAT_LAHIR VARCHAR(50);
	DECLARE VKODE INT;
	
	SET VKODE = CAST(PKODE AS UNSIGNED);
	
	IF VKODE = 0 THEN
		RETURN '';
	END IF;
	
	SELECT DESKRIPSI INTO VTEMPAT_LAHIR
	  FROM `master`.wilayah
	 WHERE ID = PKODE;
	 
  	IF FOUND_ROWS() = 0 THEN
  		SELECT DESKRIPSI INTO VTEMPAT_LAHIR
		  FROM `master`.negara n
		 WHERE ID = PKODE;
		 
		IF FOUND_ROWS() = 0 THEN
			SET VTEMPAT_LAHIR = '';
		END IF;
	END IF;

	RETURN VTEMPAT_LAHIR;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
