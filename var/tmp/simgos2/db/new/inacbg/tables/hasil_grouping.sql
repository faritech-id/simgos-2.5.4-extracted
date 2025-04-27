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

-- membuang struktur untuk table inacbg.hasil_grouping
DROP TABLE IF EXISTS `hasil_grouping`;
CREATE TABLE IF NOT EXISTS `hasil_grouping` (
  `NOPEN` char(10) NOT NULL COMMENT 'Nomor Pendaftaran',
  `NOSEP` char(25) NOT NULL COMMENT 'Nomor SEP',
  `CODECBG` char(25) NOT NULL COMMENT 'Code Ina-CBG',
  `TARIFCBG` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Ina-CBG',
  `TARIFSP` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Special Procedure',
  `TARIFSR` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Special Prosthesis',
  `TARIFSI` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Special Investigation',
  `TARIFSD` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Special Drug',
  `TARIFSA` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Kode Sub Akut',
  `TARIFSC` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Kode Chronic',
  `TARIFKLS1` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Kelas 1',
  `TARIFKLS2` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Kelas 2',
  `TARIFKLS3` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif Kelas 3',
  `TOTALTARIF` int(11) NOT NULL DEFAULT '0' COMMENT 'Total Tarif INACBG',
  `TARIFRS` int(11) NOT NULL DEFAULT '0' COMMENT 'Tarif RS',
  `UNUSR` char(25) NOT NULL DEFAULT 'None' COMMENT 'Special Prosthesis',
  `UNUSI` char(25) NOT NULL DEFAULT 'None' COMMENT 'Special Investigation',
  `UNUSP` char(25) NOT NULL DEFAULT 'None' COMMENT 'Special Procedure',
  `UNUSD` char(25) NOT NULL DEFAULT 'None' COMMENT 'Special Drug',
  `UNUSA` char(25) NOT NULL DEFAULT 'None' COMMENT 'Kode Sub Akut',
  `UNUSC` char(25) NOT NULL DEFAULT 'None' COMMENT 'Kode Chronic',
  `TANGGAL` datetime NOT NULL COMMENT 'Tanggal',
  `USER` smallint(6) NOT NULL COMMENT 'User',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT '0=Normal, 1=Final',
  `TIPE` tinyint(4) NOT NULL DEFAULT '1',
  `DC_KEMKES` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Status Kirim Ke Data Center Kemkes',
  `DC_BPJS` tinyint(4) NOT NULL DEFAULT '0' COMMENT 'Status Kirim Ke Data Center BPJS',
  `RESPONSE` text,
  `INA_GROUPER_MDC_NUMBER` CHAR(4) NULL DEFAULT NULL,
	`INA_GROUPER_MDC_DESCRIPTION` VARCHAR(1000) NULL DEFAULT NULL,
	`INA_GROUPER_DRG_CODE` CHAR(10) NULL DEFAULT NULL,
	`INA_GROUPER_DRG_DESCRIPTION` VARCHAR(1000) NULL DEFAULT NULL,
  `TOP_UP_RAWAT_GROSS` INT NOT NULL DEFAULT '0',
	`TOP_UP_RAWAT_FACTOR` DECIMAL(10,2) NOT NULL DEFAULT 0,
	`TOP_UP_RAWAT` INT NOT NULL DEFAULT 0,
	`TOP_UP_JENAZAH` INT NOT NULL DEFAULT 0,
  `COVID_19_DESCRIPTION` VARCHAR(500) NULL,
  PRIMARY KEY (`NOPEN`),
  KEY `CODECBG` (`CODECBG`),
  KEY `NOSEP` (`NOSEP`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
