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

-- membuang struktur untuk table pendaftaran.pendaftaran
DROP TABLE IF EXISTS `pendaftaran`;
CREATE TABLE IF NOT EXISTS `pendaftaran` (
  `NOMOR` char(10) NOT NULL COMMENT 'yymmdd9999',
  `NORM` int(11) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `DIAGNOSA_MASUK` int(6) DEFAULT NULL COMMENT 'Diagnosa Masuk',
  `RUJUKAN` varchar(25) DEFAULT NULL,
  `PAKET` smallint(6) DEFAULT NULL,
  `BERAT_BAYI` mediumint(9) DEFAULT NULL,
  `PANJANG_BAYI` mediumint(9) DEFAULT NULL,
  `OLEH` smallint(6) NOT NULL COMMENT 'Pengguna / Pencatat / Petugas',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status 0 = Batal / Non Aktif 1 = Aktif',
  PRIMARY KEY (`NOMOR`),
  KEY `NORM` (`NORM`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `STATUS` (`STATUS`),
  KEY `DIAGNOSA_MASUK` (`DIAGNOSA_MASUK`),
  KEY `RUJUKAN` (`RUJUKAN`),
  KEY `PAKET` (`PAKET`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Pendaftaran / Penerimaan';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
