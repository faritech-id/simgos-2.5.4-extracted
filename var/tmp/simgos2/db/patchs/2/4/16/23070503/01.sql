-- --------------------------------------------------------
-- Host:                         192.168.XXX.XXX
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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
USE `master`;

-- membuang struktur untuk procedure master.getTarifRuangRawat
DROP PROCEDURE IF EXISTS `getTarifRuangRawat`;
DELIMITER //
CREATE PROCEDURE `getTarifRuangRawat`(
	IN `PRUANG_KAMAR_TIDUR` SMALLINT,
	IN `PTANGGAL` DATETIME,
	OUT `PTARIF_ID` INT,
	OUT `PTARIF` INT
)
BEGIN
	SELECT trr.ID, trr.TARIF INTO PTARIF_ID, PTARIF
	  FROM `master`.ruang_kamar_tidur rkt,
	  		 `master`.ruang_kamar rk,
	  		 `master`.tarif_ruang_rawat trr
	 WHERE rkt.ID = PRUANG_KAMAR_TIDUR
	   AND rk.ID = rkt.RUANG_KAMAR
	   AND trr.KELAS = rk.KELAS
	   AND trr.TANGGAL_SK <= PTANGGAL
	ORDER BY trr.TANGGAL DESC LIMIT 1;	 
	
	IF FOUND_ROWS() = 0 THEN 
		SELECT trr.ID, trr.TARIF INTO PTARIF_ID, PTARIF
		  FROM `master`.ruang_kamar_tidur rkt,
		  		 `master`.ruang_kamar rk,
		  		 `master`.tarif_ruang_rawat trr
		 WHERE rkt.ID = PRUANG_KAMAR_TIDUR
		   AND rk.ID = rkt.RUANG_KAMAR
		   AND trr.KELAS = rk.KELAS
		   AND trr.`STATUS` = 1
		ORDER BY trr.TANGGAL DESC LIMIT 1;
	END IF;
	 
	IF FOUND_ROWS() = 0 THEN
		SET PTARIF_ID = NULL;
		SET PTARIF = 0;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
