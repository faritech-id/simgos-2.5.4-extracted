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

-- membuang struktur untuk function master.getTarifMarginPenjaminFarmasi
DROP FUNCTION IF EXISTS `getTarifMarginPenjaminFarmasi`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getTarifMarginPenjaminFarmasi`(
	`PPENJAMIN` SMALLINT,
	`PJENIS` TINYINT,
	`PTARIF` DECIMAL(60,2),
	`PTANGGAL` DATETIME
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VMARGIN DECIMAL(10,2);
	
	SELECT MARGIN INTO VMARGIN
	  FROM `master`.margin_penjamin_farmasi
	 WHERE PENJAMIN = PPENJAMIN
	   AND JENIS = PJENIS 
	   AND TANGGAL_SK <= PTANGGAL
    ORDER BY TANGGAL DESC LIMIT 1;
	 
	IF FOUND_ROWS() = 0 THEN
		SELECT MARGIN INTO VMARGIN
		  FROM `master`.margin_penjamin_farmasi
		 WHERE STATUS = 1
		   AND PENJAMIN = PPENJAMIN
		   AND JENIS = PJENIS 
	    ORDER BY TANGGAL DESC LIMIT 1;
	    
	   IF FOUND_ROWS() = 0 THEN
			SET VMARGIN = 0;
		END IF;
	END IF;
	
	RETURN PTARIF + (PTARIF * (VMARGIN/100));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
