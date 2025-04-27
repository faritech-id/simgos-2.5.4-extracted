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

-- membuang struktur untuk function master.getCariUmur
DROP FUNCTION IF EXISTS `getCariUmur`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getCariUmur`(
	`PTGLREG` DATETIME,
	`PTGLLAHIR` DATETIME
) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE desk VARCHAR(50);
	DECLARE thn,bln,hari INTEGER;	
	
	SET thn = YEAR(PTGLREG) - YEAR(PTGLLAHIR);
	IF DATE_ADD(PTGLLAHIR, INTERVAL thn YEAR) > PTGLREG THEN
		SET thn = thn - 1;
	END IF;
	
	SET bln = (YEAR(PTGLREG) * 12 + MONTH(PTGLREG)) - (YEAR(PTGLLAHIR) * 12 + MONTH(PTGLLAHIR));
	IF DATE_ADD(PTGLLAHIR, INTERVAL bln MONTH) > PTGLREG THEN
		SET bln = bln - 1;
	END IF;	
	SET bln = bln - (thn * 12);
	IF MONTH(PTGLREG) = 2 AND DAY(PTGLREG) >= 28 AND DAY(PTGLLAHIR) > 28 THEN
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
