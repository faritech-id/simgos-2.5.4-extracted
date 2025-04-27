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

-- membuang struktur untuk function pembayaran.getJumlahItemRincian
DROP FUNCTION IF EXISTS `getJumlahItemRincian`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getJumlahItemRincian`(
	`PTAGIHAN` CHAR(10)
,
	`PITEM` SMALLINT,
	`PJENIS` TINYINT



) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VJML DECIMAL(60,2) DEFAULT 0;
	
	
	IF PJENIS = 4 THEN
		SELECT SUM(rt.JUMLAH) INTO VJML
		  FROM pembayaran.rincian_tagihan rt
		  		 , layanan.farmasi f
		 WHERE rt.TAGIHAN = PTAGIHAN
		   AND rt.JENIS = 4
			AND f.ID = rt.REF_ID
			AND f.FARMASI = PITEM
			AND rt.`STATUS` = 1;
	END IF;
   
   IF VJML IS NULL THEN
   	SET VJML = 0;
   END IF;
   
	RETURN VJML;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
