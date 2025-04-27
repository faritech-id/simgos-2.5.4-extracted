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

-- membuang struktur untuk table generator.no_kunjungan
DROP TABLE IF EXISTS `no_kunjungan`;
CREATE TABLE IF NOT EXISTS `no_kunjungan` (
  `RUANGAN` char(10) NOT NULL,
  `TANGGAL` date NOT NULL,
  `NOMOR` smallint(6) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`RUANGAN`,`TANGGAL`,`NOMOR`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 COMMENT='REF\r\n = Kunjungan\r\n10 = Konsul\r\n11 = Mutasi\r\n12 = Lab\r\n13 = Rad\r\n14 = Resep';

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
