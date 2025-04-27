-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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

-- membuang struktur untuk function pembayaran.getTotalTagihanPembayaran
DROP FUNCTION IF EXISTS `getTotalTagihanPembayaran`;
DELIMITER //
CREATE FUNCTION `getTotalTagihanPembayaran`(
	`PTAGIHAN` CHAR(10)
) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	RETURN pembayaran.getTotalTagihan(PTAGIHAN) -
			 pembayaran.getTotalPenjaminTagihan(PTAGIHAN) -
			 pembayaran.getTotalNonTunai(PTAGIHAN) -
			 pembayaran.getTotalPiutangPasien(PTAGIHAN) -
			 pembayaran.getTotalPiutangPerusahaan(PTAGIHAN) -
			 pembayaran.getTotalDiskon(PTAGIHAN) -
			 pembayaran.getTotalDiskonDokter(PTAGIHAN) -
			 (pembayaran.getTotalDeposit(PTAGIHAN) - pembayaran.getTotalPengembalianDeposit(PTAGIHAN)) -
			 pembayaran.getTotalSubsidiTagihan(PTAGIHAN);
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
