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

-- membuang struktur untuk procedure informasi.listBORKemkes
DROP PROCEDURE IF EXISTS `listBORKemkes`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `listBORKemkes`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	SELECT MONTH(PTGL_AWAL) BULAN
		, ROUND((SUM(HP) * 100) / ((SUM(TTIDUR)) * (SUM(JMLHARI))),2) BOR
	FROM (		
		SELECT irs.AWAL AWAL
				, 0 MASUK
				, 0 PINDAHAN
				, 0 KURANG48JAM
				, 0 LEBIH48JAM
				, 0 DIPINDAHKAN
				, 0 JMLKLR
				, 0 LD
				, 0 HP
				, 0 TTIDUR
				, 0 JMLHARI
				, 0 PASIENDIRAWAT
				, LASTUPDATED
		FROM informasi.indikator_rs irs
		WHERE irs.TANGGAL= PTGL_AWAL
		UNION
		SELECT 0 AWAL
				, SUM(irs.MASUK) MASUK
				, SUM(irs.PINDAHAN) PINDAHAN
				, SUM(irs.KURANG48JAM) KURANG48JAM
				, SUM(irs.LEBIH48JAM) LEBIH48JAM
				, SUM(irs.DIPINDAHKAN) DIPINDAHKAN
				, SUM(irs.JMLKLR) JMLKLR
				, SUM(irs.LD) LD
				, SUM(irs.HP) HP
				, 0 TTIDUR
				, SUM(JMLHARI) JMLHARI
				, 0 PASIENDIRAWAT
				, LASTUPDATED
		FROM informasi.indikator_rs irs
		WHERE irs.TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR
		UNION
		SELECT 0 AWAL
				, 0 MASUK
				, 0 PINDAHAN
				, 0 KURANG48JAM
				, 0 LEBIH48JAM
				, 0 DIPINDAHKAN
				, 0 JMLKLR
				, 0 LD
				, 0 HP
				, TTIDUR
				, 0 JMLHARI
				, irs.SISA PASIENDIRAWAT
				, LASTUPDATED
		FROM informasi.indikator_rs irs
		WHERE irs.TANGGAL= PTGL_AKHIR
		) b;

	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
