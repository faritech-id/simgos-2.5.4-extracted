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

-- membuang struktur untuk procedure pembayaran.storeTindakanMedis
DROP PROCEDURE IF EXISTS `storeTindakanMedis`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `storeTindakanMedis`(
	IN `PKUNJUNGAN` CHAR(19),
	IN `PTINDAKAN_MEDIS` CHAR(11),
	IN `PTINDAKAN` SMALLINT
)
BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VKELAS SMALLINT DEFAULT 0;
	DECLARE VPAKET SMALLINT DEFAULT FALSE;
	DECLARE VQTY DECIMAL(60,2) DEFAULT 0.0;
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VJUMLAH DECIMAL(60,2) DEFAULT 1.0;
	DECLARE VREF CHAR(21);
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL_TINDAKAN, VTANGGAL DATETIME;
	
	SELECT k.NOPEN, r.JENIS_KUNJUNGAN, IF(r.JENIS_KUNJUNGAN = 3, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)), IF(rkls.KELAS IS NULL, 0, rkls.KELAS)) KELAS, p.PAKET, k.REF, p.TANGGAL, tm.TANGGAL 
	  INTO VNOPEN, VJENIS_KUNJUNGAN, VKELAS, VPAKET, VREF, VTANGGAL_PENDAFTARAN, VTANGGAL_TINDAKAN
	  FROM layanan.tindakan_medis tm,
	  		 pendaftaran.kunjungan k
	  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
			 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR,
	  		 master.ruangan r
			 LEFT JOIN master.ruangan_kelas rkls ON rkls.RUANGAN = r.ID AND rkls.`STATUS` = 1,
	  		 pendaftaran.pendaftaran p
	 WHERE tm.ID = PTINDAKAN_MEDIS
	   AND k.NOMOR = PKUNJUNGAN
	 	AND k.NOMOR = tm.KUNJUNGAN	 	
	 	AND k.RUANGAN = r.ID
		AND k.NOPEN = p.NOMOR
	  LIMIT 1;
	
	IF FOUND_ROWS() > 0 THEN
		
		SET VTANGGAL = VTANGGAL_TINDAKAN;
		
		IF EXISTS(SELECT 1
			  FROM aplikasi.properti_config pc
			 WHERE pc.ID = 6
			   AND VALUE = 'TRUE') THEN
			SET VTANGGAL = VTANGGAL_PENDAFTARAN;
		END IF;
									
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		
		SET VJUMLAH = pembayaran.getJumlahItemRincianPaket(VTAGIHAN, PTINDAKAN, 1) + 1;
		
		
		IF NOT (VJENIS_KUNJUNGAN = 3 AND NOT VREF IS NULL) THEN
			
			BEGIN
				DECLARE VKUNJUNGAN CHAR(19);
				DECLARE VKELAS_SBLM TINYINT;
				
				SELECT r.KUNJUNGAN INTO VKUNJUNGAN
				  FROM (
					SELECT k.KUNJUNGAN
					  FROM pendaftaran.konsul k
					 WHERE k.NOMOR = VREF
					 UNION
					SELECT ol.KUNJUNGAN
					  FROM layanan.order_lab ol
					 WHERE ol.NOMOR = VREF
					 UNION
					SELECT ora.KUNJUNGAN
					  FROM layanan.order_rad ora
					 WHERE ora.NOMOR = VREF
					) r;
					
				
				IF VJENIS_KUNJUNGAN = 2 THEN
					SET VKUNJUNGAN = PKUNJUNGAN;
				END IF;
				
				IF FOUND_ROWS() > 0 OR VJENIS_KUNJUNGAN = 2 THEN
					
					IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 7
						   AND VALUE = 'TRUE') THEN
						SELECT IF(k.TITIPAN = 1, k.TITIPAN_KELAS, IF(rk.KELAS IS NULL, 0, rk.KELAS)) KELAS
						  INTO VKELAS_SBLM
						  FROM pendaftaran.kunjungan k
						  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
								 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR 
						 WHERE k.NOMOR = VKUNJUNGAN
							AND k.RUANG_KAMAR_TIDUR > 0
							AND NOT k.`STATUS` = 0;
							
						IF FOUND_ROWS() > 0 THEN
							IF VKELAS_SBLM > 0 THEN
								SET VKELAS = VKELAS_SBLM;
							END IF;
						END IF;
					END IF;
					
					
					
					
					SET VKELAS_SBLM = pembayaran.getKelasRJMengikutiKelasRIYgPertama(VTAGIHAN, VKUNJUNGAN);
					IF VKELAS_SBLM > 0 THEN
						SET VKELAS = VKELAS_SBLM;
					END IF;
				END IF;
			END;
		END IF;		
				
		IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
				CALL master.inPaket(VPAKET, 1, PTINDAKAN, VQTY, VPAKET_DETIL);
				
				IF VTAGIHAN != '' AND VPAKET_DETIL > 0 AND VJUMLAH <= VQTY THEN
					CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PTINDAKAN_MEDIS, VTANGGAL, 1, 1);
				END IF;
			END IF;
			
			IF VTAGIHAN != '' AND (VPAKET_DETIL = 0 OR VJUMLAH > VQTY) THEN			
				CALL master.getTarifTindakan(PTINDAKAN, VKELAS, VTANGGAL, VTARIF_ID, VTARIF);
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, PTINDAKAN_MEDIS, 3, VTARIF_ID, 1, VTARIF, VKELAS, 0, 0);
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
