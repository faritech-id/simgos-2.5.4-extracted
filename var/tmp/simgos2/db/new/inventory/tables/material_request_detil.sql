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

-- membuang struktur untuk table inventory.material_request_detil
DROP TABLE IF EXISTS `material_request_detil`;
CREATE TABLE IF NOT EXISTS `material_request_detil` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `NO_MR` char(15) NOT NULL,
  `BARANG` int(11) NOT NULL COMMENT 'Barang Ruangan',
  `KATEGORI` char(1) NOT NULL COMMENT 'A / B / C',
  `SISA_STOK` decimal(10,2) DEFAULT NULL COMMENT 'Sisa Stok Per Periode Perencanaan',
  `RATAPENJUALAN` decimal(10,2) DEFAULT NULL COMMENT 'Rata-Rata Jumlah Barang Keluar Per Periode',
  `JML_RUMUS` decimal(10,2) DEFAULT NULL,
  `JUMLAH` decimal(10,2) DEFAULT NULL,
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `STATUS` int(1) NOT NULL DEFAULT '1' COMMENT '0=Proses,1 = OK, 2=Akan Dibuatkan PO',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
