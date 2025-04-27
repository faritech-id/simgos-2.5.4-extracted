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

-- membuang struktur untuk function master.getDiagnosa
DROP FUNCTION IF EXISTS `getDiagnosa`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getDiagnosa`(`PNOPEN` CHAR(10), `PUTAMA` INT) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR) mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
