-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for bpjs
USE `bpjs`;

-- Dumping structure for table bpjs.monitoring_rencana_kontrol
CREATE TABLE IF NOT EXISTS `monitoring_rencana_kontrol` (
  `noSuratKontrol` char(50) NOT NULL,
  `jnsKontrol` char(5) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `jnsPelayanan` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `kodeDokter` char(10) DEFAULT NULL,
  `nama` char(250) DEFAULT NULL,
  `namaDokter` char(150) DEFAULT NULL,
  `namaJnsKontrol` char(150) DEFAULT NULL,
  `namaPoliAsal` char(150) DEFAULT NULL,
  `noKartu` char(20) DEFAULT NULL,
  `noSepAsalKontrol` char(50) DEFAULT NULL,
  `nomorreferensi` char(50) DEFAULT NULL,
  `poliAsal` char(50) DEFAULT NULL,
  `poliTujuan` char(50) DEFAULT NULL,
  `terbitSEP` date DEFAULT NULL,
  `tglRencanaKontrol` date DEFAULT NULL,
  `tglTerbitKontrol` date DEFAULT NULL,
  PRIMARY KEY (`noSuratKontrol`),
  KEY `noKartu` (`noKartu`),
  KEY `tglRencanaKontrol` (`tglRencanaKontrol`),
  KEY `noSepAsalKontrol` (`noSepAsalKontrol`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
