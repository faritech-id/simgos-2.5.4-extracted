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

-- membuang struktur untuk function lis.getKunjunganTerakhir
DROP FUNCTION IF EXISTS `getKunjunganTerakhir`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getKunjunganTerakhir`(`PPENDAFTARAN` CHAR(10)) RETURNS char(25) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VKUNJUNGAN VARCHAR(25);
	
	SELECT r.id_reg_lengkap INTO VKUNJUNGAN
	  FROM pcc_rsws.register r
	  		 , pcc_rsws.mapping_unit_group mug 
	 WHERE r.noreg = PPENDAFTARAN
	   AND r.id_statusreg != 5
		AND mug.idgroup IN (2, 3)
	 ORDER BY r.tanggal DESC
	 LIMIT 1;
		
	IF FOUND_ROWS() = 0 THEN
		SET VKUNJUNGAN = '';
	END IF;
	   
	RETURN VKUNJUNGAN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
