-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganAturan1
DROP PROCEDURE IF EXISTS `prosesPerhitunganAturan1`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganAturan1`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
   # Lihat jenis referensi id = 130
	UPDATE pembayaran.penjamin_tagihan
	   SET TOTAL = 0
	 WHERE TAGIHAN = PTAGIHAN
	   AND KE = 1;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.prosesPerhitunganAturan3
DROP PROCEDURE IF EXISTS `prosesPerhitunganAturan3`;
DELIMITER //
CREATE PROCEDURE `prosesPerhitunganAturan3`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
   # Lihat jenis referensi id = 130
	UPDATE pembayaran.penjamin_tagihan
	   SET TOTAL = pembayaran.getTotalTagihan(PTAGIHAN)
	 WHERE TAGIHAN = PTAGIHAN
	   AND KE = 1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
