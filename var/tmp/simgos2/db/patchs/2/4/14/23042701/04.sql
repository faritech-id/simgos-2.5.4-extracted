-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.23 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.2.0.6213
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for medicalrecord
USE `medicalrecord`;

-- Dumping structure for table medicalrecord.indikator_keperawatan
CREATE TABLE IF NOT EXISTS `indikator_keperawatan` (
  `JENIS` smallint NOT NULL DEFAULT '0',
  `ID` int NOT NULL AUTO_INCREMENT,
  `DESKRIPSI` varchar(350) NOT NULL,
  `STATUS` tinyint NOT NULL DEFAULT '1',
  PRIMARY KEY (`JENIS`,`ID`),
  KEY `STATUS` (`STATUS`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

-- Dumping data for table medicalrecord.indikator_keperawatan: 11 rows
/*!40000 ALTER TABLE `indikator_keperawatan` DISABLE KEYS */;
INSERT INTO `indikator_keperawatan` (`JENIS`, `ID`, `DESKRIPSI`, `STATUS`) VALUES
	(3, 4, 'Benda asing dalam jalan napas.', 1),
	(1, 1, 'Dipnea', 1),
	(1, 2, 'Sulit bicara.', 1),
	(1, 3, 'Ortopnea', 1),
	(1, 4, 'Lelah.', 1),
	(1, 5, 'Kuatir mesin rusak.', 1),
	(1, 6, 'Fokus meningkat pada pernafasan.', 1),
	(1, 7, 'Pusing', 1),
	(1, 8, 'Penglihatan kabur', 1),
	(2, 1, 'batuk tidak efektif', 1),
	(2, 2, 'tidak mampu batuk.', 1),
	(2, 3, 'sputum berlebih.', 1),
	(2, 4, 'Mengi, wheezing dan / atau ronkhi kering.', 1),
	(2, 5, 'Mekonium di jalan nafas pada Neonatus.', 1),
	(2, 6, 'Frekuensi napas meningkat.', 1),
	(2, 7, 'Penggunaan otot bantu napas.', 1),
	(2, 8, 'Napas megap-megap (gasping).', 1),
	(2, 9, 'Upaya napas dan bantuan ventilator tidak sinkron.', 1),
	(2, 10, 'Nafas Dangkal.', 1),
	(2, 11, 'Agitasi.', 1),
	(2, 12, 'Nilai gas darah arteri abnorma', 1),
	(2, 13, 'PCO2 meningkat / menurun.', 1),
	(2, 14, 'PO2 menurun.', 1),
	(2, 15, 'Takikardia.', 1),
	(2, 16, 'pH arteri meningkat/menurun.', 1),
	(2, 17, 'Bunyi napas tambahan.', 1),
	(2, 18, 'Gelisah.', 1),
	(2, 19, 'Sianosis.', 1),
	(2, 20, 'Bunyi napas menurun.', 1),
	(2, 21, 'Frekuensi napas berubah.', 1),
	(2, 22, 'Pola napas berubah.', 1),
	(2, 23, 'Auskultasi suara inspirasi menurun.', 1),
	(2, 24, 'Warna kulit abnormal (mis. pucat, sianosis).', 1),
	(2, 25, 'Napas paradoks abdominal.', 1),
	(2, 26, 'Diaforesis.', 1),
	(2, 27, 'Ekspresi wajah takut.', 1),
	(2, 28, 'Tekanan darah meningkat.', 1),
	(2, 29, 'Frekuensi nadi meningkat.', 1),
	(2, 30, 'Diaforesis.', 1),
	(2, 31, 'Napas cuping hidung.', 1),
	(2, 32, ' Pola napas abnormal (cepat / lambat, regular/iregular, dalam/dangkal).', 1),
	(2, 33, ' Warna kulit abnormal (mis. pucat, kebiruan).', 1),
	(2, 34, 'Kesadaran menurun.', 1),
	(3, 3, 'Disfungsi neuromuskuler.', 1),
	(3, 2, 'Hipersekresi jalan napas. ', 1),
	(3, 1, ' Spasme jalan napas.', 1),
	(3, 5, 'Adanya jalan napas buatan.', 1),
	(3, 6, 'Sekresi yang tertahan.', 1),
	(3, 7, 'Hiperplasia dinding jalan napas.', 1),
	(3, 8, 'Proses infeksi .', 1),
	(3, 9, ' Respon alergi.', 1),
	(3, 10, ' Efek agen farmakologis (mis. anastesi).', 1),
	(3, 11, ' Hipersekresi jalan nafas.', 1),
	(3, 12, ' Ketidakcukupan energi.', 1),
	(3, 13, 'Hambatan upaya napas (misal nyeri saat bernafas, kelemahan oto pernafasan, efek sedasi.)', 1),
	(3, 14, ' Kecemasan.', 1),
	(3, 15, 'Perasaan tidak berdaya.', 1),
	(3, 16, 'Kurang terpapar informasi tentang proses penyapihan.', 1),
	(3, 17, 'Penurunan motivasi.', 1),
	(3, 18, 'Ketidakseimbangan ventilasi-perfusi.', 1),
	(3, 19, 'Perubapkhan membran alveolus-kapiler.', 1),
	(4, 1, 'Bersihan Jalan Napas Meningkat (L.01001)', 1),
	(4, 2, 'Setelah dilakukan intervensi selama, Maka Pertukaran Gas (L.01003) meningkat', 1),
	(5, 1, 'Manajemen Jalan Nafas (I. 01011)', 1),
	(5, 2, 'Pemantauan Respirasi (I.01014)', 1),
	(5, 3, 'Terapi Oksigen (I.01026)', 1),
	(7, 12, 'Siapkan bag-valve mask di samping tempat tidur Berikan media untuk berkomunikasi (mis: kertas, pulpen) ', 1),
	(7, 13, 'Dokumentasikan respon terhadap ventilator', 1),
	(7, 14, 'Kolaborasi pemilihan mode ventilator (mis: kontrol volume, kontrol tekanan atau gabungan)', 1),
	(7, 15, 'Kolaborasi pemberian agen pelumpuh otot, sedatif, analgesik, sesuai kebutuhan ', 1),
	(7, 16, 'Kolaborasi penggunaan PS atau PEEP untuk meminimalkan hipoventilasi alveolus', 1),
	(7, 17, 'Posisikan semi fowler, fowler atau head up 30 derajat', 1),
	(7, 18, 'Atur interval waktu pemantauan respirasi sesuai kondisi pasien', 1),
	(7, 19, 'Bersihkan secret pada mulut, hidung dan trachea, jika perlu', 1),
	(7, 20, 'Pertahankan kepatenan jalan nafas', 1),
	(7, 21, 'Berikan oksigen …… L/menit via ……..', 1),
	(7, 22, 'Kolaborasi penentuan dosis oksigen', 1),
	(7, 23, 'Kolaborasi penggunaan oksigen saat aktivitas dan/atau tidur', 1),
	(6, 1, 'Monitor pola napas (frekuensi, kedalaman, usaha napas)', 1),
	(6, 2, 'Monitor bunyi napas tambahan (mis. Gurgling, mengi, weezing, ronkhi kering)', 1),
	(6, 3, 'Monitor sputum (jumlah, warna, aroma)', 1),
	(6, 4, 'Periksa ind+L30+L23:L37+L23:L38+L23:L37', 1),
	(6, 5, 'Monitor efek ventilator terhadap status oksigenasi (mis: bunyi paru, X-ray paru, AGD, SaO2, SVO?, ETCO?, respon subyektif pasien)', 1),
	(6, 6, 'Monitor kriteria perlunya penyapihan ventilator', 1),
	(6, 7, 'Monitor efek negatif ventilator (mis: deviasi trakea, barotrauma, volutrauma, penurunan curah jantung, distensi gaster, emfisema subkutan)', 1),
	(6, 8, 'Monitor gejala peningkatan pernapasan (mis: peningkatan denyut jantung atau pernapasan, peningkatan tekanan darah, diaforesis, perubahan status mental)', 1),
	(6, 9, 'Monitor kondisi yang meningkatkan konsumsi oksigen (mis: demam, menggigil, kejang, dan nyeri) ', 1),
	(6, 10, 'Monitor gangguan mukosa oral, nasal, trakea dan laring', 1),
	(6, 11, 'Monitor frekuensi, irama, kedalaman, dan upaya napas', 1),
	(6, 12, 'Monitor pola napas (seperti bradipnea, takipnea, hiperventilasi, Kussmaul, Cheyne-Stokes, Biot, ataksik)', 1),
	(6, 13, 'Monitor adanya sumbatan jalan napas', 1),
	(6, 14, 'Auskultasi bunyi napas', 1),
	(6, 15, 'Monitor saturasi oksigen', 1),
	(6, 16, 'Monitor nilai AGD', 1),
	(6, 17, 'Monitor hasil x-ray toraks', 1),
	(6, 18, 'Monitor kecepatan aliran oksigen', 1),
	(6, 19, 'Monitor posisi alat terapi oksigen', 1),
	(6, 20, 'Monitor efektifitas terapi oksigen ', 1),
	(6, 21, 'Monitor kemampuan melepaskan oksigen saat makan', 1),
	(6, 22, 'Monitor tanda-tanda hipoventilasi', 1),
	(6, 23, 'Monitor tingkat kecemasan akibat terapi oksigen', 1),
	(8, 1, ' Anjurkan asupan cairan 2000 ml/hari, jika tidak kontraindikasi.', 1),
	(8, 2, 'Ajarkan teknik batuk efektif', 1),
	(9, 1, 'Kolaborasi pemberian bronkodilator, ekspektoran, mukolitik: ……', 1),
	(8, 3, 'Jelaskan tujuan dan prosedur pemantauan', 1),
	(7, 11, 'Ganti sirkuit ventilator setiap 24 jam', 1),
	(7, 9, 'Lakukan fisioterapi dada, jike perlu', 1),
	(7, 10, 'Lakukan penghisapan lendir sesuai kebututan', 1),
	(7, 8, 'Lakukan perawatan mulut secara rutin, termasuk sikat gigi setiap 12 jam', 1),
	(7, 7, 'Atur posisi kepala 45-60° untuk mencegah aspirasi Reposisi pasien setiap 2 jam, jika perlu ', 1),
	(7, 6, ' Berikan oksigen ……….. Liter/menit via …………………..', 1),
	(7, 5, 'Keluarkan sumbatan benda padat dengan forsepMcGill', 1),
	(7, 4, 'Lakukan hiperoksigenasi sebelum Penghisapan endotrakeal', 1),
	(7, 3, 'Lakukan penghisapan lendir kurang dari 15 detik', 1),
	(7, 2, 'Posisikan semi fowler, fowler atau head up 30 derajat', 1),
	(7, 1, 'Pertahankan kepatenan jalan napas dengan head-tilt dan chin-lift (jaw-thrust) jika curiga trauma cervical)', 1);
/*!40000 ALTER TABLE `indikator_keperawatan` ENABLE KEYS */;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
