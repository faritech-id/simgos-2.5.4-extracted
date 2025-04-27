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


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.tindakan_abci
CREATE TABLE IF NOT EXISTS `tindakan_abci` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `AKTIF_BERLEBIHAN_DIRUMAH` smallint NOT NULL DEFAULT '0',
  `MELUKAI_DIRI_TUJUAN_TERTENTU` smallint NOT NULL DEFAULT '0',
  `LESUH_LEMAH_KURANG_AKTIF` smallint NOT NULL DEFAULT '0',
  `AGRESIF_VERBAL_FISIK_ANAK_DEWASA` smallint NOT NULL DEFAULT '0',
  `MENYENDIRI_DARI_ORANG_LAIN` smallint NOT NULL DEFAULT '0',
  `PERGERAKAN_TUBUH_BERULANG_TIDAK_BERTUJUAN` smallint NOT NULL DEFAULT '0',
  `RAMA_BERISIK_TANPA_ALASAN` smallint NOT NULL DEFAULT '0',
  `BERTERIAK_TANPA_ALASAN` smallint NOT NULL DEFAULT '0',
  `BANYAK_BICARA` smallint NOT NULL DEFAULT '0',
  `TEMPER_TANTRUM` smallint NOT NULL DEFAULT '0',
  `STEREOTIPLIK_TIDAK_NORMAL_BERULANG` smallint NOT NULL DEFAULT '0',
  `MENATAP_LANGIT` smallint NOT NULL DEFAULT '0',
  `IMPLUSIF` smallint NOT NULL DEFAULT '0',
  `IRRITABLE` smallint NOT NULL DEFAULT '0',
  `GELISA_TIDAK_DAPAT_DUDUK_DIAM` smallint NOT NULL DEFAULT '0',
  `DOKTER` smallint NOT NULL DEFAULT '0',
  `INTERPRETASI` tinytext,
  `ANJURAN` tinytext,
  `DIBUAT_TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.tindakan_abci: ~0 rows (approximately)
/*!40000 ALTER TABLE `tindakan_abci` DISABLE KEYS */;
/*!40000 ALTER TABLE `tindakan_abci` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
