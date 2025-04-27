-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.32 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk function pembayaran.getDataJumlahLamaDirawatDanVisiteDokterPerawat
DROP FUNCTION IF EXISTS `getDataJumlahLamaDirawatDanVisiteDokterPerawat`;
DELIMITER //
CREATE FUNCTION `getDataJumlahLamaDirawatDanVisiteDokterPerawat`(
	`PNOPEN` CHAR(10)
) RETURNS varchar(100)
    DETERMINISTIC
BEGIN
	DECLARE VAKOMODASI, VVISITE SMALLINT;
	
	SELECT ROUND(SUM(IF(rt.JENIS = 2, rt.JUMLAH, 0))), ROUND(SUM(IF(rt.JENIS = 3, IF(mgp.ID IS NULL, 0, 1), 0)))
	  INTO VAKOMODASI, VVISITE
	  FROM pembayaran.tagihan_pendaftaran tp,
	  		 pembayaran.rincian_tagihan rt
	  		 LEFT JOIN `master`.tarif_tindakan tt ON tt.ID = rt.TARIF_ID
	  		 LEFT JOIN `master`.group_pemeriksaan gp ON gp.JENIS = 3 AND gp.KODE = '10' AND gp.`STATUS` = 1
	  		 LEFT JOIN `master`.mapping_group_pemeriksaan mgp ON mgp.GROUP_PEMERIKSAAN_ID = gp.ID AND mgp.PEMERIKSAAN = tt.TINDAKAN AND mgp.`STATUS` = 1
	 WHERE tp.PENDAFTARAN = PNOPEN
	   AND tp.`STATUS` = 1
	   AND rt.TAGIHAN = tp.TAGIHAN
	   AND rt.`STATUS` = 1;
	   
	IF VAKOMODASI = VVISITE THEN
		RETURN '';
	END IF;
	
	RETURN CONCAT('{"AKOMODASI": ', VAKOMODASI, ', "VISITE": ', VVISITE, '}');
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
