-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.32 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk table medicalrecord.triage
CREATE TABLE IF NOT EXISTS `triage` (
  `ID` int NOT NULL AUTO_INCREMENT,
  `NORM` int DEFAULT NULL COMMENT 'Identitas',
  `NOPEN` char(10) DEFAULT NULL,
  `KUNJUNGAN` char(19) DEFAULT NULL,
  `NIK` char(16) DEFAULT NULL COMMENT 'Identitas',
  `NAMA` varchar(75) DEFAULT NULL COMMENT 'Identitas',
  `TANGGAL_LAHIR` date DEFAULT NULL COMMENT 'Identitas',
  `JENIS_KELAMIN` tinyint DEFAULT NULL COMMENT 'Identitas',
  `TANGGAL` datetime NOT NULL,
  `KEDATANGAN` json DEFAULT NULL COMMENT '{\r\n   "TANGGAL": "",\r\n   "ALAT_TRANSPORTASI": "",\r\n   "JENIS": "1=Datang Sendiri|2=Rujukan|3=Dikirim Polisi",\r\n   "PENGANTAR": "UTK JENIS=1",\r\n   "ASAL_RUJUKAN": "UTK JENIS=2",\r\n   "SISRUTE": "0=Tidak|1=Ya (UTK JENIS=2)",\r\n   "KEPOLISIAN": "UTK JENIS=3",\r\n   "VISUM": "0=Tidak|1=Ya (UTK JENIS=3)"\r\n}',
  `KASUS` json DEFAULT NULL COMMENT '{\r\n   "JENIS": "0=Non Trauma|1=Trauma",\r\n   "LAKA_LANTAS": "0=Tidak|1=Ya(UTK JENIS=1)",\r\n   "KECELAKAAN_KERJA": "0=Tidak|1=Ya(UTK JENIS=1)",\r\n   "UPPA": "0=Tidak|1=Ya(Kasus Perempuan & Anak(UTK JENIS=0))",\r\n   "ENDEMIS": "0=Tidak|1=Ya(UTK JENIS=0)",\r\n   "DIMANA": "UTK JENIS=0"\r\n}',
  `ANAMNESE` json DEFAULT NULL COMMENT '{\r\n   "KELUHAN_UTAMA": "",\r\n   "TERPIMPIN": ""\r\n}',
  `TANDA_VITAL` json DEFAULT NULL COMMENT '{\r\n   "SISTOLE": "",\r\n   "DIASTOLE": "",\r\n   "FREK_NAFAS": "",\r\n   "FREK_NADI": "",\r\n   "SUHU": "",\r\n   "SKALA_NYERI": "",\r\n   "METODE_UKUR": ""\r\n}',
  `OBGYN` json DEFAULT NULL COMMENT '{\r\n   "USIA_GESTASI": "",\r\n   "DETAK_JANTUNG": "",\r\n   "JANIN": "",\r\n   "KONTRAKSI_UTERUS": "",\r\n   "DILATASI_SERVIKS": ""\r\n}',
  `KEBUTUHAN_KHUSUS` json DEFAULT NULL COMMENT '{\r\n   "AIRBONE": "",\r\n   "DEKONTAMINAN": ""\r\n}',
  `KATEGORI_PEMERIKSAAN` tinyint DEFAULT '1' COMMENT 'REF#222',
  `RESUSITASI` json DEFAULT NULL COMMENT '{\r\n   "CHECKED: 0,\r\n   "JALAN_NAFAS": {\r\n      "SUMBATAN": "0=Tidak|1=Ya"\r\n   },\r\n   "PERNAPASAN": {\r\n      "HENTI_NAFAS": "0=Tidak|1=Ya",\r\n      "FREK_NAFAS_DIBAWAH_10": "0=Tidak|1=Ya",\r\n      "FREK_NAFAS_DIATAS_32": "0=Tidak|1=Ya",\r\n      "SIANOSIS": "0=Tidak|1=Ya",\r\n      "NEONATUS": "0=Tidak|1=Ya",\r\n      "FREK_NAFAS_DIBAWAH_60": "0=Tidak|1=Ya",\r\n      "FREK_NAFAS_DIBAWAH_40": "0=Tidak|1=Ya",\r\n      "FREK_NAFAS_DIATAS_60": "0=Tidak|1=Ya",\r\n      "SIANOSIS SENTRAL_MENETAP_DGN_O2": "0=Tidak|1=Ya"\r\n   },\r\n   "SIRKULASI": {\r\n      "HENTI_JANTUNG": "0=Tidak|1=Ya",\r\n      "NADI_TDK_TERABA": "0=Tidak|1=Ya",\r\n      "FREK_NADI_DIBAWAH_50_DIATAS_100": "0=Tidak|1=Ya",\r\n      "NEONATUS_FREK_NADI_DIBAWAH_60": "0=Tidak|1=Ya",\r\n      "PUCAT": "0=Tidak|1=Ya",\r\n      "AKRAL_DINGIN": "0=Tidak|1=Ya",\r\n      "NEONATUS_CRT_DIATAS_3_DETIK": "0=Tidak|1=Ya"\r\n   },\r\n   "KESADARAN: {\r\n      "GCS_DIBAWAH_9": "0=Tidak|1=Ya",\r\n      "NEONATUS_DIBAWAH_36_KOMA_5_DERAJAT_C": "0=Tidak|1=Ya"\r\n   }\r\n}',
  `EMERGENCY` json DEFAULT NULL COMMENT '{\r\n   "CHECKED: 0,\r\n   "JALAN_NAFAS": {\r\n      "BEBAS": "0=Tidak|1=Ya"\r\n   },\r\n   "PERNAPASAN": {\r\n      "FREK_NAFAS_DIATAS_32": "0=Tidak|1=Ya",\r\n      "WHEEZING": "0=Tidak|1=Ya",\r\n      "NEONATUS_FREK_NAFAS_DIATAS_80_ATAU_DIBAWAH_40": "0=Tidak|1=Ya",\r\n      "SIANOSIS SENTRAL_MENETAP_DGN_O2": "0=Tidak|1=Ya"\r\n   },\r\n   "SIRKULASI": {\r\n      "NADI_TERABA_LEMAH": "0=Tidak|1=Ya",\r\n      "FREK_NADI_DIBAWAH_50": "0=Tidak|1=Ya",\r\n      "FREK_NADI_DIATAS_150": "0=Tidak|1=Ya",\r\n      "NEONATUS_FREK_NADI_DIBAWAH_100": "0=Tidak|1=Ya",\r\n      "PUCAT": "0=Tidak|1=Ya",\r\n      "AKRAL_DINGIN": "0=Tidak|1=Ya",\r\n      "NEONATUS_CRT_DIATAS_3_DETIK": "0=Tidak|1=Ya"\r\n   },\r\n   "KESADARAN: {\r\n      "GCS_9_SD_12": "0=Tidak|1=Ya",\r\n      "PUPIL_UNISOKOR": "0=Tidak|1=Ya",\r\n      "REPLEKS_CAHAYA": "0=Tidak|1=Ya",\r\n      "NEONATUS_DIBAWAH_36_KOMA_5_DERAJAT_C": "0=Tidak|1=Ya"\r\n   }\r\n}',
  `URGENT` json DEFAULT NULL COMMENT '{\r\n   "CHECKED: 0,\r\n   "JALAN_NAFAS": {\r\n      "BEBAS": "0=Tidak|1=Ya"\r\n   },\r\n   "PERNAPASAN": {\r\n      "FREK_NAFAS_24_SD_32": "0=Tidak|1=Ya",\r\n      "WHEEZING": "0=Tidak|1=Ya",\r\n      "NEONATUS_FREK_NAFAS_DIATAS_60": "0=Tidak|1=Ya",\r\n      "SIANOSIS SENTRAL_MENGHILANG_DGN_O2": "0=Tidak|1=Ya"\r\n   },\r\n   "SIRKULASI": {\r\n      "FREK_NADI_120_SD_150": "0=Tidak|1=Ya",\r\n      "NEONATUS_FREK_NADI_DIATAS_160": "0=Tidak|1=Ya",\r\n      "TD_SIST_DIATAS_160": "0=Tidak|1=Ya",\r\n      "TD_DIAST_DIATAS_100": "0=Tidak|1=Ya",\r\n      "NEONATUS_CRT_DIATAS_3_DETIK": "0=Tidak|1=Ya"\r\n   },\r\n   "KESADARAN: {\r\n      "GCS_DIATAS_13": "0=Tidak|1=Ya",\r\n      "PUPIL_UNISOKOR": "0=Tidak|1=Ya",\r\n      "REPLEKS_CAHAYA": "0=Tidak|1=Ya",\r\n      "NEONATUS_DIATAS_37_KOMA_5_ATAU_DIBAWAH_36_KOMA_5_DERAJAT_C": "0=Tidak|1=Ya"\r\n   }\r\n}',
  `LESS_URGENT` json DEFAULT NULL COMMENT '{\r\n   "CHECKED: 0,\r\n   "JALAN_NAFAS": {\r\n      "BEBAS": "0=Tidak|1=Ya"\r\n   },\r\n   "PERNAPASAN": {\r\n      "NORMAL": "0=Tidak|1=Ya"\r\n   },\r\n   "SIRKULASI": {\r\n      "NORMAL": "0=Tidak|1=Ya"\r\n   },\r\n   "KESADARAN: {\r\n      "GCS_15": "0=Tidak|1=Ya",\r\n      "PUPIL_UNISOKOR": "0=Tidak|1=Ya",\r\n      "REPLEKS_CAHAYA": "0=Tidak|1=Ya",\r\n      "NEONATUS_36_KOMA_5_SD_37_KOMA_5_DERAJAT_C": "0=Tidak|1=Ya"\r\n   }\r\n}',
  `NON_URGENT` json DEFAULT NULL COMMENT '{\r\n   "CHECKED: 0,\r\n   "JALAN_NAFAS": {\r\n      "BEBAS": "0=Tidak|1=Ya"\r\n   },\r\n   "PERNAPASAN": {\r\n      "NORMAL": "0=Tidak|1=Ya"\r\n   },\r\n   "SIRKULASI": {\r\n      "NORMAL": "0=Tidak|1=Ya"\r\n   },\r\n   "KESADARAN: {\r\n      "GCS_15": "0=Tidak|1=Ya",\r\n      "PUPIL_UNISOKOR": "0=Tidak|1=Ya",\r\n      "REPLEKS_CAHAYA": "0=Tidak|1=Ya",\r\n      "NEONATUS_36_KOMA_5_SD_37_KOMA_5_DERAJAT_C": "0=Tidak|1=Ya"\r\n   }\r\n}',
  `DOA` json DEFAULT NULL COMMENT '{\r\n   "CHECKED: 0,\r\n   "JALAN_NAFAS": {\r\n      "TIDAK_ADA_NAPAS": "0=Tidak|1=Ya"\r\n   },\r\n   "PERNAPASAN": {\r\n      "TIDAK_ADA_NADI": "0=Tidak|1=Ya"\r\n   },\r\n   "SIRKULASI": {\r\n      "NORMAL": "0=Tidak|1=Ya"\r\n   },\r\n   "KESADARAN: {\r\n      "PUPIL_MIDRIASIS_TOTAL": "0=Tidak|1=Ya",\r\n      "KAKU_MAYAT": "0=Tidak|1=Ya"\r\n   }\r\n}',
  `KRITERIA` varchar(150) DEFAULT NULL,
  `HANDOVER` varchar(150) DEFAULT NULL,
  `PLAN` tinyint DEFAULT NULL COMMENT 'REF#223',
  `OLEH` smallint NOT NULL,
  `TANGGAL_FINAL` datetime DEFAULT NULL,
  `STATUS` tinyint DEFAULT '1' COMMENT '0=Batal;1=Belum Final;2=Sudah Final',
  PRIMARY KEY (`ID`),
  KEY `NORM` (`NORM`),
  KEY `NOPEN` (`NOPEN`),
  KEY `KUNJUNGAN` (`KUNJUNGAN`),
  KEY `NIK` (`NIK`),
  KEY `NAMA` (`NAMA`)
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
