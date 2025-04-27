-- --------------------------------------------------------
-- Host:                         192.168.0.1
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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.batalRincianTagihan
DROP PROCEDURE IF EXISTS `batalRincianTagihan`;
DELIMITER //
CREATE PROCEDURE `batalRincianTagihan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT
)
BEGIN
	DECLARE VTARIF DECIMAL(60,2);
	DECLARE VJML DECIMAL(10,2);
	DECLARE VPERSENTASE_DISKON TINYINT;
	DECLARE VDISKON TINYINT;
	DECLARE VTOTAL2 DECIMAL(60, 2);
	DECLARE VTAGIHAN CHAR(10);
	
	SELECT `TAGIHAN`, TARIF, JUMLAH, PERSENTASE_DISKON, DISKON 
	  INTO VTAGIHAN, VTARIF, VJML, VPERSENTASE_DISKON, VDISKON 
	  FROM pembayaran.rincian_tagihan 
	 WHERE TAGIHAN = PTAGIHAN 
	   AND REF_ID = PREF_ID 
		AND JENIS = PJENIS
	 LIMIT 1;
	
	IF	NOT VTAGIHAN IS NULL THEN
		SET VTOTAL2 = (VJML * (VTARIF - IF(VPERSENTASE_DISKON = 0, VDISKON, (VTARIF * (VDISKON/100)))));
		
		UPDATE pembayaran.tagihan
		   SET TOTAL = TOTAL - VTOTAL2
		 WHERE ID = PTAGIHAN;
		 
		UPDATE pembayaran.rincian_tagihan 
		   SET STATUS = 0
		 WHERE TAGIHAN = PTAGIHAN
		 	AND REF_ID = PREF_ID
			AND JENIS = PJENIS;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.finalkanKunjunganBlmFinal
DROP PROCEDURE IF EXISTS `finalkanKunjunganBlmFinal`;
DELIMITER //
CREATE PROCEDURE `finalkanKunjunganBlmFinal`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	UPDATE pembayaran.tagihan t,
	  		 pembayaran.tagihan_pendaftaran tp,
	  		 pendaftaran.kunjungan k
	   SET k.`STATUS` = 2
	 WHERE t.ID = PTAGIHAN
	 	AND t.`STATUS` = 1
	   AND tp.TAGIHAN = t.ID
	   AND tp.`STATUS` = 1
	   AND k.NOPEN = tp.PENDAFTARAN
	   AND k.`STATUS` = 1;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.masihAdaOrderKonsulMutasiYgBlmDiterima
DROP PROCEDURE IF EXISTS `masihAdaOrderKonsulMutasiYgBlmDiterima`;
DELIMITER //
CREATE PROCEDURE `masihAdaOrderKonsulMutasiYgBlmDiterima`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	SELECT CONCAT(r1.DESKRIPSI, ' melakukan',
		IF(r.JENIS_KUNJUNGAN = 3, ' Mutasi ', 
			IF(r.JENIS_KUNJUNGAN = 1, ' Konsul ', ' Order ')
		), 'ke ', r.DESKRIPSI) DESKRIPSI
	  FROM (
	SELECT k.RUANGAN,
			 IF(NOT ks.KUNJUNGAN IS NULL, ks.TUJUAN,
			 	IF(NOT mt.KUNJUNGAN IS NULL, mt.TUJUAN,
				 	IF(NOT olab.KUNJUNGAN IS NULL, olab.TUJUAN,
					 	IF(NOT orad.KUNJUNGAN IS NULL, orad.TUJUAN, 
						 	IF(NOT orep.KUNJUNGAN IS NULL, orep.TUJUAN, NULL)
						)
					)
				)
			 ) TUJUAN,
			 k.MASUK
	  FROM pembayaran.tagihan t,
	  		 pembayaran.tagihan_pendaftaran tp,
	  		 pendaftaran.kunjungan k
			 LEFT JOIN pendaftaran.konsul ks ON ks.KUNJUNGAN = k.NOMOR AND ks.`STATUS` = 1
			 LEFT JOIN pendaftaran.mutasi mt ON mt.KUNJUNGAN = k.NOMOR AND mt.`STATUS` = 1
			 LEFT JOIN layanan.order_lab olab ON olab.KUNJUNGAN = k.NOMOR AND olab.`STATUS` = 1
			 LEFT JOIN layanan.order_rad orad ON orad.KUNJUNGAN = k.NOMOR AND orad.`STATUS` = 1
			 LEFT JOIN layanan.order_resep orep ON orep.KUNJUNGAN = k.NOMOR AND orep.`STATUS` = 1,
	  		 master.ruangan r
	 WHERE t.ID = PTAGIHAN
	 	AND t.`STATUS` = 1
	   AND tp.TAGIHAN = t.ID
	   AND k.NOPEN = tp.PENDAFTARAN
	   AND tp.`STATUS` = 1
	   AND r.ID = k.RUANGAN
	   AND k.`STATUS` = 2
	 ) k LEFT JOIN master.ruangan r1 ON r1.ID = k.RUANGAN
	 	  LEFT JOIN master.ruangan r ON r.ID = k.TUJUAN
	 WHERE NOT k.TUJUAN IS NULL
	 ORDER BY k.MASUK;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.prosesDistribusiTarif
DROP PROCEDURE IF EXISTS `prosesDistribusiTarif`;
DELIMITER //
CREATE PROCEDURE `prosesDistribusiTarif`(
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
		   
		IF NOT VJENIS IS NULL THEN
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
		
		IF NOT VJENIS IS NULL THEN
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
		   
		IF NOT VKATEGORI IS NULL THEN
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
	
	CALL pembayaran.hitungPembulatan(PTAGIHAN);
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganBPJSMode1
DROP PROCEDURE IF EXISTS `prosesPerhitunganBPJSMode1`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganBPJSMode1`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
	DECLARE VKELAS_HAK SMALLINT;
	DECLARE VKELAS_RAWAT SMALLINT;
	DECLARE VTARIF_NAIK_KELAS DECIMAL(60,2);
	DECLARE VTOTAL_TAGIHAN, VTOTAL_TAGIHAN_RS DECIMAL(60,2);
	DECLARE VNAIK_KELAS TINYINT DEFAULT FALSE;
	DECLARE VTOTAL DECIMAL(60,2);
	DECLARE VTOTAL_TARIF_KELAS2 DECIMAL(60,2);
	DECLARE VTOTAL_TARIF_KELAS1 DECIMAL(60,2);
	DECLARE ATURAN_JKN_MENGIKUTI_KEBIJAKAN_RS TINYINT DEFAULT FALSE;
	DECLARE VINTENSIF TINYINT DEFAULT 0;
	
	SELECT pt.NAIK_KELAS INTO VNAIK_KELAS 
	  FROM pembayaran.penjamin_tagihan pt 
	 WHERE pt.TAGIHAN = PTAGIHAN 
	   AND pt.PENJAMIN = 2 
	 LIMIT 1;	
	 
	IF NOT VNAIK_KELAS IS NULL THEN
		SELECT p.KELAS, hg.TOTALTARIF
				 , hg.TARIFSP + hg.TARIFSR + hg.TARIFSI + hg.TARIFSD + hg.TARIFSA + hg.TARIFKLS2
				 , hg.TARIFSP + hg.TARIFSR + hg.TARIFSI + hg.TARIFSD + hg.TARIFSA + hg.TARIFKLS1
		  INTO VKELAS_HAK, VTOTAL, VTOTAL_TARIF_KELAS2, VTOTAL_TARIF_KELAS1
		  FROM pendaftaran.penjamin p
		  	    , pembayaran.tagihan_pendaftaran tp
		  	    LEFT JOIN inacbg.hasil_grouping hg ON tp.PENDAFTARAN = hg.NOPEN
		 WHERE p.JENIS = 2
		   AND tp.PENDAFTARAN = p.NOPEN
		   AND tp.TAGIHAN = PTAGIHAN					 
		   AND tp.`STATUS` = 1
		   AND tp.UTAMA = 1
		 LIMIT 1;
		 
		UPDATE pembayaran.penjamin_tagihan pt
		   SET pt.TOTAL = VTOTAL
		   	 , pt.TARIF_INACBG_KELAS1 = IF(pt.KELAS_KLAIM = 3, VTOTAL, VTOTAL_TARIF_KELAS1)
		 WHERE pt.TAGIHAN = PTAGIHAN
		   AND pt.PENJAMIN = 2;
		
		SET VKELAS_RAWAT = PKELAS;				
		
		SELECT grk.KELAS INTO VKELAS_HAK
		  FROM master.group_referensi_kelas grk
		 WHERE grk.REFERENSI_KELAS = VKELAS_HAK;
		
		IF PJENIS = 2 THEN
			 SELECT grk.KELAS INTO VKELAS_RAWAT
			   FROM master.group_referensi_kelas grk
			  WHERE grk.REFERENSI_KELAS = VKELAS_RAWAT;
			  
			IF VKELAS_RAWAT = 0 THEN
				SET VKELAS_RAWAT = VKELAS_HAK;
			END IF;
		ELSE
			SELECT grk.KELAS INTO VKELAS_RAWAT
			  FROM master.group_referensi_kelas grk
			 WHERE grk.REFERENSI_KELAS = VKELAS_RAWAT;						
		END IF;
		
		IF VKELAS_RAWAT > 2 THEN
			SET VNAIK_KELAS = FALSE;
			
			IF VKELAS_RAWAT > VKELAS_HAK THEN
				SET VNAIK_KELAS = TRUE;
			END IF;
			
			IF VKELAS_RAWAT > 3 THEN
				IF NOT PINSERTED THEN
					UPDATE pembayaran.penjamin_tagihan pt
					   SET pt.TOTAL_TAGIHAN_VIP = IF(pt.TOTAL_TAGIHAN_VIP <= 0, 0, pt.TOTAL_TAGIHAN_VIP - PTOTAL)
					 WHERE pt.TAGIHAN = PTAGIHAN
					   AND pt.PENJAMIN = 2;
				END IF;
				
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_TAGIHAN_VIP = pt.TOTAL_TAGIHAN_VIP + PTOTAL
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;	
		
			IF VKELAS_RAWAT > 4 THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_NAIK_KELAS = pt.TARIF_INACBG_KELAS1
						 , pt.NAIK_DIATAS_VIP = 1
						 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
			IF VKELAS_RAWAT > 3 THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_NAIK_KELAS = pt.TARIF_INACBG_KELAS1
						 , pt.NAIK_KELAS_VIP = 1
						 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
			IF VKELAS_RAWAT > 2 THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_NAIK_KELAS = pt.TARIF_INACBG_KELAS1
						 , pt.NAIK_KELAS = IF(VNAIK_KELAS, 1, 0)
						 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
		ELSE
			IF VKELAS_RAWAT > VKELAS_HAK THEN
				SET VNAIK_KELAS = TRUE;
				SET VTARIF_NAIK_KELAS = IF(VKELAS_RAWAT = 2, VTOTAL_TARIF_KELAS2, VTOTAL_TARIF_KELAS1);				
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.NAIK_KELAS = 1
					    , pt.TOTAL_NAIK_KELAS = VTARIF_NAIK_KELAS
				   	 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
		END IF;
		
		IF VNAIK_KELAS THEN
			IF PJENIS = 2 THEN
			BEGIN
				DECLARE VLAMA_NAIK SMALLINT;
				
				SELECT SUM(rt.JUMLAH) 
				  INTO VLAMA_NAIK
				  FROM pembayaran.rincian_tagihan rt
				  		 , pembayaran.penjamin_tagihan pt
				  		 , pendaftaran.kunjungan k
				  		 	LEFT JOIN master.group_referensi_kelas grk2 ON grk2.REFERENSI_KELAS = k.TITIPAN_KELAS
						 , master.ruang_kamar_tidur rkt
						 , master.ruang_kamar rk
						 , master.group_referensi_kelas grk
				 WHERE rt.TAGIHAN = PTAGIHAN
				   AND rt.JENIS = 2
				   AND pt.TAGIHAN = rt.TAGIHAN
				   AND pt.PENJAMIN = 2
					AND k.NOMOR = rt.REF_ID
					AND rkt.ID = k.RUANG_KAMAR_TIDUR
					AND rk.ID = rkt.RUANG_KAMAR
					AND grk.REFERENSI_KELAS = rk.KELAS
					AND (grk.KELAS = pt.KELAS OR (k.TITIPAN = 1 AND grk2.KELAS = pt.KELAS));
			
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.LAMA_NAIK = VLAMA_NAIK
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END;
			END IF;
		END IF;	
		
		IF VKELAS_RAWAT <= VKELAS_HAK THEN
		BEGIN
			IF NOT PINSERTED THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_TAGIHAN_HAK = pt.TOTAL_TAGIHAN_HAK - PTOTAL
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
			
			UPDATE pembayaran.penjamin_tagihan pt
			   SET pt.TOTAL_TAGIHAN_HAK = pt.TOTAL_TAGIHAN_HAK + PTOTAL
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2;
		END;
		END IF;
		
		BEGIN
			DECLARE VTOTAL_JAMINAN DECIMAL(60,2);
			DECLARE VTOTAL_TAGIHAN_HAK DECIMAL(60,2);
			DECLARE VNAIK_KELAS_VIP TINYINT;
			DECLARE VNAIK_KELAS TINYINT;
			DECLARE VNAIK_DIATAS_VIP TINYINT;
			DECLARE VSELISIH DECIMAL(60,2);
			DECLARE VSUBSIDI DECIMAL(60,2) DEFAULT 0;
			DECLARE VSUBSIDI_TAGIHAN INT;
			DECLARE VSELISIH_MINIMAL, VTOTAL_TAGIHAN_VIP DECIMAL(60,2) DEFAULT 0;
			DECLARE VMINTARIFINACBGPERSEN SMALLINT DEFAULT 75;
			DECLARE VGUNAKANPERSENTASE TINYINT DEFAULT 0;
			DECLARE VPERSENTASE_TARIF_INACBG DECIMAL(10, 2);
			DECLARE VKELAS_KLAIM SMALLINT;
			DECLARE VTARIF_INACBG_KELAS1, VTOTAL_TAGIHAN_VIP_AKOMODASI_DAN_VISITE DECIMAL(60,2);
			
			IF EXISTS(SELECT 1 FROM aplikasi.properti_config pc WHERE pc.ID = 20 AND pc.VALUE = 'TRUE') THEN
				SET VGUNAKANPERSENTASE = 1;
			END IF;
			
			SELECT CAST(pc.VALUE AS SIGNED) INTO VMINTARIFINACBGPERSEN
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 16;
				 
			IF VMINTARIFINACBGPERSEN IS NULL THEN
				SET VMINTARIFINACBGPERSEN = 75;
			END IF;
			
			SELECT pt.TOTAL, pt.TOTAL_NAIK_KELAS, pt.NAIK_KELAS, pt.NAIK_KELAS_VIP, pt.NAIK_DIATAS_VIP
					 , pt.TOTAL_TAGIHAN_HAK, pt.SUBSIDI_TAGIHAN, pt.SELISIH_MINIMAL, pt.TOTAL_TAGIHAN_VIP, pt.KELAS_KLAIM, pt.TARIF_INACBG_KELAS1
					 , pt.TOTAL_TAGIHAN_VIP_AKOMODASI_DAN_VISITE, t.TOTAL, pt.PERSENTASE_TARIF_INACBG_KELAS1
			  INTO VTOTAL_JAMINAN, VTARIF_NAIK_KELAS, VNAIK_KELAS, VNAIK_KELAS_VIP, VNAIK_DIATAS_VIP
			  	    , VTOTAL_TAGIHAN_HAK, VSUBSIDI_TAGIHAN, VSELISIH_MINIMAL, VTOTAL_TAGIHAN_VIP, VKELAS_KLAIM, VTARIF_INACBG_KELAS1
			  	    , VTOTAL_TAGIHAN_VIP_AKOMODASI_DAN_VISITE, VTOTAL_TAGIHAN_RS, VPERSENTASE_TARIF_INACBG
			  FROM pembayaran.penjamin_tagihan pt,
			  		 pembayaran.tagihan t
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2
				AND t.ID = pt.TAGIHAN;
			   
			IF NOT VTOTAL_JAMINAN IS NULL THEN
			BEGIN					
				SET VSELISIH = VTOTAL_TAGIHAN_RS - VTOTAL_JAMINAN;
				SET VSELISIH = IF(VSELISIH <= 0, 0, VSELISIH);
														
				IF VSELISIH > 0 THEN
					IF VNAIK_KELAS = 0 AND VNAIK_KELAS_VIP = 0 THEN
						SET VSUBSIDI = VSELISIH;					
					END IF;
				END IF;
				
				IF VNAIK_KELAS_VIP = 1 OR VNAIK_DIATAS_VIP = 1 THEN
				BEGIN
					DECLARE VSELMIN DECIMAL(60, 2);
					DECLARE VSELMAX DECIMAL(60, 2);
					DECLARE VSELTGHN DECIMAL(60, 2);			
					
					IF VGUNAKANPERSENTASE = 1 THEN
						IF VPERSENTASE_TARIF_INACBG > 0 THEN
							SET VMINTARIFINACBGPERSEN = IF(VPERSENTASE_TARIF_INACBG > 75, 75, VPERSENTASE_TARIF_INACBG);
						END IF;
					END IF; 
											
					SET VSELMAX = VTARIF_INACBG_KELAS1 * (75/100);
					SET VSELTGHN = VTOTAL_TAGIHAN_VIP - VTARIF_INACBG_KELAS1;
					SET VSELTGHN = IF(VSELTGHN <= 0, 0, VSELTGHN);
					SET VSELMIN = VTARIF_NAIK_KELAS * (VMINTARIFINACBGPERSEN/100);
					
			   	IF VSELISIH > 0 THEN
				   	IF VKELAS_KLAIM = 3 THEN
				   		IF VTOTAL_TAGIHAN_VIP <= VSELMAX THEN
						   	SET VSELISIH_MINIMAL = IF(VGUNAKANPERSENTASE = 1, VSELMIN, VTOTAL_TAGIHAN_VIP);
						   ELSE
						   	SET VSELISIH_MINIMAL = IF(VGUNAKANPERSENTASE = 1, VSELMIN, VSELMAX);
						   END IF;
				   	ELSE
				   		IF VTOTAL_TAGIHAN_VIP <= VSELMAX THEN
						   	SET VSELISIH_MINIMAL = IF(VGUNAKANPERSENTASE = 1, VSELMIN, VTOTAL_TAGIHAN_VIP);
						   ELSE
						   	SET VSELISIH_MINIMAL = IF(VGUNAKANPERSENTASE = 1, VSELMIN, VSELMAX);
						   END IF;
				   	END IF;
				   ELSE
				   	SET VSELISIH_MINIMAL = 0;
				   END IF;
				   
				   UPDATE pembayaran.penjamin_tagihan pt
					   SET pt.TOTAL_NAIK_KELAS = IF(VSELISIH > 0, pt.TARIF_INACBG_KELAS1, VTOTAL_TAGIHAN_RS),
							 pt.SELISIH_MINIMAL = VSELISIH_MINIMAL
					 WHERE pt.TAGIHAN = PTAGIHAN
			   		AND pt.PENJAMIN = 2;
					
			   	SET VSUBSIDI = 0;
			   	UPDATE pembayaran.subsidi_tagihan st
			   	   SET st.TOTAL = VSUBSIDI
			   	 WHERE st.ID = VSUBSIDI_TAGIHAN;
				END;
				ELSE
					IF VNAIK_KELAS = 1 THEN
						SET VSUBSIDI = 0;
				   	UPDATE pembayaran.subsidi_tagihan st
				   	   SET st.TOTAL = VSUBSIDI
				   	 WHERE st.ID = VSUBSIDI_TAGIHAN;
					END IF;
				END IF;
			END;
			END IF;
			
			IF VSUBSIDI > 0 THEN
				IF VSUBSIDI_TAGIHAN > 0 THEN
					IF EXISTS(
						SELECT 1
						  FROM pembayaran.subsidi_tagihan st
						 WHERE st.ID = VSUBSIDI_TAGIHAN
						   AND st.`STATUS` = 1
						 LIMIT 1) THEN
						UPDATE pembayaran.subsidi_tagihan st
				   	   SET st.TOTAL = VSUBSIDI
				   	 WHERE st.ID = VSUBSIDI_TAGIHAN;
				   ELSE
				   	SET VSUBSIDI_TAGIHAN = 0;
					END IF;
				END IF;
				
				IF VSUBSIDI_TAGIHAN = 0 THEN
					INSERT INTO pembayaran.subsidi_tagihan(TAGIHAN, TOTAL, TANGGAL)
					     VALUES(PTAGIHAN, VSUBSIDI, NOW());
					SET VSUBSIDI_TAGIHAN = LAST_INSERT_ID();
					
					UPDATE pembayaran.penjamin_tagihan pt
					   SET pt.SUBSIDI_TAGIHAN = VSUBSIDI_TAGIHAN
					 WHERE pt.TAGIHAN = PTAGIHAN
			   		AND pt.PENJAMIN = 2;				   
				END IF;
			END IF;								
		END;
	ELSE
		DELETE FROM pembayaran.subsidi_tagihan WHERE TAGIHAN = PTAGIHAN;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganBPJSSebelum2023
DROP PROCEDURE IF EXISTS `prosesPerhitunganBPJSSebelum2023`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganBPJSSebelum2023`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
	DECLARE VKELAS_HAK SMALLINT;
	DECLARE VKELAS_RAWAT SMALLINT;
	DECLARE VTARIF_NAIK_KELAS DECIMAL(60,2);
	DECLARE VTOTAL_TAGIHAN DECIMAL(60,2);
	DECLARE VNAIK_KELAS TINYINT DEFAULT FALSE;
	DECLARE VTOTAL DECIMAL(60,2);
	DECLARE VTOTAL_TARIF_KELAS2 DECIMAL(60,2);
	DECLARE VTOTAL_TARIF_KELAS1 DECIMAL(60,2);
	DECLARE ATURAN_JKN_MENGIKUTI_KEBIJAKAN_RS TINYINT DEFAULT FALSE;
	DECLARE VINTENSIF TINYINT DEFAULT 0;
	
	SELECT pt.NAIK_KELAS INTO VNAIK_KELAS 
	  FROM pembayaran.penjamin_tagihan pt 
	 WHERE pt.TAGIHAN = PTAGIHAN 
	   AND pt.PENJAMIN = 2 
	 LIMIT 1;	
	 
	IF NOT VNAIK_KELAS IS NULL THEN
		SET VTOTAL_TAGIHAN = pembayaran.getTotalTagihan(PTAGIHAN);
		
		SELECT p.KELAS, hg.TOTALTARIF
				 , hg.TARIFSP + hg.TARIFSR + hg.TARIFSI + hg.TARIFSD + hg.TARIFSA + hg.TARIFKLS2
				 , hg.TARIFSP + hg.TARIFSR + hg.TARIFSI + hg.TARIFSD + hg.TARIFSA + hg.TARIFKLS1
		  INTO VKELAS_HAK, VTOTAL, VTOTAL_TARIF_KELAS2, VTOTAL_TARIF_KELAS1
		  FROM pendaftaran.penjamin p
		  	    , pembayaran.tagihan_pendaftaran tp
		  	    LEFT JOIN inacbg.hasil_grouping hg ON tp.PENDAFTARAN = hg.NOPEN
		 WHERE p.JENIS = 2
		   AND tp.PENDAFTARAN = p.NOPEN
		   AND tp.TAGIHAN = PTAGIHAN					 
		   AND tp.`STATUS` = 1
		   AND tp.UTAMA = 1
		 LIMIT 1;
		 
		UPDATE pembayaran.penjamin_tagihan pt
		   SET pt.TOTAL = VTOTAL
		   	 , pt.TARIF_INACBG_KELAS1 = IF(pt.KELAS_KLAIM = 3, VTOTAL, VTOTAL_TARIF_KELAS1)
		 WHERE pt.TAGIHAN = PTAGIHAN
		   AND pt.PENJAMIN = 2;
		
		SET VKELAS_RAWAT = PKELAS;				
		
		SELECT grk.KELAS INTO VKELAS_HAK
		  FROM master.group_referensi_kelas grk
		 WHERE grk.REFERENSI_KELAS = VKELAS_HAK;
		
		IF PJENIS = 2 THEN
			 SELECT grk.KELAS INTO VKELAS_RAWAT
			   FROM master.group_referensi_kelas grk
			  WHERE grk.REFERENSI_KELAS = VKELAS_RAWAT;
			  
			IF VKELAS_RAWAT = 0 THEN
				SET VKELAS_RAWAT = VKELAS_HAK;
			END IF;
		ELSE
			SELECT grk.KELAS INTO VKELAS_RAWAT
			  FROM master.group_referensi_kelas grk
			 WHERE grk.REFERENSI_KELAS = VKELAS_RAWAT;						
		END IF;
		
		IF VKELAS_RAWAT > 3 THEN
			SET VNAIK_KELAS = TRUE;
			
			IF PJENIS = 3 OR PJENIS = 2 THEN
				IF EXISTS(SELECT 1
				  FROM aplikasi.properti_config pc
				 WHERE pc.ID = 57
				   AND VALUE = 'TRUE') THEN
				BEGIN
					DECLARE VEKSEKUSI TINYINT DEFAULT 0;
					IF PJENIS = 2 THEN
						SET VEKSEKUSI = 1;
					ELSE
						IF EXISTS(
							SELECT 1 
							  FROM layanan.tindakan_medis tm,
							  	 	 `master`.group_pemeriksaan gp,
							  		 `master`.mapping_group_pemeriksaan mgp
							 WHERE tm.ID = PREF_ID
							   AND gp.JENIS = 3
							   AND gp.KODE = '10' 
							   AND mgp.GROUP_PEMERIKSAAN_ID = gp.ID
							   AND mgp.PEMERIKSAAN = tm.TINDAKAN
							 LIMIT 1
							) THEN
							SET VEKSEKUSI = 1;
						END IF; 
					END IF;
					
					IF VEKSEKUSI = 1 THEN
						IF NOT PINSERTED THEN
							UPDATE pembayaran.penjamin_tagihan pt
							   SET pt.TOTAL_TAGIHAN_VIP = IF(pt.TOTAL_TAGIHAN_VIP = 0, 0, pt.TOTAL_TAGIHAN_VIP - PTOTAL)
							 WHERE pt.TAGIHAN = PTAGIHAN
							   AND pt.PENJAMIN = 2;
						END IF;
						
						UPDATE pembayaran.penjamin_tagihan pt
						   SET pt.TOTAL_TAGIHAN_VIP = pt.TOTAL_TAGIHAN_VIP + PTOTAL
						 WHERE pt.TAGIHAN = PTAGIHAN
						   AND pt.PENJAMIN = 2;
					END IF;
				END;
				END IF;
			END IF;
			
			IF VKELAS_RAWAT > 4 THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_NAIK_KELAS = pt.TARIF_INACBG_KELAS1
						 , pt.NAIK_DIATAS_VIP = 1
						 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			ELSE
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_NAIK_KELAS = pt.TARIF_INACBG_KELAS1
						 , pt.NAIK_KELAS_VIP = 1
						 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
		ELSE
			IF VKELAS_RAWAT > VKELAS_HAK THEN
				SET VNAIK_KELAS = TRUE;
				SET VTARIF_NAIK_KELAS = IF(VKELAS_RAWAT = 2, VTOTAL_TARIF_KELAS2, VTOTAL_TARIF_KELAS1);				
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.NAIK_KELAS = 1
					    , pt.TOTAL_NAIK_KELAS = VTARIF_NAIK_KELAS
				   	 , pt.KELAS = IF(VKELAS_RAWAT >= pt.KELAS, VKELAS_RAWAT, pt.KELAS)
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
		END IF;
		
		IF VNAIK_KELAS THEN
			IF PJENIS = 2 THEN
			BEGIN
				DECLARE VLAMA_NAIK SMALLINT;
				
				SELECT SUM(rt.JUMLAH) 
				  INTO VLAMA_NAIK
				  FROM pembayaran.rincian_tagihan rt
				  		 , pembayaran.penjamin_tagihan pt
				  		 , pendaftaran.kunjungan k
				  		 	LEFT JOIN master.group_referensi_kelas grk2 ON grk2.REFERENSI_KELAS = k.TITIPAN_KELAS
						 , master.ruang_kamar_tidur rkt
						 , master.ruang_kamar rk
						 , master.group_referensi_kelas grk
				 WHERE rt.TAGIHAN = PTAGIHAN
				   AND rt.JENIS = 2
				   AND pt.TAGIHAN = rt.TAGIHAN
				   AND pt.PENJAMIN = 2
					AND k.NOMOR = rt.REF_ID
					AND rkt.ID = k.RUANG_KAMAR_TIDUR
					AND rk.ID = rkt.RUANG_KAMAR
					AND grk.REFERENSI_KELAS = rk.KELAS
					AND (grk.KELAS = pt.KELAS OR (k.TITIPAN = 1 AND grk2.KELAS = pt.KELAS));
			
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.LAMA_NAIK = VLAMA_NAIK
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END;
			END IF;
			
			IF EXISTS(SELECT 1
				  FROM aplikasi.properti_config pc
				 WHERE pc.ID = 9
				   AND VALUE = 'TRUE') THEN
			BEGIN			
				DECLARE VTOTAL_HAK_KELAS DECIMAL(60,2);   
				DECLARE VTOTAL_NAIK_KELAS DECIMAL(60,2);
				
				SET ATURAN_JKN_MENGIKUTI_KEBIJAKAN_RS = TRUE;

				SELECT SUM(rt.JUMLAH * master.getTarifRuangRawat(VKELAS_HAK, IF(pc.VALUE = 'TRUE', p.TANGGAL, k.MASUK)))
						 , SUM(rt.JUMLAH * rt.TARIF)
				  INTO VTOTAL_HAK_KELAS, VTOTAL_NAIK_KELAS
				  FROM pembayaran.rincian_tagihan rt
				  		 , pendaftaran.kunjungan k
				  		 	LEFT JOIN master.group_referensi_kelas grk2 ON grk2.REFERENSI_KELAS = k.TITIPAN_KELAS
						 , master.ruang_kamar_tidur rkt
						 , master.ruang_kamar rk
						 , master.group_referensi_kelas grk
						 , pendaftaran.pendaftaran p
						 , aplikasi.properti_config pc
				 WHERE rt.TAGIHAN = PTAGIHAN
				   AND rt.JENIS = 2
					AND k.NOMOR = rt.REF_ID
					AND rkt.ID = k.RUANG_KAMAR_TIDUR
					AND rk.ID = rkt.RUANG_KAMAR
					AND grk.REFERENSI_KELAS = rk.KELAS
					AND (grk.KELAS > VKELAS_HAK OR (k.TITIPAN = 1 AND grk2.KELAS > VKELAS_HAK))
					AND p.NOMOR = k.NOPEN
					AND pc.ID = 9;
					
				IF NOT VTOTAL_HAK_KELAS IS NULL THEN
					IF NOT ISNULL(VTOTAL_HAK_KELAS) AND NOT ISNULL(VTOTAL_NAIK_KELAS) THEN			
						UPDATE pembayaran.penjamin_tagihan pt
						   SET pt.TOTAL = VTOTAL_HAK_KELAS
						   	 , pt.TOTAL_NAIK_KELAS = VTOTAL_NAIK_KELAS
						 WHERE pt.TAGIHAN = PTAGIHAN
						   AND pt.PENJAMIN = 2;
					END IF;
				END IF;
			END;	
			END IF;
		END IF;
		
		IF VKELAS_RAWAT <= VKELAS_HAK THEN
		BEGIN
			IF NOT PINSERTED THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_TAGIHAN_HAK = pt.TOTAL_TAGIHAN_HAK - PTOTAL
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
			
			UPDATE pembayaran.penjamin_tagihan pt
			   SET pt.TOTAL_TAGIHAN_HAK = pt.TOTAL_TAGIHAN_HAK + PTOTAL
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2;
		END;
		END IF;
		
		BEGIN
			DECLARE VTOTAL_JAMINAN DECIMAL(60,2);
			DECLARE VTOTAL_TAGIHAN_HAK DECIMAL(60,2);
			DECLARE VNAIK_KELAS_VIP TINYINT;
			DECLARE VNAIK_KELAS TINYINT;
			DECLARE VNAIK_DIATAS_VIP TINYINT;
			DECLARE VSELISIH DECIMAL(60,2);
			DECLARE VSUBSIDI DECIMAL(60,2) DEFAULT 0;
			DECLARE VSUBSIDI_TAGIHAN INT;
			DECLARE VSELISIH_MINIMAL, VTOTAL_TAGIHAN_VIP DECIMAL(60,2) DEFAULT 0;
			DECLARE VMINTARIFINACBGPERSEN SMALLINT;
			
			SELECT CAST(pc.VALUE AS SIGNED) INTO VMINTARIFINACBGPERSEN
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 16;
				 
			IF VMINTARIFINACBGPERSEN IS NULL THEN
				SET VMINTARIFINACBGPERSEN = 0;
			END IF;
			
			SELECT pt.TOTAL, pt.TOTAL_NAIK_KELAS, pt.NAIK_KELAS, pt.NAIK_KELAS_VIP, pt.NAIK_DIATAS_VIP, pt.TOTAL_TAGIHAN_HAK, pt.SUBSIDI_TAGIHAN, pt.SELISIH_MINIMAL, pt.TOTAL_TAGIHAN_VIP
			  INTO VTOTAL_JAMINAN, VTARIF_NAIK_KELAS, VNAIK_KELAS, VNAIK_KELAS_VIP, VNAIK_DIATAS_VIP, VTOTAL_TAGIHAN_HAK, VSUBSIDI_TAGIHAN, VSELISIH_MINIMAL, VTOTAL_TAGIHAN_VIP
			  FROM pembayaran.penjamin_tagihan pt
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2;
			   
			IF NOT VTOTAL_JAMINAN IS NULL THEN
			BEGIN					
				SET VSELISIH = VTOTAL_TAGIHAN - VTOTAL_JAMINAN;
				SET VSELISIH = IF(VSELISIH <= 0, 0, VSELISIH);
														
				IF VSELISIH > 0 THEN
					IF VNAIK_KELAS = 0 AND VNAIK_KELAS_VIP = 0 THEN
						SET VSUBSIDI = VSELISIH;
					ELSE
						IF VNAIK_DIATAS_VIP = 1 THEN
							IF VTOTAL_TAGIHAN_HAK > VTOTAL_JAMINAN THEN
								SET VSUBSIDI = VTOTAL_TAGIHAN_HAK - VTOTAL_JAMINAN;
							END IF;						
						END IF;														
					END IF;
				END IF;
				
				IF VNAIK_KELAS_VIP = 1 THEN
				BEGIN
					DECLARE VSEL DECIMAL(60,2);
					DECLARE VSELMIN DECIMAL(60, 2);
					DECLARE VSELMAX DECIMAL(60, 2);		
											
					SET VSEL = VTOTAL_TAGIHAN - VTARIF_NAIK_KELAS;
					SET VSELMIN = VTARIF_NAIK_KELAS * (VMINTARIFINACBGPERSEN/100);
					SET VSELMAX = VTARIF_NAIK_KELAS * (75/100);
					
					IF NOT EXISTS(SELECT 1 FROM aplikasi.properti_config pc WHERE pc.ID = 20 AND pc.VALUE = 'TRUE') THEN
						IF VMINTARIFINACBGPERSEN != 75 THEN
							IF VSEL <= VSELMIN THEN
								SET VSELISIH_MINIMAL = VSELMIN;
							ELSE
								IF VSEL > VSELMAX THEN
									SET VSELISIH_MINIMAL = VSELMAX;
								ELSE
									SET VSELISIH_MINIMAL = VSEL;
								END IF;
							END IF;
						ELSE
							SET VSELISIH_MINIMAL = VSELMAX;
						END IF;
						
						UPDATE pembayaran.penjamin_tagihan pt
						   SET pt.SELISIH_MINIMAL = VSELISIH_MINIMAL
						 WHERE pt.TAGIHAN = PTAGIHAN
				   		AND pt.PENJAMIN = 2;
				   ELSE
				   	IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 57
						   AND VALUE = 'TRUE') THEN
						   IF VTOTAL_TAGIHAN_VIP <= VSELMAX THEN
						   	SET VSELISIH_MINIMAL = VTOTAL_TAGIHAN_VIP;
						   ELSE
						   	SET VSELISIH_MINIMAL = VSELMAX;
						   END IF;
						   
						   UPDATE pembayaran.penjamin_tagihan pt
							   SET pt.SELISIH_MINIMAL = VSELISIH_MINIMAL
							 WHERE pt.TAGIHAN = PTAGIHAN
					   		AND pt.PENJAMIN = 2;
						END IF;
						
				   	SET VSUBSIDI = 0;
				   	UPDATE pembayaran.subsidi_tagihan st
				   	   SET st.TOTAL = VSUBSIDI
				   	 WHERE st.ID = VSUBSIDI_TAGIHAN;
					END IF;
				END;
				ELSE
					IF VNAIK_KELAS = 1 THEN
						SET VSUBSIDI = 0;
				   	UPDATE pembayaran.subsidi_tagihan st
				   	   SET st.TOTAL = VSUBSIDI
				   	 WHERE st.ID = VSUBSIDI_TAGIHAN;
					END IF;
				END IF;
			END;
			END IF;
			
			IF ATURAN_JKN_MENGIKUTI_KEBIJAKAN_RS THEN
				SET VSUBSIDI = 0;
			END IF;
			
			IF VSUBSIDI > 0 THEN
				IF VSUBSIDI_TAGIHAN > 0 THEN
					IF EXISTS(
						SELECT 1
						  FROM pembayaran.subsidi_tagihan st
						 WHERE st.ID = VSUBSIDI_TAGIHAN
						   AND st.`STATUS` = 1
						 LIMIT 1) THEN
						UPDATE pembayaran.subsidi_tagihan st
				   	   SET st.TOTAL = VSUBSIDI
				   	 WHERE st.ID = VSUBSIDI_TAGIHAN;
				   ELSE
				   	SET VSUBSIDI_TAGIHAN = 0;
					END IF;
				END IF;
				
				IF VSUBSIDI_TAGIHAN = 0 THEN
					INSERT INTO pembayaran.subsidi_tagihan(TAGIHAN, TOTAL, TANGGAL)
					     VALUES(PTAGIHAN, VSUBSIDI, NOW());
					SET VSUBSIDI_TAGIHAN = LAST_INSERT_ID();
					
					UPDATE pembayaran.penjamin_tagihan pt
					   SET pt.SUBSIDI_TAGIHAN = VSUBSIDI_TAGIHAN
					 WHERE pt.TAGIHAN = PTAGIHAN
			   		AND pt.PENJAMIN = 2;				   
				END IF;
			END IF;								
		END;
	ELSE
		DELETE FROM pembayaran.subsidi_tagihan WHERE TAGIHAN = PTAGIHAN;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganTotalTagihanPerkelas
DROP PROCEDURE IF EXISTS `prosesPerhitunganTotalTagihanPerkelas`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganTotalTagihanPerkelas`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
	DECLARE VTOTAL_TAGIHAN DECIMAL(60,2);

	SELECT SUM(TARIF_HAK_KELAS * JUMLAH) INTO VTOTAL_TAGIHAN
	FROM (
		/* Administrasi */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
					 @RUANGAN := CONCAT(
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(r.DESKRIPSI,' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), 
							IF(NOT r1.DESKRIPSI IS NULL, r1.DESKRIPSI, r2.DESKRIPSI))
					 ) RUANGAN,
					 adm.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 1, 
					 	IF(tadm.ADMINISTRASI = 2, kp.TANGGAL, kj.KELUAR), 
						 NULL) TANGGAL,
					 rt.JUMLAH, rt.TARIF, rt.`STATUS`, 
					 @JENIS_KUNJUNGAN := IF(r.JENIS_KUNJUNGAN = 3, r.JENIS_KUNJUNGAN, r1.JENIS_KUNJUNGAN) JENIS_KUNJUNGAN,
					 rt.TARIF TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  	    /* Karcis RJ or RI */
					 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rt.REF_ID AND rt.JENIS = 1
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN
			  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
			  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
			  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
			  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
			  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 
			  		 /* Pelayanan Farmasi */
					 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
			  		 LEFT JOIN `master`.ruangan r2 ON r2.ID = kj.RUANGAN
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 1 AND rt.STATUS = 1
				AND NOT adm.ID = 1
				
			UNION
			/* Kartu */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
					 @RUANGAN,
					 adm.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 krtp.TANGGAL,
					 rt.JUMLAH, rt.TARIF, rt.`STATUS`, 
					 @JENIS_KUNJUNGAN JENIS_KUNJUNGAN,
					 rt.TARIF TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rt.REF_ID	
			  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
			  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 1 AND rt.STATUS = 1
			   AND adm.ID = 1
			   
			UNION
			/* Paket */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
					 ) RUANGAN,
					 pkt.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
					 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN,
					 rt.TARIF TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID
			  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
			  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
			  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
			  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 5 AND rt.STATUS = 1
			   
			UNION
			/* Akomodasi */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID,
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')', IF(kjgn.TITIPAN = 1, CONCAT(' Pasien Titipan ', kls1.DESKRIPSI), '')), '')
					 ) RUANGAN,
					 IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')', IF(kjgn.TITIPAN = 1, CONCAT(' Pasien Titipan ', kls1.DESKRIPSI), '')), '') LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
					 rt.JUMLAH, 
					 rt.TARIF - IF(rt.PERSENTASE_DISKON = 0, rt.DISKON, rt.TARIF * (rt.DISKON/100)) TARIF, 
					 rt.`STATUS`, 
					 r.JENIS_KUNJUNGAN,
					 IF(rt.JENIS=2 AND grk.KELAS!=0 AND ((kjgn.TITIPAN=0 AND grk.KELAS > pj.KELAS ) OR (kjgn.TITIPAN=1 AND grt.KELAS > pj.KELAS )), `master`.getTarifRuangRawat(pj.KELAS, p.TANGGAL), rt.TARIF) TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 LEFT JOIN `master`.referensi kls1 ON kls1.JENIS = 19 AND kls1.ID = kjgn.TITIPAN_KELAS
			  		 LEFT JOIN `master`.group_referensi_kelas grk ON rk.KELAS=grk.REFERENSI_KELAS
					 LEFT JOIN `master`.group_referensi_kelas grt ON kjgn.TITIPAN_KELAS=grt.REFERENSI_KELAS AND kjgn.TITIPAN=1
			  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 2 AND rt.STATUS = 1
			   
			UNION
			/* Tindakan */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
					 ) RUANGAN,
					 t.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
					 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN,
					 IF(rt.JENIS=3 AND grk.KELAS!=0 AND ((kjgn.TITIPAN=0 AND grk.KELAS > pj.KELAS ) OR (kjgn.TITIPAN=1 AND grt.KELAS > pj.KELAS ))
					 		,`master`.getTarifTindakan(tm.TINDAKAN, pj.KELAS, p.TANGGAL), rt.TARIF) TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
			  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			  		 LEFT JOIN `master`.group_referensi_kelas grk ON rk.KELAS=grk.REFERENSI_KELAS
					 LEFT JOIN `master`.group_referensi_kelas grt ON kjgn.TITIPAN_KELAS=grt.REFERENSI_KELAS AND kjgn.TITIPAN=1
			  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 3 AND rt.STATUS = 1
			   
			UNION
			/* Farmasi */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
					 ) RUANGAN,
					 b.NAMA LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
					 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN, 
					 rt.TARIF TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4
			  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 4 AND rt.STATUS = 1
			   
			UNION
			/* O2 */
			SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
					 CONCAT(r.DESKRIPSI,
					 	IF(r.JENIS_KUNJUNGAN = 3,
					 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
					 ) RUANGAN,
					 ref.DESKRIPSI LAYANAN,
					 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
					 rt.TARIF_ID,
					 IF(rt.JENIS =  6, kjgn.MASUK, NULL) TANGGAL, 
					 rt.JUMLAH, rt.TARIF, rt.`STATUS`, r.JENIS_KUNJUNGAN,
					 rt.TARIF TARIF_HAK_KELAS
			  FROM pembayaran.rincian_tagihan rt
			  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID
			  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
			  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
			  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
			  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
			  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
			  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			 WHERE rt.TAGIHAN = PTAGIHAN
			   AND rt.JENIS = 6 AND rt.STATUS = 1
	) ab;
	
	UPDATE pembayaran.penjamin_tagihan
	   SET TOTAL = VTOTAL_TAGIHAN
	 WHERE TAGIHAN = PTAGIHAN
	   AND KE = 1;
END//
DELIMITER ;

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
						   
						IF NOT VJENIS1 IS NULL THEN
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
						
						IF NOT VJENIS1 IS NULL THEN
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
						   
						IF NOT VKATEGORI IS NULL THEN
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

-- membuang struktur untuk procedure pembayaran.reStoreTagihan
DROP PROCEDURE IF EXISTS `reStoreTagihan`;
DELIMITER //
CREATE PROCEDURE `reStoreTagihan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VNORM INT;
	DECLARE VPENDAFTARAN CHAR(10);
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VKARTU CHAR(11);
	DECLARE VKARCIS CHAR(11);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF DECIMAL(60,2);
	DECLARE VQTY DECIMAL(60,2);
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VJENIS_KUNJUNGAN SMALLINT;
	DECLARE VTANGGAL_PENDAFTARAN DATETIME;
	DECLARE VKELAS SMALLINT DEFAULT 0;
	DECLARE VKUNJUNGAN_TMP, VREF CHAR(19);
	DECLARE VTANGGAL_TAGIHAN DATETIME DEFAULT NULL;
	DECLARE VTGL_DAFTAR_PASIEN DATETIME;
	DECLARE VPASIEN_BARU TINYINT DEFAULT 0;
	DECLARE VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN TINYINT DEFAULT FALSE;	
	
	IF pembayaran.isFinalTagihan(PTAGIHAN) = 0 THEN		
		SELECT t.TANGGAL, p.TANGGAL INTO VTANGGAL_TAGIHAN, VTGL_DAFTAR_PASIEN
		  FROM pembayaran.tagihan t, master.pasien p
		 WHERE t.ID = PTAGIHAN
		   AND t.JENIS = 1
			AND p.NORM = t.REF
		 LIMIT 1;
		 
		SET VPASIEN_BARU = IF(DATE(VTGL_DAFTAR_PASIEN) = DATE(VTANGGAL_TAGIHAN), 1, 0);
				
		IF EXISTS(SELECT 1
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 23
			   AND VALUE = 'TRUE') THEN		
			SET VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN = TRUE;
		END IF;
				
		UPDATE pembayaran.tagihan t
		   SET t.TOTAL = 0
		   	 , t.PROSEDUR_NON_BEDAH = 0
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
		   	 , t.OBAT_KRONIS = 0
		   	 , t.OBAT_KEMOTERAPI = 0
		   	 , t.ALKES = 0
		   	 , t.BMHP = 0
		   	 , t.SEWA_ALAT = 0
		   	 , t.RAWAT_INTENSIF = 0
		   	 , t.LAMA_RAWAT_INTENSIF = 0
		 WHERE t.ID = PTAGIHAN
		   AND t.STATUS = 1;		   
		
		UPDATE pembayaran.penjamin_tagihan pt
		   SET pt.TOTAL_NAIK_KELAS = 0,
		   	 pt.NAIK_KELAS = 0,
		   	 pt.NAIK_KELAS_VIP = 0,
		   	 pt.NAIK_DIATAS_VIP = 0,
		   	 pt.TOTAL_TAGIHAN_HAK = 0,	   	
		   	 pt.KELAS = 0,
		   	 pt.LAMA_NAIK = 0,
		   	 pt.TOTAL_TAGIHAN_VIP = 0,
		   	 pt.TOTAL_TAGIHAN_VIP_AKOMODASI_DAN_VISITE = 0
		 WHERE pt.TAGIHAN = PTAGIHAN;
		 
		UPDATE pembayaran.penjamin_tagihan pt,
		       pembayaran.subsidi_tagihan st
		   SET st.TOTAL = 0
		 WHERE pt.TAGIHAN = PTAGIHAN
		   AND st.TAGIHAN = pt.TAGIHAN
			AND st.ID = pt.SUBSIDI_TAGIHAN;
			
		IF NOT EXISTS(SELECT 1 FROM pembayaran.penjamin_tagihan pt WHERE pt.TAGIHAN = PTAGIHAN AND pt.KE = 1) THEN
			UPDATE pembayaran.subsidi_tagihan st
			   SET st.TOTAL = 0
			WHERE st.TAGIHAN = PTAGIHAN
			  AND st.`STATUS` = 1;
		END IF;
		 		   		
		SELECT rt.REF_ID INTO VKARTU
		  FROM pembayaran.rincian_tagihan rt,
		  		 master.tarif_administrasi ta
		 WHERE rt.TAGIHAN = PTAGIHAN
		 	AND rt.JENIS = 1
		   AND ta.ID = rt.TARIF_ID	   
		   AND ta.ADMINISTRASI = 1;
		   		
		INSERT INTO pembayaran.rincian_tagihan_temp(TANGGAL, TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, STATUS)
		  SELECT NOW(), TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, STATUS
		    FROM pembayaran.rincian_tagihan WHERE TAGIHAN = PTAGIHAN;
						
		DELETE FROM pembayaran.rincian_tagihan WHERE TAGIHAN = PTAGIHAN;		
		DELETE FROM pembayaran.rincian_tagihan_paket WHERE TAGIHAN = PTAGIHAN;		
		
		SELECT p.NOMOR, p.PAKET, p.TANGGAL, tp.REF
		  INTO VPENDAFTARAN, VPAKET, VTANGGAL_PENDAFTARAN, VREF
		  FROM pembayaran.tagihan_pendaftaran tp,
		  		 pendaftaran.pendaftaran p
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND p.NOMOR = tp.PENDAFTARAN
		   AND tp.UTAMA = 1
		 LIMIT 1;
		 
		IF VPENDAFTARAN IS NULL THEN
			SET VTANGGAL_PENDAFTARAN = NOW();
		END IF;
		
		IF VREF = '' THEN
			IF VPAKET > 0 OR NOT VPAKET IS NULL THEN
				CALL master.getTarifPaket(VPAKET, VTANGGAL_PENDAFTARAN, VTARIF_ID, VTARIF);
				CALL pembayaran.storeRincianTagihan(PTAGIHAN, VPENDAFTARAN, 5, VTARIF_ID, 1, VTARIF, 0, 0, 0);
			END IF;
					
			IF (VPAKET > 0 OR NOT VPAKET IS NULL) AND NOT VKARTU IS NULL THEN
				CALL master.inPaket(VPAKET, 3, 1, NULL, VQTY, VPAKET_DETIL);
				IF VPAKET_DETIL > 0 THEN
					CALL pembayaran.storeRincianTagihanPaket(PTAGIHAN, VPAKET_DETIL, VKARTU, VTANGGAL_PENDAFTARAN, 1, 1);
				END IF;
			END IF;
			
			IF VPAKET_DETIL = 0 AND NOT VKARTU IS NULL THEN
			BEGIN
				IF NOT VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN THEN						   
					CALL master.getTarifAdministrasi(1, 0, VTANGGAL_PENDAFTARAN, VTARIF_ID, VTARIF);
				ELSE
					CALL master.getTarifAdministrasiBerdasarkanJenisPasien(1, 0, VTANGGAL_PENDAFTARAN, VPASIEN_BARU, VTARIF_ID, VTARIF);
				END IF;
				
				SELECT k.NOMOR, IF(rk.KELAS IS NULL, -1, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, rk.KELAS)) 
				  INTO VKUNJUNGAN_TMP, VKELAS
				  FROM pendaftaran.kunjungan k
				       LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
				 		 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
				 WHERE k.NOPEN = VPENDAFTARAN			   
				   AND k.REF IS NULL
				   AND NOT k.`STATUS` = 0;
				
				IF NOT VKELAS IS NULL THEN
					IF VKELAS < 0 THEN			
						SET VKELAS = pembayaran.getKelasRJMengikutiKelasRIYgPertama(PTAGIHAN, VKUNJUNGAN_TMP);
						IF VKELAS < 0 THEN
							SET VKELAS = 0;
						END IF;
					END IF;
				END IF;						
				
				CALL pembayaran.storeRincianTagihan(PTAGIHAN, VKARTU, 1, VTARIF_ID, 1, VTARIF, VKELAS, 0, 0);
			END;
			END IF;
							
			BEGIN
				DECLARE VUTAMA TINYINT;
				DECLARE VJENIS_ADM TINYINT;
				DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
				DECLARE CR_TAGIHAN_PENDAFTARAN CURSOR FOR
					SELECT tp.PENDAFTARAN, tp.UTAMA
					  FROM pembayaran.tagihan_pendaftaran tp
					 WHERE tp.TAGIHAN = PTAGIHAN
					   AND tp.STATUS = 1
					 ORDER BY tp.UTAMA DESC;
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
				
				OPEN CR_TAGIHAN_PENDAFTARAN;
				EOF: LOOP
					FETCH CR_TAGIHAN_PENDAFTARAN INTO VPENDAFTARAN, VUTAMA;
					
					IF DATA_NOT_FOUND THEN
						UPDATE temp.temp SET ID = 0 WHERE ID = 0;
						LEAVE EOF;
					END IF;
					
					IF VUTAMA = 0 THEN					
						IF EXISTS(SELECT 1
							  FROM aplikasi.properti_config pc
							 WHERE pc.ID = 22
							   AND VALUE = 'TRUE') THEN
							UPDATE temp.temp SET ID = 0 WHERE ID = 0;
							LEAVE EOF;
						END IF;
					END IF;
					
					SELECT kp.ID, kp.JENIS
					  INTO VKARCIS, VJENIS_ADM
					  FROM cetakan.karcis_pasien kp
					 WHERE kp.NOPEN = VPENDAFTARAN
					   AND kp.`STATUS` = 1
					 LIMIT 1;
					
					CALL pembayaran.storeAdministrasiKarcis(VPENDAFTARAN, VKARCIS, VJENIS_ADM, PTAGIHAN);
				END LOOP;
				CLOSE CR_TAGIHAN_PENDAFTARAN;
			END;
		END IF;
				
		BEGIN			
			DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;
			DECLARE CR_TAGIHAN_PENDAFTARAN CURSOR FOR
				SELECT PENDAFTARAN
				  FROM pembayaran.tagihan_pendaftaran
				 WHERE TAGIHAN = PTAGIHAN
				   AND STATUS = 1;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
			
			OPEN CR_TAGIHAN_PENDAFTARAN;
			EOF: LOOP
				FETCH CR_TAGIHAN_PENDAFTARAN INTO VPENDAFTARAN;
				
				IF DATA_NOT_FOUND THEN
					UPDATE temp.temp SET ID = 0 WHERE ID = 0;
					LEAVE EOF;
				END IF;
								
				BEGIN					
					DECLARE VKUNJUNGAN CHAR(19);
					DECLARE VJENIS_KUNJUNGAN TINYINT;
					DECLARE KUNJUNGAN_NOT_FOUND TINYINT DEFAULT FALSE;
					DECLARE CR_KUNJUNGAN CURSOR FOR					
						SELECT k.NOMOR, r.JENIS_KUNJUNGAN
						  FROM pendaftaran.pendaftaran p,
						  		 pendaftaran.kunjungan k,
						  		 master.ruangan r
						 WHERE k.NOPEN = p.NOMOR
						   AND k.`STATUS` > 0
						   AND r.ID = k.RUANGAN
						   AND p.NOMOR = VPENDAFTARAN;
					DECLARE CONTINUE HANDLER FOR NOT FOUND SET KUNJUNGAN_NOT_FOUND = TRUE;
					
					OPEN CR_KUNJUNGAN;
					EOF_KUNJUNGAN: LOOP
						FETCH CR_KUNJUNGAN INTO VKUNJUNGAN, VJENIS_KUNJUNGAN;						
						
						IF KUNJUNGAN_NOT_FOUND THEN
							UPDATE temp.temp SET ID = 0 WHERE ID = 0;
							LEAVE EOF_KUNJUNGAN;
						END IF;
												
						IF VJENIS_KUNJUNGAN = 3 THEN							
							CALL pembayaran.storeAkomodasi(VKUNJUNGAN);
						END IF;					
												
						BEGIN							
							DECLARE VTINDAKAN_MEDIS CHAR(11);
							DECLARE VTINDAKAN SMALLINT;
							DECLARE TINDAKAN_MEDIS_NOT_FOUND TINYINT DEFAULT FALSE;							
							DECLARE CR_TINDAKAN_MEDIS CURSOR FOR
								SELECT ID, TINDAKAN
								  FROM layanan.tindakan_medis tm
								 WHERE tm.KUNJUNGAN = VKUNJUNGAN
								   AND tm.`STATUS` > 0;
							DECLARE CONTINUE HANDLER FOR NOT FOUND SET TINDAKAN_MEDIS_NOT_FOUND = TRUE;
							
							OPEN CR_TINDAKAN_MEDIS;
							TINDAKAN_MEDIS_EOF: LOOP
								FETCH CR_TINDAKAN_MEDIS INTO VTINDAKAN_MEDIS, VTINDAKAN;
								
								IF TINDAKAN_MEDIS_NOT_FOUND THEN
									UPDATE temp.temp SET ID = 0 WHERE ID = 0;
									LEAVE TINDAKAN_MEDIS_EOF;
								END IF;
								
								CALL pembayaran.storeTindakanMedis(VKUNJUNGAN, VTINDAKAN_MEDIS, VTINDAKAN);
							END LOOP;
							CLOSE CR_TINDAKAN_MEDIS;
						END;
												
						BEGIN
							DECLARE VLAYANAN_FARMASI CHAR(11);
							DECLARE VFARMASI SMALLINT;
							DECLARE VJUMLAH DECIMAL(60,2);
							DECLARE FARMASI_NO_FOUND TINYINT DEFAULT FALSE;						
							DECLARE CR_FARMASI CURSOR FOR
								SELECT f.ID, f.FARMASI, f.JUMLAH - SUM(IF(rf.JUMLAH IS NULL, 0, rf.JUMLAH)) JUMLAH
								  FROM layanan.farmasi f
								  		 LEFT JOIN layanan.retur_farmasi rf ON rf.ID_FARMASI = f.ID
								 WHERE f.KUNJUNGAN = VKUNJUNGAN
								   AND f.`STATUS` = 2 AND f.TINDAKAN_PAKET = 0 
								 GROUP BY ID
								 HAVING JUMLAH > 0;
							DECLARE CONTINUE HANDLER FOR NOT FOUND SET FARMASI_NO_FOUND = TRUE;
								 
							OPEN CR_FARMASI;
							FARMASI_EOF: LOOP
								FETCH CR_FARMASI INTO VLAYANAN_FARMASI, VFARMASI, VJUMLAH;
								
								IF FARMASI_NO_FOUND THEN
									UPDATE temp.temp SET ID = 0 WHERE ID = 0;
									LEAVE FARMASI_EOF;
								END IF;
								
								 CALL pembayaran.storeFarmasi(VKUNJUNGAN, VLAYANAN_FARMASI, VFARMASI, VJUMLAH);
							END LOOP;
							CLOSE CR_FARMASI;
						END;
												
						CALL pembayaran.storeO2(VKUNJUNGAN);
					END LOOP;
					CLOSE CR_KUNJUNGAN;
				END;							
			END LOOP;
			CLOSE CR_TAGIHAN_PENDAFTARAN;		   
		END;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeAdministrasiFarmasi
DROP PROCEDURE IF EXISTS `storeAdministrasiFarmasi`;
DELIMITER //
CREATE PROCEDURE `storeAdministrasiFarmasi`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VORDERID CHAR(21);
	DECLARE VRACIKAN, VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTAGIHAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VNOPEN, VRUANGAN CHAR(10);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VPENJAMIN, VPAKET SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2);
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VREF SMALLINT;
	DECLARE VTANGGAL_PENDAFTARAN DATETIME;
	
	SELECT k.REF, k.NOPEN, p.PAKET, p.TANGGAL, pj.JENIS, k.RUANGAN
	  INTO VORDERID, VNOPEN, VPAKET, VTANGGAL_PENDAFTARAN, VPENJAMIN, VRUANGAN
	  FROM pendaftaran.kunjungan k,
	  	    pendaftaran.pendaftaran p,
	  	    pendaftaran.penjamin pj,
	  		 `master`.ruangan r
	 WHERE k.NOMOR = PKUNJUNGAN
	 	AND p.NOMOR = k.NOPEN
	   AND r.ID = k.RUANGAN
	   AND r.JENIS_KUNJUNGAN = 11
		AND pj.NOPEN = p.NOMOR;
	   
	IF NOT VORDERID IS NULL THEN
		SELECT MAX(odr.RACIKAN) INTO VRACIKAN
		  FROM layanan.order_resep oresep,
		  		 layanan.order_detil_resep odr
		 WHERE odr.ORDER_ID = oresep.NOMOR
		   AND oresep.NOMOR = VORDERID;
		 
		IF NOT VRACIKAN IS NULL THEN
			SET VREF = IF(VRACIKAN = 1, 4, 3);
			IF EXISTS(SELECT 1 FROM `master`.administrasi WHERE ID = VREF AND STATUS = 1) THEN
				SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
				
				IF VPAKET IS NULL OR VPAKET = 0 THEN
					SELECT r.JENIS_KUNJUNGAN
					  INTO VJENIS_KUNJUNGAN
					  FROM layanan.order_resep orp,
					  	    pendaftaran.kunjungan k,
					  	    `master`.ruangan r
					 WHERE orp.NOMOR = VORDERID
					   AND k.NOMOR = orp.KUNJUNGAN
					   AND r.ID = k.RUANGAN
					 LIMIT 1;
					 
					IF NOT VJENIS_KUNJUNGAN IS NULL THEN
						IF VJENIS_KUNJUNGAN != 3 AND NOT VORDERID IS NULL THEN 
							IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
								SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, PKUNJUNGAN);
								IF VTAGIHAN_TERPISAH != '' THEN
									SET VTAGIHAN = VTAGIHAN_TERPISAH;
								END IF;
							END IF;
						END IF;
					END IF;
				END IF;
				
				IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
					IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
						CALL master.inPaket(VPAKET, 3, VREF, NULL, VQTY, VPAKET_DETIL);
						
						IF VTAGIHAN != '' AND VPAKET_DETIL > 0 THEN
							CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PKUNJUNGAN, VTANGGAL_PENDAFTARAN, 1, 1);
						END IF;
					END IF;
						
					IF VTAGIHAN != '' AND VPAKET_DETIL = 0 THEN
						CALL master.getTarifAdministrasi(VREF, 0, VTANGGAL_PENDAFTARAN, VTARIF_ID, VTARIF);
						CALL pembayaran.storeRincianTagihan(VTAGIHAN, PKUNJUNGAN, 1, VTARIF_ID, 1, VTARIF, 0, 0, 0);
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeAdministrasiKarcis
DROP PROCEDURE IF EXISTS `storeAdministrasiKarcis`;
DELIMITER //
CREATE PROCEDURE `storeAdministrasiKarcis`(
	IN `PNOPEN` CHAR(10),
	IN `PID` CHAR(11),
	IN `PJENIS` TINYINT,
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VJENIS_KUNJUNGAN SMALLINT;
	DECLARE VQTY, VPERSENTASE DECIMAL(60,2);
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VTANGGAL DATETIME;
	DECLARE VTANGGAL_TAGIHAN DATETIME DEFAULT NULL;
	DECLARE VTGL_DAFTAR_PASIEN DATETIME;
	DECLARE VPASIEN_BARU TINYINT DEFAULT 0;
	DECLARE VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN TINYINT DEFAULT FALSE;
	DECLARE VNORM INT;
	DECLARE VKELAS, VPENJAMIN SMALLINT DEFAULT 0;
	DECLARE VKUNJUNGAN_TMP CHAR(19);
	
	IF PJENIS IN (1,2) THEN		 
		SELECT p.PAKET, r.JENIS_KUNJUNGAN, p.TANGGAL, p.NORM, pj.JENIS INTO VPAKET, VJENIS_KUNJUNGAN, VTANGGAL, VNORM, VPENJAMIN
		  FROM pendaftaran.pendaftaran p
		    	 , pendaftaran.tujuan_pasien tp
		    	 , master.ruangan r
		    	 , pendaftaran.penjamin pj
		 WHERE p.NOMOR = PNOPEN
		 	AND tp.NOPEN = p.NOMOR
		   AND r.ID = tp.RUANGAN
			AND pj.NOPEN = p.NOMOR
		 LIMIT 1;
		 
		IF NOT VTANGGAL IS NULL THEN
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 3, 2, NULL, VQTY, VPAKET_DETIL);
				
				IF PTAGIHAN != '' AND VPAKET_DETIL > 0 THEN
					CALL pembayaran.storeRincianTagihanPaket(PTAGIHAN, VPAKET_DETIL, PID, VTANGGAL, 1, 1);
				END IF;
			END IF;
				
			IF PTAGIHAN != '' AND VPAKET_DETIL = 0 THEN
				SELECT t.TANGGAL, p.TANGGAL INTO VTANGGAL_TAGIHAN, VTGL_DAFTAR_PASIEN
				  FROM pembayaran.tagihan t, master.pasien p
				 WHERE t.ID = PTAGIHAN
				   AND t.JENIS = 1
					AND p.NORM = t.REF
				 LIMIT 1;
				 
				SET VPASIEN_BARU = IF(DATE(VTGL_DAFTAR_PASIEN) = DATE(VTANGGAL_TAGIHAN), 1, 0);
				
				IF EXISTS(SELECT 1
					  FROM aplikasi.properti_config pc
					 WHERE pc.ID = 23
					   AND VALUE = 'TRUE') THEN		
					SET VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN = TRUE;
				END IF;
	
				IF NOT VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN THEN						   
					CALL master.getTarifAdministrasi(2, VJENIS_KUNJUNGAN, VTANGGAL, VTARIF_ID, VTARIF);
				ELSE
					IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 24
						   AND VALUE = 'TRUE') THEN
						IF NOT EXISTS(SELECT 1
							  FROM pendaftaran.kunjungan k,
							  		 pendaftaran.pendaftaran p,
							       master.ruangan rg
							 WHERE NOT k.NOPEN = PNOPEN
							   AND k.`STATUS` > 0
								AND p.NOMOR = k.NOPEN
								AND p.NORM = VNORM
								AND rg.ID = k.RUANGAN
								AND rg.JENIS_KUNJUNGAN = VJENIS_KUNJUNGAN
							 LIMIT 1) THEN								   							   
							SET VPASIEN_BARU = 1;
						END IF;
					END IF;
					
					CALL master.getTarifAdministrasiBerdasarkanJenisPasien(2, VJENIS_KUNJUNGAN, VTANGGAL, VPASIEN_BARU, VTARIF_ID, VTARIF);
				END IF;
				
				SET VKELAS = 0;
					
				SELECT k.NOMOR, IF(rk.KELAS IS NULL, -1, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, rk.KELAS))
				  INTO VKUNJUNGAN_TMP, VKELAS
				  FROM pendaftaran.kunjungan k
				       LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
				 		 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
				 WHERE k.NOPEN = PNOPEN			   
				   AND k.REF IS NULL
				   AND NOT k.`STATUS` = 0;
				
				IF NOT VKELAS IS NULL THEN
					IF VKELAS < 0 THEN			
						SET VKELAS = pembayaran.getKelasRJMengikutiKelasRIYgPertama(PTAGIHAN, VKUNJUNGAN_TMP);
						IF VKELAS < 0 THEN
							SET VKELAS = 0;
						END IF;
					END IF;
				END IF;
				
				SET VPERSENTASE = penjamin_rs.getKenaikanTarif(VPENJAMIN, 1, VTANGGAL);
				IF VPERSENTASE > 0 THEN
					SET VTARIF = VTARIF + (VTARIF * VPERSENTASE);
				END IF;
				
				CALL pembayaran.storeRincianTagihan(PTAGIHAN, PID, 1, VTARIF_ID, 1, VTARIF, VKELAS, 0, 0);
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeAdministrasiKartu
DROP PROCEDURE IF EXISTS `storeAdministrasiKartu`;
DELIMITER //
CREATE PROCEDURE `storeAdministrasiKartu`(
	IN `PNORM` INT,
	IN `PID` CHAR(11),
	IN `PJENIS` TINYINT
)
BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VNOPEN CHAR(10);
	DECLARE VTANGGAL_TAGIHAN DATETIME DEFAULT NULL;
	DECLARE VTGL_DAFTAR_PASIEN DATETIME;
	DECLARE VPASIEN_BARU TINYINT DEFAULT 0;
	DECLARE VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN TINYINT DEFAULT FALSE;
	
	IF PJENIS IN (1,2) THEN
		SET VTAGIHAN = pembayaran.buatTagihan(PNORM, '');
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			SELECT t.TANGGAL, p.TANGGAL INTO VTANGGAL_TAGIHAN, VTGL_DAFTAR_PASIEN
			  FROM pembayaran.tagihan t, master.pasien p
			 WHERE t.ID = VTAGIHAN
			   AND t.JENIS = 1
				AND p.NORM = t.REF
			 LIMIT 1;
			 
			SET VPASIEN_BARU = IF(DATE(VTGL_DAFTAR_PASIEN) = DATE(VTANGGAL_TAGIHAN), 1, 0);
			
			IF EXISTS(SELECT 1
				  FROM aplikasi.properti_config pc
				 WHERE pc.ID = 23
				   AND VALUE = 'TRUE') THEN		
				SET VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN = TRUE;
			END IF;

			IF NOT VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN THEN						   
				CALL master.getTarifAdministrasi(1, 0, NOW(), VTARIF_ID, VTARIF);
			ELSE
				CALL master.getTarifAdministrasiBerdasarkanJenisPasien(1, 0, NOW(), VPASIEN_BARU, VTARIF_ID, VTARIF);
			END IF;
			
			CALL pembayaran.storeRincianTagihan(VTAGIHAN, PID, 1, VTARIF_ID, 1, VTARIF, 0, 0, 0);
		END IF;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeAkomodasi
DROP PROCEDURE IF EXISTS `storeAkomodasi`;
DELIMITER //
CREATE PROCEDURE `storeAkomodasi`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VTAGIHAN, VNOPEN, VRUANGAN CHAR(10);
	DECLARE VMASUK, VKELUAR DATETIME;
	DECLARE VREF CHAR(21);
	DECLARE VKELAS TINYINT;
	DECLARE VRUANG_KAMAR_TIDUR, VPENJAMIN SMALLINT;
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL DATETIME;
	DECLARE VTITIPAN TINYINT;
	DECLARE VPERSENTASE TINYINT;
	DECLARE VDISKON, VPERSENTASE_KENAIKAN DECIMAL(60, 2);
	
	SELECT k.NOPEN, k.MASUK, k.KELUAR, k.RUANGAN, k.REF, k.RUANG_KAMAR_TIDUR, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, rk.KELAS), k.TITIPAN
	  INTO VNOPEN, VMASUK, VKELUAR, VRUANGAN, VREF, VRUANG_KAMAR_TIDUR, VKELAS, VTITIPAN
	  FROM pendaftaran.kunjungan k
	  		 , master.ruang_kamar_tidur rkt
			 , master.ruang_kamar rk
	 WHERE k.NOMOR = PKUNJUNGAN
	   AND master.isRawatInap(k.RUANGAN) = 1
		AND rkt.ID = k.RUANG_KAMAR_TIDUR
		AND rk.ID = rkt.RUANG_KAMAR
	 LIMIT 1;
	
	IF NOT VNOPEN IS NULL THEN
		SET VKELUAR = IF(VKELUAR IS NULL, NOW(), VKELUAR);				
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		
		BEGIN
			DECLARE VTARIF_ID INT;
			DECLARE VTARIF INT;
			DECLARE VPAKET SMALLINT;
			DECLARE VKELAS_PAKET TINYINT;
			DECLARE VLAMA TINYINT DEFAULT 0;
			DECLARE VLAMA_DIRAWAT SMALLINT DEFAULT 0;
			DECLARE VSELISIH SMALLINT DEFAULT 0;
		   
		   IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN			   
			   SELECT pkt.ID, pkt.KELAS, pkt.LAMA, pdf.TANGGAL, pj.JENIS INTO VKELAS_PAKET, VKELAS_PAKET, VLAMA, VTANGGAL_PENDAFTARAN, VPENJAMIN
			     FROM pendaftaran.pendaftaran pdf
			     		 LEFT JOIN master.paket pkt ON pkt.ID = pdf.PAKET,
			     		 pendaftaran.penjamin pj
			    WHERE pdf.NOMOR = VNOPEN
				   AND pj.NOPEN = pdf.NOMOR
				 LIMIT 1;
		   
				IF NOT VTANGGAL_PENDAFTARAN IS NULL THEN
					IF NOT VKELAS_PAKET IS NULL THEN
						SET VKELAS = VKELAS_PAKET;
					END IF;
					
					SET VTANGGAL = VMASUK;
					
					IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 6
						   AND VALUE = 'TRUE') THEN
						SET VTANGGAL = VTANGGAL_PENDAFTARAN;
					END IF;
				
					SET VLAMA_DIRAWAT = pendaftaran.getLamaDirawat(VMASUK, VKELUAR, VNOPEN, PKUNJUNGAN, VREF);
										
					IF VTAGIHAN != '' AND (NOT VPAKET IS NULL OR VPAKET > 0) THEN
						CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET, PKUNJUNGAN, VTANGGAL, 1);
						
						IF NOT VREF IS NULL OR VREF != '' THEN
							SET VLAMA_DIRAWAT = VLAMA_DIRAWAT + pendaftaran.getLamaDirawatSebelumnya(VREF, VPAKET);
						END IF;
					ELSE
						SET VLAMA = 0;
					END IF;
										
					SET VSELISIH = VLAMA_DIRAWAT - VLAMA;
					IF VTAGIHAN != '' AND (VSELISIH > 0 OR VLAMA_DIRAWAT >= 0) THEN
					   IF VSELISIH >= 0 THEN		
							IF VTITIPAN = 1 THEN
								CALL master.getTarifRuangRawatByKelas(VKELAS, VTANGGAL, VTARIF_ID, VTARIF);
							ELSE			    
					      	CALL master.getTarifRuangRawat(VRUANG_KAMAR_TIDUR, VTANGGAL, VTARIF_ID, VTARIF);
					      END IF;
					      IF pendaftaran.ikutRawatInapIbu(VNOPEN, VREF) = 1 THEN
					      	CALL master.getTarifDiskon(1, VTANGGAL, VPERSENTASE, VDISKON);
					      ELSE
								SET VPERSENTASE = 0;
								SET VDISKON = 0;
					      END IF;
					      SET VPERSENTASE_KENAIKAN = penjamin_rs.getKenaikanTarif(VPENJAMIN, 2, VTANGGAL);
							IF VPERSENTASE_KENAIKAN > 0 THEN
								SET VTARIF = VTARIF + (VTARIF * VPERSENTASE_KENAIKAN);
							END IF;
						   CALL pembayaran.storeRincianTagihan(VTAGIHAN, PKUNJUNGAN, 2, VTARIF_ID, VSELISIH, VTARIF, VKELAS, VPERSENTASE, VDISKON);
						END IF;
					END IF;
				END IF;
			END IF;
		END;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeFarmasi
DROP PROCEDURE IF EXISTS `storeFarmasi`;
DELIMITER //
CREATE PROCEDURE `storeFarmasi`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PLAYANAN_FARMASI` CHAR(11),
	IN `PFARMASI` SMALLINT,
	IN `PJUMLAH` DECIMAL(60,2)
)
BEGIN
	DECLARE VNOPEN, VRUANGAN CHAR(10);
	DECLARE VTAGIHAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VJENIS_KUNJUNGAN, VJENIS_KUNJUNGAN2 TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF DECIMAL(60,2);
	DECLARE VKELAS SMALLINT DEFAULT 0;
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2) DEFAULT 0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VBARANG_RUANGAN BIGINT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VTGL_PENDAFTARAN DATETIME;
	DECLARE VKUNJUNGAN_YG_MERESEP CHAR(19);
	DECLARE VJUMLAH, VPERSENTASE DECIMAL(60,2) DEFAULT 1.0;
	DECLARE VJUMLAH_RINCIAN DECIMAL(60,2) DEFAULT 1.0;
	DECLARE VPENJAMIN SMALLINT;
	DECLARE VREF CHAR(21);
	
	SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(kr.TITIPAN = 1, kr.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS, 
	       p.PAKET, k.MASUK, kr.NOMOR, k.MASUK, k.REF, k.RUANGAN, pj.JENIS
	  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS, 
	       VPAKET, VTANGGAL, VKUNJUNGAN_YG_MERESEP, VTGL_PENDAFTARAN, VREF, VRUANGAN, VPENJAMIN
	  FROM pendaftaran.kunjungan k
	  		 LEFT JOIN layanan.order_resep ores ON ores.NOMOR = k.REF
	  		 LEFT JOIN pendaftaran.kunjungan kr ON kr.NOMOR = ores.KUNJUNGAN
	  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = kr.RUANG_KAMAR_TIDUR
			 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 master.ruangan r,
	  		 pendaftaran.pendaftaran p,
	  		 pendaftaran.penjamin pj
	 WHERE k.RUANGAN = r.ID
	   AND k.NOMOR = PKUNJUNGAN
		AND k.NOPEN = p.NOMOR
		AND pj.NOPEN = p.NOMOR
		AND k.`STATUS` = 2
	 LIMIT 1;
	
	IF NOT VNOPEN IS NULL THEN
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		
		IF VPAKET IS NULL OR VPAKET = 0 THEN
			SELECT r.JENIS_KUNJUNGAN
			  INTO VJENIS_KUNJUNGAN2
			  FROM layanan.order_resep orp,
			  	    pendaftaran.kunjungan k,
			  	    `master`.ruangan r
			 WHERE orp.NOMOR = VREF
			   AND k.NOMOR = orp.KUNJUNGAN
			   AND r.ID = k.RUANGAN
			 LIMIT 1;
			 
			IF NOT VJENIS_KUNJUNGAN2 IS NULL THEN
				IF VJENIS_KUNJUNGAN2 = 1 AND NOT VREF IS NULL THEN 
					IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
						SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, PKUNJUNGAN);
						IF VTAGIHAN_TERPISAH != '' THEN
							SET VTAGIHAN = VTAGIHAN_TERPISAH;
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
		
		SET VJUMLAH = pembayaran.getJumlahItemRincianPaket(VTAGIHAN, PFARMASI, 2) + PJUMLAH;
				
		SELECT pt.PENJAMIN INTO VPENJAMIN
		  FROM pembayaran.penjamin_tagihan pt 
		 WHERE pt.TAGIHAN = VTAGIHAN
		   AND pt.KE = 1
		 LIMIT 1;
		 
		IF VPENJAMIN IS NULL THEN
			SET VPENJAMIN = 1; 
		END IF;
		
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
		BEGIN
			DECLARE VSISA_PAKET DECIMAL(60,2) DEFAULT 0;
			DECLARE VSISA DECIMAL(60,2) DEFAULT 0;
			
			SET VSISA = PJUMLAH;
			
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 2, PFARMASI, NULL, VQTY, VPAKET_DETIL);
				IF VJUMLAH < VQTY THEN
					SET VSISA_PAKET = PJUMLAH;
					SET VSISA = 0;
				ELSE
					SET VSISA_PAKET = PJUMLAH - (VJUMLAH - VQTY);					
					IF VSISA_PAKET > 0 THEN
						SET VSISA = PJUMLAH - VSISA_PAKET;
					END IF;					
				END IF;	
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 AND VSISA_PAKET > 0 THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PLAYANAN_FARMASI, VTANGGAL, VSISA_PAKET, 1);
				END IF;
			END IF;
			
			IF VTAGIHAN != '' AND (VPAKET_DETIL = 0 OR VSISA > 0) THEN
			BEGIN
				DECLARE VKELAS_SBLM SMALLINT;
				DECLARE VKATEGORI CHAR(10);
				
				SELECT b.KATEGORI INTO VKATEGORI
				  FROM inventory.barang b
				 WHERE b.ID = PFARMASI;
								
				CALL inventory.getHargaBarang(PFARMASI, VTARIF_ID, VTARIF, VTGL_PENDAFTARAN);
								
				SET VKELAS_SBLM = pembayaran.getKelasRJMengikutiKelasRIYgPertama(VTAGIHAN, VKUNJUNGAN_YG_MERESEP);
				IF VKELAS_SBLM > 0 THEN
					SET VKELAS = VKELAS_SBLM;
				END IF;
				
				IF NOT VKATEGORI IS NULL THEN
					IF LEFT(VKATEGORI, 3) IN ('101', '102') THEN
						SET VTARIF = master.getTarifMarginPenjaminFarmasi(VPENJAMIN, 1, VTARIF, VTGL_PENDAFTARAN);
						SET VTARIF = master.getTarifFarmasiPerKelas(VKELAS, VTARIF);
					END IF;
				END IF;
				
				SET VPERSENTASE = penjamin_rs.getKenaikanTarif(VPENJAMIN, 4, VTGL_PENDAFTARAN);
				IF VPERSENTASE > 0 THEN
					SET VTARIF = VTARIF + (VTARIF * VPERSENTASE);
				END IF;
				
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, PLAYANAN_FARMASI, 4, VTARIF_ID, VSISA, VTARIF, VKELAS, 0, 0);		
			END;
			END IF;
		END;
		END IF;	
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeO2
DROP PROCEDURE IF EXISTS `storeO2`;
DELIMITER //
CREATE PROCEDURE `storeO2`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VNOPEN, VRUANGAN CHAR(10);
	DECLARE VTAGIHAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF DECIMAL(60,2);
	DECLARE VKELAS SMALLINT DEFAULT 0;
	DECLARE VPAKET, VPENJAMIN SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2) DEFAULT 0;
	DECLARE VPEMAKAIAN DECIMAL(60,2) DEFAULT 0;
	DECLARE VSISA, VPERSENTASE DECIMAL(60,2) DEFAULT 0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL_KUNJUNGAN, VTANGGAL DATETIME;
	DECLARE VREF CHAR(21);

	SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS, 
	       p.PAKET, p.TANGGAL, k.MASUK, k.RUANGAN, pj.JENIS, k.REF
	  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS, 
	       VPAKET, VTANGGAL_PENDAFTARAN, VTANGGAL_KUNJUNGAN, VRUANGAN, VPENJAMIN, VREF
	  FROM pendaftaran.kunjungan k
	  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
			 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 master.ruangan r,
	  		 pendaftaran.pendaftaran p,
	  		 pendaftaran.penjamin pj
	 WHERE k.NOMOR = PKUNJUNGAN
	 	AND k.RUANGAN = r.ID	   
		AND p.NOMOR = k.NOPEN
		AND pj.NOPEN = p.NOMOR;
		
	IF NOT VNOPEN IS NULL THEN
		SET VTANGGAL = VTANGGAL_KUNJUNGAN;
		
		IF EXISTS(SELECT 1
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 6
			   AND VALUE = 'TRUE') THEN
			SET VTANGGAL = VTANGGAL_PENDAFTARAN;
		END IF;
		
		SET VPEMAKAIAN = layanan.getTotalPemakaianO2(PKUNJUNGAN);
		SET VSISA = VPEMAKAIAN;
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		
		IF VPAKET IS NULL OR VPAKET = 0 THEN
			IF VJENIS_KUNJUNGAN = 1 AND NOT VREF IS NULL THEN 
				IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
					SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, PKUNJUNGAN);
					IF VTAGIHAN_TERPISAH != '' THEN
						SET VTAGIHAN = VTAGIHAN_TERPISAH;
					END IF;
				END IF;
			END IF;
		END IF;
			
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 4, 0, NULL, VQTY, VPAKET_DETIL);
				
				SET VSISA = VPEMAKAIAN - VQTY;
				IF VSISA <= 0 AND EXISTS(
					SELECT 1
					  FROM pembayaran.rincian_tagihan rt
					 WHERE rt.TAGIHAN = VTAGIHAN
					   AND rt.REF_ID = PKUNJUNGAN
					   AND rt.JENIS = 6) THEN
					
					CALL pembayaran.batalRincianTagihan(VTAGIHAN, PKUNJUNGAN, 6);
				ELSE
					UPDATE temp.temp SET ID = 0 WHERE ID = 0;
				END IF;
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 AND VPEMAKAIAN > 0 AND VQTY > 0 THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PKUNJUNGAN, VTANGGAL, VPEMAKAIAN, 1);
				END IF;
			END IF;						 
			
			IF VTAGIHAN != '' AND VSISA > 0.0 THEN
			BEGIN
				DECLARE VKELAS_SBLM SMALLINT;								
				
				CALL master.getTarifO2(VTANGGAL, VTARIF_ID, VTARIF);
				
				SET VKELAS_SBLM = pembayaran.getKelasRJMengikutiKelasRIYgPertama(VTAGIHAN, PKUNJUNGAN);
				IF VKELAS_SBLM > 0 THEN
					SET VKELAS = VKELAS_SBLM;
				END IF;
				
				SET VPERSENTASE = penjamin_rs.getKenaikanTarif(VPENJAMIN, 6, VTANGGAL);
				IF VPERSENTASE > 0 THEN
					SET VTARIF = VTARIF + (VTARIF * VPERSENTASE);
				END IF;
				
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, PKUNJUNGAN, 6, VTARIF_ID, VSISA, VTARIF, VKELAS, 0, 0);						
			END;
			END IF;
		END IF;	
	ELSE
		UPDATE temp.temp SET ID = 0 WHERE ID = 0;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storePenjaminTagihan
DROP PROCEDURE IF EXISTS `storePenjaminTagihan`;
DELIMITER //
CREATE PROCEDURE `storePenjaminTagihan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PPENJAMIN` SMALLINT,
	IN `PKELAS_KLAIM` TINYINT
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM pembayaran.penjamin_tagihan WHERE TAGIHAN = PTAGIHAN AND PENJAMIN = PPENJAMIN) THEN
	BEGIN
		DECLARE VKE SMALLINT;
		DECLARE VTOTAL DECIMAL(60,2);
		
		SELECT TOTAL
		  INTO VTOTAL
		  FROM pembayaran.tagihan t
		 WHERE t.ID = PTAGIHAN
		 LIMIT 1;
		
		SELECT MAX(KE) + 1 INTO VKE 
		  FROM pembayaran.penjamin_tagihan 
		 WHERE TAGIHAN = PTAGIHAN;
		 
		IF VKE IS NULL || FOUND_ROWS() = 0 THEN
			SET VKE = 1;
		ELSE
			SET VTOTAL = 0;
		END IF;
		
		INSERT INTO pembayaran.penjamin_tagihan(TAGIHAN, PENJAMIN, KE, KELAS_KLAIM, TOTAL)
		VALUES(PTAGIHAN, PPENJAMIN, VKE, PKELAS_KLAIM, VTOTAL);
	END;
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeRincianTagihan
DROP PROCEDURE IF EXISTS `storeRincianTagihan`;
DELIMITER //
CREATE PROCEDURE `storeRincianTagihan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTARIF_ID` INT,
	IN `PJUMLAH` DECIMAL(10,2),
	IN `PTARIF` DECIMAL(60,2),
	IN `PKELAS` SMALLINT,
	IN `PPERSENTASE_DISKON` TINYINT,
	IN `PDISKON` DECIMAL(60,2)
)
BEGIN
	DECLARE VTARIF DECIMAL(60,2);
	DECLARE VJML DECIMAL(10,2);
	DECLARE VJML2 DECIMAL(10,2);
	DECLARE VSTATUS TINYINT;
	DECLARE VPERSENTASE_DISKON TINYINT;
	DECLARE VDISKON TINYINT;
	DECLARE VINSERTED TINYINT DEFAULT TRUE;
	DECLARE VTOTAL DECIMAL(60, 2);
	DECLARE VTOTAL2, VTOTAL3 DECIMAL(60, 2) DEFAULT 0;
	DECLARE VCOUNT TINYINT;
	DECLARE VTAGIHAN CHAR(10);
	
	SET VTOTAL = (PJUMLAH * (PTARIF - IF(PPERSENTASE_DISKON = 0, PDISKON, (PTARIF * (PDISKON/100)))));
	SET VJML2 = PJUMLAH;
	
	# REMOVE JIKA DOUBLE
	SELECT SUM(JUMLAH * TARIF), COUNT(`TAGIHAN`)
	  INTO VTOTAL3, VCOUNT 
	  FROM pembayaran.rincian_tagihan 
	 WHERE TAGIHAN = PTAGIHAN 
	   AND REF_ID = PREF_ID 
		AND JENIS = PJENIS;
	
	IF VCOUNT = 0 THEN
		SET VTOTAL3 = 0;
	ELSE
		DELETE FROM pembayaran.rincian_tagihan WHERE TAGIHAN = PTAGIHAN AND REF_ID = PREF_ID AND JENIS = PJENIS;
	END IF;
	
	SELECT `TAGIHAN`, TARIF, JUMLAH, PERSENTASE_DISKON, DISKON, STATUS 
	  INTO VTAGIHAN, VTARIF, VJML, VPERSENTASE_DISKON, VDISKON, VSTATUS 
	  FROM pembayaran.rincian_tagihan 
	 WHERE TAGIHAN = PTAGIHAN 
	   AND REF_ID = PREF_ID 
		AND JENIS = PJENIS;
	
	IF	NOT VTAGIHAN IS NULL THEN		
		SET VTOTAL2 = (VJML * (VTARIF - IF(VPERSENTASE_DISKON = 0, VDISKON, (VTARIF * (VDISKON/100)))));
	
		IF VTARIF != PTARIF THEN
			UPDATE pembayaran.tagihan
			   SET TOTAL = (TOTAL - VTOTAL2) + VTOTAL
			 WHERE ID = PTAGIHAN;
		ELSE 
			IF VSTATUS = 0 THEN
				UPDATE pembayaran.tagihan
				   SET TOTAL = TOTAL + VTOTAL
				 WHERE ID = PTAGIHAN;
			END IF;
		END IF;
		
		UPDATE pembayaran.rincian_tagihan 
		   SET TARIF_ID = PTARIF_ID,
		   	 JUMLAH = PJUMLAH,
		   	 TARIF = PTARIF,
		   	 PERSENTASE_DISKON = PPERSENTASE_DISKON,
		   	 DISKON = PDISKON,
		   	 STATUS = 1
		 WHERE TAGIHAN = PTAGIHAN
		 	AND REF_ID = PREF_ID
			AND JENIS = PJENIS;
			
		SET VINSERTED = FALSE;
		SET VJML2 = VJML2 - VJML;
	ELSE
		INSERT INTO pembayaran.rincian_tagihan(TAGIHAN, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON)
		VALUES(PTAGIHAN, PREF_ID, PJENIS, PTARIF_ID, PJUMLAH, PTARIF, PPERSENTASE_DISKON, PDISKON);
		
		UPDATE pembayaran.tagihan
		   SET TOTAL = TOTAL + VTOTAL - VTOTAL3
		 WHERE ID = PTAGIHAN;
		 
		 SET VTARIF = 0;
		 SET VJML = 0;
	END IF;
	
	SET VTOTAL = VTOTAL - VTOTAL2;
	
	BEGIN
		DECLARE VREF_ID CHAR(5);
		DECLARE VMANUAL TINYINT;
		DECLARE VSUCCESS TINYINT DEFAULT TRUE;
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET VSUCCESS = FALSE;
		SELECT LEFT(r.REF_ID, 1), pt.MANUAL INTO VREF_ID, VMANUAL
		  FROM pembayaran.penjamin_tagihan pt,
		  	    master.referensi r
		 WHERE pt.TAGIHAN = PTAGIHAN
		   AND pt.KE = 1
		   AND r.ID = pt.PENJAMIN
			AND r.JENIS = 10
		 LIMIT 1;
		
		IF VSUCCESS THEN		
		   IF VREF_ID = '1' THEN
				CALL pembayaran.prosesPerhitunganAturan1(PTAGIHAN, PREF_ID, PJENIS, VTOTAL, VINSERTED, PKELAS);
			END IF;
				
			IF VREF_ID = '2' THEN
				CALL pembayaran.prosesPerhitunganBPJS(PTAGIHAN, PREF_ID, PJENIS, VTOTAL, VINSERTED, PKELAS);
			END IF;
			
			IF VREF_ID = '3' AND VMANUAL = 0 THEN
				CALL pembayaran.prosesPerhitunganAturan3(PTAGIHAN, PREF_ID, PJENIS, VTOTAL, VINSERTED, PKELAS);
			END IF;
			
			IF VREF_ID = '4' AND VMANUAL = 0 THEN
				CALL pembayaran.prosesPerhitunganJasaRaharja(PTAGIHAN, PREF_ID, PJENIS, VTOTAL, VINSERTED, PKELAS);
			END IF;
			
			IF VREF_ID = '5' AND VMANUAL = 0 THEN
				CALL pembayaran.prosesPerhitunganTotalTagihanPerkelas(PTAGIHAN, PREF_ID, PJENIS, VTOTAL, VINSERTED, PKELAS);
			END IF; 
		END IF;		
	END;
	
	CALL pembayaran.prosesDistribusiTarif(PTAGIHAN, PREF_ID, PJENIS, VJML2, VTOTAL, VINSERTED, PKELAS);
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeRincianTagihanInacbg
DROP PROCEDURE IF EXISTS `storeRincianTagihanInacbg`;
DELIMITER //
CREATE PROCEDURE `storeRincianTagihanInacbg`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VPROSEDUR_NON_BEDAH DECIMAL(60,2);
	DECLARE VPROSEDUR_BEDAH DECIMAL(60,2);
	DECLARE VKONSULTASI DECIMAL(60,2);
	DECLARE VTENAGA_AHLI DECIMAL(60,2);
	DECLARE VPENUNJANG DECIMAL(60,2);
	DECLARE VRADIOLOGI DECIMAL(60,2);
	DECLARE VLABORATORIUM DECIMAL(60,2);
	DECLARE VBANK_DARAH DECIMAL(60,2);
	DECLARE VREHAB_MEDIK DECIMAL(60,2);
	DECLARE VAKOMODASI DECIMAL(60,2);
	DECLARE VAKOMODASI_INTENSIF DECIMAL(60,2);
	DECLARE VOBAT DECIMAL(60,2);
	DECLARE VALKES DECIMAL(60,2);
	DECLARE VBMHP DECIMAL(60,2);
	DECLARE VSEWAALAT DECIMAL(60,2);
	DECLARE VKEPERAWATAN DECIMAL(60,2);
	
	SELECT rt.TAGIHAN
     , @PROSEDUR_NON_BEDAH:=SUM(IF(rt.JENIS=3 AND jt.ID=1, (rt.JUMLAH * rt.TARIF), 0)) PROSEDUR_NON_BEDAH
	  , @PROSEDUR_BEDAH:=SUM(IF(rt.JENIS=3 AND jt.ID=2, (rt.JUMLAH * rt.TARIF), 0)) PROSEDUR_BEDAH
	  , @KONSULTASI:=SUM(IF(rt.JENIS=3 AND jt.ID=3,(rt.JUMLAH * rt.TARIF), 0)) KONSULTASI
	  , @TENAGA_AHLI:=SUM(IF(rt.JENIS=3 AND jt.ID=4, (rt.JUMLAH * rt.TARIF), 0)) TENAGA_AHLI
	  , @PENUNJANG:=SUM(IF(rt.JENIS=3 AND jt.ID=6,(rt.JUMLAH * rt.TARIF), 0)) PENUNJANG
	  , @RADIOLOGI:=SUM(IF(rt.JENIS=3 AND jt.ID=7,(rt.JUMLAH * rt.TARIF), 0))  RADIOLOGI
	  , @LABORATORIUM:=SUM(IF(rt.JENIS=3 AND jt.ID=8,(rt.JUMLAH * rt.TARIF), 0)) LABORATORIUM
	  , @BANK_DARAH:=SUM(IF(rt.JENIS=3 AND jt.ID=9, (rt.JUMLAH * rt.TARIF), 0)) BANK_DARAH
	  , @REHAB_MEDIK:=SUM(IF(rt.JENIS=3 AND jt.ID=10, (rt.JUMLAH * rt.TARIF), 0)) REHAB_MEDIK
	  , @AKOMODASI:=SUM(IF(rt.JENIS=1, (rt.JUMLAH * rt.TARIF),0)) + SUM(IF(rt.JENIS=2 AND r.REF_ID=0, (rt.JUMLAH * rt.TARIF), 0)) AKOMODASI
	  , @AKOMODASI_INTENSIF:=SUM(IF(rt.JENIS=2 AND r.REF_ID=1, (rt.JUMLAH * rt.TARIF), 0)) AKOMODASI_INTENSIF
	  , @OBAT:=SUM(IF(rt.JENIS=4 AND LEFT(br.KATEGORI,3)='101', (rt.JUMLAH * rt.TARIF),0)) OBAT
	  , @ALKES:=SUM(IF(rt.JENIS=4 AND LEFT(br.KATEGORI,3)='102', (rt.JUMLAH * rt.TARIF),0)) ALKES
	  , @BMHP:=SUM(IF(rt.JENIS=6,(rt.JUMLAH * rt.TARIF),0)) 
	     + SUM(IF(rt.JENIS=4 AND LEFT(br.KATEGORI,1)='1' AND LEFT(br.KATEGORI,3) NOT IN ('101','102'), (rt.JUMLAH * rt.TARIF),0)) BMHP
	  , @SEWAALAT:=0 SEWAALAT
	  , ROUND((SUM(rt.JUMLAH * rt.TARIF)) -  (@PROSEDUR_NON_BEDAH+@PROSEDUR_BEDAH+@KONSULTASI+@TENAGA_AHLI+@PENUNJANG+@RADIOLOGI+@LABORATORIUM+@BANK_DARAH+@REHAB_MEDIK+@AKOMODASI+@AKOMODASI_INTENSIF+@OBAT+@ALKES+@BMHP+@SEWAALAT),2) KEPERAWATAN
	  INTO VTAGIHAN, VPROSEDUR_NON_BEDAH, VPROSEDUR_BEDAH, VKONSULTASI, VTENAGA_AHLI, VPENUNJANG, VRADIOLOGI, VLABORATORIUM, VBANK_DARAH, VREHAB_MEDIK
	     , VAKOMODASI, VAKOMODASI_INTENSIF, VOBAT, VALKES, VBMHP, VSEWAALAT, VKEPERAWATAN 
	FROM pembayaran.rincian_tagihan rt
	     LEFT JOIN pendaftaran.kunjungan pk ON rt.REF_ID=pk.NOMOR AND pk.`STATUS`!=0 AND rt.JENIS=2
	     LEFT JOIN master.ruangan r ON pk.RUANGAN=r.ID
	     LEFT JOIN layanan.tindakan_medis t ON rt.REF_ID=t.ID AND rt.JENIS=3 AND t.`STATUS`!=0
	     LEFT JOIN master.tindakan tdk ON t.TINDAKAN=tdk.ID AND tdk.`STATUS`!=0
	     LEFT JOIN master.referensi jt ON tdk.JENIS=jt.ID AND jt.JENIS=74
	     LEFT JOIN pendaftaran.kunjungan pkt ON t.KUNJUNGAN=pkt.NOMOR AND pkt.`STATUS`!=0
	     LEFT JOIN master.ruangan rtk ON pkt.RUANGAN=rtk.ID
	     LEFT JOIN layanan.farmasi f ON rt.REF_ID=f.ID AND rt.JENIS=4 AND f.`STATUS`!=0
	     LEFT JOIN inventory.barang br ON f.FARMASI=br.ID AND br.`STATUS`!=0
	WHERE rt.`STATUS`!=0 AND rt.TAGIHAN=PTAGIHAN
	GROUP BY rt.TAGIHAN;

	IF	NOT VTAGIHAN IS NULL THEN
			UPDATE pembayaran.tagihan
			   SET PROSEDUR_NON_BEDAH = VPROSEDUR_NON_BEDAH,
			       PROSEDUR_BEDAH = VPROSEDUR_BEDAH,
			       KONSULTASI = VKONSULTASI,
			       TENAGA_AHLI = VTENAGA_AHLI,
			       KEPERAWATAN = VKEPERAWATAN,
			       PENUNJANG = VPENUNJANG,
			       RADIOLOGI = VRADIOLOGI,
			       LABORATORIUM = VLABORATORIUM,
			       BANK_DARAH = VBANK_DARAH,
			       REHAB_MEDIK = VREHAB_MEDIK,
			       AKOMODASI = VAKOMODASI,
			       AKOMODASI_INTENSIF = VAKOMODASI_INTENSIF,
			       OBAT = VOBAT,
			       ALKES = VALKES,
			       BMHP = VBMHP,
			       SEWAALAT = VSEWAALAT
			 WHERE ID = PTAGIHAN;
	END IF;
	
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeRincianTagihanPaket
DROP PROCEDURE IF EXISTS `storeRincianTagihanPaket`;
DELIMITER //
CREATE PROCEDURE `storeRincianTagihanPaket`(
	IN `PTAGIHAN` CHAR(10),
	IN `PPAKET_DETIL` INT,
	IN `PREF_ID` CHAR(19),
	IN `PTANGGAL` DATETIME,
	IN `PJUMLAH` DECIMAL(60,2),
	IN `PSTATUS` TINYINT
)
BEGIN
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	
	CALL `master`.getTarifPaketDetil(PPAKET_DETIL, PTANGGAL, VTARIF_ID, VTARIF);
			
	IF	EXISTS(SELECT 1 FROM pembayaran.rincian_tagihan_paket WHERE TAGIHAN = PTAGIHAN AND PAKET_DETIL = PPAKET_DETIL AND REF_ID = PREF_ID LIMIT 1) THEN
		UPDATE pembayaran.rincian_tagihan_paket 
		   SET STATUS = PSTATUS,
		   	 TARIF_ID = VTARIF_ID,
		   	 JUMLAH = PJUMLAH
		 WHERE TAGIHAN = PTAGIHAN
		   AND PAKET_DETIL = PPAKET_DETIL
		 	AND REF_ID = PREF_ID;
	ELSE
		INSERT INTO pembayaran.rincian_tagihan_paket(TAGIHAN, PAKET_DETIL, REF_ID, TARIF_ID, JUMLAH)
		VALUES(PTAGIHAN, PPAKET_DETIL, PREF_ID, VTARIF_ID, PJUMLAH); 
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.storeTindakanMedis
DROP PROCEDURE IF EXISTS `storeTindakanMedis`;
DELIMITER //
CREATE PROCEDURE `storeTindakanMedis`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PTINDAKAN_MEDIS` CHAR(11),
	IN `PTINDAKAN` SMALLINT
)
BEGIN
	DECLARE VNOPEN, VTAGIHAN, VRUANGAN, VTAGIHAN_TERPISAH CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VKELAS SMALLINT DEFAULT 0;
	DECLARE VPAKET, VPENJAMIN SMALLINT DEFAULT FALSE;
	DECLARE VQTY, VPERSENTASE DECIMAL(60,2) DEFAULT 0.0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VJUMLAH DECIMAL(60,2) DEFAULT 1.0;
	DECLARE VREF CHAR(21);
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL_TINDAKAN, VTANGGAL DATETIME;
	
	SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(r.JENIS_KUNJUNGAN = 3, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS))
			 , IF(rkls.KELAS IS NULL, 0, rkls.KELAS)) KELAS
			 , p.PAKET, k.REF, p.TANGGAL, tm.TANGGAL, k.RUANGAN, pj.JENIS
	  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS
	       , VPAKET, VREF, VTANGGAL_PENDAFTARAN, VTANGGAL_TINDAKAN, VRUANGAN, VPENJAMIN
	  FROM layanan.tindakan_medis tm,
	  		 pendaftaran.kunjungan k
	  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
			 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 master.ruangan r
			 LEFT JOIN master.ruangan_kelas rkls ON rkls.RUANGAN = r.ID AND rkls.`STATUS` = 1,
	  		 pendaftaran.pendaftaran p,
	  		 pendaftaran.penjamin pj
	 WHERE tm.ID = PTINDAKAN_MEDIS
	   AND k.NOMOR = PKUNJUNGAN
	 	AND k.NOMOR = tm.KUNJUNGAN	 	
	 	AND k.RUANGAN = r.ID
		AND p.NOMOR = k.NOPEN
		AND pj.NOPEN = p.NOMOR
	 LIMIT 1;
	
	IF NOT VNOPEN IS NULL THEN
		SET VTANGGAL = VTANGGAL_TINDAKAN;
		
		IF EXISTS(SELECT 1
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 6
			   AND VALUE = 'TRUE') THEN
			SET VTANGGAL = VTANGGAL_PENDAFTARAN;
		END IF;
									
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		SET VJUMLAH = pembayaran.getJumlahItemRincianPaket(VTAGIHAN, PTINDAKAN, 1) + 1;
		
		IF VPAKET IS NULL OR VPAKET = 0 THEN
			IF VJENIS_KUNJUNGAN != 3 AND NOT VREF IS NULL THEN
				IF pembayaran.isTagihanTerpisah(VRUANGAN, VPENJAMIN) = 1 THEN
					SET VTAGIHAN_TERPISAH = pembayaran.getIdTagihanTerpisah(VNOPEN, PKUNJUNGAN);
					IF VTAGIHAN_TERPISAH != '' THEN
						SET VTAGIHAN = VTAGIHAN_TERPISAH;
					END IF;
				END IF;
			END IF;
		END IF;
		
		IF NOT (VJENIS_KUNJUNGAN = 3 AND NOT VREF IS NULL) THEN
			BEGIN
				DECLARE VKUNJUNGAN CHAR(19);
				DECLARE VKELAS_SBLM TINYINT;
				
				SELECT r.KUNJUNGAN INTO VKUNJUNGAN
				  FROM (
					SELECT k.KUNJUNGAN
					  FROM pendaftaran.konsul k
					 WHERE k.NOMOR = VREF
					 UNION
					SELECT ol.KUNJUNGAN
					  FROM layanan.order_lab ol
					 WHERE ol.NOMOR = VREF
					 UNION
					SELECT ora.KUNJUNGAN
					  FROM layanan.order_rad ora
					 WHERE ora.NOMOR = VREF
					) r;
					
				IF VJENIS_KUNJUNGAN = 2 THEN
					SET VKUNJUNGAN = PKUNJUNGAN;
				END IF;
				
				IF NOT VKUNJUNGAN IS NULL OR VJENIS_KUNJUNGAN = 2 THEN
					IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 7
						   AND VALUE = 'TRUE') THEN
						SELECT IF(rk.KELAS IS NULL, 0, rk.KELAS) KELAS
						  INTO VKELAS_SBLM
						  FROM pendaftaran.kunjungan k
						  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
								 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR 
						 WHERE k.NOMOR = VKUNJUNGAN
							AND k.RUANG_KAMAR_TIDUR > 0
							AND NOT k.`STATUS` = 0;
							
						IF NOT VKELAS_SBLM IS NULL THEN
							IF VKELAS_SBLM > 0 THEN
								SET VKELAS = VKELAS_SBLM;
							END IF;
						END IF;
					END IF;
					
					SET VKELAS_SBLM = pembayaran.getKelasRJMengikutiKelasRIYgPertama(VTAGIHAN, VKUNJUNGAN);
					IF VKELAS_SBLM > 0 THEN
						SET VKELAS = VKELAS_SBLM;
					END IF;
				END IF;
			END;
		END IF;		
				
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 1, PTINDAKAN, VRUANGAN, VQTY, VPAKET_DETIL);
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 AND VJUMLAH <= VQTY THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PTINDAKAN_MEDIS, VTANGGAL, 1, 1);
				END IF;
			END IF;
			
			IF VTAGIHAN != '' AND (VPAKET_DETIL = 0 OR VJUMLAH > VQTY) THEN			
				CALL master.getTarifTindakan(PTINDAKAN, VKELAS, VTANGGAL, VTARIF_ID, VTARIF);
				SET VPERSENTASE = penjamin_rs.getKenaikanTarif(VPENJAMIN, 3, VTANGGAL);
				IF VPERSENTASE > 0 THEN
					SET VTARIF = VTARIF + (VTARIF * VPERSENTASE);
				END IF;
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, PTINDAKAN_MEDIS, 3, VTARIF_ID, 1, VTARIF, VKELAS, 0, 0);
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
