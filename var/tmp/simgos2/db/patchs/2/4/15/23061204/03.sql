-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.32 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for generator
USE `generator`;

-- Dumping structure for function generator.generateNoSuratKelahiran
DELIMITER //
CREATE FUNCTION `generateNoSuratKelahiran`(
	`PTAHUN` CHAR(4)
) RETURNS varchar(6) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VNOMOR MEDIUMINT DEFAULT 0;
	
	INSERT INTO generator.no_surat_kelahiran(TAHUN, URUT)
	SELECT IFNULL(a.TAHUN, PTAHUN), IFNULL(MAX(a.URUT), 0) + 1
	  FROM generator.no_surat_kelahiran a
	 WHERE TAHUN = PTAHUN;
	 
	SELECT a.URUT
	  INTO VNOMOR
	  FROM generator.no_surat_kelahiran a
	 WHERE a.ID = LAST_INSERT_ID();
	
	RETURN LPAD(VNOMOR, 6, '0');
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
