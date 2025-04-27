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

-- membuang struktur untuk function inventory.getJumlahBarangMasuk
DROP FUNCTION IF EXISTS `getJumlahBarangMasuk`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getJumlahBarangMasuk`(`PBARANG_RUANGAN` BIGINT, `PTANGGAL_AWAL` DATETIME, `PTANGGAL_AKHIR` DATETIME) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VJUMLAH DECIMAL(60, 2);
	
	SELECT SUM(JUMLAH) INTO VJUMLAH
	  FROM inventory.transaksi_stok_ruangan
	 WHERE JENIS IN (20, 21, 31, 32, 34)
	   AND TANGGAL BETWEEN PTANGGAL_AWAL AND PTANGGAL_AKHIR
		AND BARANG_RUANGAN = PBARANG_RUANGAN;
 
	RETURN IF(VJUMLAH IS NULL, 0, VJUMLAH);
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
