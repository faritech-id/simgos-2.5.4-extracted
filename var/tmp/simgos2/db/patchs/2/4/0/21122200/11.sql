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

-- Membuang struktur basisdata untuk bpjs
USE `bpjs`;

-- membuang struktur untuk table bpjs.jenis_referensi
CREATE TABLE IF NOT EXISTS `jenis_referensi` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `deskripsi` varchar(45) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE=InnoDB;

-- Membuang data untuk tabel bpjs.jenis_referensi: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `jenis_referensi` DISABLE KEYS */;
REPLACE INTO `jenis_referensi` (`id`, `deskripsi`) VALUES
	(1, 'Jenis Kelamin'),
	(2, 'Jenis Peserta'),
	(3, 'Kelas'),
	(4, 'Status Peserta'),
	(5, 'Provider'),
	(6, 'Pembiayaan'),
	(7, 'Tujuan Kunjungan'),
	(8, 'Procedure'),
	(9, 'Penunjang'),
	(10, 'Assesment Pelayanan'),
	(11, 'Kelas Naik'),
	(12, 'Status Pulang / Cara Pulang / Cara Keluar');
/*!40000 ALTER TABLE `jenis_referensi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
