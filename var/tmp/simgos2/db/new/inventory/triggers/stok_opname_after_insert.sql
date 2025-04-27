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

-- membuang struktur untuk trigger inventory.stok_opname_after_insert
DROP TRIGGER IF EXISTS `stok_opname_after_insert`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO';
DELIMITER //
CREATE TRIGGER `stok_opname_after_insert` AFTER INSERT ON `stok_opname` FOR EACH ROW BEGIN
	DECLARE VTANGGAL DATE;
	
	SELECT MAX(TANGGAL) INTO VTANGGAL
	  FROM inventory.stok_opname
	 WHERE NOT ID IN (NEW.ID)
	   AND RUANGAN = NEW.RUANGAN
	   AND STATUS = 'Final';
	 
	SET VTANGGAL = IF(VTANGGAL IS NULL, NEW.TANGGAL, VTANGGAL);
	
	INSERT INTO inventory.stok_opname_detil(STOK_OPNAME, BARANG_RUANGAN, AWAL, SISTEM, MANUAL, TANGGAL, BARANG_MASUK, BARANG_KELUAR, OLEH, STATUS)
		SELECT NEW.ID, br.ID, 
				 inventory.getStokAwal(br.ID, CONCAT(VTANGGAL, ' 23:59:59')),
				 IF(tsr.STOK IS NULL, NULL, tsr.STOK), NULL MANUAL, tsr.TANGGAL,
				 inventory.getJumlahBarangMasuk(br.ID, CONCAT(VTANGGAL, ' 23:59:59'), CONCAT(NEW.TANGGAL, ' 23:59:59')), 
				 inventory.getJumlahBarangKeluar(br.ID, CONCAT(VTANGGAL, ' 23:59:59'), CONCAT(NEW.TANGGAL, ' 23:59:59')), 0, 1 FROM (
			SELECT br.*, inventory.getIdTransaksiStokRuangan(ID, NEW.TANGGAL) ID_TRANSAKSI
			  FROM inventory.barang_ruangan br
			 WHERE RUANGAN = NEW.RUANGAN
			   AND STATUS = 1
				) br
				LEFT JOIN inventory.transaksi_stok_ruangan tsr ON tsr.ID = br.ID_TRANSAKSI;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
