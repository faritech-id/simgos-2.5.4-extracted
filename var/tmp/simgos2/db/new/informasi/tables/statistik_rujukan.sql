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

-- membuang struktur untuk table informasi.statistik_rujukan
DROP TABLE IF EXISTS `statistik_rujukan`;
CREATE TABLE IF NOT EXISTS `statistik_rujukan` (
  `TANGGAL` date NOT NULL,
  `REF_ID_KEMKES` char(50) NOT NULL,
  `MASUK` smallint(6) NOT NULL DEFAULT '0',
  `KELUAR` smallint(6) NOT NULL DEFAULT '0',
  `BALIK` smallint(6) NOT NULL DEFAULT '0',
  `TANGGAL_UPDATED` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `KIRIM` tinyint(4) NOT NULL DEFAULT '1',
  PRIMARY KEY (`TANGGAL`),
  KEY `REF_ID_KEMKES` (`REF_ID_KEMKES`),
  KEY `TANGGAL_UPDATED` (`TANGGAL_UPDATED`),
  KEY `KIRIM` (`KIRIM`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
