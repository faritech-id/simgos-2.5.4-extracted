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

-- membuang struktur untuk trigger inventory.barang_ruangan_after_update
DROP TRIGGER IF EXISTS `barang_ruangan_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `barang_ruangan_after_update` AFTER UPDATE ON `barang_ruangan` FOR EACH ROW BEGIN
	IF OLD.STATUS != NEW.STATUS AND NEW.STATUS = 1 THEN
		INSERT INTO inventory.stok_opname_detil(STOK_OPNAME, BARANG_RUANGAN, AWAL, SISTEM, MANUAL, TANGGAL, BARANG_MASUK, BARANG_KELUAR, OLEH, STATUS)
		SELECT br.SOID, br.ID, IF(tsr.STOK IS NULL, 0, tsr.STOK), 0 MANUAL, tsr.TANGGAL, 
						 inventory.getStokAwal(br.ID, CONCAT(TANGGAL_SO, ' 23:59:59')), 
						 inventory.getJumlahBarangMasuk(br.ID, CONCAT(TANGGAL_SO, ' 23:59:59'), CONCAT(TANGGAL_SO, ' 23:59:59')), 
						 inventory.getJumlahBarangKeluar(br.ID, CONCAT(TANGGAL_SO, ' 23:59:59'), CONCAT(TANGGAL_SO, ' 23:59:59')), 0, 1 
			FROM (
				SELECT br.*, inventory.getIdTransaksiStokRuangan(br.ID, so.TANGGAL) ID_TRANSAKSI, so.TANGGAL TANGGAL_SO, so.ID SOID
				  FROM inventory.barang_ruangan br,
				  		 inventory.stok_opname so
				 WHERE br.RUANGAN = OLD.RUANGAN
				   AND br.STATUS = 1
				   AND so.RUANGAN = OLD.RUANGAN
			   	AND so.`STATUS` = 'Proses'
			   	AND NOT br.ID IN (SELECT BARANG_RUANGAN FROM inventory.stok_opname_detil sod WHERE sod.STOK_OPNAME = so.ID)
				) br
				LEFT JOIN inventory.transaksi_stok_ruangan tsr ON tsr.ID = br.ID_TRANSAKSI;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
