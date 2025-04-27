-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for master
CREATE DATABASE IF NOT EXISTS `master`;
USE `master`;

-- Dumping structure for function master.getDiagnosa
DROP FUNCTION IF EXISTS `getDiagnosa`;
DELIMITER //
CREATE FUNCTION `getDiagnosa`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR) mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosaMeninggal
DROP FUNCTION IF EXISTS `getDiagnosaMeninggal`;
DELIMITER //
CREATE FUNCTION `getDiagnosaMeninggal`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR) mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa_meninggal md 
		WHERE mr.CODE=md.KODE AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosaMR1
DROP FUNCTION IF EXISTS `getDiagnosaMR1`;
DELIMITER //
CREATE FUNCTION `getDiagnosaMR1`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r') INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR, ' (', mr.CODE,')') mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getDiagnosaPasien
DROP FUNCTION IF EXISTS `getDiagnosaPasien`;
DELIMITER //
CREATE FUNCTION `getDiagnosaPasien`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT  GROUP_CONCAT(mrcode) INTO HASIL
	FROM (SELECT CONCAT(mr.CODE,'-[',mr.STR,']') mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE  AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE
	ORDER BY  md.ID) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getICD10
DROP FUNCTION IF EXISTS `getICD10`;
DELIMITER //
CREATE FUNCTION `getICD10`(
	`PCODE` CHAR(6)
) RETURNS varchar(250) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(250);
   
	SELECT CONCAT(mr.CODE,'- ',mr.STR) mrcode INTO HASIL
		FROM master.mrconso mr
		WHERE mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND mr.CODE=PCODE
	GROUP BY mr.CODE
	LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getICD9CM
DROP FUNCTION IF EXISTS `getICD9CM`;
DELIMITER //
CREATE FUNCTION `getICD9CM`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode SEPARATOR ';'),';','\r')  INTO HASIL
	FROM (SELECT CONCAT('- ',mr.STR) mrcode, pr.ID 
			FROM master.mrconso mr,
								medicalrecord.prosedur pr 
					WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=PNOPEN
					  AND mr.SAB='ICD9CM_2005' AND TTY IN ('PX', 'PT') AND pr.INA_GROUPER=0
					GROUP BY pr.KODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeDiagnosa
DROP FUNCTION IF EXISTS `getKodeDiagnosa`;
DELIMITER //
CREATE FUNCTION `getKodeDiagnosa`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT mr.CODE mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1 AND md.NOPEN=PNOPEN
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT') AND md.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeDiagnosaMeninggal
DROP FUNCTION IF EXISTS `getKodeDiagnosaMeninggal`;
DELIMITER //
CREATE FUNCTION `getKodeDiagnosaMeninggal`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT mr.CODE mrcode, md.ID 
		FROM master.mrconso mr,
			   medicalrecord.diagnosa_meninggal md 
		WHERE mr.CODE=md.KODE AND md.`STATUS`=1 AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD10
DROP FUNCTION IF EXISTS `getKodeICD10`;
DELIMITER //
CREATE FUNCTION `getKodeICD10`(
	`PNOPEN` CHAR(10),
	`PBARIS` INT,
	`PUTAMA` TINYINT
) RETURNS char(5) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL CHAR(5);
	
	SET @row=0;
		SELECT KODE INTO HASIL
		FROM(
		SELECT KODE , @row:=@row+1 r
		FROM medicalrecord.diagnosa 
			 WHERE NOPEN = PNOPEN AND UTAMA=PUTAMA AND STATUS!=0 AND INA_GROUPER=0
			 ORDER BY UTAMA, ID) a
		WHERE r=PBARIS;
			  
	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD9
DROP FUNCTION IF EXISTS `getKodeICD9`;
DELIMITER //
CREATE FUNCTION `getKodeICD9`(
	`PNOPEN` CHAR(10),
	`PBARIS` TINYINT
) RETURNS char(5) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL CHAR(5);
	
	SET @row=0;
	SELECT KODE INTO HASIL
		FROM(
			SELECT KODE, @row:=@row+1 r 
			FROM medicalrecord.prosedur  
		   WHERE NOPEN = PNOPEN AND STATUS!=0 AND INA_GROUPER=0
		  ORDER BY ID) a
		WHERE r=PBARIS;
			  
	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getKodeICD9CM
DROP FUNCTION IF EXISTS `getKodeICD9CM`;
DELIMITER //
CREATE FUNCTION `getKodeICD9CM`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT mr.CODE mrcode, pr.ID 
		FROM master.mrconso mr,
			  	medicalrecord.prosedur pr 
		WHERE mr.CODE=pr.KODE AND pr.`STATUS`=1 AND pr.NOPEN=PNOPEN
		  AND mr.SAB='ICD9CM_2005' AND TTY IN ('PX', 'PT') AND pr.INA_GROUPER=0
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

-- Dumping structure for function master.getTblDiagnosa
DROP FUNCTION IF EXISTS `getTblDiagnosa`;
DELIMITER //
CREATE FUNCTION `getTblDiagnosa`(
	`PNOPEN` CHAR(10),
	`PUTAMA` INT
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT REPLACE(GROUP_CONCAT(mrcode),',','\r') INTO HASIL
	FROM (SELECT CONCAT(mr.CODE,'- ',mr.STR) mrcode, md.ID
		FROM master.mrconso mr,
			   medicalrecord.diagnosa md 
		WHERE mr.CODE=md.KODE AND md.UTAMA=PUTAMA AND md.`STATUS`=1
		  AND md.NOPEN=PNOPEN AND md.INA_GROUPER=0
		  AND mr.SAB='ICD10_1998' AND TTY IN ('PX', 'PT')
	GROUP BY mr.CODE) a
	ORDER BY ID;

	RETURN HASIL;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
