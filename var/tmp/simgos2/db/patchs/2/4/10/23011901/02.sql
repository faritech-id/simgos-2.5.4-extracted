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
	SELECT SUM(bpp.TOTAL)
	  INTO @total
	  FROM pembayaran.piutang_pasien bpp,
	 	    pembayaran.tagihan t
	 WHERE t.ID = bpp.TAGIHAN
	   AND t.REF = PNORM;
	   
	SELECT SUM(p3.TOTAL_BAYAR)
	  INTO @totalbyr
	  FROM pembayaran.piutang_pasien bpp,
	 	    pembayaran.tagihan t,
	 	    pembayaran.pelunasan_piutang_pasien p3
	 WHERE t.ID = bpp.TAGIHAN
	   AND t.REF = PNORM
		AND p3.TAGIHAN_PIUTANG = t.ID
		AND p3.`STATUS` = 2;
	   
	SET @total = IF(@total IS NULL, 0, @total);
	SET @totalbyr = IF(@totalbyr IS NULL, 0, @totalbyr);
	SET @sisa = CAST(@total - @totalbyr AS UNSIGNED);
	SET @harus_bayar = IF(@sisa > 0, @sisa, 0);
	  
   SELECT PNORM NORM
	       , @total TOTAL
			 , @totalbyr TOTAL_BAYAR
			 , @sisa SISA_BAYAR
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
	SELECT SUM(pp.TOTAL)
	  INTO @total
	  FROM pembayaran.piutang_perusahaan pp,
	 	    pembayaran.tagihan t
	 WHERE t.ID = pp.TAGIHAN
	   AND t.REF = PNORM;
	   
	SELECT SUM(p3.TOTAL_BAYAR)
	  INTO @totalbyr
	  FROM pembayaran.piutang_perusahaan pp,
	 	    pembayaran.tagihan t,
	 	    pembayaran.pelunasan_piutang_perusahaan p3
	 WHERE t.ID = pp.TAGIHAN
	   AND t.REF = PNORM
		AND p3.TAGIHAN_PIUTANG = t.ID
		AND p3.`STATUS` = 2;
	   
	SET @total = IF(@total IS NULL, 0, @total);
	SET @totalbyr = IF(@totalbyr IS NULL, 0, @totalbyr);
	SET @sisa = CAST(@total - @totalbyr AS UNSIGNED);
	SET @harus_bayar = IF(@sisa > 0, @sisa, 0);
	  
   SELECT PNORM NORM
	       , @total TOTAL
			 , @totalbyr TOTAL_BAYAR
			 , @sisa SISA_BAYAR
			 , @harus_bayar SISA_HARUS_BAYAR;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
