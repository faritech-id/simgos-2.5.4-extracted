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

-- membuang struktur untuk procedure pembayaran.reProsesDistribusiTarif
DROP PROCEDURE IF EXISTS `reProsesDistribusiTarif`;
DELIMITER //
CREATE PROCEDURE `reProsesDistribusiTarif`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VKATEGORI CHAR(3);
	DECLARE VREF_ID CHAR(19);
	DECLARE VJENIS, VJENIS1 TINYINT;
	DECLARE VJML DECIMAL(10,2);
	DECLARE VTOTAL DECIMAL(60,2);		
	DECLARE VSUCCESS TINYINT DEFAULT TRUE;		

	IF pembayaran.isFinalTagihan(PTAGIHAN) = 0 THEN
		CALL pembayaran.reStoreTagihan(PTAGIHAN);
	ELSE 
		UPDATE pembayaran.tagihan t
		   SET t.PROSEDUR_NON_BEDAH = 0
		   	 , t.PROSEDUR_BEDAH = 0
		   	 , t.KONSULTASI = 0
		   	 , t.TENAGA_AHLI = 0
		   	 , t.KEPERAWATAN = 0
		   	 , t.PENUNJANG = 0
		   	 , t.RADIOLOGI = 0
		   	 , t.LABORATORIUM = 0
		   	 , t.BANK_DARAH = 0
		   	 , t.REHAB_MEDIK = 0
		   	 , t.AKOMODASI = 0
		   	 , t.AKOMODASI_INTENSIF = 0
		   	 , t.OBAT = 0
		   	 , t.ALKES = 0
		   	 , t.BMHP = 0
		   	 , t.SEWA_ALAT = 0
		   	 , t.RAWAT_INTENSIF = 0
		   	 , t.LAMA_RAWAT_INTENSIF = 0
		 WHERE t.ID = PTAGIHAN;
		BEGIN
			DECLARE PROSES_DISTRIBUSI_TARIF_NOT_FOUND TINYINT DEFAULT FALSE;							
			DECLARE CR_PROSES_DISTRIBUSI_TARIF CURSOR FOR
				SELECT REF_ID, JENIS, JUMLAH, (JUMLAH * (TARIF - IF(PERSENTASE_DISKON = 0, DISKON, (TARIF * (DISKON/100)))))
				  FROM pembayaran.rincian_tagihan rt
				 WHERE rt.TAGIHAN = PTAGIHAN
				   AND rt.`STATUS` > 0;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET PROSES_DISTRIBUSI_TARIF_NOT_FOUND = TRUE;
				
			OPEN CR_PROSES_DISTRIBUSI_TARIF;
			PROSES_DISTRIBUSI_TARIF_EOF: LOOP
				FETCH CR_PROSES_DISTRIBUSI_TARIF INTO VREF_ID, VJENIS, VJML, VTOTAL;
					
				IF PROSES_DISTRIBUSI_TARIF_NOT_FOUND THEN
					UPDATE temp.temp SET ID = 0 WHERE ID = 0;
					LEAVE PROSES_DISTRIBUSI_TARIF_EOF;
				END IF;
				 
				IF VJENIS = 3 THEN
					SET VSUCCESS = TRUE;
					BEGIN
						DECLARE CONTINUE HANDLER FOR NOT FOUND SET VSUCCESS = FALSE;
						
						SELECT t.JENIS INTO VJENIS1
						  FROM layanan.tindakan_medis tm
						  		 , master.tindakan t
						 WHERE tm.ID = VREF_ID
						   AND tm.`STATUS` IN (1, 2)
						   AND t.ID = tm.TINDAKAN
						 LIMIT 1;
						   
						IF FOUND_ROWS() > 0 THEN
							UPDATE pembayaran.tagihan t
							   SET t.PROSEDUR_NON_BEDAH = t.PROSEDUR_NON_BEDAH + IF(VJENIS1 = 1, VTOTAL, 0)
							   	 , t.PROSEDUR_BEDAH = t.PROSEDUR_BEDAH + IF(VJENIS1 = 2, VTOTAL, 0)
							   	 , t.KONSULTASI = t.KONSULTASI + IF(VJENIS1 = 3, VTOTAL, 0)
							   	 , t.TENAGA_AHLI = t.TENAGA_AHLI + IF(VJENIS1 = 4, VTOTAL, 0)
							   	 , t.KEPERAWATAN = t.KEPERAWATAN + IF(VJENIS1 IN (5, 0), VTOTAL, 0)
							   	 , t.PENUNJANG = t.PENUNJANG + IF(VJENIS1 = 6, VTOTAL, 0)
							   	 , t.RADIOLOGI = t.RADIOLOGI + IF(VJENIS1 = 7, VTOTAL, 0)
							   	 , t.LABORATORIUM = t.LABORATORIUM + IF(VJENIS1 = 8, VTOTAL, 0)
							   	 , t.BANK_DARAH = t.BANK_DARAH + IF(VJENIS1 = 9, VTOTAL, 0)
							   	 , t.REHAB_MEDIK = t.REHAB_MEDIK + IF(VJENIS1 = 10, VTOTAL, 0)
							 WHERE t.ID = PTAGIHAN;
						END IF;
					END;
				END IF; 
								
				IF VJENIS = 2 THEN
					SET VSUCCESS = TRUE;
					BEGIN
						DECLARE CONTINUE HANDLER FOR NOT FOUND SET VSUCCESS = FALSE;	
						SELECT r.REF_ID INTO VJENIS1
						  FROM pendaftaran.kunjungan k
						  		 , master.ruangan r
						 WHERE k.NOMOR =VREF_ID
						   AND r.ID = k.RUANGAN
						   AND k.`STATUS` IN (1, 2)
						   AND k.RUANG_KAMAR_TIDUR > 0
						   AND r.JENIS_KUNJUNGAN = 3
						 LIMIT 1;
						
						IF FOUND_ROWS() > 0 THEN
							UPDATE pembayaran.tagihan t
							   SET t.AKOMODASI = t.AKOMODASI + IF(VJENIS1 = 0, VTOTAL, 0)
							   	 , t.AKOMODASI_INTENSIF = t.AKOMODASI_INTENSIF + IF(VJENIS1 = 1, VTOTAL, 0)
							   	 , t.RAWAT_INTENSIF = IF(VJENIS1 = 1, 1, 0)
							   	 , t.LAMA_RAWAT_INTENSIF = t.LAMA_RAWAT_INTENSIF + IF(VJENIS1 = 1, VJML, 0)
							 WHERE t.ID = PTAGIHAN;
						END IF;
					END;
				END IF;
				
				IF VJENIS = 1 THEN	
					UPDATE pembayaran.tagihan t
					   SET t.AKOMODASI = t.AKOMODASI + VTOTAL
					 WHERE t.ID = PTAGIHAN;
				END IF;
							
				IF VJENIS = 4 THEN
					SET VSUCCESS = TRUE;
					BEGIN
						DECLARE CONTINUE HANDLER FOR NOT FOUND SET VSUCCESS = FALSE;
						SELECT LEFT(b.KATEGORI, 3) INTO VKATEGORI
						  FROM layanan.farmasi f
						  		 , inventory.barang b
						 WHERE f.ID = VREF_ID
						   AND b.ID = f.FARMASI
						 LIMIT 1;
						   
						IF FOUND_ROWS() > 0 THEN
							UPDATE pembayaran.tagihan t
							   SET t.OBAT = t.OBAT + IF(VKATEGORI = '101', VTOTAL, 0)
							   	 , t.ALKES = t.ALKES + IF(VKATEGORI = '102', VTOTAL, 0)
							   	 , t.BMHP = t.BMHP + IF(NOT VKATEGORI IN ('101', '102'), VTOTAL, 0)
							 WHERE t.ID = PTAGIHAN;
						END IF;
					END;
				END IF;
							
				IF VJENIS = 6 THEN
					UPDATE pembayaran.tagihan t
					   SET t.BMHP = t.BMHP + VTOTAL
					 WHERE t.ID = PTAGIHAN;
				END IF;
			END LOOP;
			CLOSE CR_PROSES_DISTRIBUSI_TARIF;
		END;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
