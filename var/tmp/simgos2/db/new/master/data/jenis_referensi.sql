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

-- Membuang data untuk tabel master.jenis_referensi: 113 rows
/*!40000 ALTER TABLE `jenis_referensi` DISABLE KEYS */;
REPLACE INTO `jenis_referensi` (`ID`, `DESKRIPSI`, `SINGKATAN`, `APLIKASI`) VALUES
	(1, 'Agama', '', 0),
	(2, 'Jenis Kelamin', '', 1),
	(3, 'Pendidikan', '', 0),
	(4, 'Pekerjaan', '', 0),
	(5, 'Status Perkawinan', '', 0),
	(6, 'Golongan Darah', '', 0),
	(7, 'Status Hubungan Dalam Keluarga', 'SHDK', 0),
	(8, 'Jenis Kontak', '', 0),
	(9, 'Jenis Kartu Identitas', '', 0),
	(10, 'Jenis Kartu Asuransi / Penjamin', '', 0),
	(11, 'Jenis Pemberi Pelayanan Kesehatan', 'PPK', 0),
	(12, 'Jenis Peserta Isteri Suami Anak', 'PISA', 1),
	(13, 'Status Pasien', '', 1),
	(14, 'Status Pegawai', '', 1),
	(15, 'Jenis Kunjungan', '', 1),
	(16, 'Bank', '', 1),
	(17, 'Jenis Kartu Debit / Kredit', '', 1),
	(18, 'Jabatan', '', 0),
	(19, 'Kelas', '', 0),
	(20, 'Status Ruang Kamar Tidur', '', 1),
	(21, 'Status Reservasi', '', 1),
	(22, 'Status Kunjungan', '', 1),
	(23, 'Status Rujukan', '', 1),
	(24, 'Status Ambil Pasien', '', 1),
	(25, 'Status (Lainnya)', '', 1),
	(26, 'Jenis Staf Medis Fungsional', 'SMF', 0),
	(27, 'Jenis Cetak', '', 1),
	(28, 'Kepemilikan Tempat Pelayanan Kesehatan', '', 1),
	(29, 'Jenis Pelayanan Kesehatan', '', 1),
	(30, 'Jenis Tarif', '', 1),
	(31, 'Status Aktifitas Kunjungan', '', 1),
	(32, 'Jenis Petugas Medis', '', 0),
	(33, 'Kelompok Umur', '', 1),
	(34, 'Jenis Pembayaran', '', 1),
	(35, 'Satuan Laboratorium', '', 0),
	(36, 'Jenis Profesi', '', 0),
	(37, 'Jenis Item Paket', '', 1),
	(39, 'Merk/Produsen', '', 0),
	(40, 'Jenis Status Layanan Farmasi', '', 1),
	(41, 'Aturan Pakai', '', 0),
	(42, 'Generik/Zat Aktif', '', 0),
	(43, 'Group User', '', 0),
	(44, 'Kelompok Operasi', '', 1),
	(45, 'Cara Keluar', '', 1),
	(46, 'Keadaan Keluar', '', 0),
	(47, 'Jenis Resep', '', 1),
	(48, 'Ya / Tidak', 'YT', 0),
	(49, 'Jenis Tagihan', '', 1),
	(50, 'Jenis Transaksi Pembayaran Tagihan', '', 1),
	(51, 'Flow', '', 0),
	(52, 'Jenis Anastesi', '', 1),
	(53, 'Golongan Operasi', '', 1),
	(54, 'Jenis ICD', '', 1),
	(55, 'Jenis Penggunaan Obat', '', 1),
	(56, 'Jenis Deposit', '', 1),
	(57, 'Alasan Pembatalan Kunjungan', '', 1),
	(58, 'Jenis Pembatalan Retur', '', 1),
	(59, 'Alasan Pembatalan Retur', '', 1),
	(63, 'Jenis Penerimaan', '', 1),
	(66, 'Jenis Pemeriksaan PA', '', 1),
	(67, 'Alasan Pembatalan Penerimaan Barang', '', 1),
	(68, 'Periode Perencanaan', '', 0),
	(69, 'Jenis Pengguna', '', 1),
	(70, 'Ruangan Rujukan', '', 0),
	(71, 'Metode Skala Nyeri', '', 0),
	(72, 'Jenis Onset Penilaian Nyeri', '', 0),
	(73, 'Jenis Pasien', '', 0),
	(74, 'Kategori Tindakan', '', 0),
	(75, 'Jenis Rawat Inap', '', 0),
	(76, 'Jabatan', '', 0),
	(77, 'Jenis Absen', '', 0),
	(80, 'Jenis Penjamin Kecelakaan', '', 0),
	(79, 'Jenis Kemasan Racikan', '', 0),
	(78, 'Jenis Pemberian Obat', '', 0),
	(83, 'Nama Bulan', '', 0),
	(84, 'Petunjuk Racikan', '', 0),
	(86, 'Jenis Rujukan', '', 0),
	(87, 'Jenis Operasi', '', 1),
	(88, 'Status Kepegawaian', '', 0),
	(89, 'Payroll Penambah', '', 0),
	(90, 'Payroll Pengurang', '', 0),
	(91, 'Jenis Triwulan', '', 0),
	(92, 'SITT - Jenis Perujuk', '', 1),
	(93, 'SITT - Jenis Diagnosis', '', 1),
	(94, 'SITT - Klasifikasi Lokasi Anatomi', '', 1),
	(95, 'SITT - Klasifikasi Riwayat Pengobatan', '', 1),
	(96, 'SITT - Klasifikasi Status HIV', '', 1),
	(97, 'SITT - Scoring TB Anak (0 - 13)', '', 1),
	(98, 'SITT - Scoring TB Anak 5', '', 1),
	(99, 'SITT - Scoring TB Anak 6', '', 1),
	(100, 'SITT - Paduan OAT', '', 1),
	(101, 'SITT - Sumber Obat', '', 1),
	(102, 'SITT - Hasil Pemeriksaan Foto Toraks', '', 1),
	(103, 'SITT - Sebelum Pengobatan Hasil Mikroskopis', '', 1),
	(104, 'SITT - Sebelum Pengobatan TCM', '', 1),
	(105, 'SITT - Sebelum Pengobatan Biakan', '', 1),
	(106, 'SITT - Akhir Bulan Ke 2 Hasil Mikroskopis', '', 1),
	(107, 'SITT - Bulan Ke 3 Hasil Mikroskopis', '', 1),
	(108, 'SITT - Bulan Ke 5 Hasil Mikroskopis', '', 1),
	(109, 'SITT - Akhir Pengobatan Hasil Mikroskopis', '', 1),
	(110, 'SITT - Hasil Akhir Pengobatan', '', 1),
	(111, 'SITT - Hasil Tes HIV', '', 1),
	(112, 'SITT - PPK', '', 1),
	(113, 'SITT - ART', '', 1),
	(114, 'SITT - DM', '', 1),
	(115, 'SITT - Terapi DM', '', 1),
	(116, 'SITT - Dipindahkan ke TB.03 RO', '', 1),
	(117, 'SITT - Status Pengobatan', '', 1),
	(118, 'SITT - Toraks tidak dilakukan', '', 1),
	(126, 'Jenis Diskon', '', 1),
	(140, 'Daftar Suku', '', 0),
	(150, 'Racikan', '', 0),
	(145, 'Jenis Bridge', '', 1),
	(127, 'Aturan Perhitungan Akomodasi', '', 1),
	(150, 'Jenis Info Teks', '', 1);
/*!40000 ALTER TABLE `jenis_referensi` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
