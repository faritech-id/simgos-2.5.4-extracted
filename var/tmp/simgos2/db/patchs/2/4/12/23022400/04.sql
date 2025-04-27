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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk table pembayaran.tagihan_klaim
CREATE TABLE IF NOT EXISTS `tagihan_klaim` (
  `ID` bigint NOT NULL AUTO_INCREMENT,
  `TAGIHAN` char(10) NOT NULL,
  `NORM` int NOT NULL,
  `NOPEN` char(10) NOT NULL,
  `MASUK` datetime NOT NULL,
  `KELUAR` datetime DEFAULT NULL,
  `TANGGAL_FINAL` datetime NOT NULL COMMENT 'Tanggal Final Tagihan',
  `PENJAMIN` smallint NOT NULL,
  `JENIS` tinyint NOT NULL DEFAULT '1' COMMENT '1=Non Piutang; 2=Piutang Perusahaan',
  `TOTAL` decimal(60,2) NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '0' COMMENT '0=Belum Klaim; 1=Sudah Klaim',
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE KEY `TAGIHAN_PENJAMIN_JENIS` (`TAGIHAN`,`PENJAMIN`,`JENIS`) USING BTREE,
  KEY `NORM` (`NORM`) USING BTREE,
  KEY `PENDAFTARAN_ID` (`NOPEN`) USING BTREE,
  KEY `MASUK` (`MASUK`) USING BTREE,
  KEY `KELUAR` (`KELUAR`) USING BTREE,
  KEY `PENJAMIN` (`PENJAMIN`) USING BTREE,
  KEY `JENIS` (`JENIS`) USING BTREE,
  KEY `STATUS` (`STATUS`) USING BTREE,
  KEY `FINAL_TAGIHAN` (`TANGGAL_FINAL`) USING BTREE,
  KEY `TAGIHAN` (`TAGIHAN`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
