USE `pembayaran`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure pembayaran.reStoreTagihan
DROP PROCEDURE IF EXISTS `reStoreTagihan`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `reStoreTagihan`(IN `PTAGIHAN` CHAR(10)
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
	DECLARE VKUNJUNGAN_TMP CHAR(19);
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
		   	 pt.LAMA_NAIK = 0
		 WHERE pt.TAGIHAN = PTAGIHAN;
		 
		UPDATE pembayaran.penjamin_tagihan pt,
		       pembayaran.subsidi_tagihan st
		   SET st.TOTAL = 0
		 WHERE pt.TAGIHAN = PTAGIHAN
		   AND st.TAGIHAN = pt.TAGIHAN
			AND st.ID = pt.SUBSIDI_TAGIHAN;
			
		IF NOT EXISTS(SELECT 1 FROM pembayaran.penjamin_tagihan pt WHERE pt.TAGIHAN = PTAGIHAN) THEN
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
		
		SELECT p.NOMOR, p.PAKET, p.TANGGAL INTO VPENDAFTARAN, VPAKET, VTANGGAL_PENDAFTARAN
		  FROM pembayaran.tagihan_pendaftaran tp,
		  		 pendaftaran.pendaftaran p
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND p.NOMOR = tp.PENDAFTARAN
		   
		   AND tp.UTAMA = 1
		 LIMIT 1;
		 
		IF FOUND_ROWS() = 0 THEN
			SET VTANGGAL_PENDAFTARAN = NOW();
		END IF;
		 		
		IF VPAKET > 0 OR NOT VPAKET IS NULL THEN
			CALL master.getTarifPaket(VPAKET, VTANGGAL_PENDAFTARAN, VTARIF_ID, VTARIF);
			CALL pembayaran.storeRincianTagihan(PTAGIHAN, VPENDAFTARAN, 5, VTARIF_ID, 1, VTARIF, 0, 0, 0);
		END IF;
				
		IF (VPAKET > 0 OR NOT VPAKET IS NULL) AND NOT VKARTU IS NULL THEN
			CALL master.inPaket(VPAKET, 3, 1, VQTY, VPAKET_DETIL);
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
			
			IF FOUND_ROWS() > 0 THEN
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
				
				SELECT kp.ID, r.JENIS_KUNJUNGAN, p.NORM INTO VKARCIS, VJENIS_KUNJUNGAN, VNORM
				  FROM cetakan.karcis_pasien kp
				  		 , pendaftaran.tujuan_pasien tps
				  		 , pendaftaran.pendaftaran p
					  	 , master.ruangan r
				 WHERE kp.NOPEN = VPENDAFTARAN
				   AND kp.JENIS = 1
				   AND tps.NOPEN = kp.NOPEN
					AND r.ID = tps.RUANGAN
					AND p.NOMOR = tps.NOPEN
				 LIMIT 1;
				
				IF (VPAKET > 0 OR NOT VPAKET IS NULL) AND NOT VKARCIS IS NULL THEN
					CALL master.inPaket(VPAKET, 3, 2, VQTY, VPAKET_DETIL);
					IF VPAKET_DETIL > 0 THEN
						CALL pembayaran.storeRincianTagihanPaket(PTAGIHAN, VPAKET_DETIL, VKARCIS, VTANGGAL_PENDAFTARAN, 1, 1);
					END IF;
				END IF;
				
				IF VPAKET_DETIL = 0 AND NOT VKARCIS IS NULL THEN
					IF NOT VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN THEN						   
						CALL master.getTarifAdministrasi(2, VJENIS_KUNJUNGAN, VTANGGAL_PENDAFTARAN, VTARIF_ID, VTARIF);
					ELSE
						
						IF EXISTS(SELECT 1
							  FROM aplikasi.properti_config pc
							 WHERE pc.ID = 24
							   AND VALUE = 'TRUE') THEN
							IF NOT EXISTS(SELECT 1
								  FROM pendaftaran.kunjungan k,
								  		 pendaftaran.pendaftaran p,
								       master.ruangan rg
								 WHERE NOT k.NOPEN = VPENDAFTARAN
								   AND k.`STATUS` > 0
									AND p.NOMOR = k.NOPEN
									AND p.NORM = VNORM
									AND rg.ID = k.RUANGAN
									AND rg.JENIS_KUNJUNGAN = VJENIS_KUNJUNGAN
								 LIMIT 1) THEN								   							   
								SET VPASIEN_BARU = 1;
							END IF;
						END IF;
						
						CALL master.getTarifAdministrasiBerdasarkanJenisPasien(2, VJENIS_KUNJUNGAN, VTANGGAL_PENDAFTARAN, VPASIEN_BARU, VTARIF_ID, VTARIF);
					END IF;
					
					SET VKELAS = 0;
					
					SELECT k.NOMOR, IF(rk.KELAS IS NULL, -1, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, rk.KELAS))
					  INTO VKUNJUNGAN_TMP, VKELAS
					  FROM pendaftaran.kunjungan k
					       LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
					 		 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
					 WHERE k.NOPEN = VPENDAFTARAN			   
					   AND k.REF IS NULL
					   AND NOT k.`STATUS` = 0;
					
					IF FOUND_ROWS() > 0 THEN
						IF VKELAS < 0 THEN			
							SET VKELAS = pembayaran.getKelasRJMengikutiKelasRIYgPertama(PTAGIHAN, VKUNJUNGAN_TMP);
							IF VKELAS < 0 THEN
								SET VKELAS = 0;
							END IF;
						END IF;
					END IF;
					
					CALL pembayaran.storeRincianTagihan(PTAGIHAN, VKARCIS, 1, VTARIF_ID, 1, VTARIF, VKELAS, 0, 0);
				END IF;
			END LOOP;
			CLOSE CR_TAGIHAN_PENDAFTARAN;
		END;
				
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
								   AND f.`STATUS` = 2 AND f.TINDAKAN_PAKET = 0 #ScriptLine Untuk Tindakan Paket Tidak Masuk Tagihan
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
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;