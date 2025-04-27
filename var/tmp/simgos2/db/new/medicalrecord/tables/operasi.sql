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

-- membuang struktur untuk table medicalrecord.operasi
DROP TABLE IF EXISTS `operasi`;
CREATE TABLE IF NOT EXISTS `operasi` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) NOT NULL,
  `DOKTER` smallint(6) NOT NULL COMMENT 'Dokter Operator',
  `ASISTEN_DOKTER` varchar(75) NOT NULL COMMENT 'Asisten Dokter Operator',
  `ANASTESI` smallint(6) NOT NULL COMMENT 'Dokter Anastesi',
  `ASISTEN_ANASTESI` varchar(75) NOT NULL COMMENT 'Asisten Dokter Anastesi / Perawat',
  `JENIS_ANASTESI` tinyint(4) NOT NULL COMMENT 'Jenis Anastesi (Jenis Referensi=52)',
  `GOLONGAN_OPERASI` tinyint(4) NOT NULL COMMENT 'Golongan Operasi (Jenis Referensi=53)',
  `JENIS_OPERASI` tinyint(4) NOT NULL COMMENT 'Jenis Operasi (Jenis Referensi=87)',
  `PRA_BEDAH` varchar(50) NOT NULL COMMENT 'Diagnosa Pra Bedah',
  `PASCA_BEDAH` varchar(50) NOT NULL COMMENT 'Diagnosa Pasca Bedah',
  `INDIKASI` varchar(50) NOT NULL COMMENT 'Indikasi Operasi',
  `NAMA_OPERASI` varchar(50) NOT NULL COMMENT 'Nama Operasi',
  `PA` tinyint(4) NOT NULL COMMENT 'Pemeriksaan PA (1=Ya,2=Tidak)',
  `JARINGAN_DIEKSISI` varchar(50) NOT NULL COMMENT 'Jaringan Yg Dieksisi',
  `TANGGAL` date NOT NULL COMMENT 'Tanggal Operasi',
  `WAKTU_MULAI` time NOT NULL COMMENT 'Waktu Mulai Operasi',
  `WAKTU_SELESAI` time NOT NULL COMMENT 'Waktu Selesai Operasi',
  `DURASI` time NOT NULL COMMENT 'Durasi Operasi',
  `KOMPLIKASI` varchar(50) NOT NULL COMMENT 'Komplikasi Operasi',
  `PERDARAHAN` varchar(15) NOT NULL COMMENT 'Jumlah Perdarahan',
  `RUANGAN_PASCA_OPERASI` varchar(50) NOT NULL COMMENT 'Perawatan Pasca Operasi',
  `LAPORAN_OPERASI` text NOT NULL COMMENT 'Laporan Operasi',
  `DIBUAT_TANGGAL` datetime NOT NULL COMMENT 'Dibuat Tanggal',
  `OLEH` smallint(6) NOT NULL COMMENT 'Dibuat Oleh',
  `STATUS` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Status',
  PRIMARY KEY (`ID`),
  KEY `TANGGAL` (`TANGGAL`),
  KEY `STATUS` (`STATUS`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
