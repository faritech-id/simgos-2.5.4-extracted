-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.23 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

USE `kemkes`;

-- membuang struktur untuk table kemkes.pasien_tb
CREATE TABLE IF NOT EXISTS `pasien_tb` (
  `id` int NOT NULL AUTO_INCREMENT,
  `nourut_pasien` int NOT NULL COMMENT 'norm / nomor urut pasien terdaftar di rumah sakit ',
  `id_tb_03` char(25) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'kod_faskes/4digit_nama_pasien/tanggal_lahir/urutan \r\ndata dikeluarkan oleh SITB sebagai feedback ketika\r\ndata berhasil dikirimkan',
  `id_periode_laporan` tinyint NOT NULL COMMENT 'kuarter pelaporan1,2,3,4 \r\n1=Januari - Maret \r\n2=April - Juni\r\n3=Juli - September\r\n4=Oktober - Desember',
  `tanggal_buat_laporan` datetime NOT NULL COMMENT 'tanggal pengiriman data ke SITB',
  `tahun_buat_laporan` year NOT NULL COMMENT 'tahun pengiriman data ke SITB',
  `kd_wasor` char(10) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'kode kab/kota untuk faskes',
  `Noregkab` char(25) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'urutan pasien ditingkat kab',
  `kd_pasien` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'input nama pasien\r\nkode dikeluarkan oleh SITB',
  `Nik` char(16) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'NIK',
  `jenis_kelamin` tinyint NOT NULL COMMENT 'REF 2 | L / P',
  `alamat_lengkap` varchar(150) DEFAULT NULL COMMENT 'Alamt tempat tinggal',
  `id_propinsi_faskes` char(2) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Id Propinsi *faskes',
  `kd_kabupaten_faskes` char(4) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'Kd Kabupaten *faskes',
  `id_propinsi_pasien` char(2) NOT NULL COMMENT 'Id Propinsi*pasien',
  `kd_kabupaten_pasien` char(4) NOT NULL COMMENT 'Kd Kabupaten*pasien',
  `id_kecamatan_pasien` char(6) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'id kcamatan *pasien',
  `id_kelurahan` char(10) DEFAULT NULL COMMENT 'id Kelurahan *pasien',
  `kd_fasyankes` char(7) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'Kode rumah sakit',
  `nama_rujukan` tinyint NOT NULL COMMENT 'REF 92 | Pasien datang dirujuk/dikirim oleh siapa, pilihan:\r\n1. Kader/Komunitas\r\n2. Fasyankes lain\r\n3. Lain-lain',
  `sebutkan1` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'memperjelas keterangan variabel nama rujukan',
  `tipe_diagnosis` tinyint NOT NULL COMMENT 'REF 93 | Pilihan: (hanya input nomor)\r\n1. Terkonfirmasi bakteriologis\r\n2. Terdiagnosis klinis',
  `klasifikasi_lokasi_anatomi` tinyint NOT NULL COMMENT 'REF 94 | Pilihan: (hanya input nomor)\r\n1. Paru\r\n2. Ekstraparu',
  `klasifikasi_riwayat_pengobatan` tinyint NOT NULL COMMENT 'REF 95 | Pilih salah satu: (hanya input nomor)\r\n1. Baru\r\n2. Kambuh\r\n3. Diobati Setelah Gagal\r\n4. Diobati Setelah Putus Berobat \r\n5. Lain-lain\r\n6. Riwayat Pengobatan Sebelumnya Tidak Diketahui',
  `klasifikasi_status_hiv` tinyint NOT NULL COMMENT 'REF 96 | Pilih salah satu: \r\nPositif\r\nNegatif\r\nTidak Diketahui',
  `total_skoring_anak` tinyint DEFAULT NULL COMMENT 'REF 97 | Angka 0-13\r\nTidak Dilakukan\r\n(Permenkes 67 th 2016 ttg Penanggulangan TB)',
  `konfirmasiSkoring5` tinyint DEFAULT NULL COMMENT 'REF 98 | pilihan jika total_skoring_anak adalah 5, \r\npilihan: uji tuberkulin positif dan atau ada \r\nkontak TB paru/ uji tuberkulin negatif dan atau \r\ntidak ada\r\nkontak TB paru',
  `konfirmasiSkoring6` tinyint DEFAULT NULL COMMENT 'REF 99 | pilihan jika total_skoring_anak adalah \r\ntidak dilakukan, pilihan:\r\n- Ada kontak TB Paru\r\n- Tidak ada/ tidak jelas kontak TB Paru',
  `tanggal_mulai_pengobatan` datetime NOT NULL COMMENT 'tanggal mulai pengobatan TB (yyyymmdd)\r\npasien yang pasti diobati\r\n',
  `paduan_oat` varchar(250) DEFAULT NULL COMMENT 'Obat TB yang diberikan',
  `sumber_obat` tinyint DEFAULT NULL COMMENT 'REF 101 | sumber pengobatan TB, pilihannya:\r\nProgram TB\r\nBayar Sendiri\r\nAsuransi\r\nLain-lain',
  `sebutkan` varchar(500) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL COMMENT 'isian jika sumber obat lain-lain, free text',
  `sebelum_pengobatan_hasil_mikroskopis` tinyint DEFAULT NULL COMMENT 'REF 103 | hasil pemeriksaan mikroskopis untuk diagnosis \r\n(awal), pilihan isian:\r\nNeg/1-9/1+/2+/3+/Tidak Dilakukan',
  `sebelum_pengobatan_hasil_tes_cepat` tinyint DEFAULT NULL COMMENT 'REF 104 | hasil pemeriksaan tes cepat untuk diagnosis \r\n(awal), pilihan: \r\nNeg/Rif Sen/Rif Res/Rif \r\nIndet/INVALID/ERROR/NO RESULT/Tidak \r\nDilakukan',
  `sebelum_pengobatan_hasil_biakan` tinyint DEFAULT NULL COMMENT 'REF 105 | hasil pemeriksaan biakan untuk \r\ndiagnosis (awal), pilihan: \r\nNegatif/1-19 \r\nBTA/1+/2+/3+/4+/NTM/Kontaminasi/ Tidak\r\nDilakukan',
  `noreglab_bulan_2` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium bulan kedua, isian angka',
  `hasil_mikroskopis_bulan_2` tinyint DEFAULT NULL COMMENT 'REF 106 | hasil pemeriksaan mikroskopis bulan kedua,\r\npilihan: Neg/1-9/1+/2+/3+/Tidak Dilakukan (hasil\r\nfollowup pengobatan bulan ke 2)',
  `noreglab_bulan_3` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium bulan ketiga, isian angka',
  `hasil_mikroskopis_bulan_3` tinyint DEFAULT NULL COMMENT 'REF 107 | hasil pemeriksaan mikroskopis bulan ketiga,\r\npilihan: Neg/1-9/1+/2+/3+/Tidak Dilakukan (hasil \r\nfollowup pengobatan bulan ke 3)',
  `noreglab_bulan_5` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium bulan kelima, isian angka',
  `hasil_mikroskopis_bulan_5` tinyint DEFAULT NULL COMMENT 'REF 108 | hasil pemeriksaan mikroskopis bulan kelima,\r\npilihan: Neg/1-9/1+/2+/3+/Tidak Dilakukan (hasil \r\nfollowup pengobatan bulan ke 5)',
  `akhir_pengobatan_noreglab` char(25) DEFAULT NULL COMMENT 'nomor registrasi pemeriksaan laboratorium akhir pengobatan (bulan ke-6-9), isian angka',
  `akhir_pengobatan_hasil_mikroskopis` tinyint DEFAULT NULL COMMENT 'REF 109 | hasil pemeriksaan mikroskopis akhir\r\npengobatan\r\n(bulan ke 6-9), pilihan: : Neg/1-\r\n9/1+/2+/3+/Tidak Dilakukan (hasil followup \r\npengobatan bulan ke 6)',
  `tanggal_hasil_akhir_pengobatan` date DEFAULT NULL COMMENT 'tanggal hasil akhir pengobatan/berhenti berobat/selesai pengobatan',
  `hasil_akhir_pengobatan` tinyint DEFAULT NULL COMMENT 'REF 110 | hasil akhir pengobatan TB, pilihan: sembuh/ \r\npengobatan lengkap/ lost to follow up/\r\nmeninggal/ gagal/ tidak dievaluasi',
  `tanggal_dianjurkan_tes` date DEFAULT NULL COMMENT 'tanggal pasien TB dianjurkan untuk tes HIV ',
  `tanggal_tes_hiv` date DEFAULT NULL COMMENT 'tanggal pasien TB dilakukan tes HIV',
  `hasil_tes_hiv` tinyint DEFAULT NULL COMMENT 'REF 111 | hasil pemeriksaan tes HIV, pilihan: Reaktif/ non reaktif/indeterminated',
  `Ppk` tinyint DEFAULT NULL COMMENT 'REF 112 | jika pasien koinfeksi TB HIV diberikan PPK, pilihan: ya/tidak',
  `Art` tinyint DEFAULT NULL COMMENT 'REF 113 | jika pasien koinfeksi TB HIV mendapatkan ART, pilihan: ya/tidak',
  `tb_dm` tinyint DEFAULT NULL COMMENT 'REF 114 | jika pasien TB juga diabetes mellitus, pilihan: ya/tidak',
  `terapi_dm` tinyint DEFAULT NULL COMMENT 'REF 115 | terapi yang diterima pasien TB DM, pilihan: OHO/ Inj. Insulin',
  `pindah_ro` tinyint DEFAULT NULL COMMENT 'REF 116 | jika pasien TB selama pengobatan terkonfirmasi menjadi TB resistan obat, pilihan ya/tidak',
  `Umur` tinyint DEFAULT NULL COMMENT 'umur pasien dalam tahun',
  `status_pengobatan` tinyint DEFAULT NULL COMMENT 'REF 117 | status pengobatan TB berdasarkan pedoman \r\nnasional pengobatan TB, pilihan:\r\n-sesuai standar\r\n-tidak sesuai standar\r\n',
  `foto_toraks` tinyint DEFAULT NULL COMMENT 'REF 102 | hasil pemeriksaan rontgen paru, pilihan: positif/negatif/tidak dilakukan',
  `toraks_tdk_dilakukan` tinyint DEFAULT NULL COMMENT 'REF 118 |  jika foto_toraks tidak dilakukan, pilihan:\r\n- tidak dilakukan\r\n- setelah terapi antibioka non OAT: tidak ada \r\nperbaikan Klinis, ada faktor resiko TB, danatas \r\npertimbangan dokter\r\n- setelah terapi antibioka non OAT: ada\r\nPerbaikan Klinis',
  `keterangan` varchar(100) DEFAULT NULL COMMENT 'kode ICD diagnosa penyakit TB (sesuai List Kode ICD X untuk Pasien TB)',
  `Tahun` year DEFAULT NULL COMMENT 'tahun pasien mulai pengobatan TB ',
  `no_bpjs` char(25) DEFAULT NULL COMMENT 'nomor kartu bpjs untuk paien JKN ',
  `tgl_lahir` date NOT NULL COMMENT 'Tanggal lahir pasien (yyyy-mm-dd)',
  `kode_icd_x` char(6) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL COMMENT 'kode ICD diagnosa penyakit pasien TB\r\n(sesuai List Kode ICD X untuk Pasien TB)\r\n',
  `Asal_poli` char(10) NOT NULL COMMENT 'Di isi asal poli',
  `tanggal_updated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `oleh` smallint NOT NULL,
  `kirim` tinyint NOT NULL DEFAULT '1' COMMENT 'Kirim ke kemkes: 0 = belum dikirim, 1 = sudah dikirim',
  `final` TINYINT NOT NULL DEFAULT '0',	
  PRIMARY KEY (`id`),
  KEY `nourut_pasien` (`nourut_pasien`),
  KEY `id_tb_03` (`id_tb_03`),
  KEY `tahun_buat_laporan` (`tahun_buat_laporan`),
  KEY `id_periode_laporan` (`id_periode_laporan`),
  KEY `tahun` (`Tahun`) USING BTREE,
  KEY `final` (`final`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Pengeluaran data tidak dipilih.

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
