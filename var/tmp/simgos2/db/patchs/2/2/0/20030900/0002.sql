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

-- membuang struktur untuk table medicalrecord.edukasi_pasien_keluarga
CREATE TABLE IF NOT EXISTS `edukasi_pasien_keluarga` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `KESEDIAAN` int(11) DEFAULT NULL,
  `HAMBATAN` int(11) DEFAULT NULL,
  `HAMBATAN_PENDENGARAN` int(11) DEFAULT NULL,
  `HAMBATAN_PENGLIHATAN` int(11) DEFAULT NULL,
  `HAMBATAN_KOGNITIF` int(11) DEFAULT NULL,
  `HAMBATAN_FISIK` int(11) DEFAULT NULL,
  `HAMBATAN_BUDAYA` int(11) DEFAULT NULL,
  `HAMBATAN_EMOSI` int(11) DEFAULT NULL,
  `HAMBATAN_BAHASA` int(11) DEFAULT NULL,
  `HAMBATAN_LAINNYA` text,
  `PENERJEMAH` smallint(6) DEFAULT NULL,
  `BAHASA` char(50) DEFAULT NULL,
  `EDUKASI_DIAGNOSA` smallint(6) DEFAULT NULL,
  `EDUKASI_PENYAKIT` smallint(6) DEFAULT NULL,
  `EDUKASI_REHAB_MEDIK` smallint(6) DEFAULT NULL,
  `EDUKASI_HKP` smallint(6) DEFAULT NULL,
  `EDUKASI_OBAT` smallint(6) DEFAULT NULL,
  `EDUKASI_NYERI` smallint(6) DEFAULT NULL,
  `EDUKASI_NUTRISI` smallint(6) DEFAULT NULL,
  `EDUKASI_PENGGUNAAN_ALAT` smallint(6) DEFAULT NULL,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `STATUS` smallint(6) DEFAULT NULL,
  `OLEH` tinyint(4) DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Anamnesis:';

-- Membuang data untuk tabel medicalrecord.edukasi_pasien_keluarga: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `edukasi_pasien_keluarga` DISABLE KEYS */;
/*!40000 ALTER TABLE `edukasi_pasien_keluarga` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
