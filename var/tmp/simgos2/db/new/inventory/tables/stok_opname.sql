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

-- membuang struktur untuk table inventory.stok_opname
DROP TABLE IF EXISTS `stok_opname`;
CREATE TABLE IF NOT EXISTS `stok_opname` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `RUANGAN` char(10) NOT NULL,
  `TANGGAL` date NOT NULL COMMENT 'Tanggal Stok Opname utk mengambil stok akhir',
  `TANGGAL_DIBUAT` datetime NOT NULL COMMENT 'Tanggal Dibuat Stok Opname',
  `KETERANGAN` varchar(500) NOT NULL COMMENT 'Deskripsi / Alasan dll',
  `OLEH` smallint(6) NOT NULL,
  `STATUS` enum('Batal','Proses','Final') NOT NULL DEFAULT 'Proses',
  PRIMARY KEY (`ID`),
  KEY `TAHUN` (`TANGGAL`),
  KEY `RUANGAN` (`RUANGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
