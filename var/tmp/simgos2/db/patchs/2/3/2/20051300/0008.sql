-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `inacbg`;

-- membuang struktur untuk trigger inacbg.hasil_grouping_after_update
DROP TRIGGER IF EXISTS `hasil_grouping_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_grouping_after_update` AFTER UPDATE ON `hasil_grouping` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VPENJAMIN SMALLINT;
	DECLARE VDITEMUKAN TINYINT;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 1 THEN
		SET VTAGIHAN = pembayaran.getIdTagihan(OLD.NOPEN);
		UPDATE pembayaran.penjamin_tagihan
		   SET TOTAL = NEW.TOTALTARIF
		   	 , TARIF_INACBG_KELAS1 = (NEW.TARIFKLS1 + NEW.TARIFSP + NEW.TARIFSR + NEW.TARIFSI + NEW.TARIFSD + NEW.TARIFSA + NEW.TARIFSC)
		 WHERE TAGIHAN = VTAGIHAN
		   AND PENJAMIN = 2;
		
		INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
		VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", VTAGIHAN, "')"), 1);
	END IF;
	
	# 71 - Jaminan Covid E-Klaim
	SELECT CAST(m.SIMRS AS UNSIGNED) PENJAMIN, COUNT(1) DITEMUKAN
	  INTO VPENJAMIN, VDITEMUKAN
	  FROM inacbg.grouping g,
	  		 inacbg.tipe_inacbg t,
	  		 inacbg.map_inacbg_simrs m	  		 
	 WHERE g.NOPEN = NEW.NOPEN
	   AND g.DATA->'$.jns_pbyrn' = '71'
		AND t.ID = CAST(g.DATA->'$.tipe' AS UNSIGNED)
		AND m.JENIS = 3
		AND m.VERSION = t.VERSION
		AND m.INACBG = g.DATA->'$.jns_pbyrn';
	
	# Jika ditemukan maka update nomor penjamin di pendaftaran sesuai dengan nomor claim	
	IF VDITEMUKAN > 0 THEN
	   UPDATE pendaftaran.penjamin p 
	      SET p.NOMOR = NEW.NOSEP
		 WHERE p.NOPEN = NEW.NOPEN
		   AND p.JENIS = VPENJAMIN;
		   
		IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 1 THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(OLD.NOPEN);
			UPDATE pembayaran.penjamin_tagihan
			   SET TOTAL = NEW.TOP_UP_RAWAT + NEW.TOP_UP_JENAZAH
			   	 , TARIF_INACBG_KELAS1 = (NEW.TARIFKLS1 + NEW.TARIFSP + NEW.TARIFSR + NEW.TARIFSI + NEW.TARIFSD + NEW.TARIFSA + NEW.TARIFSC)
			 WHERE TAGIHAN = VTAGIHAN
			   AND PENJAMIN = VPENJAMIN;
			
			INSERT INTO aplikasi.automaticexecute(PERINTAH, IS_PROSEDUR)
			VALUES(CONCAT("CALL pembayaran.reStoreTagihan('", VTAGIHAN, "')"), 1);
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger inacbg.icd_ina_grouper_after_insert
DROP TRIGGER IF EXISTS `icd_ina_grouper_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `icd_ina_grouper_after_insert` AFTER INSERT ON `icd_ina_grouper` FOR EACH ROW BEGIN
	DECLARE VSAB VARCHAR(15);
	
	SET VSAB = IF(NEW.icd_type = 1, 'ICD10_2020', 'ICD9CM_2020');
	
	IF NOT EXISTS(SELECT 1 FROM `master`.mrconso mc WHERE mc.SAB = VSAB AND mc.TTY = 'PT' AND mc.CODE = NEW.code) THEN
		INSERT INTO `master`.mrconso(SAB, TTY, CODE, STR, VALIDCODE, ACCPDX, CODE_ASTERISK, ASTERISK, IM, ICD_TYPE, VERSION)
		VALUES(VSAB, 'PT', NEW.code, NEW.description, NEW.validcode, NEW.accpdx, NEW.code_asterisk, NEW.asterisk, NEW.im, NEW.icd_type, 6);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger inacbg.icd_ina_grouper_after_update
DROP TRIGGER IF EXISTS `icd_ina_grouper_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `icd_ina_grouper_after_update` AFTER UPDATE ON `icd_ina_grouper` FOR EACH ROW BEGIN
	DECLARE VSAB VARCHAR(15);
	
	SET VSAB = IF(NEW.icd_type = 1, 'ICD10_2020', 'ICD9CM_2020');
	
	IF EXISTS(SELECT 1 FROM `master`.mrconso mc WHERE mc.SAB = VSAB AND mc.TTY = 'PT' AND mc.CODE = NEW.code) THEN
		UPDATE `master`.mrconso
		   SET CODE = NEW.code, 
				 STR = NEW.description, 
				 VALIDCODE = NEW.validcode, 
				 ACCPDX = NEW.accpdx, 
				 CODE_ASTERISK = NEW.code_asterisk, 
				 ASTERISK = NEW.asterisk, 
				 IM = NEW.im, 
				 ICD_TYPE = NEW.icd_type
		  WHERE SAB = VSAB
		    AND TTY = 'PT'
			 AND CODE = OLD.CODE;
	ELSE
		INSERT INTO `master`.mrconso(SAB, TTY, CODE, STR, VALIDCODE, ACCPDX, CODE_ASTERISK, ASTERISK, IM, ICD_TYPE, VERSION)
		VALUES(VSAB, 'PT', NEW.code, NEW.description, NEW.validcode, NEW.accpdx, NEW.code_asterisk, NEW.asterisk, NEW.im, NEW.icd_type, 6);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
