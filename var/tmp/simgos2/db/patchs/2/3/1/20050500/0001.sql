-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `kemkes`;

-- membuang struktur untuk procedure kemkes.statistikPasien
DROP PROCEDURE IF EXISTS `statistikPasien`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `statistikPasien`()
    DETERMINISTIC
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_STATISTIK_PASIEN;
	DROP TEMPORARY TABLE IF EXISTS TEMP_ROW_STATISTIK_PASIEN;	

	CREATE TEMPORARY TABLE TEMP_STATISTIK_PASIEN ENGINE=MEMORY
	SELECT IFNULL(SUM(IF(p.status_rawat = 3, 1, 0)), 0) JML_COVID
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 0, 1, 0)), 0) JML_COVID_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 1, 1, 0)), 0) JML_COVID_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 2, 1, 0)), 0) JML_COVID_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 4, 1, 0)), 0) JML_COVID_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 3 AND p.status_keluar = 3, 1, 0)), 0) JML_COVID_DIRUJUK
			 
			 , IFNULL(SUM(IF(p.status_rawat = 2, 1, 0)), 0) JML_PDP
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 0, 1, 0)), 0) JML_PDP_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 1, 1, 0)), 0) JML_PDP_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 2, 1, 0)), 0) JML_PDP_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 4, 1, 0)), 0) JML_PDP_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 2 AND p.status_keluar = 3, 1, 0)), 0) JML_PDP_DIRUJUK
			 
			 , IFNULL(SUM(IF(p.status_rawat = 1, 1, 0)), 0) JML_ODP		 
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 0, 1, 0)), 0) JML_ODP_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 1, 1, 0)), 0) JML_ODP_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 2, 1, 0)), 0) JML_ODP_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 4, 1, 0)), 0) JML_ODP_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 1 AND p.status_keluar = 3, 1, 0)), 0) JML_ODP_DIRUJUK
			 
			 , IFNULL(SUM(IF(p.status_rawat = 4, 1, 0)), 0) JML_OTG
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 0, 1, 0)), 0) JML_OTG_DIRAWAT
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 1, 1, 0)), 0) JML_OTG_SEMBUH
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 2, 1, 0)), 0) JML_OTG_MENINGGAL
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 4, 1, 0)), 0) JML_OTG_ISOLASI
			 , IFNULL(SUM(IF(p.status_rawat = 4 AND p.status_keluar = 3, 1, 0)), 0) JML_OTG_DIRUJUK
	  FROM kemkes.pasien p
	 WHERE p.hapus = 0;

	CREATE TEMPORARY TABLE TEMP_ROW_STATISTIK_PASIEN (
		`ID` TINYINT,
		`JUDUL` VARCHAR(25),
		`DESKRIPSI` VARCHAR(50),
		`TOTAL` INT,
		`DIRAWAT` INT,
		`SEMBUH` INT,
		`MENINGGAL` INT,
		`ISOLASI` INT,
		`DIRUJUK` INT
	)
	ENGINE=MEMORY;
	
  	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
  	SELECT 1 ID, 'PASIEN COVID' JUDUL, 'Positif COVID - 19' DESKRIPSI
  			, JML_COVID TOTAL, JML_COVID_DIRAWAT DIRAWAT, JML_COVID_SEMBUH SEMBUH
			, JML_COVID_MENINGGAL MENINGGAL, JML_COVID_ISOLASI ISOLASI, JML_COVID_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;
	 
	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
	SELECT 2 ID, 'PDP' JUDUL, 'Pasien Dalam Pengawasan' DESKRIPSI
  			, JML_PDP TOTAL, JML_PDP_DIRAWAT DIRAWAT, JML_PDP_SEMBUH SEMBUH
			, JML_PDP_MENINGGAL MENINGGAL, JML_PDP_ISOLASI ISOLASI, JML_PDP_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;
	 
	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
	SELECT 3 ID, 'ODP' JUDUL, 'Orang Dalam Pemantauan' DESKRIPSI
  			, JML_ODP TOTAL, JML_ODP_DIRAWAT DIRAWAT, JML_ODP_SEMBUH SEMBUH
			, JML_ODP_MENINGGAL MENINGGAL, JML_ODP_ISOLASI ISOLASI, JML_ODP_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;
	 
	INSERT INTO TEMP_ROW_STATISTIK_PASIEN 
	SELECT 4 ID, 'OTG' JUDUL, 'Orang Tanpa Gejala' DESKRIPSI
  			, JML_OTG TOTAL, JML_OTG_DIRAWAT DIRAWAT, JML_OTG_SEMBUH SEMBUH
			, JML_OTG_MENINGGAL MENINGGAL, JML_OTG_ISOLASI ISOLASI, JML_OTG_DIRUJUK DIRUJUK  
	 FROM TEMP_STATISTIK_PASIEN;	

  SELECT *
    FROM TEMP_ROW_STATISTIK_PASIEN;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
