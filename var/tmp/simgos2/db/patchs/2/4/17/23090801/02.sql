-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
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

-- membuang struktur untuk function master.getTarifFarmasiPerKelas
DROP FUNCTION IF EXISTS `getTarifFarmasiPerKelas`;
DELIMITER //
CREATE FUNCTION `getTarifFarmasiPerKelas`(
	`PKELAS` TINYINT,
	`PTARIF` DECIMAL(60,2)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VPERSEN DECIMAL(10,2);
	DECLARE VID SMALLINT;
	
	SELECT tf.ID, tf.FARMASI INTO VID, VPERSEN
	  FROM `master`.tarif_farmasi_per_kelas tf
	 WHERE STATUS = 1
	   AND KELAS = PKELAS
	 LIMIT 1;
	 
	IF NOT VID IS NULL THEN
		RETURN PTARIF + (PTARIF * (VPERSEN/100));
	END IF;
	
	RETURN PTARIF;
END//
DELIMITER ;

-- membuang struktur untuk function master.getTarifMarginPenjaminFarmasi
DROP FUNCTION IF EXISTS `getTarifMarginPenjaminFarmasi`;
DELIMITER //
CREATE FUNCTION `getTarifMarginPenjaminFarmasi`(
	`PPENJAMIN` SMALLINT,
	`PJENIS` TINYINT,
	`PTARIF` DECIMAL(60,2),
	`PTANGGAL` DATETIME
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VMARGIN DECIMAL(10,2);
	DECLARE VID INT;
	
	SELECT mp.ID, mp.MARGIN INTO VID, VMARGIN
	  FROM `master`.margin_penjamin_farmasi mp
	 WHERE mp.PENJAMIN = PPENJAMIN
	   AND mp.JENIS = PJENIS 
	   AND mp.TANGGAL_SK <= PTANGGAL
    ORDER BY mp.TANGGAL DESC LIMIT 1;
	 
	IF VID IS NULL THEN
		SELECT mp.ID, mp.MARGIN INTO VID, VMARGIN
		  FROM `master`.margin_penjamin_farmasi mp
		 WHERE mp.STATUS = 1
		   AND mp.PENJAMIN = PPENJAMIN
		   AND mp.JENIS = PJENIS 
	    ORDER BY mp.TANGGAL DESC LIMIT 1;
	    
	   IF VID IS NULL THEN
			SET VMARGIN = 0;
		END IF;
	END IF;
	
	RETURN PTARIF + (PTARIF * (VMARGIN/100));
END//
DELIMITER ;

-- membuang struktur untuk function master.getTarifRuangRawat
DROP FUNCTION IF EXISTS `getTarifRuangRawat`;
DELIMITER //
CREATE FUNCTION `getTarifRuangRawat`(
	`PKELAS` TINYINT,
	`PTANGGAL` DATETIME
) RETURNS int
    DETERMINISTIC
BEGIN
	DECLARE VTARIF INT;
	DECLARE VID INT;
	
	SELECT trr.ID, trr.TARIF INTO VID, VTARIF
	  FROM `master`.tarif_ruang_rawat trr
	 WHERE trr.KELAS = PKELAS
	   AND trr.TANGGAL_SK <= PTANGGAL
	ORDER BY trr.TANGGAL DESC LIMIT 1;	 
	
	IF VID IS NULL THEN 
		SELECT trr.ID, trr.TARIF INTO VID, VTARIF
		  FROM `master`.tarif_ruang_rawat trr
		 WHERE trr.KELAS = PKELAS
		   AND trr.`STATUS` = 1
		ORDER BY trr.TANGGAL DESC LIMIT 1;
		
		IF VID IS NULL THEN
			SET VTARIF = 0;
		END IF;
	END IF;
	 
	RETURN VTARIF;
END//
DELIMITER ;

-- membuang struktur untuk function master.getTempatLahir
DROP FUNCTION IF EXISTS `getTempatLahir`;
DELIMITER //
CREATE FUNCTION `getTempatLahir`(
	`PKODE` CHAR(10)
) RETURNS varchar(50) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTEMPAT_LAHIR VARCHAR(50);
	DECLARE VKODE INT;
	
	SET VKODE = CAST(PKODE AS UNSIGNED);
	
	IF VKODE = 0 THEN
		RETURN '';
	END IF;
	
	SELECT DESKRIPSI INTO VTEMPAT_LAHIR
	  FROM `master`.wilayah
	 WHERE ID = PKODE;
	 
  	IF VTEMPAT_LAHIR IS NULL THEN
  		SELECT DESKRIPSI INTO VTEMPAT_LAHIR
		  FROM `master`.negara n
		 WHERE ID = PKODE;
		 
		IF VTEMPAT_LAHIR IS NULL THEN
			SET VTEMPAT_LAHIR = '';
		END IF;
	END IF;

	RETURN VTEMPAT_LAHIR;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
