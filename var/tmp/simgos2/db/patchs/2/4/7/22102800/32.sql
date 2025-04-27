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
USE `kemkes-sirs`;

-- membuang struktur untuk table kemkes-sirs.rl4b
CREATE TABLE IF NOT EXISTS `rl4b` (
  `object_id` int NOT NULL AUTO_INCREMENT,
  `id` int DEFAULT NULL COMMENT 'ID KEMKES',
  `tahun` year NOT NULL COMMENT '-',
  `no_dtd` char(50) NOT NULL COMMENT '-',
  `no_urut` smallint NOT NULL COMMENT '-',
  `no_daftar_terperinci` varchar(200) NOT NULL COMMENT '-',
  `golongan_sebab_penyakit` varchar(200) NOT NULL COMMENT '-',
  `0-<=6_hari_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_0-<=6_hari_l',
  `0-<=6_hari_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_0-<=6_hari_p',
  `>6-<=28_hari_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>6-<=28_hari_l',
  `>6-<=28_hari_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>6-<=28_hari_p',
  `>28_hari-<=1_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>28_hari-<=1_tahun_l',
  `>28_hari-<=1_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>28_hari-<=1_tahun_p',
  `>1-<=4_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>1-<=4_tahun_l',
  `>1-<=4_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>1-<=4_tahun_p',
  `>4-<=14_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>4-<=14_tahun_l',
  `>4-<=14_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>4-<=14_tahun_p',
  `>14-<=24_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>14-<=24_tahun_l',
  `>14-<=24_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>14-<=24_tahun_p',
  `>24-<=44_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>24-<=44_tahun_l',
  `>24-<=44_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>24-<=44_tahun_p',
  `>44-<=64_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>44-<=64_tahun_l',
  `>44-<=64_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>44-<=64_tahun_p',
  `>64_tahun_l` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>64_tahun_l',
  `>64_tahun_p` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_pasien_kasus_menurut_golongan_umur_dan_sex_>64_tahun_p',
  `kasus_baru_menurut_jenis_kelamain_l` smallint NOT NULL DEFAULT '0' COMMENT 'kasus_baru_menurut_jenis_kelamin_l',
  `kasus_baru_menurut_jenis_kelamain_p` smallint NOT NULL DEFAULT '0' COMMENT 'kasus_baru_menurut_jenis_kelamin_p',
  `jumlah_kasus_baru` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_kasus_baru',
  `jumlah_kunjungan` smallint NOT NULL DEFAULT '0' COMMENT 'jumlah_kunjungan',
  `tanggal_kirim` datetime DEFAULT NULL COMMENT '-',
  `kirim` tinyint NOT NULL DEFAULT '1' COMMENT '-',
  `response` text DEFAULT NULL COMMENT '-',
  PRIMARY KEY (`object_id`) USING BTREE,
  UNIQUE KEY `tahun_no` (`tahun`,`no_dtd`) USING BTREE,
  KEY `kirim` (`kirim`) USING BTREE,
  KEY `ref_id` (`id`) USING BTREE,
  KEY `tanggal_kirim` (`tanggal_kirim`) USING BTREE
) ENGINE=InnoDB;

-- Pengeluaran data tidak dipilih.

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
