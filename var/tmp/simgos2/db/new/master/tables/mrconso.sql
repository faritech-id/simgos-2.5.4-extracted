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

-- membuang struktur untuk table master.mrconso
DROP TABLE IF EXISTS `mrconso`;
CREATE TABLE IF NOT EXISTS `mrconso` (
  `CUI` char(8) NOT NULL,
  `LAT` char(3) NOT NULL,
  `TS` char(1) NOT NULL,
  `LUI` char(8) NOT NULL,
  `STT` varchar(3) NOT NULL,
  `SUI` char(8) NOT NULL,
  `ISPREF` char(1) NOT NULL,
  `AUI` char(8) NOT NULL,
  `SAUI` varchar(50) DEFAULT NULL,
  `SCUI` varchar(50) DEFAULT NULL,
  `SDUI` varchar(50) DEFAULT NULL,
  `SAB` varchar(20) NOT NULL,
  `TTY` varchar(20) NOT NULL,
  `CODE` varchar(50) NOT NULL,
  `STR` text,
  `SRL` int(11) NOT NULL,
  `SUPPRESS` char(1) NOT NULL,
  `CVF` varchar(50) DEFAULT NULL,
  `VERSION` varchar(15) NOT NULL,
  `VALIDCODE` CHAR(1) NOT NULL DEFAULT '' COMMENT '1=Bisa di pilih',
  `ACCPDX` CHAR(1) NOT NULL DEFAULT '' COMMENT 'Y=Bisa jadi diagnosa utama (utk diagnosa)',
  `CODE_ASTERISK` CHAR(15) NOT NULL DEFAULT '' COMMENT ' (utk diagnosa)',
  `ASTERISK` CHAR(1) NOT NULL DEFAULT '' COMMENT ' (utk diagnosa)',
  `IM` CHAR(1) NOT NULL DEFAULT '' COMMENT 'Indonesian Modification',
  `ICD_TYPE` TINYINT(4) NOT NULL DEFAULT '1' COMMENT '1=Diagnosa; 2=Prosedur',
  KEY `X_MRCONSO_CUI` (`CUI`),
  KEY `X_MRCONSO_AUI` (`AUI`),
  KEY `X_MRCONSO_CODE` (`CODE`),
  KEY `x_sab` (`SAB`),
  KEY `x_tty` (`TTY`(5)),
  FULLTEXT KEY `x_ftstr` (`STR`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
