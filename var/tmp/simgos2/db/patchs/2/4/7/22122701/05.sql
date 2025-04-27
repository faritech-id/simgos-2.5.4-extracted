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

-- membuang struktur untuk trigger pendaftaran.onAfterInsertKunjungan
DROP TRIGGER IF EXISTS `onAfterInsertKunjungan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertKunjungan` AFTER INSERT ON `kunjungan` FOR EACH ROW BEGIN
	DECLARE VIS_TAGIHAN_TERPISAH TINYINT DEFAULT 0;
	DECLARE VPAKET, VPENJAMIN SMALLINT;
	DECLARE VNORM INT;
	
	SELECT p.NORM, p.PAKET, pj.JENIS
	  INTO VNORM, VPAKET, VPENJAMIN
	  FROM pendaftaran.pendaftaran p,
	  	    pendaftaran.penjamin pj
	 WHERE p.NOMOR = NEW.NOPEN
	   AND pj.NOPEN = p.NOMOR
	 LIMIT 1;
	 
	IF NOT VPENJAMIN IS NULL THEN
		IF VPAKET IS NULL OR VPAKET = 0 THEN
			SET VIS_TAGIHAN_TERPISAH = pembayaran.isTagihanTerpisah(NEW.RUANGAN, VPENJAMIN);
		END IF;
	END IF;
	
	UPDATE pendaftaran.tujuan_pasien 
	   SET STATUS = 2
	 WHERE NOPEN = NEW.NOPEN
	   AND RUANGAN = NEW.RUANGAN
		AND STATUS = 1;
	
	IF NEW.RUANG_KAMAR_TIDUR > 0 THEN
		UPDATE master.ruang_kamar_tidur SET STATUS = 3 WHERE ID = NEW.RUANG_KAMAR_TIDUR;
	END IF;
		
	IF NOT NEW.REF IS NULL THEN
	BEGIN
		DECLARE VID VARCHAR(2);
		DECLARE VTAGIHAN CHAR(10);
		
		SET VID = LEFT(NEW.REF, 2);
		
		IF VIS_TAGIHAN_TERPISAH = 1 THEN
			SET VTAGIHAN = pembayaran.buatTagihanTerpisah(VNORM, NEW.NOPEN, NEW.NOMOR);
		END IF;
		
		CASE VID
			WHEN '10' THEN
				UPDATE pendaftaran.konsul
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
			 WHEN '11' THEN 
				UPDATE pendaftaran.mutasi
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
			WHEN '12' THEN
				UPDATE layanan.order_lab
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
				   
				CALL layanan.storeOrderLabDiTindakan(NEW.REF, NEW.DITERIMA_OLEH);
			WHEN '13' THEN
				UPDATE layanan.order_rad
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
				   
				CALL layanan.storeOrderRadDiTindakan(NEW.REF, NEW.DITERIMA_OLEH);
			WHEN '14' THEN
				UPDATE layanan.order_resep
				   SET STATUS = 2
				 WHERE NOMOR = NEW.REF
				   AND STATUS = 1;
				   
				CALL layanan.storeOrderResepDiFarmasi(NEW.REF, NEW.DITERIMA_OLEH);
		END CASE;
	END;
   END IF;
   
	IF EXISTS(SELECT 1 FROM information_schema.ROUTINES r WHERE r.ROUTINE_SCHEMA = 'regonline' AND r.ROUTINE_NAME = 'insertTaskAntrian') THEN
		CALL regonline.insertTaskAntrian(NEW.NOPEN,NEW.NOMOR, 2, NEW.REF);
	END IF;
	
	
	IF EXISTS(SELECT 1 FROM `master`.ruangan r WHERE r.ID = NEW.RUANGAN AND r.JENIS_KUNJUNGAN = 1) THEN
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
			  VALUES (CONCAT("CALL pendaftaran.doProsesPaket('", NEW.NOMOR, "')"), 1);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger pendaftaran.onAfterUpdatePenjamin
DROP TRIGGER IF EXISTS `onAfterUpdatePenjamin`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdatePenjamin` AFTER UPDATE ON `penjamin` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	
	IF NEW.JENIS != OLD.JENIS THEN
		SET VTAGIHAN = pembayaran.getIdTagihan(OLD.NOPEN);
		
		IF OLD.JENIS = 1 AND NEW.JENIS != 1 THEN
			UPDATE pembayaran.tagihan_pendaftaran tp,
					 pembayaran.tagihan t
				SET t.STATUS = 0
			 WHERE tp.PENDAFTARAN = OLD.NOPEN
			   AND tp.REF != ''
			   AND tp.STATUS = 1
			   AND t.ID = tp.TAGIHAN;
		END IF;
		
		IF OLD.JENIS != 1 AND NEW.JENIS = 1 THEN
			UPDATE pembayaran.tagihan_pendaftaran tp,
					 pembayaran.tagihan t
				SET t.STATUS = 1
			 WHERE tp.PENDAFTARAN = OLD.NOPEN
			   AND tp.REF != ''
			   AND tp.STATUS = 1
			   AND t.ID = tp.TAGIHAN;
		END IF;
		
		DELETE FROM pembayaran.penjamin_tagihan
		 WHERE TAGIHAN = VTAGIHAN
			AND PENJAMIN = OLD.JENIS;
		IF NEW.JENIS > 1 THEN
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF VTAGIHAN != '' THEN
					CALL pembayaran.storePenjaminTagihan(VTAGIHAN, NEW.JENIS, NEW.KELAS);
				END IF;
			END IF;
		END IF;
		
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", VTAGIHAN, "')"), 1);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
