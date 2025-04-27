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

-- membuang struktur untuk table kemkes.rekap_pasien_masuk
CREATE TABLE IF NOT EXISTS `rekap_pasien_masuk` (
  `tanggal` date NOT NULL,
  `igd_suspect_l` smallint NOT NULL DEFAULT '0',
  `igd_suspect_p` smallint NOT NULL DEFAULT '0',
  `igd_confirm_l` smallint NOT NULL DEFAULT '0',
  `igd_confirm_p` smallint NOT NULL DEFAULT '0',
  `rj_suspect_l` smallint NOT NULL DEFAULT '0',
  `rj_suspect_p` smallint NOT NULL DEFAULT '0',
  `rj_confirm_l` smallint NOT NULL DEFAULT '0',
  `rj_confirm_p` smallint NOT NULL DEFAULT '0',
  `ri_suspect_l` smallint NOT NULL DEFAULT '0',
  `ri_suspect_p` smallint NOT NULL DEFAULT '0',
  `ri_confirm_l` smallint NOT NULL DEFAULT '0',
  `ri_confirm_p` smallint NOT NULL DEFAULT '0',
  `baru` tinyint NOT NULL DEFAULT '1',
  `tgl_kirim` datetime DEFAULT NULL,
  `kirim` tinyint NOT NULL DEFAULT '0',
  `response` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`tanggal`),
  KEY `kirim` (`kirim`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Membuang data untuk tabel kemkes.rekap_pasien_masuk: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `rekap_pasien_masuk` DISABLE KEYS */;
/*!40000 ALTER TABLE `rekap_pasien_masuk` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
