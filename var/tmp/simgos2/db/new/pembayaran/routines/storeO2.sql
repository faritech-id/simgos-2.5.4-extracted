-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure pembayaran.storeO2
DROP PROCEDURE IF EXISTS `storeO2`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `storeO2`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF DECIMAL(60,2);
	DECLARE VKELAS SMALLINT DEFAULT 0;
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2) DEFAULT 0;
	DECLARE VPEMAKAIAN DECIMAL(60,2) DEFAULT 0;
	DECLARE VSISA DECIMAL(60,2) DEFAULT 0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL_KUNJUNGAN, VTANGGAL DATETIME;

	SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS, p.PAKET, p.TANGGAL, k.MASUK
	  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS, VPAKET, VTANGGAL_PENDAFTARAN, VTANGGAL_KUNJUNGAN
	  FROM pendaftaran.kunjungan k
	  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
			 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 master.ruangan r,
	  		 pendaftaran.pendaftaran p
	 WHERE k.NOMOR = PKUNJUNGAN
	 	AND k.RUANGAN = r.ID	   
		AND k.NOPEN = p.NOMOR;
		
	IF FOUND_ROWS() > 0 THEN
		
		SET VTANGGAL = VTANGGAL_KUNJUNGAN;
		
		IF EXISTS(SELECT 1
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 6
			   AND VALUE = 'TRUE') THEN
			SET VTANGGAL = VTANGGAL_PENDAFTARAN;
		END IF;
		
		
		SET VPEMAKAIAN = layanan.getTotalPemakaianO2(PKUNJUNGAN);
		SET VSISA = VPEMAKAIAN;
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);		
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 4, 0, VQTY, VPAKET_DETIL);
				
				SET VSISA = VPEMAKAIAN - VQTY;
				
				
				IF VSISA <= 0 AND EXISTS(
					SELECT 1
					  FROM pembayaran.rincian_tagihan rt
					 WHERE rt.TAGIHAN = VTAGIHAN
					   AND rt.REF_ID = PKUNJUNGAN
					   AND rt.JENIS = 6) THEN
					
					CALL pembayaran.batalRincianTagihan(VTAGIHAN, PKUNJUNGAN, 6);
				ELSE
					UPDATE temp.temp SET ID = 0 WHERE ID = 0;
				END IF;								
				
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 AND VPEMAKAIAN > 0 AND VQTY > 0 THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PKUNJUNGAN, VTANGGAL, VPEMAKAIAN, 1);
				END IF;
			END IF;						 
			
			IF VTAGIHAN != '' AND VSISA > 0.0 THEN
			BEGIN
				DECLARE VKELAS_SBLM SMALLINT;								
				
				CALL master.getTarifO2(VTANGGAL, VTARIF_ID, VTARIF);
				
				SET VKELAS_SBLM = pembayaran.getKelasRJMengikutiKelasRIYgPertama(VTAGIHAN, PKUNJUNGAN);
				IF VKELAS_SBLM > 0 THEN
					SET VKELAS = VKELAS_SBLM;
				END IF;
				
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, PKUNJUNGAN, 6, VTARIF_ID, VSISA, VTARIF, VKELAS, 0, 0);						
			END;
			END IF;
		END IF;	
	ELSE
		UPDATE temp.temp SET ID = 0 WHERE ID = 0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
