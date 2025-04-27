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

-- membuang struktur untuk procedure pembayaran.storeRincianTagihanPaket
DROP PROCEDURE IF EXISTS `storeRincianTagihanPaket`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeRincianTagihanPaket`(
	IN `PTAGIHAN` CHAR(10),
	IN `PPAKET_DETIL` INT,
	IN `PREF_ID` CHAR(19),
	IN `PTANGGAL` DATETIME,
	IN `PJUMLAH` DECIMAL(60,2),
	IN `PSTATUS` TINYINT
)
BEGIN
	DECLARE VTARIF_ID INT;
	DECLARE VTARIF INT;
	
	CALL `master`.getTarifPaketDetil(PPAKET_DETIL, PTANGGAL, VTARIF_ID, VTARIF);
			
	IF	EXISTS(SELECT 1 FROM pembayaran.rincian_tagihan_paket WHERE TAGIHAN = PTAGIHAN AND PAKET_DETIL = PPAKET_DETIL AND REF_ID = PREF_ID LIMIT 1) THEN
		UPDATE pembayaran.rincian_tagihan_paket 
		   SET STATUS = PSTATUS,
		   	 TARIF_ID = VTARIF_ID,
		   	 JUMLAH = PJUMLAH
		 WHERE TAGIHAN = PTAGIHAN
		   AND PAKET_DETIL = PPAKET_DETIL
		 	AND REF_ID = PREF_ID;
	ELSE
		INSERT INTO pembayaran.rincian_tagihan_paket(TAGIHAN, PAKET_DETIL, REF_ID, TARIF_ID, JUMLAH)
		VALUES(PTAGIHAN, PPAKET_DETIL, PREF_ID, VTARIF_ID, PJUMLAH); 
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
