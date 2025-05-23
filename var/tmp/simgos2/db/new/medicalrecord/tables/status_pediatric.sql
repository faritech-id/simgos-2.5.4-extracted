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

-- membuang struktur untuk table medicalrecord.status_pediatric
DROP TABLE IF EXISTS `status_pediatric`;
CREATE TABLE IF NOT EXISTS `status_pediatric` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `STATUS_PEDIATRIC` int(1) NOT NULL DEFAULT '0' COMMENT '1. GIZI KURANG 2. GIZI CUKUP 3. LENGKAP',
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` int(11) NOT NULL,
  `STATUS` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`),
  CONSTRAINT `FK__pendaftaran.kunjungan` FOREIGN KEY (`KUNJUNGAN`) REFERENCES `pendaftaran`.`kunjungan` (`nomor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Penilaian:';

-- Membuang data untuk tabel medicalrecord.status_pediatric: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `status_pediatric` DISABLE KEYS */;
/*!40000 ALTER TABLE `status_pediatric` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
