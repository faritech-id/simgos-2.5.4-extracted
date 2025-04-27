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

-- membuang struktur untuk procedure pembayaran.hitungTotalTagihanPenjualan
DROP PROCEDURE IF EXISTS `hitungTotalTagihanPenjualan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `hitungTotalTagihanPenjualan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	UPDATE tagihan t, (
	SELECT p.NOMOR, SUM(pd.JUMLAH * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)))) TOTAL
			FROM penjualan.penjualan p
				, penjualan.penjualan_detil pd
				  LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = pd.MARGIN
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
