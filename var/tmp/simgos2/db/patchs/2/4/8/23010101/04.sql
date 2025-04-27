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


-- Membuang struktur basisdata untuk medicalrecord
USE `medicalrecord`;

-- membuang struktur untuk function medicalrecord.getHasilLaboratoriumResume
DROP FUNCTION IF EXISTS `getHasilLaboratoriumResume`;
DELIMITER //
CREATE FUNCTION `getHasilLaboratoriumResume`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL TEXT;
   
	SELECT GROUP_CONCAT(DISTINCT(CONCAT(ptl.PARAMETER,'=', hlab.HASIL,' ', IF(sl.DESKRIPSI IS NULL,'',sl.DESKRIPSI)))) INTO HASIL
	  FROM medicalrecord.`resume` r, 
	        JSON_TABLE(r.HASIL_RAD,
	         '$[*]' COLUMNS(
	                ID INT PATH '$.ID'
						
	            )   
	       ) AS hl
	     , layanan.hasil_lab hlab
	     , master.parameter_tindakan_lab ptl
			 LEFT JOIN master.referensi sl ON ptl.SATUAN=sl.ID AND sl.JENIS=35
	WHERE r.NOPEN=PNOPEN AND hl.ID=hlab.ID AND hlab.`STATUS`!=0 AND hlab.PARAMETER_TINDAKAN=ptl.ID AND ptl.`STATUS`!=0
		;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
