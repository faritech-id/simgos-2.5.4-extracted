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


-- Membuang struktur basisdata untuk lis
CREATE DATABASE IF NOT EXISTS `lis`;
USE `lis`;

-- membuang struktur untuk procedure lis.storeHasilLabToHIS
DROP PROCEDURE IF EXISTS `storeHasilLabToHIS`;
DELIMITER //
CREATE PROCEDURE `storeHasilLabToHIS`(
	IN `PID` BIGINT
)
BEGIN
	DECLARE VID BIGINT;
	DECLARE VTINDAKAN_MEDIS CHAR(11);
	DECLARE VPARAMETER_TINDAKAN_LAB INT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VHASIL VARCHAR(250);
	DECLARE VKETERANGAN TEXT;
	DECLARE VNILAI_NORMAL VARCHAR(500);
	DECLARE VUSER VARCHAR(50);
	DECLARE VSATUAN VARCHAR(25);
	DECLARE DATA_NOT_FOUND INT DEFAULT FALSE;
	DECLARE VSTATUS TINYINT DEFAULT 2;
	DECLARE SUCCESS INT DEFAULT TRUE;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	
	SELECT hl.ID, tm.ID TINDAKAN_MEDIS, mh.PARAMETER_TINDAKAN_LAB, hl.LIS_TANGGAL, hl.LIS_HASIL, hl.LIS_CATATAN, hl.LIS_NILAI_NORMAL, hl.LIS_SATUAN
	  INTO VID, VTINDAKAN_MEDIS, VPARAMETER_TINDAKAN_LAB, VTANGGAL, VHASIL, VKETERANGAN, VNILAI_NORMAL, VSATUAN
	  FROM lis.hasil_log hl
	  		 , lis.mapping_hasil mh
	  		 , layanan.tindakan_medis tm
	 WHERE mh.LIS_KODE_TEST = hl.LIS_KODE_TEST
	   AND mh.HIS_KODE_TEST = hl.HIS_KODE_TEST
	   AND mh.PREFIX_KODE = hl.PREFIX_KODE
	   AND mh.VENDOR_LIS = hl.VENDOR_LIS
	   AND tm.KUNJUNGAN = hl.HIS_NO_LAB
		AND tm.TINDAKAN = hl.HIS_KODE_TEST
		AND tm.`STATUS` = 1
		AND hl.STATUS = 1
		AND hl.ID = PID
		LIMIT 1;
	
	IF NOT VID IS NULL THEN
		IF EXISTS(
			SELECT 1 
			  FROM layanan.hasil_lab hl 
			 WHERE hl.TINDAKAN_MEDIS = VTINDAKAN_MEDIS 
			   AND hl.PARAMETER_TINDAKAN = VPARAMETER_TINDAKAN_LAB
			   AND hl.`STATUS` = 1) THEN
			UPDATE layanan.hasil_lab
			   SET TANGGAL = VTANGGAL
			   	 , HASIL = VHASIL
			   	 , NILAI_NORMAL = VNILAI_NORMAL
			   	 , SATUAN = VSATUAN
			   	 , KETERANGAN = VKETERANGAN
			 WHERE TINDAKAN_MEDIS = VTINDAKAN_MEDIS 
			   AND PARAMETER_TINDAKAN = VPARAMETER_TINDAKAN_LAB
			   AND `STATUS` = 1;
		ELSE
			BEGIN
				DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET SUCCESS = FALSE;
				INSERT INTO layanan.hasil_lab(ID, TINDAKAN_MEDIS, PARAMETER_TINDAKAN, TANGGAL, HASIL, NILAI_NORMAL, SATUAN, KETERANGAN, OTOMATIS, OLEH)
				VALUES(generator.generateIdHasilLab(VTANGGAL), VTINDAKAN_MEDIS, VPARAMETER_TINDAKAN_LAB, VTANGGAL, VHASIL, VNILAI_NORMAL, VSATUAN, VKETERANGAN, 1, 1);
				
				IF NOT SUCCESS THEN
					SET VSTATUS = 8;
				END IF;
			END;
		END IF;		
	ELSE
		SET VSTATUS = 3;
	END IF;
	
	INSERT INTO aplikasi.automaticexecute(PERINTAH)
		VALUES(CONCAT("UPDATE lis.hasil_log SET STATUS = ", VSTATUS, " WHERE ID = ", PID));
END//
DELIMITER ;

-- membuang struktur untuk function lis.createKunjunganLab
DROP FUNCTION IF EXISTS `createKunjunganLab`;
DELIMITER //
CREATE FUNCTION `createKunjunganLab`(
	`PKUNJUNGAN` CHAR(25),
	`PPENDAFTARAN` CHAR(10),
	`PTANGGAL` DATETIME,
	`PUSER` SMALLINT,
	`PGDS` TINYINT
) RETURNS char(25) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VKUNJUNGAN CHAR(25);
	DECLARE VRUANGAN CHAR(10);
	DECLARE VFINAL_HASIL, VAUTO_FINAL_HASIL_GDS TINYINT;
	
	SELECT o.RUANGAN_LAB, o.AUTO_FINAL_HASIL_GDS
	  INTO VRUANGAN, VAUTO_FINAL_HASIL_GDS
	  FROM lis.lis_tanpa_order_config o
	 LIMIT 1;
	 
	IF VRUANGAN IS NULL THEN
		RETURN '';
	END IF;
	
	SET VFINAL_HASIL = 0;
	IF PGDS = 1 THEN
		SET VFINAL_HASIL = VAUTO_FINAL_HASIL_GDS;
	END IF;
	
	SELECT k.NOMOR
	  INTO VKUNJUNGAN
	  FROM pendaftaran.kunjungan k
	 WHERE k.NOPEN = PPENDAFTARAN
	   AND k.OTOMATIS = 1
	   AND k.RUANGAN = VRUANGAN
	   AND k.MASUK = PTANGGAL
		AND k.`STATUS` = 1
	 LIMIT 1;
	 
	IF VKUNJUNGAN IS NULL THEN
		# buat kunjungan lab
		SET VKUNJUNGAN = generator.generateNoKunjungan(VRUANGAN, DATE(PTANGGAL));
		
		INSERT INTO pendaftaran.kunjungan(NOMOR, NOPEN, RUANGAN, MASUK, KELUAR, REF, DITERIMA_OLEH, FINAL_HASIL, FINAL_HASIL_OLEH, FINAL_HASIL_TANGGAL, OTOMATIS, STATUS)
		VALUES(VKUNJUNGAN, PPENDAFTARAN, VRUANGAN, PTANGGAL, PTANGGAL, PKUNJUNGAN, PUSER, VFINAL_HASIL, PUSER, NOW(), 1, 2);
		
		RETURN VKUNJUNGAN;
	END IF;
	
	RETURN VKUNJUNGAN;
END//
DELIMITER ;

-- membuang struktur untuk function lis.createTindakanMedis
DROP FUNCTION IF EXISTS `createTindakanMedis`;
DELIMITER //
CREATE FUNCTION `createTindakanMedis`(
	`PKUNJUNGAN` CHAR(25),
	`PTINDAKAN` SMALLINT,
	`PTANGGAL` DATETIME,
	`PUSER` SMALLINT
) RETURNS char(25) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VTINDAKAN_MEDIS CHAR(11);
	DECLARE VDOKTER SMALLINT;
	
	SELECT a.DOKTER_LAB
	  INTO VDOKTER
	  FROM lis.lis_tanpa_order_config a
	 LIMIT 1;
	
	SELECT tm.ID
	  INTO VTINDAKAN_MEDIS
	  FROM layanan.tindakan_medis tm
	 WHERE tm.KUNJUNGAN = PKUNJUNGAN
	   AND tm.OTOMATIS = 1
	   AND tm.TINDAKAN = PTINDAKAN
	   AND tm.TANGGAL = PTANGGAL
	 LIMIT 1;
	
	IF NOT VTINDAKAN_MEDIS IS NULL THEN
		RETURN VTINDAKAN_MEDIS;
	END IF;
	
	SET VTINDAKAN_MEDIS = generator.generateIdTindakanMedis(DATE(PTANGGAL));
	INSERT INTO layanan.tindakan_medis(ID, KUNJUNGAN, TINDAKAN, TANGGAL, OLEH, OTOMATIS)
	VALUES(VTINDAKAN_MEDIS, PKUNJUNGAN, PTINDAKAN, PTANGGAL, PUSER, 1);
	
	# Masukan dokter penanggung jawab ke dalam petugas tindakan medis
	IF NOT VDOKTER IS NULL THEN
		IF NOT EXISTS(
			SELECT 1 
			  FROM layanan.petugas_tindakan_medis ptm 
			 WHERE ptm.TINDAKAN_MEDIS = VTINDAKAN_MEDIS
			   AND ptm.JENIS = 1
			   AND ptm.MEDIS = VDOKTER) THEN
			INSERT INTO layanan.petugas_tindakan_medis(TINDAKAN_MEDIS, JENIS, MEDIS)
			VALUES (VTINDAKAN_MEDIS, 1, VDOKTER);
		END IF;
	END IF;
	
	RETURN VTINDAKAN_MEDIS;
END//
DELIMITER ;

-- membuang struktur untuk function lis.getKunjunganTerakhir
DROP FUNCTION IF EXISTS `getKunjunganTerakhir`;
DELIMITER //
CREATE FUNCTION `getKunjunganTerakhir`(
	`PPENDAFTARAN` CHAR(10)
) RETURNS char(25) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VKUNJUNGAN VARCHAR(25);
	
	SELECT k.NOMOR
	  INTO VKUNJUNGAN
	  FROM pendaftaran.kunjungan k,
	  		 `master`.ruangan r
	 WHERE k.NOPEN = PPENDAFTARAN
	   AND k.`STATUS` IN (1,2)
	   AND r.ID = k.RUANGAN
	   AND r.JENIS_KUNJUNGAN IN (1,2,3)
	 ORDER BY k.MASUK DESC
	 LIMIT 1;
	   
	RETURN IFNULL(VKUNJUNGAN, '');
END//
DELIMITER ;

-- membuang struktur untuk function lis.getPendaftaranTerakhir
DROP FUNCTION IF EXISTS `getPendaftaranTerakhir`;
DELIMITER //
CREATE FUNCTION `getPendaftaranTerakhir`(
	`PPASIEN` INT
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
    COMMENT 'Mengambil noreg yang terakhir khusus IGD dan IRNA'
BEGIN
   DECLARE VPENDAFTARAN CHAR(10);
   DECLARE VJENIS_PENDAFTARAN TINYINT;
   DECLARE VDUA_BELAS_JAM TINYINT;
   DECLARE VJML TINYINT;
   
   # Ambil nomor pendaftaran terakhir dimana statusnya aktif dan belum bayar
   SELECT COUNT(*), NOMOR, JENIS_KUNJUNGAN, DUA_BELAS_JAM
      INTO VJML, VPENDAFTARAN, VJENIS_PENDAFTARAN, VDUA_BELAS_JAM
     FROM (
		SELECT p.NOMOR, r.JENIS_KUNJUNGAN, IF(TIMEDIFF(NOW(), p.TANGGAL) <= '12:00:00', 1, 0) DUA_BELAS_JAM
	     FROM pendaftaran.pendaftaran p,
		  		 pendaftaran.tujuan_pasien tpas,
		  		 `master`.ruangan r,
		  	    pembayaran.tagihan_pendaftaran tp,
		  	    pembayaran.tagihan t
		 WHERE p.NORM = PPASIEN
		   AND p.`STATUS` = 1
		   AND tpas.NOPEN = p.NOMOR
   		AND r.ID = tpas.RUANGAN
   		AND r.JENIS_KUNJUNGAN IN (1,2,3)
		   AND tp.PENDAFTARAN = p.NOMOR
		   AND tp.`STATUS` = 1
		   AND t.ID = tp.TAGIHAN
		   AND t.REF = PPASIEN
		   AND t.`STATUS` = 1
		 ORDER BY p.TANGGAL DESC 
	 	 LIMIT 1
	) a;
 	 
 	# Jika ada pendaftaran terakhir
 	IF VJML > 0 THEN
 		# Jika rawat darurat dan rawat inap
 		/*IF VJENIS_PENDAFTARAN IN (2, 3) THEN
	 		SELECT COUNT(*)
	 		  INTO VJML
			  FROM layanan.pasien_pulang pp 
			 WHERE pp.NOPEN = VPENDAFTARAN
			   AND pp.`STATUS` = 1
			 ORDER BY pp.TANGGAL DESC
			 LIMIT 1;
			 
			-- Jika pasien sudah pulang
			IF VJML > 0 THEN
				RETURN '';
			END IF;
			
			/*
			IF VJENIS_PENDAFTARAN = 2 THEN
				IF VDUA_BELAS_JAM = 1 THEN
					RETURN VPENDAFTARAN;
				END IF;
				
				RETURN '';
			END IF;
			*/
		# END IF;
		
		RETURN VPENDAFTARAN;
 	END IF;
   
   RETURN '';
END//
DELIMITER ;

-- membuang struktur untuk function lis.pasienIsValid
DROP FUNCTION IF EXISTS `pasienIsValid`;
DELIMITER //
CREATE FUNCTION `pasienIsValid`(
	`PID` INT
) RETURNS tinyint
    DETERMINISTIC
BEGIN	
	RETURN EXISTS(
		SELECT 1 
		  FROM `master`.pasien p
		 WHERE p.NORM = PID);
END//
DELIMITER ;

-- membuang struktur untuk trigger lis.hasil_log_after_insert
DROP TRIGGER IF EXISTS `hasil_log_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_after_insert` AFTER INSERT ON `hasil_log` FOR EACH ROW BEGIN   
	# Add parameter kode dan nama jika belum ada
	IF NOT EXISTS(SELECT 1 FROM lis.parameter_lis p WHERE p.VENDOR_ID = NEW.VENDOR_LIS AND p.KODE = NEW.LIS_KODE_TEST) THEN
		INSERT INTO lis.parameter_lis(VENDOR_ID, KODE, NAMA)
		VALUES(NEW.VENDOR_LIS, TRIM(NEW.LIS_KODE_TEST), TRIM(NEW.LIS_NAMA_TEST)); 
	END IF;
	
	# Add mapping hasil
	IF NOT EXISTS(
		SELECT 1 
		  FROM lis.mapping_hasil mh 
		 WHERE mh.VENDOR_LIS = NEW.VENDOR_LIS
		   AND mh.LIS_KODE_TEST = TRIM(NEW.LIS_KODE_TEST)
			AND mh.PREFIX_KODE = NEW.PREFIX_KODE
			AND mh.HIS_KODE_TEST = NEW.HIS_KODE_TEST) THEN
		INSERT INTO lis.mapping_hasil(`VENDOR_LIS`, LIS_KODE_TEST, PREFIX_KODE, HIS_KODE_TEST)
		VALUES(NEW.VENDOR_LIS, TRIM(NEW.LIS_KODE_TEST), NEW.PREFIX_KODE, HIS_KODE_TEST); 
	END IF;
	
	# jika his no lab and his kode test valid 
	IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
		CALL lis.storeHasilLabToHIS(NEW.ID);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis.hasil_log_after_update
DROP TRIGGER IF EXISTS `hasil_log_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `hasil_log_after_update` AFTER UPDATE ON `hasil_log` FOR EACH ROW BEGIN
	IF NEW.LIS_HASIL != OLD.LIS_HASIL OR NEW.STATUS = 1 THEN	
		# jika his no lab and his kode test valid 
		IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
			CALL lis.storeHasilLabToHIS(OLD.ID);	
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis.hasil_log_before_insert
DROP TRIGGER IF EXISTS `hasil_log_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_before_insert` BEFORE INSERT ON `hasil_log` FOR EACH ROW BEGIN
	# Vendor Tanpa Order
	IF NEW.VENDOR_LIS = 2 THEN
	BEGIN
		DECLARE VPENDAFTARAN CHAR(10);
		DECLARE VKUNJUNGAN, VHIS_NO_LAB CHAR(19);
		DECLARE VHIS_KODE_TEST INT;
		DECLARE VTINDAKAN_MEDIS CHAR(11);
		DECLARE VGDS TINYINT DEFAULT 0;
		
		# jika status = 1
		IF NEW.STATUS = 1 THEN
			# Hasil tanpa order
			IF NEW.LIS_HASIL != '' THEN # jika hasil valid
				# jika vendor novanet (bioconnect)
				IF NEW.VENDOR_LIS = 2 THEN
					# Jika pemeriksaan gds
					IF NEW.LIS_NAMA_INSTRUMENT = 'Novanet' THEN
					BEGIN
						DECLARE VPREFIX CHAR(1);
						DECLARE VPASIEN INT;
						SET VPREFIX = UPPER(LEFT(NEW.REF, 1));
						SET VPASIEN = CAST(SUBSTRING(NEW.REF, 2) AS UNSIGNED);
						
						SET VGDS = 1;
						
						IF EXISTS(
							SELECT 1 
							  FROM lis.prefix_parameter_lis p 
							 WHERE p.VENDOR_ID = NEW.VENDOR_LIS 
							   AND p.KODE = VPREFIX 
								AND p.LIS_KODE_TEST = NEW.LIS_KODE_TEST
						) THEN
							SET NEW.REF = VPASIEN;
							SET NEW.PREFIX_KODE = VPREFIX;
						END IF;
					END;
					END IF;
				END IF;
				
				IF lis.pasienIsValid(NEW.REF) = 1 THEN # jika pasien valid
					# jika vendor novanet (bioconnect)
					IF NEW.VENDOR_LIS = 2 THEN
						# jika his kode test belum di set
						IF NEW.HIS_KODE_TEST = 0 THEN
						BEGIN
							DECLARE VPARAMETER_TINDAKAN_LAB INT;
							
							SELECT mh.HIS_KODE_TEST, mh.PARAMETER_TINDAKAN_LAB
							  INTO VHIS_KODE_TEST, VPARAMETER_TINDAKAN_LAB
							  FROM lis.mapping_hasil mh
							 WHERE mh.VENDOR_LIS = NEW.VENDOR_LIS
							   AND mh.LIS_KODE_TEST = NEW.LIS_KODE_TEST
							   AND mh.PREFIX_KODE = NEW.PREFIX_KODE
							 LIMIT 1;
							 
							SET NEW.HIS_KODE_TEST = IFNULL(VHIS_KODE_TEST,0);
							SET VPARAMETER_TINDAKAN_LAB = IFNULL(VPARAMETER_TINDAKAN_LAB, 0);
							IF NEW.HIS_KODE_TEST = 0 OR VPARAMETER_TINDAKAN_LAB = 0 THEN
								SET NEW.STATUS = 3;
							END IF;
						END;
						END IF;
						
						# jika his no lab belum di set
						IF NEW.HIS_NO_LAB = '' THEN
							# ambil jika ada his no lab yg di set sebelumnya dimana lis no sama
							SELECT hl.HIS_NO_LAB
							  INTO VHIS_NO_LAB
							  FROM lis.hasil_log hl
							 WHERE hl.LIS_NO = NEW.LIS_NO
							   AND hl.HIS_NO_LAB != ''
							 LIMIT 1;
							 
							IF VHIS_NO_LAB IS NOT NULL THEN # jika ada
								SET NEW.HIS_NO_LAB = VHIS_NO_LAB;
							ELSE # jika belum di set
								SET VPENDAFTARAN = lis.getPendaftaranTerakhir(NEW.REF);
								# jika pendafaran terakhir valid
								IF VPENDAFTARAN != '' THEN
									# Ambil kunjungan terakhir
									SET VKUNJUNGAN = lis.getKunjunganTerakhir(VPENDAFTARAN);
									IF VKUNJUNGAN != '' THEN
										SET NEW.HIS_NO_LAB = lis.createKunjunganLab(VKUNJUNGAN, VPENDAFTARAN, NEW.LIS_TANGGAL, NEW.LIS_USER, VGDS);
									ELSE
										SET NEW.STATUS = 8;
									END IF;
								ELSE
									SET NEW.STATUS = 5;
								END IF;
							END IF;
						END IF;
						
						# jika his no lab and his kode test valid 
						IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
							SET VTINDAKAN_MEDIS = lis.createTindakanMedis(NEW.HIS_NO_LAB, NEW.HIS_KODE_TEST, NEW.LIS_TANGGAL, NEW.LIS_USER);
						END IF;
					END IF;
				ELSE
					IF LENGTH(NEW.REF) != 10 AND INSTR(NEW.REF, 'QC') = 0 THEN
						SET NEW.STATUS = 10;
					ELSE
						SET NEW.STATUS = 4;
					END IF;
				END IF;
			ELSE 
				SET NEW.STATUS = 9;
			END IF;
		END IF;
	END;
	ELSE
		IF TRIM(NEW.HIS_NO_LAB) = '' OR NEW.HIS_NO_LAB IS NULL THEN
			SET NEW.STATUS = 8;
		END IF;
		
		IF NEW.HIS_KODE_TEST = 0 THEN
			SET NEW.STATUS = 3;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis.hasil_log_before_update
DROP TRIGGER IF EXISTS `hasil_log_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_log_before_update` BEFORE UPDATE ON `hasil_log` FOR EACH ROW BEGIN
	IF OLD.VENDOR_LIS != 2 THEN
		IF TRIM(NEW.HIS_NO_LAB) = '' OR NEW.HIS_NO_LAB IS NULL THEN
			SET NEW.STATUS = 8;
		END IF;
		
		IF OLD.HIS_KODE_TEST = 0 AND NEW.HIS_KODE_TEST = 0 THEN
			SET NEW.STATUS = 3;
		END IF;
	ELSE
	BEGIN
		DECLARE VPENDAFTARAN CHAR(10);
		DECLARE VKUNJUNGAN, VHIS_NO_LAB CHAR(19);
		DECLARE VHIS_KODE_TEST INT;
		DECLARE VTINDAKAN_MEDIS CHAR(11);
		DECLARE VGDS TINYINT DEFAULT 0;
		
		# jika status = 1
		IF NEW.STATUS = 1 THEN
			# Hasil tanpa order
			IF NEW.LIS_HASIL != '' THEN # jika hasil valid
				# jika vendor novanet (bioconnect)
				IF NEW.VENDOR_LIS = 2 THEN
					# Jika pemeriksaan gds
					IF NEW.LIS_NAMA_INSTRUMENT = 'Novanet' THEN
					BEGIN
						DECLARE VPREFIX CHAR(1);
						DECLARE VPASIEN INT;
						SET VPREFIX = UPPER(LEFT(NEW.REF, 1));
						SET VPASIEN = CAST(SUBSTRING(NEW.REF, 2) AS UNSIGNED);
						
						SET VGDS = 1;
						
						IF EXISTS(
							SELECT 1 
							  FROM lis.prefix_parameter_lis p 
							 WHERE p.VENDOR_ID = NEW.VENDOR_LIS 
							   AND p.KODE = VPREFIX 
								AND p.LIS_KODE_TEST = NEW.LIS_KODE_TEST
						) THEN
							SET NEW.REF = VPASIEN;
							SET NEW.PREFIX_KODE = VPREFIX;
						END IF;
					END;
					END IF;
				END IF;
				
				IF lis.pasienIsValid(NEW.REF) = 1 THEN # jika pasien valid
					# jika vendor novanet (bioconnect)
					IF NEW.VENDOR_LIS = 2 THEN
						# jika his kode test belum di set
						IF OLD.HIS_KODE_TEST = 0 AND NEW.HIS_KODE_TEST = 0 THEN
						BEGIN
							DECLARE VPARAMETER_TINDAKAN_LAB INT;
							
							SELECT mh.HIS_KODE_TEST, mh.PARAMETER_TINDAKAN_LAB
							  INTO VHIS_KODE_TEST, VPARAMETER_TINDAKAN_LAB
							  FROM lis.mapping_hasil mh
							 WHERE mh.VENDOR_LIS = NEW.VENDOR_LIS
							   AND mh.LIS_KODE_TEST = NEW.LIS_KODE_TEST
							   AND mh.PREFIX_KODE = NEW.PREFIX_KODE
							 LIMIT 1;
							 
							SET NEW.HIS_KODE_TEST = IFNULL(VHIS_KODE_TEST,0);
							SET VPARAMETER_TINDAKAN_LAB = IFNULL(VPARAMETER_TINDAKAN_LAB, 0);
							IF NEW.HIS_KODE_TEST = 0 OR VPARAMETER_TINDAKAN_LAB = 0 THEN
								SET NEW.STATUS = 3;
							END IF;
						END;
						END IF;
						
						# jika his no lab belum di set
						IF OLD.HIS_NO_LAB = '' AND NEW.HIS_NO_LAB = '' THEN
							# ambil jika ada his no lab yg di set sebelumnya dimana lis no sama
							SELECT hl.HIS_NO_LAB
							  INTO VHIS_NO_LAB
							  FROM lis.hasil_log hl
							 WHERE hl.LIS_NO = OLD.LIS_NO
							   AND hl.HIS_NO_LAB != ''
							 LIMIT 1;
							 
							IF VHIS_NO_LAB IS NOT NULL THEN # jika ada
								SET NEW.HIS_NO_LAB = VHIS_NO_LAB;
							ELSE # jika belum di set
								SET VPENDAFTARAN = lis.getPendaftaranTerakhir(NEW.REF);
								# jika pendafaran terakhir valid
								IF VPENDAFTARAN != '' THEN
									# Ambil kunjungan terakhir
									SET VKUNJUNGAN = lis.getKunjunganTerakhir(VPENDAFTARAN);
									IF VKUNJUNGAN != '' THEN
										SET NEW.HIS_NO_LAB = lis.createKunjunganLab(VKUNJUNGAN, VPENDAFTARAN, NEW.LIS_TANGGAL, NEW.LIS_USER, VGDS);
									ELSE
										SET NEW.STATUS = 8;
									END IF;
								ELSE
									SET NEW.STATUS = 5;
								END IF;
							END IF;
						END IF;
						
						# jika his no lab and his kode test valid 
						IF NEW.HIS_NO_LAB != '' AND NEW.HIS_KODE_TEST > 0 THEN
							SET VTINDAKAN_MEDIS = lis.createTindakanMedis(NEW.HIS_NO_LAB, NEW.HIS_KODE_TEST, NEW.LIS_TANGGAL, NEW.LIS_USER);
						END IF;
					END IF;
				ELSE
					IF LENGTH(NEW.REF) != 10 AND INSTR(NEW.REF, 'QC') = 0 THEN
						SET NEW.STATUS = 10;
					ELSE
						SET NEW.STATUS = 4;
					END IF;
				END IF;
			ELSE 
				SET NEW.STATUS = 9;
			END IF;
		END IF;
	END;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis.parameter_lis_after_insert
DROP TRIGGER IF EXISTS `parameter_lis_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `parameter_lis_after_insert` AFTER INSERT ON `parameter_lis` FOR EACH ROW BEGIN
	# Add mapping hasil
	IF NOT EXISTS(
		SELECT 1 
		  FROM lis.mapping_hasil mh 
		 WHERE mh.VENDOR_LIS = NEW.VENDOR_ID
		   AND mh.LIS_KODE_TEST = NEW.KODE) THEN
		INSERT INTO lis.mapping_hasil(`VENDOR_LIS`, LIS_KODE_TEST)
		VALUES(NEW.VENDOR_ID, NEW.KODE); 
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
