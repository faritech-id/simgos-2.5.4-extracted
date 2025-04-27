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

-- membuang struktur untuk table kemkes.kamar_simrs_rs_online
CREATE TABLE IF NOT EXISTS `kamar_simrs_rs_online` (
  `id` int NOT NULL AUTO_INCREMENT,
  `ruang_kamar` smallint NOT NULL DEFAULT '0' COMMENT 'ruang kamar simrs',
  `tempat_tidur` smallint NOT NULL DEFAULT '0' COMMENT 'tempat tidur rs online',
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `kamar_simrs` (`ruang_kamar`) USING BTREE,
  KEY `status` (`status`),
  KEY `tempat_tidur` (`tempat_tidur`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
