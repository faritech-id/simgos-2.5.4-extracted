USE `layanan`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for trigger layanan.pemakaian_bhp_detil_after_update
DROP TRIGGER IF EXISTS `pemakaian_bhp_detil_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pemakaian_bhp_detil_after_update` AFTER UPDATE ON `pemakaian_bhp_detil` FOR EACH ROW BEGIN
	DECLARE VTANGGAL DATETIME;
	DECLARE VRUANGAN CHAR(10);
	DECLARE VBARANG INT;
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 0 THEN
		SELECT  br.ID, bp.TANGGAL INTO VBARANG, VTANGGAL
			FROM layanan.pemakaian_bhp bp, layanan.pemakaian_bhp_detil pd, inventory.barang_ruangan br
		WHERE br.BARANG = pd.BARANG AND br.RUANGAN = bp.RUANGAN AND pd.PEMAKAIAN = bp.ID AND pd.ID = OLD.ID;
		
		IF NOT VBARANG IS NULL THEN
			INSERT INTO inventory.transaksi_stok_ruangan 
			(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
			VALUES
			(VBARANG, 63, OLD.ID, VTANGGAL, OLD.JUMLAH);
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;