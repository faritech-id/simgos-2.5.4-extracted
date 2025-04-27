-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk kemkes-sirs
USE `kemkes-sirs`;

-- membuang struktur untuk table kemkes-sirs.rl3-1
CREATE TABLE IF NOT EXISTS `rl3-1` (
  `object_id` int NOT NULL AUTO_INCREMENT,
  `id` int DEFAULT NULL COMMENT 'ID KEMKES',
  `tahun` year NOT NULL COMMENT '-',
  `no` smallint NOT NULL COMMENT '-',
  `jenis_pelayanan` varchar(200) NOT NULL COMMENT '-',
  `pasien_awal_tahun` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `pasien_masuk` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `pasien_keluar_hidup` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `kurang_48_jam` smallint NOT NULL DEFAULT '0' COMMENT '<_48_jam',
  `lebih_48_jam` smallint NOT NULL DEFAULT '0' COMMENT '>=_48_jam',
  `jumlah_lama_dirawat` mediumint NOT NULL DEFAULT '0' COMMENT '-',
  `pasien_akhir_tahun` mediumint NOT NULL DEFAULT '0' COMMENT '-',
  `jumlah_hari_perawatan` mediumint NOT NULL DEFAULT '0' COMMENT '-',
  `vvip` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `vip` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `i` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `ii` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `iii` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `kelas_khusus` smallint NOT NULL DEFAULT '0' COMMENT '-',
  `tanggal_kirim` datetime DEFAULT NULL COMMENT '-',
  `kirim` tinyint NOT NULL DEFAULT '1' COMMENT '-',
  `response` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT '-',
  PRIMARY KEY (`object_id`) USING BTREE,
  UNIQUE KEY `tahun_no` (`tahun`,`no`) USING BTREE,
  KEY `kirim` (`kirim`) USING BTREE,
  KEY `ref_id` (`id`) USING BTREE,
  KEY `tanggal_kirim` (`tanggal_kirim`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
