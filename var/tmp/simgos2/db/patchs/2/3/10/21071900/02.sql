-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk function pendaftaran.getJumlahAntrianTempatTidur
DROP FUNCTION IF EXISTS `getJumlahAntrianTempatTidur`;
DELIMITER //
CREATE FUNCTION `getJumlahAntrianTempatTidur`(
	`PRUANGAN` CHAR(50)
) RETURNS smallint
    DETERMINISTIC
BEGIN
	DECLARE VJUMLAH SMALLINT;
	
	SELECT COUNT(*) 
	  INTO VJUMLAH 
	FROM pendaftaran.antrian_tempat_tidur att
	 WHERE att.RENCANA_RUANGAN = PRUANGAN
	   AND att.`STATUS` = 1;
	   
	RETURN VJUMLAH;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
