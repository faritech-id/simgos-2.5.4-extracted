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

-- membuang struktur untuk table inventory.purchase_order_detil
DROP TABLE IF EXISTS `purchase_order_detil`;
CREATE TABLE IF NOT EXISTS `purchase_order_detil` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `ID_PO` char(15) NOT NULL,
  `BARANG` int(11) NOT NULL COMMENT 'Barang Ruangan',
  `ID_MR_DETIL` int(11) NOT NULL,
  `ID_SPH` int(11) NOT NULL,
  `JUMLAH` decimal(10,2) NOT NULL,
  `STATUS` int(1) NOT NULL DEFAULT '1',
  `OLEH` smallint(6) NOT NULL,
  `UPDATE_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  KEY `NO_PO` (`ID_PO`),
  KEY `BARANG` (`BARANG`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
