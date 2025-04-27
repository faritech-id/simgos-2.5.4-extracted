-- --------------------------------------------------------
-- Host:                         192.168.23.254
-- Versi server:                 5.7.24 - MySQL Community Server (GPL)
-- OS Server:                    Linux
-- HeidiSQL Versi:               9.5.0.5196
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;


-- Membuang struktur basisdata untuk pembayaran
#CREATE DATABASE IF NOT EXISTS `pembayaran` /*!40100 DEFAULT CHARACTER SET latin1 */;
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.storeAkomodasi
DROP PROCEDURE IF EXISTS `storeAkomodasi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeAkomodasi`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VTAGIHAN, VNOPEN, VRUANGAN CHAR(10);
	DECLARE VMASUK, VKELUAR DATETIME;
	DECLARE VREF CHAR(21);
	DECLARE VKELAS TINYINT;
	DECLARE VRUANG_KAMAR_TIDUR SMALLINT;
	DECLARE VTANGGAL_PENDAFTARAN, VTANGGAL DATETIME;
	DECLARE VTITIPAN TINYINT;
	DECLARE VPERSENTASE TINYINT;
	DECLARE VDISKON DECIMAL(60, 2);
	
	SELECT k.NOPEN, k.MASUK, k.KELUAR, k.RUANGAN, k.REF, k.RUANG_KAMAR_TIDUR, IF(k.TITIPAN = 1, k.TITIPAN_KELAS, rk.KELAS), k.TITIPAN
	  INTO VNOPEN, VMASUK, VKELUAR, VRUANGAN, VREF, VRUANG_KAMAR_TIDUR, VKELAS, VTITIPAN
	  FROM pendaftaran.kunjungan k
	  		 , master.ruang_kamar_tidur rkt
			 , master.ruang_kamar rk
	 WHERE k.NOMOR = PKUNJUNGAN
	   AND master.isRawatInap(k.RUANGAN) = 1
		AND rkt.ID = k.RUANG_KAMAR_TIDUR
		AND rk.ID = rkt.RUANG_KAMAR;
	
	IF FOUND_ROWS() > 0 THEN
		SET VKELUAR = IF(VKELUAR IS NULL OR VKELUAR = '', NOW(), VKELUAR);
		
		/* Ambil tagihan */
		SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
		
		BEGIN
			DECLARE VTARIF_ID INT;
			DECLARE VTARIF INT;
			DECLARE VPAKET SMALLINT;
			DECLARE VKELAS_PAKET TINYINT;
			DECLARE VLAMA TINYINT DEFAULT 0;
			DECLARE VLAMA_DIRAWAT SMALLINT DEFAULT 0;
			DECLARE VSELISIH SMALLINT DEFAULT 0;
		   
		   IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
			   /* Ambil Info Paket di pendaftaran & paket */
			   SELECT pkt.ID, pkt.KELAS, pkt.LAMA, pdf.TANGGAL INTO VKELAS_PAKET, VKELAS_PAKET, VLAMA, VTANGGAL_PENDAFTARAN
			     FROM pendaftaran.pendaftaran pdf
			     		 LEFT JOIN master.paket pkt ON pkt.ID = pdf.PAKET
			    WHERE pdf.NOMOR = VNOPEN;
		   
				IF FOUND_ROWS() > 0 THEN
					IF NOT VKELAS_PAKET IS NULL THEN
						SET VKELAS = VKELAS_PAKET;
					END IF;
					# SET DEFAULT PEMBACAAN TARIF BERDASARKAN TANGGAL MASUK KUNJUNGAN
					SET VTANGGAL = VMASUK;
					# JIKA BERLAKUKAN TARIF BARU BERDASARKAN TANGGAL PENDAFTARAN
					IF EXISTS(SELECT 1
						  FROM aplikasi.properti_config pc
						 WHERE pc.ID = 6
						   AND VALUE = 'TRUE') THEN
						SET VTANGGAL = VTANGGAL_PENDAFTARAN;
					END IF;
				
					/* Ambil lama di rawat */
					SET VLAMA_DIRAWAT = pendaftaran.getLamaDirawat(VMASUK, VKELUAR, VNOPEN, PKUNJUNGAN, VREF);
					
					/* Store data ke rincian tagihan paket jika paket */
					IF VTAGIHAN != '' AND (NOT VPAKET IS NULL OR VPAKET > 0) THEN
						CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET, PKUNJUNGAN, VTANGGAL, 1);
						
						IF NOT VREF IS NULL OR VREF != '' THEN
							SET VLAMA_DIRAWAT = VLAMA_DIRAWAT + pendaftaran.getLamaDirawatSebelumnya(VREF, VPAKET);
						END IF;
					ELSE
						SET VLAMA = 0;
					END IF;
					
					/* Cek jika ada selisih lama di rawat */
					SET VSELISIH = VLAMA_DIRAWAT - VLAMA;
					IF VTAGIHAN != '' AND (VSELISIH > 0 OR VLAMA_DIRAWAT >= 0) THEN
					   IF VSELISIH >= 0 THEN		
							IF VTITIPAN = 1 THEN
								CALL master.getTarifRuangRawatByKelas(VKELAS, VTANGGAL, VTARIF_ID, VTARIF);
							ELSE			    
					      	CALL master.getTarifRuangRawat(VRUANG_KAMAR_TIDUR, VTANGGAL, VTARIF_ID, VTARIF);
					      END IF;
					      IF pendaftaran.ikutRawatInapIbu(VNOPEN, VREF) = 1 THEN
					      	CALL master.getTarifDiskon(1, VTANGGAL, VPERSENTASE, VDISKON);
					      ELSE
								SET VPERSENTASE = 0;
								SET VDISKON = 0;
					      END IF;
						   CALL pembayaran.storeRincianTagihan(VTAGIHAN, PKUNJUNGAN, 2, VTARIF_ID, VSELISIH, VTARIF, VKELAS, VPERSENTASE, VDISKON);
						END IF;
					END IF;
				END IF;
			END IF;
		END;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
