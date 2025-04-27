-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for master
USE `master`;

-- Dumping structure for function master.getAturanPakai2New
DROP FUNCTION IF EXISTS `getAturanPakaiDenganFrekuensiDanRute`;
DELIMITER //
CREATE FUNCTION `getAturanPakaiDenganFrekuensiDanRute`(
	`DOSIS` CHAR(50),
	`PFREKUENSI` INT,
	`PRUTE` INT
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VATURAN_PAKAI VARCHAR(250);
	DECLARE VFREKUENSI,VRUTE VARCHAR(100);
	
	SELECT f.FREKUENSI INTO VFREKUENSI FROM master.frekuensi_aturan_resep f WHERE f.ID = PFREKUENSI;
	IF VFREKUENSI IS NULL THEN
		SET VFREKUENSI = '';
	END IF;
	
	SELECT r.DESKRIPSI INTO VRUTE FROM master.referensi r WHERE r.JENIS = 217 AND r.ID = PRUTE;
	IF VRUTE IS NULL THEN
		SET VRUTE = '';
	END IF;
	
	RETURN CONCAT(IF(DOSIS = '', DOSIS, CONCAT(DOSIS, ' ')),VFREKUENSI,'  ',VRUTE);
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
