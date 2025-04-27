-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Server version:               8.0.11 - MySQL Community Server - GPL
-- Server OS:                    Win64
-- HeidiSQL Version:             11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE inventory;

-- Dumping structure for table inventory.no_seri_barang_ruangan
CREATE TABLE IF NOT EXISTS `no_seri_barang_ruangan` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `BARANG_RUANGAN` int(11) NOT NULL,
  `NO_SERI` varchar(50) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT '1=default; 2=penerimaan dan distribusi (laundry); 3=distribusi (inventory);',
  `KONDISI_BARANG` smallint(6) DEFAULT NULL COMMENT '1=infeksi; 2=non infeksi;',
  PRIMARY KEY (`ID`),
  KEY `BARANG_RUANGAN` (`BARANG_RUANGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
