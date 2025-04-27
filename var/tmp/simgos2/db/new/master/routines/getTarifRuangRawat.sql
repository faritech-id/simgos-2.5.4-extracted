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

-- membuang struktur untuk function master.getTarifRuangRawat
DROP FUNCTION IF EXISTS `getTarifRuangRawat`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getTarifRuangRawat`(
	`PKELAS` TINYINT,
	`PTANGGAL` DATETIME

) RETURNS int(11)
    DETERMINISTIC
BEGIN
	DECLARE VTARIF INT;
	SELECT trr.TARIF INTO VTARIF
	  FROM `master`.tarif_ruang_rawat trr
	 WHERE trr.KELAS = PKELAS
	   AND trr.TANGGAL_SK <= PTANGGAL
	ORDER BY trr.TANGGAL DESC LIMIT 1;	 
	
	IF FOUND_ROWS() = 0 THEN 
		SELECT trr.TARIF INTO VTARIF
		  FROM `master`.tarif_ruang_rawat trr
		 WHERE trr.KELAS = PKELAS
		   AND trr.`STATUS` = 1
		ORDER BY trr.TANGGAL DESC LIMIT 1;
		
		IF FOUND_ROWS() = 0 THEN
			SET VTARIF = 0;
		END IF;
	END IF;
	 
	RETURN VTARIF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
