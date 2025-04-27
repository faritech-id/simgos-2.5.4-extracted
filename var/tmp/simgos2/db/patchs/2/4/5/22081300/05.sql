-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk generator
CREATE DATABASE IF NOT EXISTS `generator`;
USE `generator`;

-- membuang struktur untuk function generator.generateIdPenggunaAksesLog
DROP FUNCTION IF EXISTS `generateIdPenggunaAksesLog`;
DELIMITER //
CREATE FUNCTION `generateIdPenggunaAksesLog`(
	`PTANGGAL` DATE
) RETURNS varchar(15) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VNOMOR INT DEFAULT 0;
	
	INSERT INTO generator.id_pengguna_akses_log(TANGGAL, NOMOR)
	SELECT IFNULL(a.TANGGAL, PTANGGAL), IFNULL(MAX(a.NOMOR), 0) + 1
	  FROM generator.id_pengguna_akses_log a
	 WHERE TANGGAL = PTANGGAL;
	 
	SELECT a.NOMOR
	  INTO VNOMOR
	  FROM generator.id_pengguna_akses_log a
	 WHERE a.ID = LAST_INSERT_ID();
	
	RETURN CONCAT(DATE_FORMAT(PTANGGAL, '%y%m%d'), LPAD(VNOMOR, 9, '0'));
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
