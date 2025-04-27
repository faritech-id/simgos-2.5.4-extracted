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

-- membuang struktur untuk function pembayaran.getJumlahItemRincianPaket
DROP FUNCTION IF EXISTS `getJumlahItemRincianPaket`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getJumlahItemRincianPaket`(
	`PTAGIHAN` CHAR(10),
	`PITEM` SMALLINT,
	`PJENIS` TINYINT







) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VJML DECIMAL(60,2) DEFAULT 0;
	
	
	SELECT SUM(rtp.JUMLAH) INTO VJML
	  FROM pembayaran.rincian_tagihan_paket rtp
	  		 , master.paket_detil pd
	 WHERE rtp.TAGIHAN = PTAGIHAN
	   AND pd.ID = rtp.PAKET_DETIL
	   AND pd.JENIS = PJENIS
	   AND pd.ITEM = PITEM;
   
   IF VJML IS NULL THEN
   	SET VJML = 0;
   END IF;
   
	RETURN VJML;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
