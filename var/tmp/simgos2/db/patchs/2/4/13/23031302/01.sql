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
	 
	IF FOUND_ROWS() > 0 THEN
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
			DECLARE VMINTARIFINACBGPERSEN SMALLINT;
			DECLARE VKELAS_KLAIM SMALLINT;
			DECLARE VTARIF_INACBG_KELAS1 DECIMAL(60,2);
			
			SELECT CAST(pc.VALUE AS SIGNED) INTO VMINTARIFINACBGPERSEN
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 16;
				 
			IF FOUND_ROWS() = 0 THEN
				SET VMINTARIFINACBGPERSEN = 0;
			END IF;
			
			SELECT pt.TOTAL, pt.TOTAL_NAIK_KELAS, pt.NAIK_KELAS, pt.NAIK_KELAS_VIP, pt.NAIK_DIATAS_VIP
					 , pt.TOTAL_TAGIHAN_HAK, pt.SUBSIDI_TAGIHAN, pt.SELISIH_MINIMAL, pt.TOTAL_TAGIHAN_VIP, pt.KELAS_KLAIM, pt.TARIF_INACBG_KELAS1
			  INTO VTOTAL_JAMINAN, VTARIF_NAIK_KELAS, VNAIK_KELAS, VNAIK_KELAS_VIP, VNAIK_DIATAS_VIP
			  	    , VTOTAL_TAGIHAN_HAK, VSUBSIDI_TAGIHAN, VSELISIH_MINIMAL, VTOTAL_TAGIHAN_VIP, VKELAS_KLAIM, VTARIF_INACBG_KELAS1
			  FROM pembayaran.penjamin_tagihan pt
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2;
			   
			IF FOUND_ROWS() > 0 THEN
			BEGIN					
				SET VSELISIH = VTOTAL_TAGIHAN - VTOTAL_JAMINAN;
				SET VSELISIH = IF(VSELISIH <= 0, 0, VSELISIH);
														
				IF VSELISIH > 0 THEN
					IF VNAIK_KELAS = 0 AND VNAIK_KELAS_VIP = 0 THEN
						SET VSUBSIDI = VSELISIH;					
					END IF;
				END IF;
				
				IF VNAIK_KELAS_VIP = 1 OR VNAIK_DIATAS_VIP = 1 THEN
				BEGIN
					DECLARE VSEL DECIMAL(60,2);
					DECLARE VSELMIN DECIMAL(60, 2);
					DECLARE VSELMAX DECIMAL(60, 2);		
					DECLARE VSELTGHN DECIMAL(60, 2);			
											
					SET VSEL = VTOTAL_TAGIHAN - VTARIF_INACBG_KELAS1;
					SET VSELMAX = VTARIF_INACBG_KELAS1 * (75/100);
					SET VSELTGHN = VTOTAL_TAGIHAN_VIP - VTARIF_INACBG_KELAS1;
					SET VSELTGHN = IF(VSELTGHN <= 0, 0, VSELTGHN);
			   	
			   	IF VKELAS_KLAIM = 3 THEN
			   		IF VSELTGHN <= VSELMAX THEN
					   	SET VSELISIH_MINIMAL = VSELTGHN;
					   ELSE
					   	SET VSELISIH_MINIMAL = VSELMAX;
					   END IF;
					   SET VSEL = VSELTGHN;
			   	ELSE
			   		IF VTOTAL_TAGIHAN_VIP <= VSELMAX THEN
					   	SET VSELISIH_MINIMAL = VTOTAL_TAGIHAN_VIP;
					   ELSE
					   	SET VSELISIH_MINIMAL = VSELMAX;
					   END IF;
					   SET VSEL = VTOTAL_TAGIHAN_VIP;
			   	END IF;
				   
				   UPDATE pembayaran.penjamin_tagihan pt
					   SET pt.TOTAL_NAIK_KELAS = IF(VSEL > 0, pt.TARIF_INACBG_KELAS1, VTOTAL_TAGIHAN_VIP),
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

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganBPJSMode2
DROP PROCEDURE IF EXISTS `prosesPerhitunganBPJSMode2`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganBPJSMode2`(
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
	 
	IF FOUND_ROWS() > 0 THEN
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
		
		IF VKELAS_RAWAT > 2 THEN
			SET VNAIK_KELAS = FALSE;
			
			IF VKELAS_RAWAT > VKELAS_HAK THEN
				SET VNAIK_KELAS = TRUE;
			END IF;
			
			IF VKELAS_RAWAT > 3 THEN
				IF PJENIS = 3 OR PJENIS = 2 THEN
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
			DECLARE VMINTARIFINACBGPERSEN SMALLINT;
			DECLARE VKELAS_KLAIM SMALLINT;
			DECLARE VTARIF_INACBG_KELAS1 DECIMAL(60,2);
			
			SELECT CAST(pc.VALUE AS SIGNED) INTO VMINTARIFINACBGPERSEN
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 16;
				 
			IF FOUND_ROWS() = 0 THEN
				SET VMINTARIFINACBGPERSEN = 0;
			END IF;
			
			SELECT pt.TOTAL, pt.TOTAL_NAIK_KELAS, pt.NAIK_KELAS, pt.NAIK_KELAS_VIP, pt.NAIK_DIATAS_VIP
					 , pt.TOTAL_TAGIHAN_HAK, pt.SUBSIDI_TAGIHAN, pt.SELISIH_MINIMAL, pt.TOTAL_TAGIHAN_VIP, pt.KELAS_KLAIM, pt.TARIF_INACBG_KELAS1
			  INTO VTOTAL_JAMINAN, VTARIF_NAIK_KELAS, VNAIK_KELAS, VNAIK_KELAS_VIP, VNAIK_DIATAS_VIP
			  	    , VTOTAL_TAGIHAN_HAK, VSUBSIDI_TAGIHAN, VSELISIH_MINIMAL, VTOTAL_TAGIHAN_VIP, VKELAS_KLAIM, VTARIF_INACBG_KELAS1
			  FROM pembayaran.penjamin_tagihan pt
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2;
			   
			IF FOUND_ROWS() > 0 THEN
			BEGIN					
				SET VSELISIH = VTOTAL_TAGIHAN - VTOTAL_JAMINAN;
				SET VSELISIH = IF(VSELISIH <= 0, 0, VSELISIH);
														
				IF VSELISIH > 0 THEN
					IF VNAIK_KELAS = 0 AND VNAIK_KELAS_VIP = 0 THEN
						SET VSUBSIDI = VSELISIH;					
					END IF;
				END IF;
				
				IF VNAIK_KELAS_VIP = 1 OR VNAIK_DIATAS_VIP = 1 THEN
				BEGIN
					DECLARE VSEL DECIMAL(60,2);
					DECLARE VSELMIN DECIMAL(60, 2);
					DECLARE VSELMAX DECIMAL(60, 2);
					DECLARE VSELTGHN DECIMAL(60, 2);			
											
					SET VSEL = VTOTAL_TAGIHAN - VTARIF_INACBG_KELAS1;
					SET VSELMAX = VTARIF_INACBG_KELAS1 * (75/100);
					SET VSELTGHN = VTOTAL_TAGIHAN_VIP - VTARIF_INACBG_KELAS1;
					SET VSELTGHN = IF(VSELTGHN <= 0, 0, VSELTGHN);
			   	
			   	IF VKELAS_KLAIM = 3 THEN
			   		IF VSELTGHN <= VSELMAX THEN
					   	SET VSELISIH_MINIMAL = VSELTGHN;
					   ELSE
					   	SET VSELISIH_MINIMAL = VSELMAX;
					   END IF;
					   SET VSEL = VSELTGHN;
			   	ELSE
			   		IF VTOTAL_TAGIHAN_VIP <= VSELMAX THEN
					   	SET VSELISIH_MINIMAL = VTOTAL_TAGIHAN_VIP;
					   ELSE
					   	SET VSELISIH_MINIMAL = VSELMAX;
					   END IF;
					   SET VSEL = VTOTAL_TAGIHAN_VIP;
			   	END IF;
				   
				   UPDATE pembayaran.penjamin_tagihan pt
					   SET pt.TOTAL_NAIK_KELAS = IF(VSEL > 0, pt.TARIF_INACBG_KELAS1, VTOTAL_TAGIHAN_VIP),
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

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
