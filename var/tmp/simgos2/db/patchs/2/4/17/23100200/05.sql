-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk table master.surveilans_penyakit_menular
CREATE TABLE IF NOT EXISTS `surveilans_penyakit_menular` (
  `ID` int(2) DEFAULT NULL,
  `KODE_ICD10` varchar(20) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `DESKRIPSI_PENYAKIT_MENULAR` text CHARACTER SET latin1 COLLATE latin1_swedish_ci,
  KEY `idsurvei` (`ID`) USING BTREE,
  KEY `kode_penyakit` (`KODE_ICD10`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Insert data untuk tabel master.surveilans_penyakit_menular: ~33 rows (lebih kurang)
INSERT INTO `surveilans_penyakit_menular` (`ID`, `KODE_ICD10`, `DESKRIPSI_PENYAKIT_MENULAR`) VALUES
	(1, 'A00.9', 'Kolera'),
	(2, 'A09.9', 'Diare'),
	(3, NULL, 'Diare Berdarah'),
	(4, NULL, 'Tifus Perut Klinis'),
	(5, 'A01.0', 'Tifus Perut Widal Kultur (+)'),
	(6, 'A15.0', 'TB Paru BTA (+)'),
	(7, 'A16.2', 'Tersangka TB Paru'),
	(8, 'A30.1', 'Kusta PB'),
	(9, 'A30.5', 'Kusta MB'),
	(10, 'B05.9', 'Campak'),
	(11, 'A36.9', 'Difteri'),
	(12, 'R05', 'Batuk Rajan'),
	(13, 'B35', 'Tetanus'),
	(14, 'K75.9', 'Hepatitis Klinis'),
	(15, 'B16.9', 'Hepatitis Hbs Ag (+)'),
	(16, 'B18.1', 'Hepatitis Hbs Ag (+)'),
	(17, 'B54', 'Malaria Klinis'),
	(18, 'B51.9', 'Malaria Vivax'),
	(19, 'B50.9', 'Malaria Falsifarum'),
	(20, 'B53.8', 'Malaria Mix'),
	(21, 'A91', 'Demam Berdarah Dengue'),
	(22, 'A90', 'Demam Dengue'),
	(23, 'J18.9', 'Pneumonia'),
	(24, 'A53.9', 'Sifilis'),
	(25, 'A54.9', 'Gonorrhoe'),
	(26, 'A66.9', 'Frambusia'),
	(27, 'B74.9', 'Filariasis'),
	(28, 'J11.1', 'Influenza'),
	(29, 'G04.9', 'Ensefalitis'),
	(30, 'G03.9', 'Meningitis'),
	(31, NULL, 'Influenza Like Illness (ILI)'),
	(32, 'J09', 'Suspek AI'),
	(33, NULL, 'AI');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
