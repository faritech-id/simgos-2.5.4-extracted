-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.33 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.1.0.6116
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.pemeriksaan_saluran_cernah_bawah
CREATE TABLE IF NOT EXISTS `pemeriksaan_saluran_cernah_bawah` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `ADA_KELAINAN` tinyint NOT NULL DEFAULT '0',
  `RASA_TIDAK_ENAK` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `RASA_PANAS` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `RASA_MELILIT` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `BIASA` tinyint NOT NULL DEFAULT '0' COMMENT '1. SUBTERNAL 2. EPIGASTRIUM 3. SELURUH PERUT 4. NYERI HIPOKONDRIUM KIRI 5. NYERI HIPOKONDRIUM KANAN',
  `LOKALISASI` text NOT NULL,
  `BERHUBUNGAN_DENGAN_MAKAN` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `BANGUN_TENGAH_MALAM_KARENA_NYERI` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `KEMBUNG` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `CEPAT_KENYANG` tinyint NOT NULL DEFAULT '0' COMMENT '0. Tidak, 1. Ya',
  `DESKRIPSI` text NOT NULL,
  `TANGGAL` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` smallint NOT NULL DEFAULT '0',
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `STATUS` (`STATUS`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.pemeriksaan_saluran_cernah_bawah: ~0 rows (approximately)
/*!40000 ALTER TABLE `pemeriksaan_saluran_cernah_bawah` DISABLE KEYS */;
/*!40000 ALTER TABLE `pemeriksaan_saluran_cernah_bawah` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
