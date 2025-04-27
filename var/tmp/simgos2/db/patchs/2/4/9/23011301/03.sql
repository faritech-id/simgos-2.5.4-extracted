-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
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

-- membuang struktur untuk procedure medicalrecord.CetakMR2ProsedurLain
DROP PROCEDURE IF EXISTS `CetakMR2ProsedurLain`;
DELIMITER //
CREATE PROCEDURE `CetakMR2ProsedurLain`(
	IN `PNOPEN` CHAR(10)
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_DATA_PROSEDUR;
	CREATE TEMPORARY TABLE TEMP_DATA_PROSEDUR ENGINE=MEMORY
    SELECT r.NOPEN, jt.IDPROSEDUR
        FROM medicalrecord.`resume` r, 
                JSON_TABLE(r.DIAGNOSA_PROSEDUR,
                '$[*]' COLUMNS(
                        ID INT PATH '$.ID',
                        UTAMA INT PATH '$.UTAMA',
                        NESTED PATH '$.PROSEDUR[*]' 
                            COLUMNS (
                            IDPROSEDUR VARCHAR(10) PATH '$.IDPROSEDUR'
                            )
                    )   
            ) AS jt
        WHERE r.NOPEN=PNOPEN;

	SELECT pr.NOPEN,  pr.KODE KODE_PROSEDUR, IFNULL(`master`.getDeskripsiICD(pr.KODE),pr.TINDAKAN) DESKRIPSI_PROSEDUR
		FROM medicalrecord.prosedur pr
			 LEFT JOIN TEMP_DATA_PROSEDUR p ON pr.NOPEN=p.NOPEN AND pr.ID=p.IDPROSEDUR
	WHERE pr.`STATUS`!=0 AND pr.INA_GROUPER=0 AND pr.NOPEN=PNOPEN AND p.IDPROSEDUR IS NULL AND pr.INACBG=1 ;	 	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
