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
CREATE DATABASE IF NOT EXISTS `pembayaran`;
USE `pembayaran`;

-- membuang struktur untuk trigger pembayaran.gabung_tagihan_after_insert
DROP TRIGGER IF EXISTS `gabung_tagihan_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `gabung_tagihan_after_insert` AFTER INSERT ON `gabung_tagihan` FOR EACH ROW BEGIN
	DECLARE VJML TINYINT;
	DECLARE VKARTU_KARCIS TINYINT DEFAULT 0;
	
	UPDATE pembayaran.tagihan
	   SET STATUS = 0
	 WHERE ID = NEW.DARI;
			  
	UPDATE pembayaran.tagihan_pendaftaran
	   SET STATUS = 0
	 WHERE TAGIHAN = NEW.DARI
	   AND STATUS = 1;
	   
	SELECT COUNT(*) JML 
	  INTO VJML
	  FROM pembayaran.rincian_tagihan rt
	 WHERE rt.TAGIHAN = NEW.DARI
	   AND rt.STATUS = 1;
	 
	IF VJML = 1 THEN
		SELECT COUNT(*) JML 
		  INTO VJML
		  FROM pembayaran.rincian_tagihan rt
		 WHERE rt.TAGIHAN = NEW.DARI
		   AND rt.STATUS = 1
			AND rt.JENIS = 1;
		IF VJML = 1 THEN
			SET VKARTU_KARCIS = 1;
			INSERT INTO pembayaran.rincian_tagihan(tagihan, REF_ID, JENIS, TARIF_ID, JUMLAH, TARIF, PERSENTASE_DISKON, DISKON, STATUS)
			SELECT NEW.KE, rt.REF_ID, rt.JENIS, rt.TARIF_ID, rt.JUMLAH, rt.TARIF, rt.PERSENTASE_DISKON, rt.DISKON, rt.STATUS
		     FROM pembayaran.rincian_tagihan rt
		    WHERE rt.TAGIHAN = NEW.DARI
		      AND rt.STATUS = 1
			   AND rt.JENIS = 1;
		END IF;
	END IF;
	
	IF VKARTU_KARCIS = 0 THEN
		UPDATE pembayaran.tagihan_pendaftaran ke,
		  		 pembayaran.tagihan_pendaftaran dr
		  	SET ke.STATUS = 1
		 WHERE ke.TAGIHAN = NEW.KE
		   AND ke.UTAMA = 0
		   AND dr.TAGIHAN = NEW.DARI
			AND ke.PENDAFTARAN = dr.PENDAFTARAN;
		
		INSERT INTO pembayaran.tagihan_pendaftaran(TAGIHAN, PENDAFTARAN, UTAMA)
		SELECT NEW.KE, dr.PENDAFTARAN, 0
		  FROM pembayaran.tagihan_pendaftaran dr
		 WHERE dr.TAGIHAN = NEW.DARI
		   AND NOT EXISTS(
			SELECT 1
			  FROM pembayaran.tagihan_pendaftaran ke
			 WHERE ke.TAGIHAN = NEW.KE
			   AND ke.PENDAFTARAN = dr.PENDAFTARAN);	
		/*INSERT INTO pembayaran.tagihan_pendaftaran(TAGIHAN, PENDAFTARAN, UTAMA)
			  SELECT NEW.KE, PENDAFTARAN, 0
			    FROM pembayaran.tagihan_pendaftaran
			   WHERE TAGIHAN = NEW.DARI;*/		
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
