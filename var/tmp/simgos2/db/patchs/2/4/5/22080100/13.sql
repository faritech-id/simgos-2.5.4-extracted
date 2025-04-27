-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk lis
CREATE DATABASE IF NOT EXISTS `lis`;
USE `lis`;

-- membuang struktur untuk table lis.lis_tanpa_order_config
CREATE TABLE IF NOT EXISTS `lis_tanpa_order_config` (
  `ID` tinyint NOT NULL AUTO_INCREMENT,
  `RUANGAN_LAB` char(10) NOT NULL,
  `DOKTER_LAB` smallint NOT NULL COMMENT 'Dokter Id',
  `ANALIS_LAB` smallint NOT NULL COMMENT 'Perawat Id',
  `AUTO_FINAL_HASIL_GDS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB COMMENT='Hanya 1 config tanpa order';

-- Pengeluaran data tidak dipilih.

REPLACE INTO `lis_tanpa_order_config` (`ID`, `RUANGAN_LAB`, `DOKTER_LAB`, `ANALIS_LAB`, `AUTO_FINAL_HASIL_GDS`) VALUES (1, '', 0, 0, 1);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
