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


-- Membuang struktur basisdata untuk lis_his
CREATE DATABASE IF NOT EXISTS `lis_his` /*!40100 DEFAULT CHARACTER SET latin1 */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `lis_his`;

-- membuang struktur untuk table lis_his.hasil_lab
CREATE TABLE IF NOT EXISTS `hasil_lab` (
  `no_lab` varchar(15) DEFAULT NULL,
  `asal_lab` varchar(4) DEFAULT NULL,
  `no_registrasi` varchar(25) DEFAULT NULL,
  `no_rm` varchar(10) DEFAULT NULL,
  `tgl_order` datetime DEFAULT NULL,
  `no_urut` int DEFAULT NULL,
  `kode_test_his` varchar(10) DEFAULT NULL,
  `kode_test` varchar(6) DEFAULT NULL,
  `nama_test` varchar(35) DEFAULT NULL,
  `flag` varchar(1) DEFAULT NULL,
  `hasil` varchar(3000) DEFAULT NULL,
  `unit` varchar(15) DEFAULT NULL,
  `nilai_normal` varchar(200) DEFAULT NULL,
  `kode` varchar(1) DEFAULT NULL,
  `his_test_id_order` varchar(25) DEFAULT NULL,
  `status` tinyint DEFAULT '0' COMMENT '0=blm di ambil his, 1=sudah di ambil',
  `Created_DT` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  KEY `no_lab` (`no_lab`,`no_registrasi`,`no_rm`),
  KEY `status` (`status`)
) ENGINE=InnoDB DEFAULT;

-- Membuang data untuk tabel lis_his.hasil_lab: ~0 rows (lebih kurang)
REPLACE INTO `hasil_lab` (`no_lab`, `asal_lab`, `no_registrasi`, `no_rm`, `tgl_order`, `no_urut`, `kode_test_his`, `kode_test`, `nama_test`, `flag`, `hasil`, `unit`, `nilai_normal`, `kode`, `his_test_id_order`, `status`, `Created_DT`) VALUES
	('2207182004', '1', '1010501032207220002', '932094', '2022-07-22 11:00:03', 3, '100312161', 'LEKO', '  Lekosit', '', '6.9', 'ribu/µL', '4 ~ 10', 'U', '10323', 1, '2022-07-22 06:00:00'),
	('2207182004', '1', '1010501032207220002', '932094', '2022-07-22 11:00:03', 4, '100312163', 'ERITR', '  Eritrosit', '', '4.09', 'juta/µL', '3.8 ~ 5.2', 'U', '10323', 1, '2022-07-22 06:00:00'),
	('2207182004', '1', '1010501032207220002', '932094', '2022-07-22 11:00:03', 5, '100312167', 'HB', '  Hemoglobin', 'L', '11.7', 'g/dL', '12 ~ 15', 'U', '10323', 1, '2022-07-22 06:00:00'),
	('2207182004', '1', '1010501032207220002', '932094', '2022-07-22 11:00:03', 26, '100375170', 'AST', '  AST (SGOT)', '', '30', 'U/L', '< 38', 'U', '', 1, '2022-07-22 06:00:00');

-- membuang struktur untuk table lis_his.map_item_order
CREATE TABLE IF NOT EXISTS `map_item_order` (
  `id` int NOT NULL AUTO_INCREMENT,
  `test` varchar(25) NOT NULL,
  `test_name` varchar(250) NOT NULL,
  `order_item_id` varchar(25) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `test` (`test`),
  KEY `order_item_id` (`order_item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=134;

-- Membuang data untuk tabel lis_his.map_item_order: ~0 rows (lebih kurang)
REPLACE INTO `map_item_order` (`id`, `test`, `test_name`, `order_item_id`) VALUES
	(1, '106760', 'Tes RT-PCR Covid-19', ''),
	(2, '106762', 'Pengambilan Sampel Swab Nasofaring dan Orofaring', ''),
	(3, '100376', 'GPT _', ''),
	(4, '100312', 'Hematologi Rutin Automatik -', ''),
	(5, '100367', 'Glukose Sewaktu _', ''),
	(6, '100370', 'Ureum _', ''),
	(7, '100371', 'Kreatinin _', ''),
	(8, '100375', 'GOT _', ''),
	(9, '100379', 'Albumin _', ''),
	(10, '100396', 'Elektrolit _', ''),
	(11, '100397', 'Analisa Gas Darah', ''),
	(12, '100556', 'Analisa Cairan Pleura', ''),
	(13, '100329', 'Waktu Prothtrombine (PT) _', ''),
	(14, '100330', 'APTT _', ''),
	(15, '100373', 'Bilirubin Total _', ''),
	(16, '100374', 'Bilirubin Direk _', ''),
	(17, '100400', 'HBs Ag (ICT)', ''),
	(18, '100349', 'Urine Rutin __', ''),
	(19, '100474', 'Analisa Faeces _', ''),
	(20, '107140', 'Pengambilan Sampel darah Arteri', ''),
	(21, '106747', 'Pengambilan Sampel Darah dan Serum', ''),
	(22, '100401', 'HBs Ag (Elisa) _', ''),
	(23, '100404', 'Anti HCV (Elisa) _', ''),
	(24, '106984', 'Tes Antigen Covid-19 Metode Rapid Tes', ''),
	(25, '103275', 'Laktat Darah', ''),
	(26, '100365', 'Glukose Puasa _', ''),
	(27, '100366', 'Glukose 2 Jam PP _', ''),
	(28, '100382', 'Kolesterol Total _', ''),
	(29, '100383', 'Kolesterol HDL _', ''),
	(30, '100384', 'Kolesterol LDL (Direk) _', ''),
	(31, '100385', 'Trigliserida _', ''),
	(32, '104542', 'Golongan Darah ABO, Rhesus', ''),
	(33, '106280', 'Ureum Urine (UUN)', ''),
	(34, '103690', 'Prokalsitonin', ''),
	(35, '100378', 'Protein Total _', ''),
	(36, '100403', 'Anti HCV (ICT)', ''),
	(37, '100390', 'LDH _', ''),
	(38, '103278', 'CRP Kuantitatif', ''),
	(39, '100391', 'D Dimer _', ''),
	(40, '107155', 'Pengambilan Sampel Swab Nasofaring & Orofaring', ''),
	(41, '100380', 'Globulin _', ''),
	(42, '100377', 'Alkali Fosfatase _', ''),
	(43, '100381', 'Gamma GT _', ''),
	(44, '100417', 'Ferritine _', ''),
	(45, '107139', 'Pengambilan Sampel darah dan Pediatric', ''),
	(46, '100327', 'Waktu Bekuan __', ''),
	(47, '100328', 'Waktu Pendarahan _', ''),
	(48, '104278', 'Trepoma Palidum H Antigen (TPHA)', ''),
	(49, '100426', 'Anti HIV (ICT)', ''),
	(50, '102547', 'Cross Matching', ''),
	(51, '107059', 'Tes Cepat Molekuler RT-PCR Covid-19', ''),
	(52, '107138', 'Pengambilan Sampel darah dan Neonatal (NICU)', ''),
	(53, '101246', 'Pengambilan Sampel Darah', ''),
	(54, '100427', 'Anti HIV (Elisa) _', ''),
	(55, '100428', 'DHF IGg/IgM (ICT)', ''),
	(56, '103483', 'Biakan dan Resistensi (Medium Padat)', ''),
	(57, '100394', 'Asam Urat _', ''),
	(58, '100369', 'HBA 1c _', ''),
	(59, '100321', 'Retikulosit Otomatik + Hematologi Rutin _', ''),
	(60, '100322', 'Fe (Besi) _', ''),
	(61, '100323', 'TIBC _', ''),
	(62, '100324', 'Gambaran Darah tepi * _', ''),
	(63, '106290', 'TCM Mycobacterium Tuberculosa (Genexpert Tb) ', ''),
	(64, '100395', 'Calsium _', ''),
	(65, '103274', 'Magnesium Darah', ''),
	(66, '100388', 'CK _', ''),
	(67, '100314', 'Laju Endap Darah Automotik -', ''),
	(68, '100434', 'FT4 _', ''),
	(69, '100435', '  TSHs', ''),
	(70, '101422', 'Hbe Ag	', ''),
	(71, '105788', 'Anti HBe (Elisa Vidas)', ''),
	(72, '100438', 'CEA _', ''),
	(73, '100439', 'AFP _', ''),
	(74, '100442', 'CA 19-9 _', ''),
	(75, '100549', 'Sputum BTA 3 X (Pewarnaan)', ''),
	(76, '100462', 'Pengecatan Gram _', ''),
	(77, '100463', 'Jamur _', ''),
	(78, '106293', 'Kultur dan Sensitivitas Jamur', ''),
	(79, '103484', 'Biakan dan Resistensi (Medium Cair)', ''),
	(80, '103053', 'Analisa Cairan Otak', ''),
	(81, '105712', 'Asam Urat (Urine)', ''),
	(82, '100409', 'Anti Toxoplasma IgG _', ''),
	(83, '100410', 'Anti Toxoplasma IgM _', ''),
	(84, '100413', 'Anti CMV IgG _', ''),
	(85, '100414', 'Anti CMV IgM _', ''),
	(86, '105670', 'Konsul dr Ahli Patologi Klinik (IRNA)', ''),
	(87, '100441', 'CA 12-5 _', ''),
	(88, '101375', 'Tes Narkoba ( 3 Jenis Obat )	', ''),
	(89, '106267', 'Plano Test (HCG)', ''),
	(90, '100332', 'Fibrinogen _', ''),
	(91, '100326', 'Evaluasi SST _', ''),
	(92, '100636', 'BMP (Bone Morrow Fucture)', ''),
	(93, '103232', 'Rasio IT', ''),
	(94, '100443', 'CA 15-3 _', ''),
	(95, '104260', 'Amilase Darah', ''),
	(96, '104393', 'Lipase Darah', ''),
	(97, '100423', 'RF _', ''),
	(98, '107142', 'Pengambilan Sampel Kultur (Darah, Urin, Sputum, dan Kerokan)', ''),
	(99, '100429', 'Dengue NS1 _', ''),
	(100, '106988', 'Real Time - PCR Covid-19 (Untuk Perjalanan)', ''),
	(101, '100411', 'Anti Rubella IgG _', ''),
	(102, '102296', 'IgM Salmonella (TF Semikuantitatif)', ''),
	(103, '106284', 'Vitamin D', ''),
	(104, '104314', 'Anti HBc Total', ''),
	(105, '100339', 'Sel LE _', ''),
	(106, '100341', 'Coombs\' Test', ''),
	(107, '100459', 'Beta  HCG  Kwantitatif _', ''),
	(108, '101520', 'Sputum BTA 1 X (Pewarnaan)', ''),
	(109, '107141', 'Pengambilan Sampel darah Keadaan Sulit ( Pasien Luka Bakar, Pasien Udema, Pasien Kemoterapi)', ''),
	(110, '100440', 'PSA _', ''),
	(111, '106750', 'Pengambilan Sampel Sputum', ''),
	(112, '100360', 'Urin Kehamilan (HCG) _', ''),
	(113, '100402', 'Anti HBs _', ''),
	(114, '100422', 'ASTO _', ''),
	(115, '106210', 'Darah Per Bag (UTD Provinsi Sul-Sel) (Tindakan Cross Matching dan Golongan Darah)', ''),
	(116, '106301', 'Hs Troponin I', ''),
	(117, '105762', 'Analisa Cairan Asites', ''),
	(118, '106278', 'Activated Clotting Time', ''),
	(119, '105763', 'Analisa Cairan Lain', ''),
	(120, '100468', 'Lepto Dipstick _', ''),
	(121, '101371', 'Plebotomi Tarapeutik	', ''),
	(122, '100406', 'Anti HAV  IgM _', ''),
	(123, '100412', 'Anti Rubella IgM _', ''),
	(124, '100475', 'Malaria Mikroskopik _', ''),
	(125, '100420', 'Widal _', ''),
	(126, '106213', 'Antigen Malaria', ''),
	(127, '106287', 'HCV RNA', ''),
	(128, '100372', 'Kreatinin Klrens _', ''),
	(129, '105775', 'Cool Box (1X Pengiriman Darah)', ''),
	(130, '101161', 'Gula Puasa Strip', ''),
	(131, '101162', 'Gula Darah 2 Jam Post Prandial (strip)', ''),
	(132, '100368', 'Glukose Toleransi _', ''),
	(133, '100405', 'Anti HBc IgM _', '');

-- membuang struktur untuk table lis_his.map_ruangan_lab
CREATE TABLE IF NOT EXISTS `map_ruangan_lab` (
  `id` int NOT NULL AUTO_INCREMENT,
  `lis_lab` varchar(10) NOT NULL DEFAULT '',
  `lis_lab_name` varchar(50) NOT NULL DEFAULT '',
  `his_lab` varchar(10) NOT NULL DEFAULT '',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=latin1;

-- Membuang data untuk tabel lis_his.map_ruangan_lab: ~0 rows (lebih kurang)
REPLACE INTO `map_ruangan_lab` (`id`, `lis_lab`, `lis_lab_name`, `his_lab`) VALUES
	(1, '1', 'Laboratorium Sentral', ''),
	(2, '2', 'Laboratorium Gawat Darurat', ''),
	(3, '3', '', ''),
	(4, '4', '', '');

-- membuang struktur untuk table lis_his.order_lab
CREATE TABLE IF NOT EXISTS `order_lab` (
  `asal_lab` varchar(10) DEFAULT NULL COMMENT '1=Lab Sentral,2=Lab IGD,3=Lab PCC',
  `kode_asal_lab` varchar(10) DEFAULT NULL,
  `nama_asal_lab` varchar(50) CHARACTER SET latin1 COLLATE latin1_swedish_ci DEFAULT NULL,
  `no_lab` varchar(15) DEFAULT NULL,
  `no_registrasi` varchar(25) DEFAULT NULL,
  `no_rm` varchar(15) DEFAULT NULL,
  `tgl_order` datetime DEFAULT NULL,
  `nama_pas` varchar(50) DEFAULT NULL,
  `jenis_kel` varchar(1) DEFAULT NULL COMMENT '1=Laki-laki, 0=Perempuan',
  `tgl_lahir` datetime DEFAULT NULL,
  `usia` varchar(10) DEFAULT NULL,
  `alamat` varchar(80) DEFAULT NULL,
  `kode_dok_kirim` varchar(10) DEFAULT NULL,
  `nama_dok_kirim` varchar(30) DEFAULT NULL COMMENT 'Nama Dokter',
  `kode_ruang` varchar(10) DEFAULT NULL,
  `nama_ruang` varchar(25) DEFAULT NULL COMMENT 'Nama Asal Di Register RS',
  `kode_carYUa_bayar` varchar(10) DEFAULT NULL,
  `cara_bayar` varchar(25) DEFAULT NULL,
  `ket_klinis` varchar(80) DEFAULT NULL COMMENT 'Diagnosa Awal',
  `test` varchar(2000) DEFAULT NULL COMMENT 'Kode Test/Tindakan',
  `order_item_id` varchar(25) DEFAULT NULL,
  `order_item_name` varchar(150) DEFAULT NULL,
  `waktu_kirim` datetime DEFAULT NULL,
  `prioritas` varchar(1) DEFAULT NULL,
  `jns_rawat` varchar(5) DEFAULT NULL COMMENT '1=RJ,2=RI,6=RDarurat,3=Konsul RJ,4=Konsul RI,7=Konsul RD',
  `dok_jaga` varchar(50) DEFAULT NULL,
  `batal` tinyint DEFAULT '0',
  `status` tinyint DEFAULT '0',
  KEY `no_registrasi` (`no_lab`,`no_registrasi`,`no_rm`,`tgl_order`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- Membuang data untuk tabel lis_his.order_lab: ~0 rows (lebih kurang)
REPLACE INTO `order_lab` (`asal_lab`, `kode_asal_lab`, `nama_asal_lab`, `no_lab`, `no_registrasi`, `no_rm`, `tgl_order`, `nama_pas`, `jenis_kel`, `tgl_lahir`, `usia`, `alamat`, `kode_dok_kirim`, `nama_dok_kirim`, `kode_ruang`, `nama_ruang`, `kode_cara_bayar`, `cara_bayar`, `ket_klinis`, `test`, `order_item_id`, `order_item_name`, `waktu_kirim`, `prioritas`, `jns_rawat`, `dok_jaga`, `batal`, `status`) VALUES
	('1', '101050103', 'Laboratorium Sentral', '2', '1010501032207220002', '932094', '2022-07-22 11:00:03', 'Muhammad Alwin', '1', '1989-02-11 00:00:00', NULL, 'Perintis Kemerdekaan IV', '64', 'Muhammad Al Fatih', '101030403', 'Perawatan Interna Kelas 2', '2', 'BPJS / JKN', NULL, '100312', '10323', 'Hematologi Rutin Automatik (tarif 24)', '2022-07-22 11:00:03', '0', '2', NULL, 0, 0),
	('1', '101050103', 'Laboratorium Sentral', '2', '1010501032207220002', '932094', '2022-07-22 11:00:03', 'Muhammad Alwin', '1', '1989-02-11 00:00:00', NULL, 'Perintis Kemerdekaan IV', '64', 'Muhammad Al Fatih', '101030403', 'Perawatan Interna Kelas 2', '2', 'BPJS / JKN', NULL, '100428', '10374', 'DHF IgG/IgM (Rapid)', '2022-07-22 11:00:03', '0', '2', NULL, 0, 0);

-- membuang struktur untuk trigger lis_his.hasil_lab_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_lab_before_insert` BEFORE INSERT ON `hasil_lab` FOR EACH ROW BEGIN
	DECLARE VTEST, VITEM VARCHAR(25);

	SET VTEST = LEFT(NEW.kode_test_his, 6);
		
	SELECT m.order_item_id
	  INTO VITEM
	  FROM lis_his.map_item_order m
	 WHERE m.test = VTEST
	 LIMIT 1;
	 
	IF NOT VITEM IS NULL THEN
	   SET NEW.his_test_id_order = VITEM;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis_his.hasil_lab_before_update
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `hasil_lab_before_update` BEFORE UPDATE ON `hasil_lab` FOR EACH ROW BEGIN
	DECLARE VTEST, VITEM VARCHAR(25);

	IF OLD.kode_test_his != NEW.kode_test_his THEN
		SET VTEST = LEFT(NEW.kode_test_his, 6);
			
		SELECT m.order_item_id
		  INTO VITEM
		  FROM lis_his.map_item_order m
		 WHERE m.test = VTEST
		 LIMIT 1;
		 
		IF NOT VITEM IS NULL THEN
		   SET NEW.his_test_id_order = VITEM;
		END IF;
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger lis_his.order_lab_before_insert
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `order_lab_before_insert` BEFORE INSERT ON `order_lab` FOR EACH ROW BEGIN
	-- Pengambilan kode test lis dan di set pada field test
	BEGIN	
		DECLARE VTEST VARCHAR(25);
		
		SELECT m.test
		  INTO VTEST
		  FROM lis_his.map_item_order m
		 WHERE m.order_item_id = NEW.order_item_id
		 LIMIT 1;
		 
		IF NOT VTEST IS NULL THEN
		   SET NEW.test = VTEST;
		END IF;
	END;
	
	-- Pengambilan kode lis lab dan di set pada field asal_lab
	BEGIN	
		DECLARE VLIS_LAB VARCHAR(25);
		
		SELECT m.lis_lab
		  INTO VLIS_LAB
		  FROM lis_his.map_ruangan_lab m
		 WHERE m.his_lab = NEW.kode_asal_lab
		 LIMIT 1;
		 
		IF NOT VLIS_LAB IS NULL THEN
		   SET NEW.asal_lab = VLIS_LAB;
		END IF;
	END;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

ALTER TABLE `hasil_lab`
	ADD INDEX `no_registrasi_kode_test` (`no_registrasi`, `kode_test`);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
