-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.34 - MySQL Community Server - GPL
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

-- membuang struktur untuk trigger pendaftaran.onAfterInsertPendaftaran
DROP TRIGGER IF EXISTS `onAfterInsertPendaftaran`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertPendaftaran` AFTER INSERT ON `pendaftaran` FOR EACH ROW BEGIN
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF DECIMAL(60,2);
	
	SET VTAGIHAN = pembayaran.buatTagihan(NEW.NORM, NEW.NOMOR);
	IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
		CALL cetakan.storeKarcis(NEW.NOMOR, 1, NEW.OLEH);
		IF NEW.PAKET > 0 OR NOT NEW.PAKET IS NULL THEN
			IF VTAGIHAN != '' THEN
			BEGIN
				DECLARE VQTY DECIMAL(60,2);
				DECLARE VPAKET_DETIL INT DEFAULT 0;
				DECLARE VKARTU CHAR(11);
				
				CALL master.getTarifPaket(NEW.PAKET, NEW.TANGGAL, VTARIF_ID, VTARIF);
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, NEW.NOMOR, 5, VTARIF_ID, 1, VTARIF, 0, 0, 0, 
					JSON_OBJECT(
						'TARIF_HAK', JSON_OBJECT('ID', VTARIF_ID, 'TOTAL', VTARIF, 'JUMLAH', 1)
					)
				);
				
				CALL master.inPaket(NEW.PAKET, 3, 1, NULL, VQTY, VPAKET_DETIL);
				IF VPAKET_DETIL > 0 THEN
					SELECT rt.REF_ID INTO VKARTU
					  FROM pembayaran.rincian_tagihan rt,
					  		 master.tarif_administrasi ta
					 WHERE rt.TAGIHAN = VTAGIHAN 
					   AND rt.JENIS = 1 
					   AND ta.ID = rt.TARIF_ID
					   AND ta.ADMINISTRASI = 1
						AND rt.STATUS = 1;
						
					IF FOUND_ROWS() > 0 THEN
						CALL pembayaran.storeRincianTagihanPaket(VTAGIHAN, VPAKET_DETIL, VKARTU, NEW.TANGGAL, 1, 1);
						CALL pembayaran.batalRincianTagihan(VTAGIHAN, VKARTU, 1);	
					END IF;
				END IF;
			END;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
