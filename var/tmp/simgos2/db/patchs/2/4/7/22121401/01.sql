-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.30 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk table master.general_consent
CREATE TABLE IF NOT EXISTS `general_consent` (
  `ID` tinyint NOT NULL AUTO_INCREMENT,
  `JENIS` tinyint NOT NULL COMMENT '1=Kondisi Pelayanan Umum, 2=Kewajiban Keuangan, 3= Hak Pasien, 4=Kewajiban Pasien, 5=Tata Tertib',
  `DESKRIPSI` text NOT NULL,
  `DESCRIPTION` text NOT NULL,
  PRIMARY KEY (`ID`,`JENIS`)
) ENGINE=InnoDB;

-- Membuang data untuk tabel master.general_consent: ~49 rows (lebih kurang)
INSERT INTO `general_consent` (`ID`, `JENIS`, `DESKRIPSI`, `DESCRIPTION`) VALUES
	(1, 1, 'Selama dalam perawatan di RSUP Dr. Wahidin Sudirohusodo Makassar, pasien/keluarga bersedia menerima informasi terkait dengan pemeriksaan yang akan dilakukan dan tindakan medis, keperawatan serta pemeriksaan penunjang lainnya.', 'During hospitalization in dr. Wahidin Sudirohusodo Hospital, patient consent to performed medical examination and treatment, nursing care, and other required examination'),
	(1, 2, 'Selama perawatan di RSUP Dr. Wahidin Sudirohusodo Makassar, pasien umum bersedia menanggung semua biaya yang telah dikeluarkan', 'During hospitalization in dr. Wahidin Sudirohusodohospital, uninsured patient will financially responsible for charge to the hospital'),
	(1, 3, 'Memperoleh informasi mengenai tata tertib dan peraturan yang berlaku di Rumah Sakit', ''),
	(1, 4, 'Mematuhi peraturan yang berlaku di Rumah Sakit', ''),
	(1, 5, 'Pasien hanya dijaga oleh 1 (satu) orang penjaga, kecuali pasien kritis, dijaga oleh maksimal 2 (dua) orang,  dengan menggunakan kartu jaga pasien', ''),
	(2, 1, 'Di unit pelayanan tertentu RSUP Dr. Wahidin Sudirohusodo Makassar, ada keterlibatan peserta didik dalam pemberian pelayanan yang didampingi oleh petugas RS, baik dokter, perawat, maupun tenaga medis lainnya', 'In several units of dr. Wahidin Sudirohusodo Hospital, patient may received health care by enrolled students such as physicians, nurses, and other health care providers that will be supervised by hospital employees'),
	(2, 2, 'Selama perawatan di RSUP Dr. Wahidin Sudirohusodo Makassar, pasien atau keluarganya bersedia menyelesaikan kewajiban keuangan setelah pasien dinyatakan boleh pulang', 'During hospitalization in dr, Wahidin Sudirohusodo hospital, patient or family agree to pay the payment responsible after discharge from hospitalization'),
	(2, 3, 'Memperoleh informasi tentang hak dan kewajiban pasien', ''),
	(2, 4, 'Menggunakan fasilitas Rumah Sakit secara bertanggung jawab', ''),
	(2, 5, 'Pengunjung wajib mentaati jam besuk :\r\n- Pagi, Pukul 10.00 - 12.00 WITA\r\n- Sore, Pukul 17.00 - 19.00 WITA', ''),
	(3, 1, 'Selama perawatan di RSUP Dr. Wahidin Sudirohusodo Makassar, pasien yang memerlukan tindakan medis invasive akan diberikan penjelasan oleh tim medis yang merawat sebelum pasien menyatakan persetujuannya untuk dilakukan tindakan tersebut', 'During hospitalization in dr. Wahidin Sudirohusodo hospital, before invasive medical treatment, patient will be explained about the treatment by health care provider and consent from patient and family will be needed'),
	(3, 2, 'Selama perawatan di RSUP Dr. Wahidin Sudirohusodo Makassar, pasien yang menggunakan IKS bersedia melengkapi persyaratan administrasi dalam waktu 2x24 jam dan membayar kelebihan selisih biaya dari yang ditanggung, sedangkan pasien JKN bersedia melengkapi persyaratan administrasi dalam waktu 3x24 jam, dan membayar kelebihan selisih biaya dari yang ditanggung jika menempati kelas yang lebih tinggi dari hak kelasnya', 'During hospitalization in dr. Wahidin Sudirohusodo hospital, Patient using health insurance and partnership system agree to complete require administration in 2x24 hours and pay the excess of the cost difference incurred, whereas patients JKN willing to complete the administrative requirements within 3x24 hours, and pay the excess of the cost difference incurred if the class occupies higher than the right class'),
	(3, 3, 'Memperoleh layanan yang manusiawi, adil, jujur dan tanpa diskriminasi', ''),
	(3, 4, 'Menghormati hak pasien lain, pengunjung dan hak tenaga kesehatan serta petugas lainnya yang bekerja di Rumah Sakit', ''),
	(3, 5, 'Tidak merokok diseputar Rumah Sakit', ''),
	(4, 1, 'Selama dalam perawatan di RSUP Dr. Wahidin Sudirohusodo Makassar, pasien dianjurkan untuk tidak mengenakan atau menyimpan barang berharga. Kehilangan ataupun kerusakan barang bukan merupakan tanggung jawab RSUP Dr.Wahidin Sudirohusodo Makassar', 'During hospitalization in dr. Wahidin Sudirohusodo hospital, patient and family shouldn’t use or bring valuables to the hospital. Hospital will not be responsible for any loss and destruction of personal property'),
	(4, 3, 'Memperoleh layanan kesehatan yang bermutu sesuai dengan standar profesi dan standar prosedur operasional', ''),
	(4, 4, 'Memberikan informasi yang jujur, lengkap dan akurat sesuai dengan kemampuan dan pengetahuannya tentang masalah kesehatannya', ''),
	(4, 5, 'Tidak membawa anak kecil dibawah 12 tahun', ''),
	(5, 1, 'Pasien dan keluarga bersedia mengikuti peraturan dan ketentuan yang berlaku di RSUP Dr. Wahidin Sudirohusodo Makassar', 'Patient and family agree to obey dr. Wahidin Sudirohusodo Hospital’s rules'),
	(5, 3, 'Memperoleh layanan yang efektif dan efisien sehingga pasien terhindar dari kerugian fisik dan materi', ''),
	(5, 4, 'Memberikan informasi mengenai kemampuan finansial dan jaminan kesehatan yang dimilikinya', ''),
	(5, 5, 'Tidak membawa :\r\nA. Makanan basah\r\nB. Peralatan makan/minum dan pisau (senjata tajam)\r\nC. Alat Elektronik (Radio, TV, Laptop, Kipas Angin)\r\nD. Alat Tidur (Fasilitas Lainnya)\r\nE. Tas Koper\r\nF. Barang berharga dan uang dalam jumlah besar ', ''),
	(6, 1, 'Pasien dan keluarga dapat memilih kelas ruang perawatan yang tersedia di RSUP Dr. Wahidin Sudirohusodo Makassar, berdasarkan pola tarif yang berlaku sesuai dengan hak perawatan yang ditanggung asuransi kesehatan atau jenis IKS yang akan digunakan', 'Patient and family can choose bed type which is available depend on authority of health insurance or partnership that used by patient'),
	(6, 3, 'Mengajukan pengaduan atas kualitas pelayanan yang didapatkan', ''),
	(6, 4, 'Mematuhi rencana terapi yang direkomendasikan oleh Tenaga Kesehatan di Rumah Sakit dan disetujui oleh pasien yang bersangkutan setelah mendapatkan penjelasan sesuai dengan ketentuan peraturaan perundang-undangan', ''),
	(6, 5, 'Tidak mencuci/menjemur pakaian, serta memakai air secara berlebihan', ''),
	(7, 1, 'Saya memahami informasi yang ada di dalam diri saya, termasuk diagnosis, hasil laboratorium dan hasil tes diagnostik yang akan digunakan untuk perawatan medis, rumah sakit yang akan menjaga kerahasiaannya', 'I have understood the information  about myself, including diagnosis, laboratory result, and other diagnostic test that will be used in medical treatment, hospital will keep it’s confidentiality'),
	(7, 3, 'Memilih dokter dan kelas perawatan sesuai dengan keinginannya dan peraturan yang berlaku di Rumah Sakit', ''),
	(7, 4, 'Menerima segala konsekuensi atas keputusan pribadinya untuk menolak rencana terapi yang direkomendasikan oleh Tenaga Kesehatan dan/atau tidak mematuhi petunjuk yang diberikan oleh Tenaga Kesehatan untuk penyembuhan penyakit atau masalah kesehatannya dan', ''),
	(7, 5, 'Tidak duduk/tidur di tempat tidur pasien', ''),
	(8, 1, 'Saya memberi wewenang kepada rumah sakit untuk memberikan informasi tentang diagnosis, hasil pelayanan dan pengobatan bila diperlukan untuk memproses klaim asuransi/perusahaan dan atau lembaga pemerintah', 'I give the authority to hospital to give information about diagnosis, service, and medical treatment if necessary to process assurance/company claim and/or government institution'),
	(8, 3, 'Meminta konsultasi tentang penyakit yang dideritanya kepada dokter lain yang mempunyai Surat Izin Praktik (SIP) baik di dalam maupun di luar Rumah Sakit', ''),
	(8, 4, 'Memberikan imbalan jasa atas pelayanan yang diterima', ''),
	(8, 5, 'Tidak memakai listrik Rumah Sakit', ''),
	(9, 1, 'Saya memberi wewenang kepada rumah sakit untuk melakukan pencatatan medis kedalam bentuk elektronik dan data tersebut dapat dipertukarkan dengan pihak lain untuk kepentingan pasien, pendidikan dan penelitian', 'I give the authority to hospital to carry out medical records in electronic form and the data can be questioned with other parties for the benefit of patients, education and research'),
	(9, 3, 'Mendapatkan privasi dan kerahasiaan penyakit yang diderita termasuk data-data medisnya', ''),
	(9, 5, 'Tidak mengganggu ketenangan pasien', ''),
	(10, 1, 'Saya memberi wewenang kepada rumah sakit untuk memberikan informasi tentang diagnosis, hasil pelayanan dan pengobatan bila diperlukan kepada anggota keluarga saya ', 'I give the authority to hospital to give information about diagnosis, service, and medical treatment if necessary to my family :'),
	(10, 3, 'Mendapat informasi yang meliputi diagnosis dan tata cara tindakan medis, tujuan tindakan medis, alternatif tindakan, risiko dan komplikasi yang mungkin terjadi, dan prognosis terhadap tindakan yang dilakukan serta perkiraan biaya pengobatan', ''),
	(10, 5, 'Wajib menjaga kebersihan Rumah Sakit', ''),
	(11, 3, 'Memberikan persetujuan atau menolak atas tindakan yang akan dilakukan oleh tenaga kesehatan terhadap penyakit yang dideritanya', ''),
	(12, 3, 'Didampingi keluarganya dalam keadaan kritis', ''),
	(13, 3, 'Menjalankan ibadah sesuai agama atau kepercayaan yang dianutnya selama hal itu tidak mengganggu pasien lainnya', ''),
	(14, 3, 'Memperoleh keamanan dan keselamatan dirinya selama dalam perawatan di Rumah Sakit', ''),
	(15, 3, 'Mengajukan usul, saran, perbaikan atas perlakuan Rumah Sakit terhadap dirinya', ''),
	(16, 3, 'Menolak pelayanan bimbingan rohani yang tidak sesuai dengan agama dan kepercayaan yang dianutnya', ''),
	(17, 3, 'Menggugat dan/atau menuntut Rumah Sakit apabila Rumah Sakit diduga memberikan pelayanan yang tidak sesuai standar baik secara perdata ataupun pidana dan', ''),
	(18, 3, 'Mengeluhkan pelayanan Rumah Sait yang tidak sesuai dengan standar pelayanan melalui media cetak dan elektronik sesuai dengan ketentuan peraturan perundang-undangan', '');

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
