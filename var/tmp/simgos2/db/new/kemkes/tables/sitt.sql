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

-- membuang struktur untuk table kemkes.sitt
DROP TABLE IF EXISTS `sitt`;
CREATE TABLE IF NOT EXISTS `sitt` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `nourut_pasien` int(11) NOT NULL COMMENT 'norm / nomor urut pasien terdaftar di rumah sakit ',
  `id_tb_03` char(25) DEFAULT NULL COMMENT 'kod_faskes/4digit_nama_pasien/tanggal_input dikeluarkan oleh SITT sebagai feedback ketika data berhasil dikirimkan',
  `id_periode_laporan` tinyint(4) NOT NULL COMMENT 'kuarter pelaporan 1,2,3,4 1=Januari - Maret 2=April - Juni 3=Juli - September 4=Oktober - Desember ',
  `tanggal_buat_laporan` datetime NOT NULL COMMENT 'tanggal pengiriman data ke SITT/SITB',
  `tahun_buat_laporan` year(4) NOT NULL COMMENT 'tahun pengiriman data ke SITT/SITB ',
  `kd_wasor` char(10) DEFAULT NULL COMMENT 'kode kab/kota untuk faskes ',
  `noregkab` char(25) DEFAULT NULL COMMENT 'urutan pasien ditingkat kab',
  `kd_pasien` varchar(100) NOT NULL COMMENT 'input nama pasien kode dikeluarkan oleh SITT',
  `nik` char(16) NOT NULL COMMENT 'NIK',
  `jenis_kelamin` tinyint(4) NOT NULL COMMENT 'REF 2 | L / P',
  `alamat_lengkap` varchar(150) DEFAULT NULL COMMENT 'Alamt tempat tinggal',
  `id_propinsi` char(2) NOT NULL COMMENT 'Id Propinsi *pasien',
  `kd_kabupaten` char(4) NOT NULL COMMENT 'Kd Kabupaten *pasien',
  `id_kecamatan` char(6) DEFAULT NULL COMMENT 'id kcamatan *pasien',
  `id_kelurahan` char(10) DEFAULT NULL COMMENT 'id Kelurahan *pasien',
  `kd_fasyankes` char(7) DEFAULT NULL COMMENT 'Kd rumah sakit',
  `nama_rujukan` tinyint(4) NOT NULL COMMENT 'REF 92 | Pasien datang dirujuk/dikirim oleh siapa, pilihan: 1- Inisiatif pasien/Keluarga 2- Anggota Masyarakat/Kader 3- Faskes 4- Dokter Praktek Mandiri 5- Poli lain 6- Lain-lain',
  `sebutkan1` varchar(100) DEFAULT NULL COMMENT 'memperjelas keterangan variable no 16 ',
  `tipe_diagnosis` tinyint(4) NOT NULL COMMENT 'REF 93 | Pilihan: - Terkonfirmasi bakteriologis - Terdiagnosis klinis',
  `klasifikasi_lokasi_anatomi` tinyint(4) NOT NULL COMMENT 'REF 94 | Pilihan: - Paru - Ekstraparu',
  `klasifikasi_riwayat_pengobatan` tinyint(4) NOT NULL COMMENT 'REF 95 | Pilih salah satu: 1-Baru 2-Kambuh 3-Diobati setelah gagal 4-Diobati Setelah Putus Berobat 5-Lain-lain 6-Riwayat Pengobatan Sebelumnya Tidak Diketahui 7-Pindahan',
  `klasifikasi_status_hiv` tinyint(4) NOT NULL COMMENT 'REF 96 | Pilih salah satu: Positif Negatif Tidak Diketahui',
  `total_skoring_anak` tinyint(4) DEFAULT NULL COMMENT 'REF 97 | angka 1-13/tidak dilakukan (Permenkes 67 th 2016 ttg Penanggulangan TB)',
  `konfirmasiSkoring5` tinyint(4) DEFAULT NULL COMMENT 'REF 98 | pilihan jika total_skoring_anak adalah 5, pilihan: uji tuberkulin positif dan atau ada kontak TB paru/ uji tuberkulin negatif dan atau tidak ada kontak TB paru',
  `konfirmasiSkoring6` tinyint(4) DEFAULT NULL COMMENT 'REF 99 | pilihan jika total_skoring_anak adalah tidak dilakukan, pilihan: - Ada kontak TB Paru - Tidak ada/ tidak jelas kontak TB Paru',
  `tanggal_mulai_pengobatan` datetime NOT NULL COMMENT 'tanggal mulai pengobatan TB (yyyymmdd) pasien yang pasti diobati',
  `paduan_oat` tinyint(4) DEFAULT NULL COMMENT 'REF 100 | obat yang diberikan',
  `sumber_obat` tinyint(4) DEFAULT NULL COMMENT 'REF 101 | sumber pengobatan TB, pilihannya: Program TB/ Bayar Sendiri/ Asuransi/ Lain-lain ',
  `sebutkan` varchar(250) DEFAULT NULL COMMENT 'isian jika sumber obat lain-lain, free text',
  `sebelum_pengobatan_hasil_mikroskopis` tinyint(4) DEFAULT NULL COMMENT 'REF 103 | hasil pemeriksaan mikroskopis untuk diagnosis (awal), pilihan isian positif/negatif/tidak dilakukan',
  `sebelum_pengobatan_hasil_tes_cepat` tinyint(4) DEFAULT NULL COMMENT 'REF 104 | hasil pemeriksaan tes cepat untuk diagnosis (awal), pilihan: Rif sensitif/Rif resisten/ Negatif/Rif Indeterminated/Invalid/Error/No Result/ Tidak dilakukan',
  `sebelum_pengobatan_hasil_biakan` tinyint(4) DEFAULT NULL COMMENT 'REF 105 | hasil pemeriksaan biakan untuk diagnosis (awal), pilihan: Negatif/1-19 BTA/1+/2+/3+/4+/NTM/Kontaminasi/ Tidak dilakukan',
  `noreglab_bulan_2` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium bulan kedua, isian angka',
  `hasil_mikroskopis_bulan_2` tinyint(4) DEFAULT NULL COMMENT 'REF 106 | hasil pemeriksaan mikroskopis bulan kedua, pilihan: positif/negatif/tidak dilakukan',
  `noreglab_bulan_3` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium bulan ketiga, isian angka',
  `hasil_mikroskopis_bulan_3` tinyint(4) DEFAULT NULL COMMENT 'REF 107 | hasil pemeriksaan mikroskopis bulan ketiga, pilihan: positif/negatif/tidak dilakukan',
  `noreglab_bulan_5` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium bulan kelima, isian angka',
  `hasil_mikroskopis_bulan_5` tinyint(4) DEFAULT NULL COMMENT 'REF 108 | hasil pemeriksaan mikroskopis bulan kelima, pilihan: positif/negatif/tidak dilakukan',
  `akhir_pengobatan_noreglab` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium akhir pengobatan (bulan ke-6-9), isian angka',
  `akhir_pengobatan_hasil_mikroskopis` tinyint(4) DEFAULT NULL COMMENT 'REF 109 | hasil pemeriksaan mikroskopis akhir pengobatan (bulan ke 6-9), pilihan: positif/negatif/tidak dilakukan',
  `tanggal_hasil_akhir_pengobatan` date DEFAULT NULL COMMENT 'tanggal hasil akhir pengobatan/berhenti berobat/selesai pengobatan',
  `hasil_akhir_pengobatan` tinyint(4) DEFAULT NULL COMMENT 'REF 110 | hasil akhir pengobatan TB, pilihan: sembuh/ pengobatan lengkap/ lost to follow up/ meninggal/ gagal/ pindah ',
  `tanggal_dianjurkan_tes` date DEFAULT NULL COMMENT 'tanggal pasien TB dianjurkan untuk tes HIV ',
  `tanggal_tes_hiv` date DEFAULT NULL COMMENT 'tanggal pasien TB dilakukan tes HIV',
  `hasil_tes_hiv` tinyint(4) DEFAULT NULL COMMENT 'REF 111 | hasil pemeriksaan tes HIV, pilihan: Reaktif/ non reaktif/indeterminated',
  `ppk` tinyint(4) DEFAULT NULL COMMENT 'REF 112 | jika pasien koinfeksi TB HIV diberikan PPK, pilihan: ya/tidak',
  `art` tinyint(4) DEFAULT NULL COMMENT 'REF 113 | jika pasien koinfeksi TB HIV mendapatkan ART, pilihan: ya/tidak',
  `tb_dm` tinyint(4) DEFAULT NULL COMMENT 'REF 114 | jika pasien TB juga diabetes mellitus, pilihan: ya/tidak',
  `terapi_dm` tinyint(4) DEFAULT NULL COMMENT 'REF 115 | terapi yang diterima pasien TB DM, pilihan: OHO/ Inj. Insulin',
  `umur` tinyint(4) DEFAULT NULL COMMENT 'umur pasien',
  `status_pengobatan` tinyint(4) DEFAULT NULL COMMENT 'REF 117 | status pengobatan TB berdasarkan pedoman nasional pengobatan TB, pilihan: -sesuai standar -tidak sesuai standar',
  `foto_toraks` tinyint(4) DEFAULT NULL COMMENT 'REF 102 | hasil pemeriksaan rontgen paru, pilihan: positif/negatif/tidak dilakukan',
  `toraks_tdk_dilakukan` tinyint(4) DEFAULT NULL COMMENT 'REF 118 | jika foto_toraks tidak dilakukan, pilihan: - tidak dilakukan - setelah terapi antibioka non OAT: tidak ada perbaikan Klinis, ada faktor resiko TB, dan atas pertimbangan dokter - setelah terapi antibioka non OAT: ada Perbaikan Klinis',
  `pindah_ro` tinyint(4) DEFAULT NULL COMMENT 'REF 116 | jika pasien TB selama pengobatan terkonfirmasi menjadi TB resistan obat, pilihan ya/tidak ',
  `keterangan` varchar(100) DEFAULT NULL COMMENT 'kode ICD diagnosa penyakit TB (sesuai List Kode ICD X untuk Pasien TB)',
  `tahun` year(4) DEFAULT NULL COMMENT 'tahun pasien mulai pengobatan TB ',
  `no_bpjs` char(25) DEFAULT NULL COMMENT 'nomor kartu bpjs untuk paien JKN ',
  `tgl_lahir` date NOT NULL COMMENT 'Tanggal lahir pasien (yyyy-mm-dd)',
  `kode_icd_x` char(6) NOT NULL COMMENT 'kode ICD diagnosa penyakit pasien TB (sesuai List Kode ICD X untuk Pasien TB)',
  `tanggal_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `oleh` smallint(6) NOT NULL,
  `kirim` tinyint(4) NOT NULL DEFAULT '1' COMMENT 'Kirim ke kemkes: 0 = belum dikirim, 1 = sudah dikirim',
  PRIMARY KEY (`id`),
  KEY `nourut_pasien` (`nourut_pasien`),
  KEY `id_tb_03` (`id_tb_03`),
  KEY `tahun` (`tahun`),
  KEY `tahun_buat_laporan` (`tahun_buat_laporan`),
  KEY `id_periode_laporan` (`id_periode_laporan`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
