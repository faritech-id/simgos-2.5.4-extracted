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


-- Membuang struktur basisdata untuk lis_bridging
CREATE DATABASE IF NOT EXISTS `lis_bridging` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `lis_bridging`;

-- membuang struktur untuk table lis_bridging.demographics
CREATE TABLE IF NOT EXISTS `demographics` (
  `patient_id` varchar(50) NOT NULL,
  `gender_id` varchar(10) NOT NULL,
  `gender_name` varchar(50) NOT NULL,
  `date_of_birth` date NOT NULL,
  `patient_name` varchar(255) NOT NULL,
  `patient_address` text,
  `city_id` varchar(50) DEFAULT NULL,
  `city_name` varchar(50) DEFAULT NULL,
  `phone_number` varchar(50) DEFAULT NULL,
  `fax_number` varchar(50) DEFAULT NULL,
  `mobile_number` varchar(50) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`patient_id`) USING BTREE
) ENGINE=InnoDB;

-- Membuang data untuk tabel lis_bridging.demographics: ~2 rows (lebih kurang)
REPLACE INTO `demographics` (`patient_id`, `gender_id`, `gender_name`, `date_of_birth`, `patient_name`, `patient_address`, `city_id`, `city_name`, `phone_number`, `fax_number`, `mobile_number`, `email`) VALUES
	('1149503', '1', 'Laki - Laki', '1976-01-01', 'dede daryani', 'cihideung', '3205192009', 'DESAKOLOT', NULL, NULL, NULL, NULL),
	('1163251', '0', 'Perempuan', '1953-02-12', 'ROHYATI binti SUBRATA', 'KP CIKADU', '3205192001', 'CILAWU', NULL, NULL, NULL, NULL);

-- membuang struktur untuk table lis_bridging.ordered_item
CREATE TABLE IF NOT EXISTS `ordered_item` (
  `order_number` varchar(50) DEFAULT NULL,
  `order_item_id` varchar(50) DEFAULT NULL,
  `order_item_name` varchar(50) DEFAULT NULL,
  `order_item_datetime` datetime DEFAULT NULL,
  `order_status` tinyint DEFAULT '1' COMMENT '0 = batal; 1 = aktif',
  KEY `idx_order_number` (`order_number`) USING BTREE,
  KEY `idx_order_item_id` (`order_item_id`) USING BTREE,
  KEY `idx_order_item_name` (`order_item_name`) USING BTREE,
  KEY `idx_order_item_datetime` (`order_item_datetime`) USING BTREE
) ENGINE=InnoDB;

-- Membuang data untuk tabel lis_bridging.ordered_item: ~2 rows (lebih kurang)
REPLACE INTO `ordered_item` (`order_number`, `order_item_id`, `order_item_name`, `order_item_datetime`, `order_status`) VALUES
	('1010104011903280002', '1226', 'Glukosa 2 jam PP - 1xSdg2', '2019-03-28 16:57:55', 1),
	('1010104011904040008', '1231', 'SGOT - 1xSdg2', '2019-04-04 14:01:26', 1);

-- membuang struktur untuk table lis_bridging.registration
CREATE TABLE IF NOT EXISTS `registration` (
  `patient_id` varchar(50) NOT NULL,
  `visit_number` varchar(50) NOT NULL,
  `order_number` varchar(50) NOT NULL,
  `order_datetime` datetime NOT NULL,
  `diagnose_id` varchar(50) DEFAULT NULL,
  `diagnose_name` varchar(255) DEFAULT NULL,
  `service_unit_id` varchar(50) NOT NULL,
  `service_unit_name` varchar(255) NOT NULL,
  `guarantor_id` varchar(50) DEFAULT NULL,
  `guarantor_name` varchar(50) DEFAULT NULL,
  `agreement_id` bigint DEFAULT NULL,
  `agreement_name` text,
  `doctor_id` varchar(50) DEFAULT NULL,
  `doctor_name` varchar(50) DEFAULT NULL,
  `class_id` varchar(50) DEFAULT NULL,
  `class_name` varchar(50) DEFAULT NULL,
  `ward_id` varchar(50) DEFAULT NULL,
  `ward_name` varchar(50) DEFAULT NULL,
  `room_id` varchar(50) DEFAULT NULL,
  `room_name` varchar(50) DEFAULT NULL,
  `bed_id` varchar(50) DEFAULT NULL,
  `bed_name` varchar(50) DEFAULT NULL,
  `reg_user_id` varchar(20) DEFAULT NULL,
  `reg_user_name` varchar(50) DEFAULT NULL,
  `lis_reg_no` varchar(20) DEFAULT NULL,
  `retrieved_dt` datetime DEFAULT NULL,
  `retrieved_flag` char(1) DEFAULT NULL,
  PRIMARY KEY (`order_number`) USING BTREE
) ENGINE=InnoDB;

-- Membuang data untuk tabel lis_bridging.registration: ~2 rows (lebih kurang)
REPLACE INTO `registration` (`patient_id`, `visit_number`, `order_number`, `order_datetime`, `diagnose_id`, `diagnose_name`, `service_unit_id`, `service_unit_name`, `guarantor_id`, `guarantor_name`, `agreement_id`, `agreement_name`, `doctor_id`, `doctor_name`, `class_id`, `class_name`, `ward_id`, `ward_name`, `room_id`, `room_name`, `bed_id`, `bed_name`, `reg_user_id`, `reg_user_name`, `lis_reg_no`, `retrieved_dt`, `retrieved_flag`) VALUES
	('1149503', '1901150354', '1010104011903280002', '2019-03-28 16:57:55', NULL, NULL, '101010401', 'Laboratorium Klinik', '1', 'Tanpa Asuransi / Umum', 0, 'Non Kelas', '34', 'dr. Yanti Widamayanti, Sp.PD', '0', 'Non Kelas', '101010102', 'Klinik Dalam', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
	('1163251', '1904020224', '1010104011904040008', '2019-04-04 14:01:26', NULL, NULL, '101010401', 'Laboratorium Klinik', '2', 'BPJS / JKN', 0, 'Non Kelas', '22', 'dr. Hj. Shelvi Febrianti, Sp.PD', '0', 'Non Kelas', '101010102', 'Klinik Dalam', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

-- membuang struktur untuk table lis_bridging.result_bridge_lis
CREATE TABLE IF NOT EXISTS `result_bridge_lis` (
  `lis_reg_no` varchar(10) NOT NULL,
  `lis_test_id` varchar(25) NOT NULL,
  `his_reg_no` varchar(50) DEFAULT NULL,
  `test_name` varchar(50) DEFAULT NULL,
  `result` text,
  `result_comment` text,
  `reference_value` text,
  `reference_note` text,
  `test_flag_sign` varchar(5) DEFAULT NULL,
  `test_unit_name` varchar(25) DEFAULT NULL,
  `instrument_name` varchar(50) DEFAULT NULL,
  `authorization_date` datetime DEFAULT NULL,
  `authorization_user` varchar(50) DEFAULT NULL,
  `greaterthan_value` varchar(50) DEFAULT NULL,
  `lessthan_value` varchar(50) DEFAULT NULL,
  `company_id` varchar(10) DEFAULT NULL,
  `agreement_id` varchar(10) DEFAULT NULL,
  `age_year` varchar(3) DEFAULT NULL,
  `age_month` varchar(2) DEFAULT NULL,
  `age_days` varchar(2) DEFAULT NULL,
  `his_test_id_order` varchar(50) DEFAULT NULL,
  `transfer_flag` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`lis_reg_no`,`lis_test_id`) USING BTREE,
  KEY `his_reg_no` (`his_reg_no`) USING BTREE,
  KEY `idx_lis_reg_no` (`lis_reg_no`) USING BTREE,
  KEY `idx_transfer_flag` (`transfer_flag`) USING BTREE
) ENGINE=InnoDB;

-- Membuang data untuk tabel lis_bridging.result_bridge_lis: ~2 rows (lebih kurang)
REPLACE INTO `result_bridge_lis` (`lis_reg_no`, `lis_test_id`, `his_reg_no`, `test_name`, `result`, `result_comment`, `reference_value`, `reference_note`, `test_flag_sign`, `test_unit_name`, `instrument_name`, `authorization_date`, `authorization_user`, `greaterthan_value`, `lessthan_value`, `company_id`, `agreement_id`, `age_year`, `age_month`, `age_days`, `his_test_id_order`, `transfer_flag`) VALUES
	('1901150354', '00000001', '1010104011903280002', 'Glu', '80', NULL, '70-90', NULL, NULL, 'mmHg', 'Gastat-602i', '2019-03-29 15:05:18', '10034', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1226', 2),
	('1904020224', '00000005', '1010104011904040008', 'SGOT - 1xSdg2', '25', NULL, '52', NULL, NULL, 'mmHg', 'gastat-602i', '2019-04-04 14:04:44', '10034', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '1231', 2);

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
