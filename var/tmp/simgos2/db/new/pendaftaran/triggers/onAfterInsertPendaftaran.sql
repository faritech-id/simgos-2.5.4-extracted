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
				CALL pembayaran.storeRincianTagihan(VTAGIHAN, NEW.NOMOR, 5, VTARIF_ID, 1, VTARIF, 0, 0, 0);
				
				CALL master.inPaket(NEW.PAKET, 3, 1, VQTY, VPAKET_DETIL);
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

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
