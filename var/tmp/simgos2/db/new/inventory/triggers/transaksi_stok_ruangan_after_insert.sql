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

-- membuang struktur untuk trigger inventory.transaksi_stok_ruangan_after_insert
DROP TRIGGER IF EXISTS `transaksi_stok_ruangan_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `transaksi_stok_ruangan_after_insert` AFTER INSERT ON `transaksi_stok_ruangan` FOR EACH ROW BEGIN
	DECLARE VID CHAR(23);
	
	SELECT ID INTO VID
	  FROM inventory.transaksi_stok_ruangan
	 WHERE BARANG_RUANGAN = NEW.BARANG_RUANGAN
		AND ID > NEW.ID
	 ORDER BY ID ASC LIMIT 1;
	 
	IF FOUND_ROWS() > 0 THEN
		INSERT INTO inventory.recalculation(BARANG_RUANGAN, ID) VALUES(NEW.BARANG_RUANGAN, VID);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
