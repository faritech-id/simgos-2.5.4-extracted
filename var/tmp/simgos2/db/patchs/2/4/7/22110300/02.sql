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

-- Membuang struktur basisdata untuk layanan
USE `layanan`;

-- membuang struktur untuk table layanan.status_hasil_pemeriksaan
CREATE TABLE IF NOT EXISTS `status_hasil_pemeriksaan` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `TINDAKAN_MEDIS_ID` char(11) NOT NULL,
  `JENIS` tinyint NOT NULL COMMENT 'REF#74',
  `STATUS_HASIL` tinyint NOT NULL DEFAULT '1' COMMENT 'REF#208',
  `STATUS_PENGIRIMAN_HASIL` tinyint NOT NULL DEFAULT '1' COMMENT 'REF#209',
  `TANGGAL_PENGIRIMAN_HASIL` datetime DEFAULT NULL,
  `PETUGAS_PENGIRIMAN_HASIL` smallint DEFAULT NULL,
  `PPSPH` smallint DEFAULT NULL COMMENT 'Petugas Pencatat Status Pengiriman Hasil',
  `STATUS_PEMERIKSAAN` tinyint NOT NULL DEFAULT '0' COMMENT '0=Belum diperiksa, 1=Sudah diperiksa',
  `TANGGAL_PEMERIKSAAN` tinyint DEFAULT NULL,
  `PETUGAS_PEMERIKSAAN` smallint DEFAULT NULL,
  `PPSP` smallint DEFAULT NULL COMMENT 'Petugas Pencatat Status Pemeriksaan',
  PRIMARY KEY (`ID`),
  KEY `TINDAKAN_MEDIS_ID` (`TINDAKAN_MEDIS_ID`),
  KEY `STATUS_HASIL` (`STATUS_HASIL`),
  KEY `JENIS` (`JENIS`),
  KEY `STATUS_PENGIRIMAN_HASIL` (`STATUS_PENGIRIMAN_HASIL`),
  KEY `STATUS_PEMERIKSAAN` (`STATUS_PEMERIKSAAN`)
) ENGINE=InnoDB;

-- Membuang data untuk tabel layanan.status_hasil_pemeriksaan: ~0 rows (lebih kurang)

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
