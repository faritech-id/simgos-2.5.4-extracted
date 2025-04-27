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
CREATE DATABASE IF NOT EXISTS `kemkes-sirs` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `kemkes-sirs`;

-- membuang struktur untuk table kemkes-sirs.rl1-2
CREATE TABLE IF NOT EXISTS `rl1-2` (
  `object_id` int NOT NULL AUTO_INCREMENT,
  `id` int DEFAULT NULL COMMENT 'ID KEMKES',
  `tahun` year NOT NULL,
  `bor` decimal(10,2) NOT NULL,
  `los` decimal(10,2) NOT NULL,
  `bto` decimal(10,2) NOT NULL,
  `toi` decimal(10,2) NOT NULL,
  `ndr` decimal(10,2) NOT NULL,
  `gdr` decimal(10,2) NOT NULL,
  `ratakunjungan` decimal(10,2) NOT NULL,
  `tanggal_kirim` datetime DEFAULT NULL,
  `kirim` tinyint NOT NULL DEFAULT '1',
  `response` text,
  PRIMARY KEY (`object_id`),
  UNIQUE KEY `tahun` (`tahun`),
  KEY `kirim` (`kirim`),
  KEY `ref_id` (`id`) USING BTREE,
  KEY `tanggal_kirim` (`tanggal_kirim`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
