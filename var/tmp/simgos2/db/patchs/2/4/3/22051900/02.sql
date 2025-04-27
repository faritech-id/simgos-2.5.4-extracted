-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk generator
USE `generator`;

-- membuang struktur untuk function generator.generateNoPembayaran
DROP FUNCTION IF EXISTS `generateNoPembayaran`;
DELIMITER //
CREATE FUNCTION `generateNoPembayaran`(
	`PTANGGAL` DATE
) RETURNS char(11) CHARSET utf8mb4
    DETERMINISTIC
BEGIN
	DECLARE VNOMOR SMALLINT DEFAULT 0;
	
	INSERT INTO generator.no_pembayaran(TANGGAL, NOMOR)
	SELECT IFNULL(a.TANGGAL, PTANGGAL), IFNULL(MAX(a.NOMOR), 0) + 1
	  FROM generator.no_pembayaran a
	 WHERE TANGGAL = PTANGGAL;
	 
	SELECT a.NOMOR
	  INTO VNOMOR
	  FROM generator.no_pembayaran a
	 WHERE a.ID = LAST_INSERT_ID();
	
	RETURN CONCAT(DATE_FORMAT(PTANGGAL, '%y%m%d'), LPAD(VNOMOR, 5, '0'));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
