-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk pembayaran
CREATE DATABASE IF NOT EXISTS `pembayaran`;
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.getTotalPiutangPerorangan
DROP PROCEDURE IF EXISTS `getTotalPiutangPerorangan`;
DELIMITER //
CREATE PROCEDURE `getTotalPiutangPerorangan`(
	IN `PNORM` INT
)
BEGIN
   
	SELECT
		1 NORM, 
		@total:= SUM(IF(bpp.TOTAL IS NULL, 0, bpp.TOTAL)) TOTAL,
		@totalbyr:= SUM(IF(bppp.TOTAL_BAYAR IS NULL, 0, bppp.TOTAL_BAYAR)) TOTAL_BAYAR,
		@sisa := @total - @totalbyr  SISA_BAYAR,
		IF(@sisa > 0, @sisa ,0) SISA_HARUS_BAYAR
	FROM pembayaran.piutang_pasien bpp
	LEFT JOIN pembayaran.pelunasan_piutang_pasien bppp ON bppp.TAGIHAN_PIUTANG = bpp.TAGIHAN AND bppp.`STATUS` = 2
	LEFT JOIN pembayaran.tagihan bt ON bt.ID = bpp.TAGIHAN
	WHERE bt.REF = PNORM 
	AND bt.JENIS = 1 
	AND bt.`STATUS` = 2
	AND bpp.`STATUS` = 1;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
