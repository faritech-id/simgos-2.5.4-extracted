-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.22 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk kemkes
USE `kemkes`;

-- membuang struktur untuk table kemkes.rekap_pasien_keluar
CREATE TABLE IF NOT EXISTS `rekap_pasien_keluar` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tanggal` date NOT NULL,
  `sembuh` smallint NOT NULL DEFAULT '0',
  `discarded` smallint NOT NULL DEFAULT '0',
  `meninggal_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_pre_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_neo_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_bayi_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_balita_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_anak_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_remaja_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_dws_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_lansia_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_pre_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_neo_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_bayi_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_balita_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_anak_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_remaja_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_dws_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_prob_lansia_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_disarded_komorbid` smallint NOT NULL DEFAULT '0',
  `meninggal_discarded_tanpa_komorbid` smallint NOT NULL DEFAULT '0',
  `dirujuk` smallint NOT NULL DEFAULT '0',
  `isman` smallint NOT NULL DEFAULT '0',
  `aps` smallint NOT NULL DEFAULT '0',
  `baru` tinyint NOT NULL DEFAULT '1',
  `tgl_kirim` datetime DEFAULT NULL,
  `kirim` tinyint NOT NULL DEFAULT '0',
  `response` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `tanggal` (`tanggal`) USING BTREE,
  KEY `kirim` (`kirim`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
