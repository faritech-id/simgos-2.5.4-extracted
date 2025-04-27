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

-- membuang struktur untuk table aplikasi.modules
DROP TABLE IF EXISTS `modules`;
CREATE TABLE IF NOT EXISTS `modules` (
  `ID` char(20) NOT NULL,
  `NAMA` varchar(50) NOT NULL,
  `LEVEL` tinyint(4) NOT NULL DEFAULT '1',
  `DESKRIPSI` varchar(150) NOT NULL,
  `STATUS` tinyint(4) NOT NULL DEFAULT '1',
  `CLASS` varchar(150) DEFAULT NULL,
  `ICON_CLS` varchar(75) DEFAULT NULL,
  `HAVE_CHILD` tinyint(4) NOT NULL DEFAULT '0',
  `MENU_HOME` TINYINT(4) NOT NULL DEFAULT '0',
  `PACKAGE_NAME` VARCHAR(50) DEFAULT NULL,
  `INTERNAL_PACKAGE` TINYINT NOT NULL DEFAULT '1',
  `CRUD` TINYINT(4) NOT NULL DEFAULT '0' COMMENT '0=Non Aktif; 1=Aktif',
  `C` TINYINT(4) NOT NULL DEFAULT '0',
  `R` TINYINT(4) NOT NULL DEFAULT '0',
  `U` TINYINT(4) NOT NULL DEFAULT '0',
  `D` TINYINT(4) NOT NULL DEFAULT '0',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
