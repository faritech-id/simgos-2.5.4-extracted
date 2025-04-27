-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk bpjs
USE `bpjs`;

-- membuang struktur untuk table bpjs.referensi
CREATE TABLE IF NOT EXISTS `referensi` (
  `id` smallint NOT NULL AUTO_INCREMENT,
  `jenis_referensi_id` smallint NOT NULL,
  `kode` char(5) NOT NULL DEFAULT '',
  `deskripsi` varchar(500) NOT NULL,
  `status` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `jenis_referensi_id_kode` (`jenis_referensi_id`,`kode`)
) ENGINE=InnoDB;

-- Membuang data untuk tabel bpjs.referensi: ~0 rows (lebih kurang)
/*!40000 ALTER TABLE `referensi` DISABLE KEYS */;
REPLACE INTO `referensi` (`id`, `jenis_referensi_id`, `kode`, `deskripsi`, `status`) VALUES
	(1, 1, 'L', 'Laki - laki', 1),
	(2, 1, 'P', 'Perempuan', 1),
	(3, 3, '1', 'Kelas I', 1),
	(4, 3, '2', 'Kelas II', 1),
	(5, 3, '3', 'Kelas III', 1),
	(6, 4, '0', 'Aktif', 1),
	(7, 4, '2', 'Meninggal', 1),
	(8, 4, '6', 'Tidak Ditanggung / Masa Berlaku Sudah Berakhir (Anak Umur > 21)', 1),
	(9, 4, '7', 'Penangguhan Peserta', 1),
	(10, 4, '9', 'Non Aktif Karna Premi', 1),
	(11, 4, '15', 'Non Aktif Diakhir Bulan', 1),
	(12, 6, '1', 'Pribadi', 1),
	(13, 6, '2', 'Pemberi Kerja', 1),
	(14, 6, '3', 'Asuransi Kesehatan Tambahan', 1),
	(15, 7, '0', 'Normal', 1),
	(16, 7, '1', 'Prosedur', 1),
	(17, 7, '2', 'Konsul Dokter', 1),
	(18, 8, '', 'Tidak ada', 1),
	(19, 8, '0', 'Prosedur Tidak Berkelanjutan', 1),
	(20, 8, '1', 'Prosedur dan Terapi Berkelanjutan', 1),
	(21, 9, '', 'Tidak ada', 1),
	(22, 9, '1', 'Radioterapi', 1),
	(23, 9, '2', 'Kemoterapi', 1),
	(24, 9, '3', 'Rehabilitasi Medik', 1),
	(25, 9, '4', 'Rehabilitasi Psikososial', 1),
	(26, 9, '5', 'Transfusi Darah', 1),
	(27, 9, '6', 'Pelayanan Gigi', 1),
	(28, 9, '7', 'Laboratorium', 1),
	(29, 9, '8', 'USG', 1),
	(30, 9, '9', 'Farmasi', 1),
	(31, 9, '10', 'Lain-Lain', 1),
	(33, 9, '11', 'MRI', 1),
	(34, 9, '12', 'Hemodialisa', 1),
	(36, 10, '', 'Tidak ada', 1),
	(37, 10, '1', 'Poli spesialis tidak tersedia pada hari sebelumnya', 1),
	(38, 10, '2', 'Jam Poli telah berakhir pada hari sebelumnya', 1),
	(39, 10, '3', 'Dokter Spesialis yang dimaksud tidak praktek pada hari sebelumnya', 1),
	(40, 10, '4', 'Atas Instruksi RS', 1),
	(41, 10, '5', 'Tujuan Kontrol', 1),
	(42, 11, '1', 'VVIP', 1),
	(43, 11, '2', 'VIP', 1),
	(44, 11, '3', 'Kelas 1', 1),
	(45, 11, '4', 'Kelas 2', 1),
	(46, 11, '5', 'Kelas 3', 1),
	(47, 11, '6', 'ICCU', 1),
	(48, 11, '7', 'ICU', 1),
	(49, 12, '1', 'Atas Persetujuan Dokter', 1),
	(50, 12, '3', 'Atas Permintaan Sendiri', 1),
	(51, 12, '4', 'Meninggal', 1),
	(52, 12, '5', 'Lain-lain', 1);
/*!40000 ALTER TABLE `referensi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
