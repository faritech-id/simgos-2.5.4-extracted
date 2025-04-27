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


-- Membuang struktur basisdata untuk penjamin_rs
USE `penjamin_rs`;

-- membuang struktur untuk function penjamin_rs.getKenaikanTarif
DROP FUNCTION IF EXISTS `getKenaikanTarif`;
DELIMITER //
CREATE FUNCTION `getKenaikanTarif`(
	`PPENJAMIN` SMALLINT,
	`PJENIS` TINYINT,
	`PTANGGAL` DATETIME
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VPERSENTASE DECIMAL(60,2);
	SELECT kt.PERSENTASE INTO VPERSENTASE
	  FROM penjamin_rs.kenaikan_tarif kt
	 WHERE kt.PENJAMIN = PPENJAMIN
	   AND kt.JENIS = PJENIS
	   AND kt.TANGGAL_SK <= PTANGGAL
	ORDER BY kt.TANGGAL DESC LIMIT 1;	 
	
	IF VPERSENTASE IS NULL THEN 
		SELECT kt.PERSENTASE INTO VPERSENTASE
		  FROM penjamin_rs.kenaikan_tarif kt
		 WHERE kt.PENJAMIN = PPENJAMIN
		   AND kt.JENIS = PJENIS
		   AND kt.STATUS = 1
		ORDER BY kt.TANGGAL DESC LIMIT 1;
		
		IF VPERSENTASE IS NULL THEN
			SET VPERSENTASE = 0;
		END IF;
	END IF;
	 
	RETURN IF(VPERSENTASE > 0, (VPERSENTASE / 100), 0);
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
