-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk table pembayaran.penjamin_tagihan
DROP TABLE IF EXISTS `penjamin_tagihan`;
CREATE TABLE IF NOT EXISTS `penjamin_tagihan` (
  `TAGIHAN` char(10) NOT NULL,
  `PENJAMIN` smallint(10) NOT NULL,
  `KE` tinyint(4) NOT NULL DEFAULT '1',
  `TOTAL` decimal(60,2) NOT NULL COMMENT 'Total Jaminan Hak',
  `TOTAL_NAIK_KELAS` decimal(60,2) NOT NULL COMMENT 'Total Naik AUTO_INCREMENT=23 Kelas Non VIP',
  `NAIK_KELAS` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Naik Kelas Non VIP',
  `NAIK_KELAS_VIP` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Naik Kelas VIP',
  `NAIK_DIATAS_VIP` tinyint(4) NOT NULL DEFAULT '0',
  `KELAS` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Kelas Naik',
  `LAMA_NAIK` smallint(6) NOT NULL DEFAULT '0' COMMENT 'Lama Naik Kelas',
  `TOTAL_TAGIHAN_HAK` decimal(60,2) NOT NULL COMMENT 'Total Tagihan Hak',
  `TARIF_INACBG_KELAS1` decimal(60,2) NOT NULL,
  `SUBSIDI_TAGIHAN` int(11) NOT NULL,
  `SELISIH_MINIMAL` decimal(60,2) DEFAULT '0.00' COMMENT 'Minimal penambahan/Selisih',
  `KELAS_KLAIM` tinyint(4) NOT NULL DEFAULT '0',
  `PERSENTASE_TARIF_INACBG_KELAS1` decimal(10,2) NOT NULL DEFAULT '0.00' COMMENT 'Max 75 persen',
  PRIMARY KEY (`TAGIHAN`,`PENJAMIN`),
  KEY `SUBSIDI_TAGIHAN` (`SUBSIDI_TAGIHAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
