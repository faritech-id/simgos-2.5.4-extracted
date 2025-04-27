-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk inacbg

USE `inacbg`;

-- membuang struktur untuk trigger inacbg.hasil_grouping_after_insert
DROP TRIGGER IF EXISTS `hasil_grouping_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_grouping_after_insert` AFTER INSERT ON `hasil_grouping` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VPENJAMIN SMALLINT;
	DECLARE VDITEMUKAN TINYINT;
	DECLARE VJNS CHAR(1);
	
	IF NEW.STATUS = 1 THEN
		SET VTAGIHAN = IFNULL(NEW.TAGIHAN_ID, pembayaran.getIdTagihan(NEW.NOPEN));	
	
		SELECT CAST(m.SIMRS AS UNSIGNED) PENJAMIN, REPLACE(g.DATA->'$.jns_perawatan','"','') JNS, COUNT(1) DITEMUKAN
		  INTO VPENJAMIN, VJNS, VDITEMUKAN
		  FROM inacbg.grouping g,
		  		 inacbg.tipe_inacbg t,
		  		 inacbg.map_inacbg_simrs m	  		 
		 WHERE g.NOPEN = NEW.NOPEN
		   AND g.DATA->'$.jns_pbyrn' = '71'
			AND t.ID = CAST(g.DATA->'$.tipe' AS UNSIGNED)
			AND m.JENIS = 3
			AND m.VERSION = t.VERSION
			AND m.INACBG = g.DATA->'$.jns_pbyrn';
		
		IF VDITEMUKAN > 0 THEN
			UPDATE pembayaran.penjamin_tagihan
			   SET TOTAL = IF(VJNS = '2', NEW.TOTALTARIF, NEW.TOP_UP_RAWAT + NEW.TOP_UP_JENAZAH)
			   	 , TARIF_INACBG_KELAS1 = (NEW.TARIFKLS1 + NEW.TARIFSP + NEW.TARIFSR + NEW.TARIFSI + NEW.TARIFSD + NEW.TARIFSA + NEW.TARIFSC)
			 WHERE TAGIHAN = VTAGIHAN
			   AND PENJAMIN = VPENJAMIN;			
		ELSE
			UPDATE pembayaran.penjamin_tagihan pt
			   SET TOTAL = NEW.TOTALTARIF
			   	 , TARIF_INACBG_KELAS1 = IF(pt.KELAS_KLAIM = 3, NEW.TOTALTARIF, (NEW.TARIFKLS1 + NEW.TARIFSP + NEW.TARIFSR + NEW.TARIFSI + NEW.TARIFSD + NEW.TARIFSA + NEW.TARIFSC))
			 WHERE TAGIHAN = VTAGIHAN
			   AND PENJAMIN = 2;
		END IF;
		
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
 		VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", VTAGIHAN, "')"), 1);		
	END IF;

END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
