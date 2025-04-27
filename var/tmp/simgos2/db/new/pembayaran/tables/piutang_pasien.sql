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

-- membuang struktur untuk table pembayaran.piutang_pasien
DROP TABLE IF EXISTS `piutang_pasien`;
CREATE TABLE IF NOT EXISTS `piutang_pasien` (
  `TAGIHAN` char(10) NOT NULL,
  `NAMA` varchar(75) NOT NULL,
  `SHDK` tinyint(4) NOT NULL,
  `NO_KARTU_IDENTITAS` varchar(16) NOT NULL,
  `JENIS_KARTU` tinyint(4) NOT NULL,
  `ALAMAT_KARTU` varchar(150) NOT NULL,
  `ALAMAT_TEMPAT_TINGGAL` varchar(150) NOT NULL,
  `TELEPON` varchar(35) NOT NULL,
  `ALASAN` varchar(250) NOT NULL,
  `TANGGAL` datetime NOT NULL,
  `TOTAL` decimal(60,2) NOT NULL,
  `JENIS_PEMBAYARAN` tinyint(4) NOT NULL COMMENT '1=Bayar Sekaligus; 2=Angsuran',
  `LAMA_ANGSURAN` tinyint(4) NOT NULL DEFAULT '12',
  `BESAR_ANGSURAN` decimal(60,2) NOT NULL,
  `OLEH` smallint(6) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`TAGIHAN`),
  KEY `JENIS_KARTU` (`JENIS_KARTU`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `SHDK` (`SHDK`),
  KEY `NO_KARTU_IDENTITAS` (`NO_KARTU_IDENTITAS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
