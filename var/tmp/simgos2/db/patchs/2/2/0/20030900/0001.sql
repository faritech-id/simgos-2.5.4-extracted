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

-- membuang struktur untuk table medicalrecord.kondisi_sosial
CREATE TABLE IF NOT EXISTS `kondisi_sosial` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` varchar(19) DEFAULT NULL,
  `MARAH` tinyint(4) DEFAULT '0',
  `CEMAS` tinyint(4) DEFAULT '0',
  `TAKUT` tinyint(4) DEFAULT '0',
  `BUNUH_DIRI` tinyint(4) DEFAULT '0',
  `LAINNYA` varchar(100) DEFAULT NULL,
  `MASALAH_PERILAKU` text,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint(6) DEFAULT NULL,
  `STATUS` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Anamnesis:';

-- Membuang data untuk tabel medicalrecord.kondisi_sosial: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `kondisi_sosial` DISABLE KEYS */;
/*!40000 ALTER TABLE `kondisi_sosial` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
