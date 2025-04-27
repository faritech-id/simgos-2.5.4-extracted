-- --------------------------------------------------------
-- Host:                         192.168.23.245
-- Versi server:                 5.7.26 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk pembayaran
#CREATE DATABASE IF NOT EXISTS `pembayaran` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganBPJS
DROP PROCEDURE IF EXISTS `prosesPerhitunganBPJS`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `prosesPerhitunganBPJS`(
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
		
	# JIKA PASIEN BPJS & AMBIL STATUS NAIK KELAS
	SELECT pt.NAIK_KELAS INTO VNAIK_KELAS 
	  FROM pembayaran.penjamin_tagihan pt 
	 WHERE pt.TAGIHAN = PTAGIHAN 
	   AND pt.PENJAMIN = 2 
	 LIMIT 1;	
	 
	IF FOUND_ROWS() > 0 THEN
		# AMBIL TOTAL TAGIHAN			      
		SET VTOTAL_TAGIHAN = pembayaran.getTotalTagihan(PTAGIHAN);
		
		# AMBIL HAK KELAS, TARIF INACBG KELAS HAK DAN KELAS 1 
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
		   	 , pt.TARIF_INACBG_KELAS1 = VTOTAL_TARIF_KELAS1
		 WHERE pt.TAGIHAN = PTAGIHAN
		   AND pt.PENJAMIN = 2;
		
		SET VKELAS_RAWAT = PKELAS;				
		
		SELECT grk.KELAS INTO VKELAS_HAK
		  FROM master.group_referensi_kelas grk
		 WHERE grk.REFERENSI_KELAS = VKELAS_HAK;
		 
		# JIKA AKOMODASI & RAWAT INTENSI
		IF PJENIS = 2 THEN
			/*
			SELECT r.REF_ID INTO VINTENSIF
			  FROM pendaftaran.kunjungan k
			  		 , master.ruangan r
			 WHERE k.NOMOR = PREF_ID
			   AND r.ID = k.RUANGAN
			   AND k.`STATUS` IN (1, 2)
			   AND k.RUANG_KAMAR_TIDUR > 0
			   AND r.JENIS_KUNJUNGAN = 3
			 LIMIT 1;
			 */
			 #IF VINTENSIF = 1 THEN
				 SELECT grk.KELAS INTO VKELAS_RAWAT
				   FROM master.group_referensi_kelas grk
				  WHERE grk.REFERENSI_KELAS = VKELAS_RAWAT;
				  
				IF VKELAS_RAWAT = 0 THEN
					SET VKELAS_RAWAT = VKELAS_HAK;
				END IF;
			 #END IF;
		ELSE
			SELECT grk.KELAS INTO VKELAS_RAWAT
			  FROM master.group_referensi_kelas grk
			 WHERE grk.REFERENSI_KELAS = VKELAS_RAWAT;						
		END IF;
		
		/* naik kelas vip */			
		IF VKELAS_RAWAT > 3 THEN
			SET VNAIK_KELAS = TRUE;
			/* diatas vip */
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
			/* naik kelas non vip */
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
			
			# JIKA ATURAN_JKN_MENGIKUTI_KEBIJAKAN_RS
			IF EXISTS(SELECT 1
				  FROM aplikasi.properti_config pc
				 WHERE pc.ID = 9
				   AND VALUE = 'TRUE') THEN
			# PERHITUNGAN SELISIH AKOMODASI ANTARA KELAS HAK DAN NAIK KELAS	
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
					
				IF FOUND_ROWS() > 0 THEN
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
		
		/* ambil total tagihan hak */
		IF VKELAS_RAWAT <= VKELAS_HAK THEN
		BEGIN
			/* jika not inserted maka kurangi  */		
			IF NOT PINSERTED THEN
				UPDATE pembayaran.penjamin_tagihan pt
				   SET pt.TOTAL_TAGIHAN_HAK = pt.TOTAL_TAGIHAN_HAK - PTOTAL
				 WHERE pt.TAGIHAN = PTAGIHAN
				   AND pt.PENJAMIN = 2;
			END IF;
			
			/* store total tagihan hak ke penjamin tagihan */				
			UPDATE pembayaran.penjamin_tagihan pt
			   SET pt.TOTAL_TAGIHAN_HAK = pt.TOTAL_TAGIHAN_HAK + PTOTAL
			 WHERE pt.TAGIHAN = PTAGIHAN
			   AND pt.PENJAMIN = 2;
		END;
		END IF;
		
		/* hitung & store subsidi & minimal selisih */			
		BEGIN
			DECLARE VTOTAL_JAMINAN DECIMAL(60,2);
			DECLARE VTOTAL_TAGIHAN_HAK DECIMAL(60,2);
			DECLARE VNAIK_KELAS_VIP TINYINT;
			DECLARE VNAIK_KELAS TINYINT;
			DECLARE VNAIK_DIATAS_VIP TINYINT;
			DECLARE VSELISIH DECIMAL(60,2);
			DECLARE VSUBSIDI DECIMAL(60,2) DEFAULT 0;
			DECLARE VSUBSIDI_TAGIHAN INT;
			DECLARE VSELISIH_MINIMAL DECIMAL(60,2) DEFAULT 0;
			DECLARE VMINTARIFINACBGPERSEN SMALLINT;
			
			SELECT CAST(pc.VALUE AS SIGNED) INTO VMINTARIFINACBGPERSEN
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 16;
				 
			IF FOUND_ROWS() = 0 THEN
				SET VMINTARIFINACBGPERSEN = 0;
			END IF;
			
			SELECT pt.TOTAL, pt.TOTAL_NAIK_KELAS, pt.NAIK_KELAS, pt.NAIK_KELAS_VIP, pt.NAIK_DIATAS_VIP, pt.TOTAL_TAGIHAN_HAK, pt.SUBSIDI_TAGIHAN, pt.SELISIH_MINIMAL
			  INTO VTOTAL_JAMINAN, VTARIF_NAIK_KELAS, VNAIK_KELAS, VNAIK_KELAS_VIP, VNAIK_DIATAS_VIP, VTOTAL_TAGIHAN_HAK, VSUBSIDI_TAGIHAN, VSELISIH_MINIMAL
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
