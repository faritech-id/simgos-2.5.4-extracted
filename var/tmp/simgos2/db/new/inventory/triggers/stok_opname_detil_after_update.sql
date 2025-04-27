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

-- membuang struktur untuk trigger inventory.stok_opname_detil_after_update
DROP TRIGGER IF EXISTS `stok_opname_detil_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `stok_opname_detil_after_update` AFTER UPDATE ON `stok_opname_detil` FOR EACH ROW BEGIN
	DECLARE VSELISIH DECIMAL(60,2) DEFAULT 0;
	DECLARE VJENIS TINYINT;
	DECLARE VTANGGAL DATE;		
	
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
		SELECT TANGGAL INTO VTANGGAL
		  FROM inventory.stok_opname
		 WHERE ID = OLD.STOK_OPNAME;
		 
		
		
		SET VSELISIH = OLD.MANUAL;
		SET VJENIS = 11;
		
		INSERT INTO inventory.transaksi_stok_ruangan(BARANG_RUANGAN, JENIS, REF, TANGGAL, JUMLAH)
			 VALUES(OLD.BARANG_RUANGAN, VJENIS, OLD.STOK_OPNAME, CONCAT(VTANGGAL, ' 23:59:59'), VSELISIH);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
