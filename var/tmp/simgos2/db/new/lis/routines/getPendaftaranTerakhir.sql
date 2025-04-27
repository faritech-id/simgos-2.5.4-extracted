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

-- membuang struktur untuk function lis.getPendaftaranTerakhir
DROP FUNCTION IF EXISTS `getPendaftaranTerakhir`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getPendaftaranTerakhir`(`PPASIEN` INT) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
    COMMENT 'Mengambil noreg yang terakhir khusus IGD dan IRNA'
BEGIN
   DECLARE VPENDAFTARAN CHAR(10);
   DECLARE ROWS_FOUND INT;
   
   
	SELECT noreg 
	  INTO VPENDAFTARAN
	  FROM pcc_rsws.register 
	 WHERE norm = PPASIEN
	   AND id_statusreg IN (2, 6)
	 ORDER BY tanggal DESC
	 LIMIT 1;
	
	
	IF FOUND_ROWS() > 0 THEN
		
		IF EXISTS(
			SELECT 1
			  FROM pcc_rsws.register_keluar
			 WHERE noreg = VPENDAFTARAN
			   AND status_reg_keluar = 1
			 LIMIT 1) THEN
			RETURN '';
		END IF;
		
		RETURN VPENDAFTARAN;		
	END IF;
	
	RETURN '';
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
