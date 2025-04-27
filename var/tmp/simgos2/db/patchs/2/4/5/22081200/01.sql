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


-- Membuang struktur basisdata untuk master
CREATE DATABASE IF NOT EXISTS `master`;
USE `master`;

-- membuang struktur untuk function master.getAturanPakai
DROP FUNCTION IF EXISTS `getAturanPakai`;
DELIMITER //
CREATE FUNCTION `getAturanPakai`(
	`PKODE` VARCHAR(250)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VATURAN_PAKAI VARCHAR(250);
	
	SELECT DESKRIPSI INTO VATURAN_PAKAI
	  FROM referensi ref 
	WHERE ref.JENIS = 41 
	  AND CONCAT('',ref.ID,'') = PKODE;
	 
	IF VATURAN_PAKAI IS NULL THEN
		SET VATURAN_PAKAI = PKODE;
	END IF;

	RETURN VATURAN_PAKAI;
END//
DELIMITER ;

-- membuang struktur untuk function master.getDiagnosaMeninggal
DROP FUNCTION IF EXISTS `getDiagnosaMeninggal`;
DELIMITER //
CREATE FUNCTION `getDiagnosaMeninggal`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	  FROM (
		SELECT CONCAT('- ',mr.STR) mrcode, md.ID 
		  FROM master.mrconso mr,
			    medicalrecord.diagnosa_meninggal md 
		 WHERE mr.CODE = md.KODE 
		   AND md.`STATUS` = 1 
			AND md.NOPEN = PNOPEN
		   AND mr.SAB = 'ICD10_1998' 
			AND TTY IN ('PX', 'PT')
	    GROUP BY mr.CODE
	  ) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- membuang struktur untuk function master.getDokterTindakan
DROP FUNCTION IF EXISTS `getDokterTindakan`;
DELIMITER //
CREATE FUNCTION `getDokterTindakan`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(DOKTER SEPARATOR ';'),';',' ; ')  
	  INTO HASIL
	  FROM (
		SELECT DISTINCT(CONCAT('- ',master.getNamaLengkapPegawai(md.NIP))) DOKTER, md.ID
		  FROM master.dokter md,
			    layanan.petugas_tindakan_medis ptm,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k,
			    master.ruangan r 
		 WHERE md.ID = ptm.MEDIS 
		   AND ptm.JENIS IN (1,2) 
			AND ptm.`STATUS` = 1 
			AND ptm.TINDAKAN_MEDIS = tm.ID 
			AND tm.`STATUS` = 1
		   AND tm.KUNJUNGAN = k.NOMOR 
			AND k.`STATUS` != 0 
			AND k.RUANGAN = r.ID 
			AND r.JENIS = 5 
			AND r.JENIS_KUNJUNGAN NOT IN (0,4,5,11,13,14)
		   AND NOT EXISTS (SELECT 1 FROM layanan.pasien_pulang pp WHERE pp.NOPEN = k.NOPEN AND pp.DOKTER = ptm.MEDIS AND pp.`STATUS` != 0 LIMIT 1)
		   AND k.NOPEN = PNOPEN
     ) a
   ORDER BY DOKTER;

	RETURN HASIL;
END//
DELIMITER ;

-- membuang struktur untuk function master.getKodeDiagnosaMeninggal
DROP FUNCTION IF EXISTS `getKodeDiagnosaMeninggal`;
DELIMITER //
CREATE FUNCTION `getKodeDiagnosaMeninggal`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') 
	  INTO HASIL
	  FROM (
	   SELECT mr.CODE mrcode, md.ID 
		  FROM master.mrconso mr,
			    medicalrecord.diagnosa_meninggal md 
		 WHERE mr.CODE = md.KODE 
		   AND md.`STATUS` = 1 
			AND md.NOPEN = PNOPEN
		   AND mr.SAB = 'ICD10_1998' 
			AND TTY IN ('PX', 'PT')
	    GROUP BY mr.CODE
	  ) a
	 ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- membuang struktur untuk function master.getTindakanKonsul
DROP FUNCTION IF EXISTS `getTindakanKonsul`;
DELIMITER //
CREATE FUNCTION `getTindakanKonsul`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(TINDAKAN SEPARATOR ';'))  INTO HASIL
	  FROM (
	   SELECT CONCAT('- ',mt.NAMA) TINDAKAN
		  FROM master.tindakan mt,
			    layanan.tindakan_medis tm,
			    pendaftaran.kunjungan k
		  WHERE mt.ID = tm.TINDAKAN 
		    AND tm.`STATUS` != 0 
			 AND k.REF IS NOT NULL
		    AND tm.KUNJUNGAN = k.NOMOR 
			 AND k.`STATUS` != 0 
			 AND mt.JENIS NOT IN (7,8,9) 
			 AND k.NOPEN = PNOPEN
		GROUP BY mt.ID
	  ) a
	ORDER BY TINDAKAN;

	RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
