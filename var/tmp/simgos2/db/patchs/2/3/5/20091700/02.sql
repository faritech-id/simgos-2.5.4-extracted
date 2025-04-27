-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.prosesDistribusiTarif
DROP PROCEDURE IF EXISTS `prosesDistribusiTarif`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `prosesDistribusiTarif`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PJUMLAH` DECIMAL(10,2),
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
	DECLARE VJENIS TINYINT;
	DECLARE VKATEGORI CHAR(3);
	
	IF PJENIS = 3 THEN
		
		SELECT t.JENIS INTO VJENIS
		  FROM layanan.tindakan_medis tm
		  		 , master.tindakan t
		 WHERE tm.ID = PREF_ID
		   AND tm.`STATUS` IN (1, 2)
		   AND t.ID = tm.TINDAKAN
		 LIMIT 1;
		   
		IF FOUND_ROWS() > 0 THEN
			UPDATE pembayaran.tagihan t
			   SET t.PROSEDUR_NON_BEDAH = t.PROSEDUR_NON_BEDAH + IF(VJENIS = 1, PTOTAL, 0)
			   	 , t.PROSEDUR_BEDAH = t.PROSEDUR_BEDAH + IF(VJENIS = 2, PTOTAL, 0)
			   	 , t.KONSULTASI = t.KONSULTASI + IF(VJENIS = 3, PTOTAL, 0)
			   	 , t.TENAGA_AHLI = t.TENAGA_AHLI + IF(VJENIS = 4, PTOTAL, 0)
			   	 , t.KEPERAWATAN = t.KEPERAWATAN + IF(VJENIS IN (5, 0), PTOTAL, 0)
			   	 , t.PENUNJANG = t.PENUNJANG + IF(VJENIS = 6, PTOTAL, 0)
			   	 , t.RADIOLOGI = t.RADIOLOGI + IF(VJENIS = 7, PTOTAL, 0)
			   	 , t.LABORATORIUM = t.LABORATORIUM + IF(VJENIS = 8, PTOTAL, 0)
			   	 , t.BANK_DARAH = t.BANK_DARAH + IF(VJENIS = 9, PTOTAL, 0)
			   	 , t.REHAB_MEDIK = t.REHAB_MEDIK + IF(VJENIS = 10, PTOTAL, 0)
			   	 , t.SEWA_ALAT = t.SEWA_ALAT + IF(VJENIS = 11, PTOTAL, 0)
			 WHERE t.ID = PTAGIHAN;
		END IF;
	END IF; 
	
	
	IF PJENIS = 2 THEN	
		SELECT r.REF_ID INTO VJENIS
		  FROM pendaftaran.kunjungan k
		  		 , master.ruangan r
		 WHERE k.NOMOR = PREF_ID
		   AND r.ID = k.RUANGAN
		   AND k.`STATUS` IN (1, 2)
		   AND k.RUANG_KAMAR_TIDUR > 0
		   AND r.JENIS_KUNJUNGAN = 3
		 LIMIT 1;
		
		IF FOUND_ROWS() > 0 THEN
			UPDATE pembayaran.tagihan t
			   SET t.AKOMODASI = t.AKOMODASI + IF(VJENIS = 0, PTOTAL, 0)
			   	 , t.AKOMODASI_INTENSIF = t.AKOMODASI_INTENSIF + IF(VJENIS = 1, PTOTAL, 0)
			   	 , t.RAWAT_INTENSIF = IF(VJENIS = 1, 1, 0)
			   	 , t.LAMA_RAWAT_INTENSIF = t.LAMA_RAWAT_INTENSIF + IF(VJENIS = 1, PJUMLAH, 0)
			 WHERE t.ID = PTAGIHAN;			 			 
		END IF;
	END IF;
	
	IF PJENIS = 1 THEN	
		UPDATE pembayaran.tagihan t
		   SET t.AKOMODASI = t.AKOMODASI + PTOTAL
		 WHERE t.ID = PTAGIHAN;
	END IF;
	
	
	IF PJENIS = 4 THEN
		SELECT LEFT(b.KATEGORI, 3) INTO VKATEGORI
		  FROM layanan.farmasi f
		  		 , inventory.barang b
		 WHERE f.ID = PREF_ID
		   AND b.ID = f.FARMASI
		 LIMIT 1;
		   
		IF FOUND_ROWS() > 0 THEN
			UPDATE pembayaran.tagihan t
			   SET t.OBAT = t.OBAT + IF(VKATEGORI = '101', PTOTAL, 0)
			   	 , t.ALKES = t.ALKES + IF(VKATEGORI = '102', PTOTAL, 0)
			   	 , t.BMHP = t.BMHP + IF(NOT VKATEGORI IN ('101', '102'), PTOTAL, 0)
			 WHERE t.ID = PTAGIHAN;
		END IF;
	END IF;
	
	
	IF PJENIS = 6 THEN
		UPDATE pembayaran.tagihan t
		   SET t.BMHP = t.BMHP + PTOTAL
		 WHERE t.ID = PTAGIHAN;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
