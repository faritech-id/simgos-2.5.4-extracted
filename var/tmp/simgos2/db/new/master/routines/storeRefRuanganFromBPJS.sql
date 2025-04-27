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

-- membuang struktur untuk procedure master.storeRefRuanganFromBPJS
DROP PROCEDURE IF EXISTS `storeRefRuanganFromBPJS`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `storeRefRuanganFromBPJS`(
	IN `PKODE` CHAR(5),
	IN `PNAMA` VARCHAR(150)
)
BEGIN
	IF NOT EXISTS(SELECT 1 FROM master.referensi r WHERE r.JENIS = 70 AND r.REF_ID = PKODE) THEN
		INSERT INTO master.referensi(JENIS, DESKRIPSI, REF_ID, STATUS)
		VALUES(70, PNAMA, PKODE, 1);
	ELSE
		UPDATE master.referensi r
	      SET r.DESKRIPSI = PNAMA
	    WHERE r.JENIS = 70
	      AND r.REF_ID = PKODE;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
