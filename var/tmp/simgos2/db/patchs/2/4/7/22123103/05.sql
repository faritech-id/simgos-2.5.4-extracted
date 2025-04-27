USE `pembayaran`;
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

-- Dumping structure for procedure pembayaran.hitungTotalTagihanPenjualan
DROP PROCEDURE IF EXISTS `hitungTotalTagihanPenjualan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `hitungTotalTagihanPenjualan`(IN `PTAGIHAN` CHAR(10)
)
BEGIN
	UPDATE tagihan t, (
	SELECT p.NOMOR, SUM(
			(pd.JUMLAH * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)))) +
				((pd.JUMLAH * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)))) * (pp.PPN / 100))
			) TOTAL
			FROM penjualan.penjualan p
				, penjualan.penjualan_detil pd
				  LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = pd.MARGIN
				  LEFT JOIN penjualan.ppn_penjualan pp ON pp.ID = pd.PPN
				, inventory.barang b
				, inventory.harga_barang hb
			WHERE b.ID = pd.BARANG
			AND hb.ID = pd.HARGA_BARANG 
			AND pd.PENJUALAN_ID = p.NOMOR
			 AND p.NOMOR = PTAGIHAN) trx
	  SET t.TOTAL = trx.TOTAL
	WHERE t.ID = trx.NOMOR;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;