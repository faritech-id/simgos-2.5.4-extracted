-- --------------------------------------------------------
-- Host:                         192.168.23.228
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for layanan
USE `layanan`;

-- Dumping structure for procedure layanan.CetakLabelPA
DROP PROCEDURE IF EXISTS `CetakLabelPA`;
DELIMITER //
CREATE PROCEDURE `CetakLabelPA`(
	IN `PKUNJUNGAN` VARCHAR(50),
	IN `PNOPA` VARCHAR(10),
	IN `PBAHAN` VARCHAR(50)
)
BEGIN
	SELECT
		PNOPA NOPA, pp.NORM, `master`.getNamaLengkap(pp.NORM) NAMA, DATE_FORMAT(p.TANGGAL_LAHIR, "%d-%m-%Y") TGL_LAHIR, PBAHAN BAHAN
	FROM
		layanan.hasil_pa hp,
		pendaftaran.kunjungan pk,
		pendaftaran.pendaftaran pp
		LEFT JOIN `master`.pasien p ON p.NORM=pp.NORM
	WHERE
		hp.KUNJUNGAN=pk.NOMOR
		AND pp.NOMOR=pk.NOPEN
		AND pk.NOMOR=PKUNJUNGAN
	LIMIT 1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
