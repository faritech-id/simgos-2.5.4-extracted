-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
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

-- Dumping structure for function generator.generateIdHasilEvaluasiSST
DROP FUNCTION IF EXISTS `generateIdHasilEvaluasiSST`;
DELIMITER //
CREATE FUNCTION `generateIdHasilEvaluasiSST`(
	`PTANGGAL` DATE
) RETURNS varchar(12) CHARSET latin1
    DETERMINISTIC
BEGIN
	INSERT INTO generator.id_hasil_evaluasi_sst(TANGGAL)
	VALUES(PTANGGAL);
		
	RETURN CONCAT(DATE_FORMAT(PTANGGAL, '%y%m%d'), LPAD(LAST_INSERT_ID(), 6, '0'));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
