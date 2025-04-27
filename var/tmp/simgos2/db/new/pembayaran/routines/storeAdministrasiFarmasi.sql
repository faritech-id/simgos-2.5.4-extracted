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

-- membuang struktur untuk procedure pembayaran.storeAdministrasiFarmasi
DROP PROCEDURE IF EXISTS `storeAdministrasiFarmasi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeAdministrasiFarmasi`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VORDERID CHAR(21);
	DECLARE VRACIKAN TINYINT;
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VNOPEN CHAR(10);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	DECLARE VPAKET SMALLINT DEFAULT NULL;
	DECLARE VQTY DECIMAL(60,2);
	DECLARE VPAKET_DETIL INT DEFAULT 0;
	DECLARE VREF SMALLINT;
	DECLARE VTANGGAL_PENDAFTARAN DATETIME;
	
	SELECT k.REF, k.NOPEN, p.PAKET, p.TANGGAL INTO VORDERID, VNOPEN, VPAKET, VTANGGAL_PENDAFTARAN
	  FROM pendaftaran.kunjungan k,
	  	    pendaftaran.pendaftaran p,
	  		 `master`.ruangan r
	 WHERE k.NOMOR = PKUNJUNGAN
	 	AND p.NOMOR = k.NOPEN
	   AND r.ID = k.RUANGAN
	   AND r.JENIS_KUNJUNGAN = 11;
	   
	IF FOUND_ROWS() > 0 THEN
		IF NOT VORDERID IS NULL THEN
			SELECT MAX(odr.RACIKAN) INTO VRACIKAN
			  FROM layanan.order_resep oresep,
			  		 layanan.order_detil_resep odr
			 WHERE odr.ORDER_ID = oresep.NOMOR
			   AND oresep.NOMOR = VORDERID;
			 
			IF NOT VRACIKAN IS NULL THEN
				SET VREF = IF(VRACIKAN = 1, 4, 3);
				IF EXISTS(SELECT 1 FROM `master`.administrasi WHERE ID = VREF AND STATUS = 1) THEN
					SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
					IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
						IF NOT VPAKET IS NULL OR VPAKET > 0 THEN
							CALL master.inPaket(VPAKET, 3, VREF, VQTY, VPAKET_DETIL);
							
							IF VTAGIHAN != '' AND VPAKET_DETIL > 0 THEN
								CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, PKUNJUNGAN, VTANGGAL_PENDAFTARAN, 1, 1);
							END IF;
						END IF;
							
						IF VTAGIHAN != '' AND VPAKET_DETIL = 0 THEN
							CALL master.getTarifAdministrasi(VREF, 0, VTANGGAL_PENDAFTARAN, VTARIF_ID, VTARIF);
							CALL pembayaran.storeRincianTagihan(VTAGIHAN, PKUNJUNGAN, 1, VTARIF_ID, 1, VTARIF, 0, 0, 0);
						END IF;
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
