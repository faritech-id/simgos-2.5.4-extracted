USE `layanan`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for table layanan.telaah_awal_resep
CREATE TABLE IF NOT EXISTS `telaah_awal_resep` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `JENIS` tinyint NOT NULL DEFAULT '1' COMMENT '1=Telaah Awal, 2=Telaah Akhir',
  `RESEP` char(21) NOT NULL COMMENT 'ID tabel order_resep (Jika Jenis = 1), No.Kunjungan (Jika Jenis-2)',
  `REF_TELAAH` int NOT NULL COMMENT 'Ref Jenis = 210',
  `STATUS` smallint DEFAULT '1',
  `OLEH` smallint NOT NULL,
  `INPUT_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `UPDATE_TIME` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`ID`),
  UNIQUE KEY `RESEP_REF_TELAAH` (`RESEP`,`REF_TELAAH`,`JENIS`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
