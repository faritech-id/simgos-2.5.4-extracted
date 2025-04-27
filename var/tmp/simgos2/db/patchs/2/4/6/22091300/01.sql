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


-- Membuang struktur basisdata untuk master
CREATE DATABASE IF NOT EXISTS `master`;
USE `master`;

-- membuang struktur untuk procedure master.inPaket
DROP PROCEDURE IF EXISTS `inPaket`;
DELIMITER //
CREATE PROCEDURE `inPaket`(
	IN `PPAKET` SMALLINT,
	IN `PJENIS` TINYINT,
	IN `PITEM` SMALLINT,
	IN `PRUANGAN` CHAR(10),
	OUT `PQTY` DECIMAL(60,2),
	OUT `PID_DETIL` INT
)
BEGIN
	IF NOT PRUANGAN IS NULL THEN
		SELECT SUM(QTY) INTO PQTY 
		  FROM `master`.paket_detil a
		 WHERE PAKET = PPAKET
		   AND JENIS = PJENIS
		   AND ITEM = PITEM
			AND STATUS = 1
		 LIMIT 1;
		 
		IF PQTY > 0 THEN
			SELECT ID INTO PID_DETIL 
			  FROM `master`.paket_detil a
			 WHERE PAKET = PPAKET
			   AND JENIS = PJENIS
			   AND ITEM = PITEM
			   AND RUANGAN = PRUANGAN
				AND STATUS = 1
			 LIMIT 1;
		END IF;
	END IF;
	
	IF PID_DETIL IS NULL THEN
		SELECT ID, QTY INTO PID_DETIL, PQTY 
		  FROM `master`.paket_detil a
		 WHERE PAKET = PPAKET
		   AND JENIS = PJENIS
		   AND ITEM = PITEM
			AND STATUS = 1
		 LIMIT 1;
		 
		IF PID_DETIL IS NULL THEN
			SET PID_DETIL = 0;
			SET PQTY = 0;
		END IF;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
