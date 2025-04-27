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


-- Dumping database structure for pendaftaran
USE `pendaftaran`;

-- Dumping structure for table pendaftaran.antrian_tempat_tidur
CREATE TABLE  `antrian_tempat_tidur` (
  `ID` int NOT NULL COMMENT '-',
  `NORM` int NOT NULL COMMENT '-',
  `TANGGAL` datetime NOT NULL COMMENT '-',
  `RENCANA_KELAS` smallint NOT NULL COMMENT 'REF-19',
  `RENCANA_KELAS_ALTERNATIF` smallint NOT NULL COMMENT 'REF-19',
  `PRIORITAS` tinyint(1) NOT NULL COMMENT 'REF-158',
  `DIAGNOSA` varchar(250) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '-',
  `DPJP` smallint NOT NULL COMMENT '-',
  `PEMOHON_ID` char(16) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '-',
  `RESERVASI_NOMOR` char(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'Terisi jika status 2',
  `STATUS` tinyint(1) NOT NULL COMMENT 'REF-159',
  PRIMARY KEY (`ID`),
  KEY `NORM_TANGGAL_RESERVASI_NOMOR` (`NORM`,`TANGGAL`,`RESERVASI_NOMOR`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

-- Dumping structure for table pendaftaran.pemohon
CREATE TABLE `pemohon` (
  `ID` int NOT NULL COMMENT '-',
  `NIK` char(16) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '-',
  `NAMA` varchar(150) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '-',
  `ALAMAT` varchar(500) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '-',
  `KONTAK_HP` varchar(35) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT '-',
  `KONTAK_EMAIL` varchar(35) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT '-',
  `BAHASA` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT '-',
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Data exporting was unselected.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
