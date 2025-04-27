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

-- membuang struktur untuk table master.rl4_icd10
DROP TABLE IF EXISTS `rl4_icd10`;
CREATE TABLE IF NOT EXISTS `rl4_icd10` (
  `ID` int(11) NOT NULL,
  `KODE` varchar(20) NOT NULL,
  `IDJENISRL` tinyint(4) NOT NULL COMMENT '1=4Adan4B dan 2=4Adan4B Sebab Luar',
  `IDRL4AB` int(4) NOT NULL COMMENT 'tbl master.jenis_laporan_detil untuk RL 4A dan 4B',
  `KET` varchar(20) NOT NULL,
  PRIMARY KEY (`ID`),
  KEY `kodeicd10` (`KODE`),
  KEY `idrl4ab` (`IDRL4AB`),
  KEY `ket` (`KET`),
  KEY `IDJENISRL` (`IDJENISRL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
