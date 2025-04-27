-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk function master.getCariUmur
DROP FUNCTION IF EXISTS `getCariUmur`;
DELIMITER //
CREATE FUNCTION `getCariUmur`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE desk VARCHAR(50);
	DECLARE thn,bln,hari INTEGER;
	DECLARE vjmlHariBulanFeb TINYINT;
	
	SET vjmlHariBulanFeb = IF((YEAR(PTGLREG) % 4) = 0, 29, 28);
	
	SET thn = YEAR(PTGLREG) - YEAR(PTGLLAHIR);
	IF DATE_ADD(PTGLLAHIR, INTERVAL thn YEAR) > PTGLREG THEN
		SET thn = thn - 1;
	END IF;
	
	SET bln = (YEAR(PTGLREG) * 12 + MONTH(PTGLREG)) - (YEAR(PTGLLAHIR) * 12 + MONTH(PTGLLAHIR));
	IF DATE_ADD(PTGLLAHIR, INTERVAL bln MONTH) > PTGLREG THEN
		SET bln = bln - 1;
	END IF;	
	SET bln = bln - (thn * 12);
	IF MONTH(PTGLREG) = 2 AND DAY(PTGLREG) >= vjmlHariBulanFeb AND DAY(PTGLLAHIR) > vjmlHariBulanFeb THEN
		SET bln = bln - 1;
	END IF;
	
	SET hari = DAY(LAST_DAY(PTGLLAHIR)) - DAY(PTGLLAHIR);
	IF DAY(PTGLREG) >= DAY(PTGLLAHIR) THEN
		SET hari = DAY(PTGLREG) - DAY(PTGLLAHIR);
	ELSE
		SET hari = hari + DAY(PTGLREG);
	END IF;
	
	RETURN CONCAT(thn, ' Th/ ', bln, ' bl/ ', hari, ' hr');
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
