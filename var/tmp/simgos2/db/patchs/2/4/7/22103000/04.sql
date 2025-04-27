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

-- Membuang struktur basisdata untuk kemkes-rsonline
USE `kemkes-rsonline`;

-- membuang struktur untuk procedure kemkes-rsonline.executeTempatTidurRSOnline
DROP PROCEDURE IF EXISTS `executeTempatTidurRSOnline`;
DELIMITER //
CREATE PROCEDURE `executeTempatTidurRSOnline`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTGL_AWAL DATETIME;
   DECLARE VTGL_AKHIR DATETIME;
  
   SET VTGL_AWAL = CONCAT(PTGL_AWAL, ' 00:00:01');
   SET VTGL_AKHIR = CONCAT(PTGL_AKHIR, ' 23:59:59');
  
	BEGIN
		DROP TEMPORARY TABLE IF EXISTS TEMP_TT_ONLINE_HASIL;  
     
     	CREATE TEMPORARY TABLE TEMP_TT_ONLINE_HASIL ENGINE=MEMORY
      	SELECT id_tt
	       		 , ruang
			       , COUNT(DISTINCT(idruang)) jumlah_ruang
			       , SUM(jumlah) jumlah
			       , SUM(terpakai) terpakai
			       , SUM(terpakai_suspek) terpakai_suspek
			       , SUM(terpakai_konfirmasi) terpakai_konfirmasi
			       , covid
			       , antrian
			  FROM (
				SELECT kso.tempat_tidur id_tt
				       , IF(kso.covid = 1, '', ttk.SUBUNIT) ruang
				       , ttk.IDSUBUNIT idruang
				       , (ttk.TTLAKI + ttk.TTPEREMPUAN) jumlah
				       , (ttk.JMLLAKI + ttk.JMLPEREMPUAN) terpakai
				       , IF(kso.covid = 1, (ttk.JMLLAKI + ttk.JMLPEREMPUAN)- ttk.TERPAKAI_KONFIRMASI,0) terpakai_suspek
					    , IF(kso.covid = 1, ttk.TERPAKAI_KONFIRMASI,0) terpakai_konfirmasi
				       , kso.covid
				       , IF(kso.covid = 1, kso.tempat_tidur, CONCAT(ttk.IDSUBUNIT, kso.tempat_tidur)) data_group
				       , pendaftaran.getJumlahAntrianTempatTidur(ttk.IDSUBUNIT) antrian
				  FROM informasi.tempat_tidur_kemkes ttk,
				  		 `kemkes-rsonline`.kamar_simrs_rs_online kso
				 WHERE kso.ruang_kamar = ttk.IDKAMAR
				   AND kso.tempat_tidur != 0
					AND kso.`status` = 1
					AND ttk.LASTUPDATED BETWEEN VTGL_AWAL AND VTGL_AKHIR
			) tt
			GROUP BY data_group;      
   END;
  
  	BEGIN    
	    DECLARE VIDTT TINYINT;
	    DECLARE VRUANG VARCHAR(1000);
	    DECLARE VJUMLAH_RUANGAN SMALLINT;
	    DECLARE VJUMLAH SMALLINT;
	    DECLARE VTERPAKAI SMALLINT;
	    DECLARE VTERPAKAI_SUSPEK SMALLINT;
       DECLARE VTERPAKAI_KONFIRMASI SMALLINT;
	    DECLARE VANTRIAN SMALLINT;
	    
	    DECLARE VCOVID TINYINT;
	    
	    DECLARE DATA_NOT_FOUND TINYINT DEFAULT FALSE;    
	    DECLARE CR_EXEC_DATA CURSOR FOR 
	      SELECT id_tt
				  , ruang
	           , jumlah_ruang
	           , jumlah
	           , terpakai
	           , terpakai_suspek
	           , terpakai_konfirmasi
	           , covid
	           , antrian
	        FROM TEMP_TT_ONLINE_HASIL;      
	    DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	            
	    OPEN CR_EXEC_DATA;
	            
	    EXIT_EXEC: LOOP
	      FETCH CR_EXEC_DATA INTO 
				VIDTT
				, VRUANG
				, VJUMLAH_RUANGAN
				, VJUMLAH
				, VTERPAKAI
				, VTERPAKAI_SUSPEK
				, VTERPAKAI_KONFIRMASI
				, VCOVID
				, VANTRIAN;
	      
	      IF DATA_NOT_FOUND THEN
	      	UPDATE temp.temp SET ID = 0 WHERE ID = 0;
	        LEAVE EXIT_EXEC;
	      END IF;                  
	            
	      IF EXISTS(SELECT 1 FROM `kemkes-rsonline`.data_tempat_tidur WHERE id_tt = VIDTT AND ruang = VRUANG) THEN
	        UPDATE `kemkes-rsonline`.data_tempat_tidur 
	           SET jumlah_ruang = VJUMLAH_RUANGAN
				  		, jumlah = VJUMLAH
						, terpakai = VTERPAKAI
						, terpakai_suspek = VTERPAKAI_SUSPEK
						, terpakai_konfirmasi = VTERPAKAI_KONFIRMASI
						, covid = VCOVID
						, antrian = VANTRIAN
						, kirim = 1
	          WHERE id_tt = VIDTT AND ruang = VRUANG;
	      ELSE
	        REPLACE INTO `kemkes-rsonline`.data_tempat_tidur(
			  		id_tt, ruang, jumlah_ruang, jumlah, terpakai, terpakai_suspek, terpakai_konfirmasi, covid, antrian
				)VALUES (
					VIDTT, VRUANG, VJUMLAH_RUANGAN, VJUMLAH, VTERPAKAI, VTERPAKAI_SUSPEK, VTERPAKAI_KONFIRMASI, VCOVID, VANTRIAN
				);
	      END IF;
	    END LOOP;    
	    CLOSE CR_EXEC_DATA;
	END;    
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-rsonline.statistikPasien
DROP PROCEDURE IF EXISTS `statistikPasien`;
DELIMITER //
CREATE PROCEDURE `statistikPasien`()
    DETERMINISTIC
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_STATISTIK_PASIEN;
	DROP TEMPORARY TABLE IF EXISTS TEMP_ROW_STATISTIK_PASIEN;	

	CREATE TEMPORARY TABLE TEMP_STATISTIK_PASIEN ENGINE=MEMORY
	SELECT IFNULL(SUM(IF(p.status_rawat = 3, 1, 0)), 0) JML_COVID
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 0, 1, 0)), 0) JML_COVID_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 1, 1, 0)), 0) JML_COVID_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 2, 1, 0)), 0) JML_COVID_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 4, 1, 0)), 0) JML_COVID_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 3, 1, 0)), 0) JML_COVID_DIRUJUK
			 
			 , IFNULL(SUM(IF(p.status_rawat = 2, 1, 0)), 0) JML_PDP
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 0, 1, 0)), 0) JML_PDP_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 1, 1, 0)), 0) JML_PDP_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 2, 1, 0)), 0) JML_PDP_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 4, 1, 0)), 0) JML_PDP_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 3, 1, 0)), 0) JML_PDP_DIRUJUK
			 
			 , IFNULL(SUM(IF(p.status_rawat = 1, 1, 0)), 0) JML_ODP		 
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 0, 1, 0)), 0) JML_ODP_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 1, 1, 0)), 0) JML_ODP_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 2, 1, 0)), 0) JML_ODP_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 4, 1, 0)), 0) JML_ODP_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 3, 1, 0)), 0) JML_ODP_DIRUJUK
			 
			 , IFNULL(SUM(IF(p.status_rawat = 4, 1, 0)), 0) JML_OTG
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 0, 1, 0)), 0) JML_OTG_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 1, 1, 0)), 0) JML_OTG_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 2, 1, 0)), 0) JML_OTG_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 4, 1, 0)), 0) JML_OTG_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 3, 1, 0)), 0) JML_OTG_DIRUJUK
	  FROM `kemkes-rsonline`.pasien p
	 WHERE p.hapus = 0;

	CREATE TEMPORARY TABLE TEMP_ROW_STATISTIK_PASIEN (
		`ID` TINYINT,
		`JUDUL` VARCHAR(25),
		`DESKRIPSI` VARCHAR(50),
		`TOTAL` INT,
		`DIRAWAT` INT,
		`SEMBUH` INT,
		`MENINGGAL` INT,
		`ISOLASI` INT,
		`DIRUJUK` INT
	)
	ENGINE=MEMORY;
	
  	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
  	SELECT 1 ID, 'PASIEN COVID' JUDUL, 'Positif COVID - 19' DESKRIPSI
  			, JML_COVID TOTAL, JML_COVID_DIRAWAT DIRAWAT, JML_COVID_SEMBUH SEMBUH
			, JML_COVID_MENINGGAL MENINGGAL, JML_COVID_ISOLASI ISOLASI, JML_COVID_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;
	 
	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
	SELECT 2 ID, 'PDP' JUDUL, 'Pasien Dalam Pengawasan' DESKRIPSI
  			, JML_PDP TOTAL, JML_PDP_DIRAWAT DIRAWAT, JML_PDP_SEMBUH SEMBUH
			, JML_PDP_MENINGGAL MENINGGAL, JML_PDP_ISOLASI ISOLASI, JML_PDP_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;
	 
	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
	SELECT 3 ID, 'ODP' JUDUL, 'Orang Dalam Pemantauan' DESKRIPSI
  			, JML_ODP TOTAL, JML_ODP_DIRAWAT DIRAWAT, JML_ODP_SEMBUH SEMBUH
			, JML_ODP_MENINGGAL MENINGGAL, JML_ODP_ISOLASI ISOLASI, JML_ODP_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;
	 
	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
	SELECT 4 ID, 'OTG' JUDUL, 'Orang Tanpa Gejala' DESKRIPSI
  			, JML_OTG TOTAL, JML_OTG_DIRAWAT DIRAWAT, JML_OTG_SEMBUH SEMBUH
			, JML_OTG_MENINGGAL MENINGGAL, JML_OTG_ISOLASI ISOLASI, JML_OTG_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;	

  SELECT *
    FROM TEMP_ROW_STATISTIK_PASIEN;
END//
DELIMITER ;

-- membuang struktur untuk procedure kemkes-rsonline.updateKamarSIMRSOnline
DROP PROCEDURE IF EXISTS `updateKamarSIMRSOnline`;
DELIMITER //
CREATE PROCEDURE `updateKamarSIMRSOnline`()
BEGIN
	
	INSERT INTO `kemkes-rsonline`.kamar_simrs_rs_online(ruang_kamar)
	SELECT rk.ID
	  FROM `master`.ruang_kamar rk       
	       LEFT JOIN `kemkes-rsonline`.kamar_simrs_rs_online k ON k.ruang_kamar = rk.ID,
	       `master`.ruangan r
	 WHERE rk.`STATUS` = 1
	   AND k.id IS NULL
	   AND r.ID = rk.RUANGAN
	   AND r.JENIS_KUNJUNGAN = 3
	   AND r.JENIS = 5;
	   
	
	UPDATE `master`.ruang_kamar rk,
	       `kemkes-rsonline`.kamar_simrs_rs_online k
	   SET k.`status` = 0
	 WHERE k.ruang_kamar = rk.ID
	   AND k.`status` = 1
	   AND rk.`STATUS` = 0;
	   
	
	UPDATE `master`.ruang_kamar rk,
	       `kemkes-rsonline`.kamar_simrs_rs_online k
	   SET k.`status` = 1
	 WHERE k.ruang_kamar = rk.ID
	   AND k.`status` = 0
	   AND rk.`STATUS` = 1;
END//
DELIMITER ;

-- membuang struktur untuk event kemkes-rsonline.runEveryMinute
DROP EVENT IF EXISTS `runEveryMinute`;
DELIMITER //
CREATE EVENT `runEveryMinute` ON SCHEDULE EVERY 1 MINUTE STARTS '2021-01-27 13:14:07' ON COMPLETION PRESERVE ENABLE DO BEGIN
	CALL `kemkes-rsonline`.updateKamarSIMRSOnline();
END//
DELIMITER ;

-- membuang struktur untuk event kemkes-rsonline.runEveryThreeMinute
DROP EVENT IF EXISTS `runEveryThreeMinute`;
DELIMITER //
CREATE EVENT `runEveryThreeMinute` ON SCHEDULE EVERY 3 MINUTE STARTS '2021-01-27 16:45:27' ON COMPLETION PRESERVE ENABLE DO BEGIN
	CALL `kemkes-rsonline`.executeTempatTidurRSOnline(DATE(NOW()), DATE(NOW()));
END//
DELIMITER ;

-- membuang struktur untuk trigger kemkes-rsonline.data_kebutuhan_apd_before_update
DROP TRIGGER IF EXISTS `data_kebutuhan_apd_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `data_kebutuhan_apd_before_update` BEFORE UPDATE ON `data_kebutuhan_apd` FOR EACH ROW BEGIN
	IF NEW.jumlah_eksisting != OLD.jumlah_eksisting OR NEW.jumlah != OLD.jumlah OR NEW.jumlah_diterima != OLD.jumlah_diterima THEN
		SET NEW.kirim = 1;
	END IF;
	
	IF NEW.kirim != OLD.kirim AND OLD.kirim = 1 AND NEW.kirim = 0 AND NEW.response != NULL THEN
		SET NEW.tgl_kirim = NOW();
	END IF;
	
	IF NEW.kirim != OLD.kirim AND NEW.kirim = 1 AND OLD.kirim = 0 THEN
		SET NEW.response = NULL;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.data_kebutuhan_sdm_before_update
DROP TRIGGER IF EXISTS `data_kebutuhan_sdm_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `data_kebutuhan_sdm_before_update` BEFORE UPDATE ON `data_kebutuhan_sdm` FOR EACH ROW BEGIN
	IF NEW.jumlah_eksisting != OLD.jumlah_eksisting OR NEW.jumlah != OLD.jumlah OR NEW.jumlah_diterima != OLD.jumlah_diterima THEN
		SET NEW.kirim = 1;
	END IF;
	
	IF NEW.kirim != OLD.kirim AND OLD.kirim = 1 AND NEW.kirim = 0 AND NEW.response != NULL THEN
		SET NEW.tgl_kirim = NOW();
	END IF;
	
	IF NEW.kirim != OLD.kirim AND NEW.kirim = 1 AND OLD.kirim = 0 THEN
		SET NEW.response = NULL;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.data_tempat_tidur_before_update
DROP TRIGGER IF EXISTS `data_tempat_tidur_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `data_tempat_tidur_before_update` BEFORE UPDATE ON `data_tempat_tidur` FOR EACH ROW BEGIN
	IF NEW.jumlah_ruang != OLD.jumlah_ruang OR 
	   NEW.jumlah != OLD.jumlah OR 
		NEW.terpakai != OLD.terpakai OR 
		NEW.prepare != OLD.prepare OR 
		NEW.prepare_plan != OLD.prepare_plan OR 
		NEW.covid != OLD.covid THEN
		SET NEW.kirim = 1;
	END IF;
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.kebutuhan_apd_after_insert
DROP TRIGGER IF EXISTS `kebutuhan_apd_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `kebutuhan_apd_after_insert` AFTER INSERT ON `kebutuhan_apd` FOR EACH ROW BEGIN
	IF NOT EXISTS(SELECT 1 FROM `kemkes-rsonline`.data_kebutuhan_apd dka WHERE dka.id_kebutuhan = NEW.id_kebutuhan) THEN
		INSERT INTO `kemkes-rsonline`.data_kebutuhan_apd(id_kebutuhan)
		VALUES(NEW.id_kebutuhan);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.kebutuhan_sdm_after_insert
DROP TRIGGER IF EXISTS `kebutuhan_sdm_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `kebutuhan_sdm_after_insert` AFTER INSERT ON `kebutuhan_sdm` FOR EACH ROW BEGIN
	IF NOT EXISTS(SELECT 1 FROM `kemkes-rsonline`.data_kebutuhan_sdm dks WHERE dks.id_kebutuhan = NEW.id_kebutuhan) THEN
		INSERT INTO `kemkes-rsonline`.data_kebutuhan_sdm(id_kebutuhan)
		VALUES(NEW.id_kebutuhan);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.pasien_before_insert
DROP TRIGGER IF EXISTS `pasien_before_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `pasien_before_insert` BEFORE INSERT ON `pasien` FOR EACH ROW BEGIN
	IF NEW.tglkeluar = '0000-00-00' THEN
		SET NEW.tglkeluar = NULL;
	END IF;
	
	IF NEW.tgl_lapor = '0000-00-00 00:00:00' THEN
		SET NEW.tgl_lapor = NULL;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.pasien_before_update
DROP TRIGGER IF EXISTS `pasien_before_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `pasien_before_update` BEFORE UPDATE ON `pasien` FOR EACH ROW BEGIN
	IF NEW.tglkeluar = '0000-00-00' THEN
		SET NEW.tglkeluar = NULL;
	END IF;
	
	IF NEW.tgl_lapor = '0000-00-00 00:00:00' THEN
		SET NEW.tgl_lapor = NULL;
	END IF;
	
	IF NEW.noc != OLD.noc
		OR NEW.initial != OLD.initial
		OR NEW.nama_lengkap != OLD.nama_lengkap
		OR NEW.tglmasuk != OLD.tglmasuk
		OR NEW.gender != OLD.gender
		OR NEW.birthdate != OLD.birthdate
		OR NEW.kewarganegaraan != OLD.kewarganegaraan
		OR NEW.sumber_penularan != OLD.sumber_penularan
		OR NEW.kecamatan != OLD.kecamatan
		OR NEW.tglkeluar != OLD.tglkeluar
		OR NEW.status_keluar != OLD.status_keluar
		OR NEW.tgl_lapor != OLD.tgl_lapor
		OR NEW.status_rawat != OLD.status_rawat
		OR NEW.status_keluar != OLD.status_keluar
		OR NEW.status_isolasi != OLD.status_isolasi
		OR NEW.email != OLD.email
		OR NEW.notelp != OLD.notelp
		OR NEW.sebab_kematian != OLD.sebab_kematian
	THEN
		SET NEW.kirim = 1;
	END IF;
	
	IF NEW.kirim != OLD.kirim AND OLD.kirim = 1 AND NEW.kirim = 0 AND NEW.response != NULL THEN
		SET NEW.tgl_kirim = NOW();
	END IF;
	
	IF NEW.kirim != OLD.kirim AND NEW.kirim = 1 AND OLD.kirim = 0 THEN
		SET NEW.response = NULL;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger kemkes-rsonline.tempat_tidur_after_insert
DROP TRIGGER IF EXISTS `tempat_tidur_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `tempat_tidur_after_insert` AFTER INSERT ON `tempat_tidur` FOR EACH ROW BEGIN
	
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
