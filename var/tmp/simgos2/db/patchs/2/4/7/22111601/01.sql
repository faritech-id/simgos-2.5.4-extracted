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


-- Membuang struktur basisdata untuk cetakan
CREATE DATABASE IF NOT EXISTS `cetakan`;
USE `cetakan`;

-- membuang struktur untuk trigger cetakan.onAfterInsertKarcisPasien
DROP TRIGGER IF EXISTS `onAfterInsertKarcisPasien`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertKarcisPasien` AFTER INSERT ON `karcis_pasien` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VJENIS_KUNJUNGAN SMALLINT;
	DECLARE VQTY DECIMAL(60,2);
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VTANGGAL DATETIME;
	DECLARE VTANGGAL_TAGIHAN DATETIME DEFAULT NULL;
	DECLARE VTGL_DAFTAR_PASIEN DATETIME;
	DECLARE VPASIEN_BARU TINYINT DEFAULT 0;
	DECLARE VAKTIF_TARIF_ADM_BERDASARKAN_JENIS_PASIEN TINYINT DEFAULT FALSE;
	DECLARE VNORM INT;
	
	IF NEW.JENIS IN (1,2) THEN		 
		SELECT p.PAKET, r.JENIS_KUNJUNGAN, p.TANGGAL, p.NORM INTO VPAKET, VJENIS_KUNJUNGAN, VTANGGAL, VNORM
		  FROM pendaftaran.pendaftaran p
		    	 , pendaftaran.tujuan_pasien tp
		    	 , master.ruangan r
		 WHERE p.NOMOR = NEW.NOPEN
		 	AND tp.NOPEN = p.NOMOR
		   AND r.ID = tp.RUANGAN;
		 
		IF FOUND_ROWS() > 0 THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(NEW.NOPEN);
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
					CALL master.inPaket(VPAKET, 3, 2, NULL, VQTY, VPAKET_DETIL);
					
					IF VTAGIHAN != '' AND VPAKET_DETIL > 0 THEN
						CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, NEW.ID, VTANGGAL, 1, 1);
					END IF;
				END IF;
					
				IF VTAGIHAN != '' AND VPAKET_DETIL = 0 THEN
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
								 WHERE NOT k.NOPEN = NEW.NOPEN
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
					
					CALL pembayaran.storeRincianTagihan(VTAGIHAN, NEW.ID, 1, VTARIF_ID, 1, VTARIF, 0, 0, 0);
				END IF;
				
				INSERT INTO aplikasi.automaticexecute(PERINTAH)
				VALUES(CONCAT("CALL pendaftaran.updateTanggalAdministrasiDanTagihan('", VTAGIHAN, "', '", VTANGGAL, "')"));				
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
