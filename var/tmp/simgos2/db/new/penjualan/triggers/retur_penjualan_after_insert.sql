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

-- membuang struktur untuk trigger penjualan.retur_penjualan_after_insert
DROP TRIGGER IF EXISTS `retur_penjualan_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `retur_penjualan_after_insert` AFTER INSERT ON `retur_penjualan` FOR EACH ROW BEGIN
	DECLARE VBARANG_RUANGAN BIGINT;
	
	
	SELECT br.ID INTO VBARANG_RUANGAN
	  FROM penjualan.penjualan p
	  		 LEFT JOIN inventory.barang_ruangan br ON br.RUANGAN = p.RUANGAN AND br.BARANG = NEW.BARANG
	 WHERE p.NOMOR = NEW.PENJUALAN_ID
	 LIMIT 1;
	 
	IF FOUND_ROWS() > 0 THEN
		INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
			  VALUES(VBARANG_RUANGAN, 31, NEW.ID, NEW.TANGGAL, NEW.JUMLAH);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
