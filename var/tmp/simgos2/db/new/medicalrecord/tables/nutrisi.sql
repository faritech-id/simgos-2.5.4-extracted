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

-- membuang struktur untuk table medicalrecord.nutrisi
DROP TABLE IF EXISTS `nutrisi`;
CREATE TABLE IF NOT EXISTS `nutrisi` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `BERAT_BADAN` decimal(10,2) NOT NULL,
  `TINGGI_BADAN` decimal(10,2) NOT NULL,
  `INDEX_MASSA_TUBUH` decimal(10,2) NOT NULL,
  `LINGKAR_KEPALA` decimal(10,2) NOT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` int(11) NOT NULL,
  `STATUS` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `OLEH` (`OLEH`),
  KEY `STATUS` (`STATUS`),
  CONSTRAINT `FK_pemeriksaan_umum_pendaftaran.kunjungan` FOREIGN KEY (`KUNJUNGAN`) REFERENCES `pendaftaran`.`kunjungan` (`nomor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Pemeriksaan->Umum:';

-- Membuang data untuk tabel medicalrecord.nutrisi: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `nutrisi` DISABLE KEYS */;
/*!40000 ALTER TABLE `nutrisi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
