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

-- membuang struktur untuk trigger layanan.onAfterUpdateFarmasi
DROP TRIGGER IF EXISTS `onAfterUpdateFarmasi`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterUpdateFarmasi` AFTER UPDATE ON `farmasi` FOR EACH ROW BEGIN
	DECLARE VNOPEN CHAR(10);
	DECLARE VBARANG_RUANGAN BIGINT;
	DECLARE VTAGIHAN CHAR(10);
	
	IF NEW.STATUS != OLD.STATUS THEN
		SELECT k.NOPEN
		  INTO VNOPEN
		  FROM pendaftaran.kunjungan k
		 WHERE k.NOMOR = OLD.KUNJUNGAN
		 LIMIT 1;
		
		IF FOUND_ROWS() > 0 THEN
			SET VTAGIHAN = pembayaran.getIdTagihan(VNOPEN);
			IF pembayaran.isFinalTagihan(VTAGIHAN) = 0 THEN
				IF OLD.STATUS = 1 AND NEW.STATUS = 2 THEN
					IF NEW.FARMASI > 0 THEN
						
						BEGIN
							SELECT br.ID INTO VBARANG_RUANGAN
							  FROM pendaftaran.kunjungan k
							  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
							 WHERE k.NOMOR = NEW.KUNJUNGAN
							 LIMIT 1;
							 
							IF FOUND_ROWS() > 0 THEN
								INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
									  VALUES(VBARANG_RUANGAN, 33, OLD.ID, OLD.TANGGAL, NEW.JUMLAH);
							END IF;
						END;
						
						
						CALL pembayaran.storeFarmasi(OLD.KUNJUNGAN, OLD.ID, NEW.FARMASI, NEW.JUMLAH);
					END IF;
				ELSEIF OLD.STATUS = 2 AND NEW.STATUS = 1 THEN
					IF NEW.FARMASI > 0 THEN										
						
						BEGIN
							SELECT br.ID INTO VBARANG_RUANGAN
							  FROM pendaftaran.kunjungan k
							  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = k.RUANGAN AND br.BARANG = NEW.FARMASI
							 WHERE k.NOMOR = NEW.KUNJUNGAN
							 LIMIT 1;
							 
							IF FOUND_ROWS() > 0 THEN
								INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
									  VALUES(VBARANG_RUANGAN, 35, OLD.ID, OLD.TANGGAL, NEW.JUMLAH);
							END IF;
						END;
					
						
						CALL pembayaran.batalkanStoreFarmasi(OLD.KUNJUNGAN, OLD.ID, NEW.FARMASI, NEW.JUMLAH);
					END IF;
				END IF;
			END IF;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
