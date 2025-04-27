-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.hitungTotalPenerimaanTunaiDiKasir
DROP PROCEDURE IF EXISTS `hitungTotalPenerimaanTunaiDiKasir`;
DELIMITER //
CREATE PROCEDURE `hitungTotalPenerimaanTunaiDiKasir`()
BEGIN
	UPDATE pembayaran.transaksi_kasir tk, (
		SELECT tk.NOMOR, SUM(pt.TOTAL) TOTAL
		  FROM pembayaran.transaksi_kasir tk,
		  		 pembayaran.pembayaran_tagihan pt
		 WHERE pt.TRANSAKSI_KASIR_NOMOR = tk.NOMOR
		   AND pt.JENIS IN (1, 4)
		   AND pt.`STATUS` IN (1, 2)
		   AND tk.TUTUP IS NULL
		 GROUP BY tk.NOMOR) p
	   SET tk.TOTAL = p.TOTAL
	 WHERE tk.NOMOR = p.NOMOR;
END//
DELIMITER ;

-- membuang struktur untuk event pembayaran.onHitungTotalPenerimaanTunaiDiKasir
DROP EVENT IF EXISTS `onHitungTotalPenerimaanTunaiDiKasir`;
DELIMITER //
CREATE EVENT `onHitungTotalPenerimaanTunaiDiKasir` ON SCHEDULE EVERY 15 SECOND STARTS '2022-12-31 22:14:44' ON COMPLETION PRESERVE ENABLE DO BEGIN
	CALL pembayaran.hitungTotalPenerimaanTunaiDiKasir();
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
