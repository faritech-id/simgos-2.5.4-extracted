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

-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk trigger pendaftaran.onAfterUpdateKunjungan
DROP TRIGGER IF EXISTS `onAfterUpdateKunjungan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateKunjungan` AFTER UPDATE ON `kunjungan` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VJENIS_PEMBATALAN TINYINT;
	DECLARE VJUMLAH INT;
	
	SELECT COUNT(*), JENIS 
	  INTO VJUMLAH, VJENIS_PEMBATALAN 
	  FROM pembatalan.pembatalan_kunjungan
	 WHERE KUNJUNGAN = OLD.NOMOR
	 ORDER BY TANGGAL DESC LIMIT 1;
	 
	IF VJUMLAH = 0 THEN
		SET VJENIS_PEMBATALAN = 0;
	END IF;
	
	IF pendaftaran.ikutRawatInapIbu(NEW.NOPEN, NEW.REF) = 0 THEN
		IF NEW.RUANG_KAMAR_TIDUR > 0 AND (OLD.STATUS != NEW.STATUS AND (NEW.STATUS = 0 OR NEW.STATUS = 2)) THEN
			IF NOT VJENIS_PEMBATALAN = 1 THEN
				IF VJENIS_PEMBATALAN = 0 THEN
					UPDATE master.ruang_kamar_tidur SET STATUS = 1 WHERE ID = NEW.RUANG_KAMAR_TIDUR;
				ELSE
					IF NOT EXISTS(SELECT 1 FROM pendaftaran.kunjungan k WHERE (NOT k.NOMOR = OLD.NOMOR) AND k.RUANG_KAMAR_TIDUR = NEW.RUANG_KAMAR_TIDUR AND k.STATUS = 1 LIMIT 1) THEN
						UPDATE master.ruang_kamar_tidur SET STATUS = 1 WHERE ID = NEW.RUANG_KAMAR_TIDUR;
					END IF;
				END IF;
			END IF;
		ELSEIF NEW.RUANG_KAMAR_TIDUR > 0 AND (OLD.STATUS != NEW.STATUS AND NEW.STATUS = 1) THEN		
			IF VJENIS_PEMBATALAN = 2 THEN
				UPDATE master.ruang_kamar_tidur SET STATUS = 3 WHERE ID = NEW.RUANG_KAMAR_TIDUR;
			END IF;
		END IF;
	END IF;
		
	SET VTAGIHAN = pembayaran.getIdTagihan(OLD.NOPEN);
			   	
	IF master.isRawatInap(OLD.RUANGAN) THEN		
		IF (NOT NEW.KELUAR IS NULL AND
			NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2) OR OLD.MASUK != NEW.MASUK THEN
			CALL pembayaran.storeAkomodasi(NEW.NOMOR);
		END IF;
		
		IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
			IF (NEW.RUANG_KAMAR_TIDUR > 0 OR NOT NEW.RUANG_KAMAR_TIDUR IS NULL) AND NOT NEW.REF IS NULL THEN
				UPDATE pendaftaran.mutasi
				   SET STATUS = 0
				 WHERE NOMOR = NEW.REF;
			END IF;
		END IF;
	ELSE
		BEGIN
			DECLARE VJENIS_KUNJUNGAN TINYINT;
			SELECT COUNT(*), JENIS_KUNJUNGAN 
			  INTO VJUMLAH, VJENIS_KUNJUNGAN
			  FROM master.ruangan
			 WHERE ID = OLD.RUANGAN;
			
			IF VJUMLAH = 0 THEN
				SET VJENIS_KUNJUNGAN = 1;
			END IF;
			 
			IF NEW.STATUS != OLD.STATUS AND VJENIS_KUNJUNGAN = 11 THEN
				IF NEW.STATUS = 2 THEN
					CALL pembayaran.storeAdministrasiFarmasi(OLD.NOMOR);
					CALL layanan.finalPelayananFarmasi(OLD.NOMOR);
				ELSEIF NEW.STATUS = 1 THEN
					IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
						CALL pembayaran.batalRincianTagihan(VTAGIHAN, OLD.NOMOR, 1);
						CALL layanan.batalFinalPelayananFarmasi(OLD.NOMOR);
					END IF;
				END IF;
			END IF;
		END;
	END IF;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
		IF NEW.REF IS NULL THEN
			UPDATE pendaftaran.tujuan_pasien
			   SET STATUS = 1
			 WHERE NOPEN = OLD.NOPEN
			   AND STATUS = 2;
		ELSE
		BEGIN
			DECLARE VID VARCHAR(2);
			SET VID = LEFT(NEW.REF, 2);
			
			CASE VID
				WHEN '10' THEN
					UPDATE pendaftaran.konsul
					   SET STATUS = 0
					 WHERE NOMOR = NEW.REF
					   AND STATUS = 2;
				 WHEN '11' THEN 
					UPDATE pendaftaran.mutasi
					   SET STATUS = 0
					 WHERE NOMOR = NEW.REF
					   AND STATUS = 2;
				WHEN '12' THEN
					UPDATE layanan.order_lab
					   SET STATUS = 0
					 WHERE NOMOR = NEW.REF
					   AND STATUS = 2;
				WHEN '13' THEN
					UPDATE layanan.order_rad
					   SET STATUS = 0
					 WHERE NOMOR = NEW.REF
					   AND STATUS = 2;
				WHEN '14' THEN
					UPDATE layanan.order_resep
					   SET STATUS = 0
					 WHERE NOMOR = NEW.REF
					   AND STATUS = 2;
			END CASE;
		END;
		END IF;
	END IF;	
	
	IF (NEW.MASUK != OLD.MASUK) OR (NEW.KELUAR != OLD.KELUAR) THEN
	BEGIN
		DECLARE VJENIS TINYINT DEFAULT 1;
		IF NEW.KELUAR != OLD.KELUAR THEN
			SET VJENIS = 2;
		END IF;
		IF EXISTS(SELECT 1 FROM pendaftaran.perubahan_tanggal_kunjungan WHERE KUNJUNGAN = OLD.NOMOR AND JENIS = VJENIS AND STATUS = 1) THEN				
			UPDATE pendaftaran.perubahan_tanggal_kunjungan
				SET STATUS = 2
				WHERE KUNJUNGAN = OLD.NOMOR
				AND JENIS = VJENIS
				AND STATUS = 1;
		END IF;	
	END;
	END IF;
		
	IF (OLD.DPJP IS NULL OR (OLD.DPJP != NEW.DPJP)) AND OLD.REF IS NULL THEN
		UPDATE pendaftaran.tujuan_pasien SET DOKTER = NEW.DPJP WHERE NOPEN = OLD.NOPEN;
	END IF;
		
	IF OLD.FINAL_HASIL != NEW.FINAL_HASIL AND NEW.FINAL_HASIL = 1 THEN
	BEGIN		
		DECLARE VDIAGNOSA CHAR(10);
		DECLARE VNORM INT;
		
		SELECT COUNT(*), dga.KODE, p.NORM 
		  INTO VJUMLAH, VDIAGNOSA, VNORM
		  FROM medicalrecord.diagnosa dga
		       JOIN pendaftaran.pendaftaran p ON p.NOMOR = dga.NOPEN
		       JOIN kemkes.icd_tb itb ON itb.KODE = dga.KODE
		 WHERE dga.NOPEN = NEW.NOPEN 
		 ORDER BY dga.UTAMA ASC LIMIT 1;
		
		IF VJUMLAH > 0 THEN
			CALL kemkes.storePasienTerkonfirmasiTB(VNORM, OLD.NOMOR, VDIAGNOSA);
		END IF;
				
		UPDATE layanan.status_hasil_pemeriksaan shp, layanan.tindakan_medis tm, `master`.tindakan t
		   SET shp.STATUS_HASIL = 3
		 WHERE tm.ID = shp.TINDAKAN_MEDIS_ID
		   AND tm.KUNJUNGAN = OLD.NOMOR
		   AND tm.STATUS = 1
			AND t.ID = tm.TINDAKAN
			AND t.JENIS IN (7, 8);
	END;
	END IF;

	IF EXISTS(SELECT 1 FROM information_schema.ROUTINES r WHERE r.ROUTINE_SCHEMA = 'regonline' AND r.ROUTINE_NAME = 'insertTaskAntrian') THEN
		CALL regonline.insertTaskAntrian(OLD.NOPEN, OLD.NOMOR, 2, OLD.REF);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
