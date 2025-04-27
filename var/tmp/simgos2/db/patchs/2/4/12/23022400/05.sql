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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.procStoreTagihanKlaim
DROP PROCEDURE IF EXISTS `procStoreTagihanKlaim`;
DELIMITER //
CREATE PROCEDURE `procStoreTagihanKlaim`(
	IN `PAWAL` DATE,
	IN `PAKHIR` DATE
)
BEGIN
	DECLARE VAWAL, VAKHIR DATETIME;
	
	SET VAWAL = CONCAT(PAWAL, ' 00:00:00');
	SET VAKHIR = CONCAT(PAKHIR, ' 23:59:59');
	
	DROP TEMPORARY TABLE IF EXISTS TEMP_TAGIHAN_KLAIM;
	CREATE TEMPORARY TABLE TEMP_TAGIHAN_KLAIM ENGINE=MEMORY
		SELECT TAGIHAN, NORM, NOPEN, MASUK, KELUAR, TANGGAL_FINAL, PENJAMIN, JENIS, TOTAL
		  FROM (
		SELECT pt.TAGIHAN, t.REF NORM, tp.PENDAFTARAN NOPEN, p.TANGGAL MASUK, ppg.TANGGAL KELUAR, pt.TANGGAL TANGGAL_FINAL, 
				 IFNULL(pjt.PENJAMIN, pp.PENJAMIN) PENJAMIN,
				 IF(pjt.PENJAMIN IS NULL, IF(pp.PENJAMIN IS NULL, NULL, 2), 1) JENIS, 
				 IFNULL(pjt.TOTAL, pp.TOTAL) TOTAL
		  FROM pembayaran.tagihan t,
		  		 pembayaran.tagihan_pendaftaran tp,
		  		 pendaftaran.pendaftaran p
				 LEFT JOIN layanan.pasien_pulang ppg ON ppg.NOPEN = p.NOMOR AND ppg.`STATUS` = 1,
		  		 pembayaran.pembayaran_tagihan pt
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON pjt.TAGIHAN = pt.TAGIHAN AND pjt.TOTAL > 0
		  		 LEFT JOIN pembayaran.piutang_perusahaan pp ON pp.TAGIHAN = pt.TAGIHAN AND pp.TOTAL > 0 AND pp.`STATUS` = 1
		  		 LEFT JOIN pembayaran.tagihan_klaim tk ON tk.TAGIHAN = pt.TAGIHAN AND tk.PENJAMIN = IFNULL(pjt.PENJAMIN, pp.PENJAMIN) AND tk.JENIS = IF(pjt.PENJAMIN IS NULL, 2, 1) AND tk.STATUS = 1
		 WHERE t.JENIS = 1
		 	AND t.`STATUS` = 2
		 	AND tp.TAGIHAN = t.ID
		 	AND tp.UTAMA = 1
		 	AND tp.`STATUS` = 1
		 	AND p.NOMOR = tp.PENDAFTARAN
		   AND pt.TAGIHAN = t.ID
		   AND pt.JENIS = 1
		   AND pt.`STATUS` = 2
		   AND tk.ID IS NULL
		   AND pt.TANGGAL BETWEEN VAWAL AND VAKHIR
		 ORDER BY pt.TANGGAL) tk
		 WHERE NOT tk.PENJAMIN IS NULL;
					
	ALTER TABLE TEMP_TAGIHAN_KLAIM 
	   ADD KEY(TAGIHAN),
		ADD KEY(PENJAMIN),
		ADD KEY(JENIS);
	   
	INSERT INTO pembayaran.tagihan_klaim(TAGIHAN, NORM, NOPEN, MASUK, KELUAR, TANGGAL_FINAL, PENJAMIN, JENIS, TOTAL)
	SELECT t.TAGIHAN, t.NORM, t.NOPEN, t.MASUK, t.KELUAR, t.TANGGAL_FINAL, t.PENJAMIN, t.JENIS, t.TOTAL
	  FROM TEMP_TAGIHAN_KLAIM t
	 WHERE NOT EXISTS(SELECT 1 FROM pembayaran.tagihan_klaim tk WHERE tk.TAGIHAN = t.TAGIHAN AND tk.PENJAMIN = t.PENJAMIN AND tk.JENIS = t.JENIS);
	  		 
	UPDATE TEMP_TAGIHAN_KLAIM t,
	  		 pembayaran.tagihan_klaim tk
	  	SET tk.KELUAR = t.KELUAR,
		  	 tk.TANGGAL_FINAL = t.TANGGAL_FINAL,
	  		 tk.TOTAL = t.TOTAL
	 WHERE tk.TAGIHAN = t.TAGIHAN 
	   AND tk.PENJAMIN = t.PENJAMIN 
		AND tk.JENIS = t.JENIS
		AND tk.STATUS = 0;
END//
DELIMITER ;

-- membuang struktur untuk trigger pembayaran.onAfterInsertPembayaranTagihan
DROP TRIGGER IF EXISTS `onAfterInsertPembayaranTagihan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertPembayaranTagihan` AFTER INSERT ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.JENIS IN (1, 8) AND NEW.STATUS = 2 THEN 
		UPDATE pembayaran.tagihan
		   SET STATUS = 2
		 WHERE ID = NEW.TAGIHAN
		   AND STATUS = 1;
		   
		CALL pembayaran.procStoreTagihanKlaim(DATE(NEW.TANGGAL), DATE(NEW.TANGGAL));
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger pembayaran.pembayaran_tagihan_after_update
DROP TRIGGER IF EXISTS `pembayaran_tagihan_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pembayaran_tagihan_after_update` AFTER UPDATE ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
	   IF NEW.JENIS IN (1, 8) THEN  
			UPDATE pembayaran.tagihan
			   SET STATUS = 2
			 WHERE ID = NEW.TAGIHAN
			   AND STATUS = 1;
			
			CALL pembayaran.procStoreTagihanKlaim(DATE(NEW.TANGGAL), DATE(NEW.TANGGAL));
		END IF;
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
