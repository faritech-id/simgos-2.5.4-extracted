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

-- membuang struktur untuk trigger penjualan.penjualan_detil_after_update
DROP TRIGGER IF EXISTS `penjualan_detil_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `penjualan_detil_after_update` AFTER UPDATE ON `penjualan_detil` FOR EACH ROW BEGIN
	DECLARE VBARANG_RUANGAN BIGINT;
	DECLARE VTANGGAL_TERIMA DATETIME;
	DECLARE VID INT;
	DECLARE VJUMLAH INT;
	
	IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 2 THEN
		SELECT br.ID, p.TANGGAL INTO VBARANG_RUANGAN, VTANGGAL_TERIMA
		  FROM penjualan.penjualan p
		  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = p.RUANGAN AND br.BARANG = OLD.BARANG
		 WHERE p.NOMOR = OLD.PENJUALAN_ID
		 LIMIT 1;
		 
		IF FOUND_ROWS() > 0 THEN
			INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
				  VALUES(VBARANG_RUANGAN, 30, OLD.ID, VTANGGAL_TERIMA, NEW.JUMLAH);
		END IF;
	END IF;
	
	IF NEW.ID != 0 AND OLD.JUMLAH != NEW.JUMLAH THEN
		SELECT pd.PENJUALAN_ID, pd.JUMLAH INTO VID, VJUMLAH
		 FROM penjualan.penjualan_detil pd
		WHERE pd.ID = OLD.ID
		LIMIT 1;
		
		IF FOUND_ROWS() > 0 THEN
			CALL pembayaran.hitungTotalTagihanPenjualan(NEW.PENJUALAN_ID);
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
