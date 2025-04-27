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

-- membuang struktur untuk table layanan.dcm_rad
DROP TABLE IF EXISTS `dcm_rad`;
CREATE TABLE IF NOT EXISTS `dcm_rad` (
  `ID` bigint(20) NOT NULL AUTO_INCREMENT,
  `TINDAKAN_MEDIS` char(11) NOT NULL COMMENT 'Layanan / Pemeriksaan dll',
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `PATIENT_ID` char(25) NOT NULL,
  `STUDY_UID` varchar(60) NOT NULL,
  `SERIES_UID` varchar(60) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `PATIENT_ID_STUDY_UID_SERIES_UID` (`PATIENT_ID`,`STUDY_UID`,`SERIES_UID`),
  KEY `TINDAKAN_MEDIS` (`TINDAKAN_MEDIS`),
  KEY `TANGGAL` (`TANGGAL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
