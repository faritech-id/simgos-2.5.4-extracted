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

-- membuang struktur untuk table kemkes.rekap_pasien_komorbid
CREATE TABLE IF NOT EXISTS `rekap_pasien_komorbid` (
  `id` int NOT NULL AUTO_INCREMENT,
  `tanggal` date NOT NULL,
  `icu_dengan_ventilator_suspect_l` smallint NOT NULL DEFAULT '0',
  `icu_dengan_ventilator_suspect_p` smallint NOT NULL DEFAULT '0',
  `icu_dengan_ventilator_confirm_l` smallint NOT NULL DEFAULT '0',
  `icu_dengan_ventilator_confirm_p` smallint NOT NULL DEFAULT '0',
  `icu_tanpa_ventilator_suspect_l` smallint NOT NULL DEFAULT '0',
  `icu_tanpa_ventilator_suspect_p` smallint NOT NULL DEFAULT '0',
  `icu_tanpa_ventilator_confirm_l` smallint NOT NULL DEFAULT '0',
  `icu_tanpa_ventilator_confirm_p` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_dengan_ventilator_suspect_l` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_dengan_ventilator_suspect_p` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_dengan_ventilator_confim_l` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_dengan_ventilator_confim_p` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_tanpa_ventilator_suspect_l` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_tanpa_ventilator_suspect_p` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_tanpa_ventilator_confim_l` smallint NOT NULL DEFAULT '0',
  `icu_tekanan_negatif_tanpa_ventilator_confim_p` smallint NOT NULL DEFAULT '0',
  `isolasi_tekanan_negatif_suspect_l` smallint NOT NULL DEFAULT '0',
  `isolasi_tekanan_negatif_suspect_p` smallint NOT NULL DEFAULT '0',
  `isolasi_tekanan_negatif_confirm_l` smallint NOT NULL DEFAULT '0',
  `isolasi_tekanan_negatif_confirm_p` smallint NOT NULL DEFAULT '0',
  `isolasi_tanpa_tekanan_negatif_suspect_l` smallint NOT NULL DEFAULT '0',
  `isolasi_tanpa_tekanan_negatif_suspect_p` smallint NOT NULL DEFAULT '0',
  `isolasi_tanpa_tekanan_negatif_confirm_l` smallint NOT NULL DEFAULT '0',
  `isolasi_tanpa_tekanan_negatif_confirm_p` smallint NOT NULL DEFAULT '0',
  `nicu_khusus_covid_suspect_l` smallint NOT NULL DEFAULT '0',
  `nicu_khusus_covid_suspect_p` smallint NOT NULL DEFAULT '0',
  `nicu_khusus_covid_confirm_l` smallint NOT NULL DEFAULT '0',
  `nicu_khusus_covid_confirm_p` smallint NOT NULL DEFAULT '0',
  `picu_khusus_covid_suspect_l` smallint NOT NULL DEFAULT '0',
  `picu_khusus_covid_suspect_p` smallint NOT NULL DEFAULT '0',
  `picu_khusus_covid_confirm_l` smallint NOT NULL DEFAULT '0',
  `picu_khusus_covid_confirm_p` smallint NOT NULL DEFAULT '0',
  `baru` tinyint NOT NULL DEFAULT '1',
  `tgl_kirim` datetime DEFAULT NULL,
  `kirim` tinyint NOT NULL DEFAULT '0',
  `response` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `tanggal` (`tanggal`) USING BTREE,
  KEY `kirim` (`kirim`) USING BTREE
) ENGINE=InnoDB;

-- Membuang data untuk tabel kemkes.rekap_pasien_komorbid: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `rekap_pasien_komorbid` DISABLE KEYS */;
/*!40000 ALTER TABLE `rekap_pasien_komorbid` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
