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

-- membuang struktur untuk table layanan.order_resep
DROP TABLE IF EXISTS `order_resep`;
CREATE TABLE IF NOT EXISTS `order_resep` (
  `NOMOR` char(21) NOT NULL,
  `KUNJUNGAN` char(19) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `DOKTER_DPJP` smallint(6) NOT NULL,
  `PEMBERI_RESEP` varchar(100) NOT NULL,
  `BERAT_BADAN` decimal(10,2) NOT NULL,
  `TINGGI_BADAN` decimal(10,2) NOT NULL,
  `DIAGNOSA` varchar(250) NOT NULL,
  `ALERGI_OBAT` varchar(250) NOT NULL,
  `GANGGUAN_FUNGSI_GINJAL` tinyint(4) NOT NULL DEFAULT '0',
  `MENYUSUI` tinyint(4) NOT NULL DEFAULT '0',
  `HAMIL` tinyint(4) NOT NULL DEFAULT '0',
  `RESEP_PASIEN_PULANG` tinyint(4) NOT NULL DEFAULT '0',
  `TUJUAN` char(10) NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status Order',
  PRIMARY KEY (`NOMOR`),
  KEY `TUJUAN` (`TUJUAN`),
  KEY `DOKTER_ASAL` (`DOKTER_DPJP`),
  KEY `STATUS` (`STATUS`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `TANGGAL` (`TANGGAL`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
