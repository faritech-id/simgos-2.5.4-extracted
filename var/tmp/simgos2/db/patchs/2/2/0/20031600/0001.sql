-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk table medicalrecord.permasalahan_gizi
CREATE TABLE IF NOT EXISTS `permasalahan_gizi` (
  `ID` int(11) NOT NULL AUTO_INCREMENT,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `BERAT_BADAN_SIGNIFIKAN` int(1) NOT NULL COMMENT '"Ya (1)" "TIdak (0)"',
  `PERUBAHAN_BERAT_BADAN` int(1) NOT NULL COMMENT '"0,5-5 kg (1)", ">5-10 kg (2)", ">10-15 kg (3)", ">15 kg (4)"',
  `INTAKE_MAKANAN` int(1) NOT NULL COMMENT '"Ya (1)" "Tidak Dalam 3 hari terakhir (0)"',
  `KONDISI_KHUSUS` text NOT NULL,
  `SKOR` int(2) NOT NULL,
  `STATUS_SKOR` int(1) NOT NULL COMMENT '"Ya (skor â‰¥ 2) (1)" "Tidak(0)"',
  `TANGGAL` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `OLEH` int(11) NOT NULL,
  `STATUS` int(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ID`),
  UNIQUE KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `OLEH` (`OLEH`),
  KEY `STATUS` (`STATUS`),
  CONSTRAINT `` FOREIGN KEY (`KUNJUNGAN`) REFERENCES `pendaftaran`.`kunjungan` (`nomor`),
  CONSTRAINT `FK_permasalahan_gizi_pasien_pendaftaran.kunjungan` FOREIGN KEY (`KUNJUNGAN`) REFERENCES `pendaftaran`.`kunjungan` (`nomor`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COMMENT='Anamnesis:';

-- Membuang data untuk tabel medicalrecord.permasalahan_gizi: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `permasalahan_gizi` DISABLE KEYS */;
/*!40000 ALTER TABLE `permasalahan_gizi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
