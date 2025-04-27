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

-- membuang struktur untuk table lis.flag_lis
CREATE TABLE IF NOT EXISTS `flag_lis` (
  `ID` SMALLINT NOT NULL AUTO_INCREMENT,
  `VENDOR_ID` tinyint NOT NULL,
  `KODE` char(5) NOT NULL,
  `DESKRIPSI` varchar(100) NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `VENDOR_ID_KODE` (`VENDOR_ID`,`KODE`)
) ENGINE=InnoDB AUTO_INCREMENT=6;

-- Membuang data untuk tabel lis.flag_lis: ~0 rows (lebih kurang)
REPLACE INTO `flag_lis` (`ID`, `VENDOR_ID`, `KODE`, `DESKRIPSI`, `STATUS`) VALUES
	(1, 2, '', 'Tidak Diketahui', 1),
	(2, 2, 'L', 'Rendah', 1),
	(3, 2, 'N', 'Normal', 1),
	(4, 2, 'H', 'Tinggi', 1),
	(5, 2, 'HH', 'Tinggi Sekali', 1);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
