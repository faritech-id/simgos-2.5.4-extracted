-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk table medicalrecord.penilaian_nyeri
CREATE TABLE IF NOT EXISTS `penilaian_nyeri` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `NYERI` smallint(6) DEFAULT NULL,
  `ONSET` smallint(6) DEFAULT NULL,
  `SKALA` decimal(10,2) DEFAULT NULL,
  `METODE` smallint(6) DEFAULT NULL COMMENT 'Ref = 71',
  `PENCETUS` char(150) DEFAULT NULL,
  `GAMBARAN` text,
  `DURASI` char(50) DEFAULT NULL,
  `LOKASI` char(150) DEFAULT NULL,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint(6) DEFAULT NULL,
  `STATUS` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Penilaian:';

-- Membuang data untuk tabel medicalrecord.penilaian_nyeri: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `penilaian_nyeri` DISABLE KEYS */;
/*!40000 ALTER TABLE `penilaian_nyeri` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
