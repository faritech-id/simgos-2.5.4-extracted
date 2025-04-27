-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.5.0.6677
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
				 pjt.PENJAMIN PENJAMIN,
				 1 JENIS, 
				 pjt.TOTAL TOTAL
		  FROM pembayaran.tagihan t,
		  		 pembayaran.tagihan_pendaftaran tp,
		  		 pendaftaran.pendaftaran p
				 LEFT JOIN layanan.pasien_pulang ppg ON ppg.NOPEN = p.NOMOR AND ppg.`STATUS` = 1,
		  		 pembayaran.pembayaran_tagihan pt
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON pjt.TAGIHAN = pt.TAGIHAN AND pjt.TOTAL > 0
		  		 LEFT JOIN pembayaran.tagihan_klaim tk ON tk.TAGIHAN = pt.TAGIHAN AND tk.PENJAMIN = pjt.PENJAMIN AND tk.JENIS = 1 AND tk.STATUS = 1
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
		 WHERE NOT tk.PENJAMIN IS NULL
		UNION
		SELECT TAGIHAN, NORM, NOPEN, MASUK, KELUAR, TANGGAL_FINAL, PENJAMIN, JENIS, TOTAL
		  FROM (
		SELECT pt.TAGIHAN, t.REF NORM, tp.PENDAFTARAN NOPEN, p.TANGGAL MASUK, ppg.TANGGAL KELUAR, pt.TANGGAL TANGGAL_FINAL, 
				 pp.PENJAMIN PENJAMIN,
				 2 JENIS, 
				 pp.TOTAL TOTAL
		  FROM pembayaran.tagihan t,
		  		 pembayaran.tagihan_pendaftaran tp,
		  		 pendaftaran.pendaftaran p
				 LEFT JOIN layanan.pasien_pulang ppg ON ppg.NOPEN = p.NOMOR AND ppg.`STATUS` = 1,
		  		 pembayaran.pembayaran_tagihan pt
		  		 LEFT JOIN pembayaran.piutang_perusahaan pp ON pp.TAGIHAN = pt.TAGIHAN AND pp.TOTAL > 0 AND pp.`STATUS` = 1
		  		 LEFT JOIN pembayaran.tagihan_klaim tk ON tk.TAGIHAN = pt.TAGIHAN AND tk.PENJAMIN = pp.PENJAMIN AND tk.JENIS = 2 AND tk.STATUS = 1
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
		   AND NOT pp.ID IS NULL 
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

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
