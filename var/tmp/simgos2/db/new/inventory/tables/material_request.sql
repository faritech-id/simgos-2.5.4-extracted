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

-- membuang struktur untuk table inventory.material_request
DROP TABLE IF EXISTS `material_request`;
CREATE TABLE IF NOT EXISTS `material_request` (
  `NO_MR` char(50) NOT NULL,
  `TANGGAL` date NOT NULL,
  `RUMUS_KATEGORI_A` int(10) NOT NULL COMMENT 'ID RUMUS_PERENCANAAN KATEGORI A',
  `RUMUS_KATEGORI_B` int(10) NOT NULL COMMENT 'ID RUMUS_PERENCANAAN KATEGORI B',
  `RUMUS_KATEGORI_C` int(10) NOT NULL COMMENT 'ID RUMUS_PERENCANAAN KATEGORI C',
  `STATUS` int(1) NOT NULL DEFAULT '1' COMMENT '1=Proses, 2=Selesai, 3=sudah di terima ULP,0=Di Batalkan',
  `OLEH` int(11) NOT NULL,
  `UPDATE_TIME` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`NO_MR`),
  KEY `RUMUS_PERENCANAAN` (`RUMUS_KATEGORI_A`),
  KEY `RUMUS_KATEGORI_B` (`RUMUS_KATEGORI_B`),
  KEY `RUMUS_KATEGORI_C` (`RUMUS_KATEGORI_C`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
