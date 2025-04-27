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

-- membuang struktur untuk procedure pembayaran.getTotalPiutangPerorangan
DROP PROCEDURE IF EXISTS `getTotalPiutangPerorangan`;
DELIMITER //
CREATE PROCEDURE `getTotalPiutangPerorangan`(
	IN `PNORM` INT
)
BEGIN   
	SELECT @total:= SUM(IF(bpp.TOTAL IS NULL, 0, bpp.TOTAL)),
			 @totalbyr:= SUM(IF(bppp.TOTAL_BAYAR IS NULL, 0, bppp.TOTAL_BAYAR)),
			 @sisa := @total - @totalbyr,
			 IF(@sisa > 0, @sisa , 0)
	  INTO @total, @totalbyr, @sisa, @harus_bayar
	  FROM pembayaran.piutang_pasien bpp
			 LEFT JOIN pembayaran.pelunasan_piutang_pasien bppp ON bppp.TAGIHAN_PIUTANG = bpp.TAGIHAN AND bppp.`STATUS` = 2
			 LEFT JOIN pembayaran.tagihan bt ON bt.ID = bpp.TAGIHAN
	 WHERE bt.REF = PNORM 
	   AND bt.JENIS = 1 
	   AND bt.`STATUS` IN (1, 2)
	   AND bpp.`STATUS` = 1;
	  
   SELECT PNORM NORM
	       , IF(@total IS NULL, 0, @total) TOTAL
			 , IF(@totalbyr IS NULL, 0, @totalbyr) TOTAL_BAYAR
			 , IF(@sisa IS NULL, 0, @sisa) SISA_BAYAR
			 , @harus_bayar SISA_HARUS_BAYAR;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.getTotalPiutangPerusahaan
DROP PROCEDURE IF EXISTS `getTotalPiutangPerusahaan`;
DELIMITER //
CREATE PROCEDURE `getTotalPiutangPerusahaan`(
	IN `PNORM` INT
)
BEGIN   
	SELECT @total:= SUM(IF(bpp.TOTAL IS NULL, 0, bpp.TOTAL)),
			 @totalbyr:= IF(bppp.TOTAL_BAYAR IS NULL, 0, SUM(bppp.TOTAL_BAYAR)),
			 @sisa := @total - @totalbyr,
			 IF(@sisa > 0, @sisa , 0)
	  INTO @total, @totalbyr, @sisa, @harus_bayar
	  FROM pembayaran.piutang_perusahaan bpp
	       LEFT JOIN pembayaran.pelunasan_piutang_perusahaan bppp ON bppp.TAGIHAN_PIUTANG = bpp.TAGIHAN AND bppp.`STATUS` = 2
	       LEFT JOIN pembayaran.tagihan bt ON bt.ID = bpp.TAGIHAN
 	 WHERE bt.REF = PNORM 
	   AND bt.JENIS = 1 
	   AND bt.`STATUS` IN (1, 2)
	   AND bpp.`STATUS` = 1;
	
	SELECT PNORM NORM
	       , IF(@total IS NULL, 0, @total) TOTAL
			 , IF(@totalbyr IS NULL, 0, @totalbyr) TOTAL_BAYAR
			 , IF(@sisa IS NULL, 0, @sisa) SISA_BAYAR
			 , @harus_bayar SISA_HARUS_BAYAR;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
