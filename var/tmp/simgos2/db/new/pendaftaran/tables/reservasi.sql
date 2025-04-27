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

-- membuang struktur untuk table pendaftaran.reservasi
DROP TABLE IF EXISTS `reservasi`;
CREATE TABLE IF NOT EXISTS `reservasi` (
  `NOMOR` char(10) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `RUANG_KAMAR_TIDUR` smallint(6) NOT NULL,
  `BERAKHIR` datetime DEFAULT NULL COMMENT 'Batas Reservasi jika belum melakukan pendaftaran',
  `ATAS_NAMA` varchar(75) DEFAULT NULL COMMENT 'Nama yang meminta reservasi',
  `KONTAK_INFO` varchar(100) DEFAULT NULL COMMENT 'Kontak Informasi',
  `OLEH` smallint(6) NOT NULL COMMENT 'Petugas yg melakukan reservasi',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status Reservasi',
  PRIMARY KEY (`NOMOR`),
  KEY `RUANG_KAMAR_TIDUR` (`RUANG_KAMAR_TIDUR`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
