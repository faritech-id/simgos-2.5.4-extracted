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

-- membuang struktur untuk table pendaftaran.kunjungan
DROP TABLE IF EXISTS `kunjungan`;
CREATE TABLE IF NOT EXISTS `kunjungan` (
  `NOMOR` char(19) NOT NULL,
  `NOPEN` char(10) NOT NULL,
  `RUANGAN` char(10) NOT NULL,
  `MASUK` datetime NOT NULL,
  `KELUAR` datetime DEFAULT NULL,
  `RUANG_KAMAR_TIDUR` smallint(6) DEFAULT NULL,
  `REF` char(21) DEFAULT NULL COMMENT 'Ref. Konsul / Mutas / Order dll',
  `DITERIMA_OLEH` smallint(6) NOT NULL COMMENT 'Petugas',
  `BARU` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Status Kunjungan',
  `TITIPAN` tinyint(4) NOT NULL DEFAULT '0',
  `TITIPAN_KELAS` tinyint(4) DEFAULT NULL,
  `STATUS` smallint(6) NOT NULL DEFAULT '1' COMMENT 'Status Aktifitas Kunjungan',
  `FINAL_HASIL` TINYINT NOT NULL DEFAULT '0',
  `FINAL_HASIL_OLEH` SMALLINT NULL,
  `FINAL_HASIL_TANGGAL` DATETIME NULL,
  PRIMARY KEY (`NOMOR`),
  UNIQUE KEY `NOPEN_RUANGAN_MASUK` (`NOPEN`,`RUANGAN`,`MASUK`),
  KEY `REF` (`REF`),
  KEY `BARU` (`BARU`),
  KEY `KELUAR` (`KELUAR`),
  KEY `NOPEN` (`NOPEN`),
  KEY `RUANGAN` (`RUANGAN`),
  KEY `MASUK` (`MASUK`),
  KEY `RUANG_KAMAR_TIDUR` (`RUANG_KAMAR_TIDUR`),
  KEY `STATUS` (`STATUS`),
  KEY `FINAL_HASIL` (`FINAL_HASIL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
