-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk penjamin_rs
USE `penjamin_rs`;

-- membuang struktur untuk table penjamin_rs.cara_keluar
CREATE TABLE IF NOT EXISTS `cara_keluar` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `PENJAMIN` int NOT NULL,
  `KODE_PENJAMIN` char(2) NOT NULL DEFAULT '',
  `KODE_RS` smallint NOT NULL DEFAULT '0',
  `TANGGAL` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `STATUS` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`,`PENJAMIN`) USING BTREE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1 COMMENT='Cara Keluar Pasien / Pulang';

-- Membuang data untuk tabel penjamin_rs.cara_keluar: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `cara_keluar` DISABLE KEYS */;
REPLACE INTO `cara_keluar` (`ID`, `PENJAMIN`, `KODE_PENJAMIN`, `KODE_RS`, `TANGGAL`, `STATUS`) VALUES
	(1, 2, '1', 1, '2021-12-05 11:30:28', 1),
	(2, 2, '3', 2, '2021-12-05 11:31:44', 1),
	(3, 2, '3', 4, '2021-12-05 11:35:29', 1),
	(4, 2, '4', 6, '2021-12-05 11:36:31', 1),
	(5, 2, '4', 7, '2021-12-05 11:36:40', 1),
	(6, 2, '5', 3, '2021-12-05 11:37:05', 1),
	(7, 2, '5', 5, '2021-12-05 11:37:16', 1);
/*!40000 ALTER TABLE `cara_keluar` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
