-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk informasi
USE `informasi`;

DROP PROCEDURE IF EXISTS `executeTempatTidurDipesanTapiDigunakan`;

-- membuang struktur untuk procedure informasi.executeTempatTidurDipesanTapiTdkDigunakan
DROP PROCEDURE IF EXISTS `executeTempatTidurDipesanTapiTdkDigunakan`;
DELIMITER //
CREATE PROCEDURE `executeTempatTidurDipesanTapiTdkDigunakan`()
BEGIN
   DECLARE VBATAS_WAKTU CHAR(8) DEFAULT '00:59:59';
      
   SELECT pc.VALUE
     INTO VBATAS_WAKTU
     FROM aplikasi.properti_config pc
    WHERE pc.ID = 35;

    IF VBATAS_WAKTU IS NULL THEN
        SET VBATAS_WAKTU = '00:59:59';
    END IF;
   
	DROP TEMPORARY TABLE IF EXISTS TEMP_TEMPAT_TIDUR_DIPESAN;

	CREATE TEMPORARY TABLE TEMP_TEMPAT_TIDUR_DIPESAN ENGINE = MEMORY
	SELECT rkt.ID, r.NOMOR
	  FROM master.ruang_kamar_tidur rkt
	  		 LEFT JOIN pendaftaran.reservasi r ON r.RUANG_KAMAR_TIDUR = rkt.ID AND r.`STATUS` = 1
	  		 LEFT JOIN pendaftaran.mutasi m ON m.RESERVASI = r.NOMOR AND m.`STATUS` = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.RESERVASI = r.NOMOR AND tp.`STATUS` = 1
	 WHERE NOT rkt.`STATUS` IN (0)
	   AND rkt.`STATUS` = 2	   
	   AND INSTR(r.ATAS_NAMA, ' - ') > 0	   
	   AND m.NOMOR IS NULL 
		AND tp.NOPEN IS NULL
		AND TIMEDIFF(NOW(), r.TANGGAL) > VBATAS_WAKTU;
	
	UPDATE pendaftaran.reservasi r, TEMP_TEMPAT_TIDUR_DIPESAN ttt
	   SET r.`STATUS` = 0
	 WHERE r.NOMOR = ttt.NOMOR
	   AND r.`STATUS` = 1;
END//
DELIMITER ;

-- membuang struktur untuk event informasi.runExecuteTempatTidur
DROP EVENT IF EXISTS `runExecuteTempatTidur`;
DELIMITER //
CREATE EVENT `runExecuteTempatTidur` ON SCHEDULE EVERY 1 MINUTE STARTS '2020-01-30 08:29:18' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
	CALL informasi.executeTempatTidurTerisiTapiKosong();
	
	CALL informasi.executeTempatTidurDipesanTapiTdkDigunakan();
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
