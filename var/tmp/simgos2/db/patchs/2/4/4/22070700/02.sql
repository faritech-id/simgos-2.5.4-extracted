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

-- membuang struktur untuk procedure pembayaran.batalGabungTagihan
DROP PROCEDURE IF EXISTS `batalGabungTagihan`;
DELIMITER //
CREATE PROCEDURE `batalGabungTagihan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_BATAL_GABUNG;
	DROP TEMPORARY TABLE IF EXISTS REMOVE_BATAL_GABUNG;
	
	-- BATAL_GABUNG_TAGIHAN_SESUAI_RIWAYAT_GABUNG
	IF EXISTS(SELECT 1
		  FROM aplikasi.properti_config pc
		 WHERE pc.ID = 41
		   AND VALUE = 'TRUE') THEN
		-- Mengambil data gabung tagihan sesuai parameter batal gabung tagihan dan masukan ke dalam tabel sementara
		CREATE TEMPORARY TABLE TEMP_BATAL_GABUNG ENGINE = MEMORY
		SELECT *
		  FROM pembayaran.gabung_tagihan gt
		 WHERE gt.KE = PTAGIHAN
		   AND gt.`STATUS` = 1
		 ORDER BY gt.TANGGAL DESC
		 LIMIT 1;
		 
		-- Non aktifkan tagihan pendaftaran yang sesuai dengan parameter batal gabung tagihan
		UPDATE pembayaran.tagihan_pendaftaran tp
		   SET tp.STATUS = 0
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND tp.STATUS = 1
		   AND tp.UTAMA = 0;
		   
		-- Mengaktifkan tagihan sebelumnya sebelum digabung tagihan
		UPDATE pembayaran.tagihan t, TEMP_BATAL_GABUNG bg
		   SET t.STATUS = 1
		 WHERE t.ID = bg.DARI;
		 
		-- Mengaktifkan tagihan sebelumnya sebelum digabung tagihan
		UPDATE pembayaran.tagihan_pendaftaran tp, TEMP_BATAL_GABUNG bg
		   SET tp.STATUS = 1
		 WHERE tp.TAGIHAN = bg.DARI;
		 
		-- Remove gabung tagihan
		DELETE FROM pembayaran.gabung_tagihan WHERE ID IN (SELECT ID FROM TEMP_BATAL_GABUNG);
		
		-- Remove tagihan pendafaran sesuai parameter tagihan dimana utama = 0
		DELETE FROM pembayaran.tagihan_pendaftaran WHERE TAGIHAN = PTAGIHAN AND UTAMA = 0;
	ELSE
		-- Mengambil data tagihan pendaftaran utama = 0
		CREATE TEMPORARY TABLE TEMP_BATAL_GABUNG ENGINE = MEMORY
		SELECT * 
		  FROM pembayaran.tagihan_pendaftaran tp
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND tp.UTAMA = 0
		   AND tp.`STATUS` = 1;
		   
		-- Mengambil data gabung tagihan sekarang dan sebelumnya untuk di hapus
		CREATE TEMPORARY TABLE REMOVE_BATAL_GABUNG ENGINE = MEMORY
		SELECT DISTINCT gb.ID
		  FROM pembayaran.gabung_tagihan gb 
		  		 , pembayaran.tagihan_pendaftaran tp
		  		 , pembayaran.tagihan_pendaftaran tp2
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND tp2.PENDAFTARAN = tp.PENDAFTARAN
			AND tp2.`STATUS` = 0
			AND (gb.KE = tp.TAGIHAN OR gb.KE = tp2.TAGIHAN);
		   	
		-- Non aktifkan tagihan pendaftaran yang sesuai dengan parameter batal gabung tagihan
		UPDATE pembayaran.tagihan_pendaftaran tp
		   SET tp.STATUS = 0
		 WHERE tp.TAGIHAN = PTAGIHAN
		   AND tp.STATUS = 1
		   AND tp.UTAMA = 0;
		
		-- Mengaktifkan semua tagihan sebelumnya sebelum di gabung	   
		UPDATE pembayaran.tagihan t, pembayaran.tagihan_pendaftaran tp, TEMP_BATAL_GABUNG bg
		   SET t.STATUS = 1
		 WHERE t.ID = tp.TAGIHAN AND t.STATUS = 0
		   AND NOT tp.TAGIHAN = bg.TAGIHAN 	
		   AND tp.STATUS = 0
		   AND tp.UTAMA = 1
			AND tp.PENDAFTARAN = bg.PENDAFTARAN;
		
		-- Mengaktifkan semua tagihan pendaftaran pada tagihan sebelumnya	   
		UPDATE pembayaran.tagihan_pendaftaran tp, TEMP_BATAL_GABUNG bg
		   SET tp.STATUS = 1
		 WHERE NOT tp.TAGIHAN = bg.TAGIHAN 	
		   AND tp.STATUS = 0
		   AND tp.UTAMA = 1
			AND tp.PENDAFTARAN = bg.PENDAFTARAN;
			
		-- Remove gabung tagihan
		DELETE FROM pembayaran.gabung_tagihan WHERE ID IN (SELECT ID FROM REMOVE_BATAL_GABUNG);
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
