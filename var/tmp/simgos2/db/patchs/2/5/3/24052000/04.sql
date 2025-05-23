-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
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
	DECLARE VSUCCESS INT DEFAULT TRUE;
	
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
		IF EXISTS(SELECT 1 FROM aplikasi.properti_config pc WHERE pc.ID = 58 AND pc.VALUE = 'FALSE') THEN
			SET VNILAI_NORMAL = NULL;
			SET VSATUAN = NULL;
		END IF;
	
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
				DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;
				INSERT INTO layanan.hasil_lab(ID, TINDAKAN_MEDIS, PARAMETER_TINDAKAN, TANGGAL, HASIL, NILAI_NORMAL, SATUAN, KETERANGAN, OTOMATIS, OLEH)
				VALUES(generator.generateIdHasilLab(VTANGGAL), VTINDAKAN_MEDIS, VPARAMETER_TINDAKAN_LAB, VTANGGAL, VHASIL, VNILAI_NORMAL, VSATUAN, VKETERANGAN, 1, 1);
				
				IF NOT VSUCCESS THEN
					SET VSTATUS = 8;
				END IF;
			END;
		END IF;		
	ELSE
		SET VSTATUS = 3;
	END IF;
	
	INSERT INTO aplikasi.automaticexecute_02(PERINTAH)
		VALUES(CONCAT("UPDATE lis.hasil_log SET STATUS = ", VSTATUS, " WHERE ID = ", PID));
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
