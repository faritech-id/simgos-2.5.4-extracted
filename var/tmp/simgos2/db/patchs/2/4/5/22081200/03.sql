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

-- membuang struktur untuk function master.getJawabanKonsul
DROP FUNCTION IF EXISTS `getJawabanKonsul`;
DELIMITER //
CREATE FUNCTION `getJawabanKonsul`(
	`PNOPEN` CHAR(10)
) RETURNS text CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE HASIL TEXT;
	
	SELECT (GROUP_CONCAT(KONSUL SEPARATOR ' \r'))
	  INTO HASIL
	  FROM (
		SELECT CONCAT('- KSM/Bagian : ',smf.DESKRIPSI,' \r', '- Jawaban : ', jk.JAWABAN,' \r','- Anjuran : ', jk.ANJURAN,'; ') KONSUL
		  FROM pendaftaran.jawaban_konsul jk
				 LEFT JOIN master.dokter_smf mds ON jk.DOKTER = mds.DOKTER
				 LEFT JOIN master.referensi smf ON mds.SMF = smf.ID AND smf.JENIS = 26,
				 pendaftaran.kunjungan k
		 WHERE jk.KONSUL_NOMOR = k.REF
			AND k.`STATUS` != 0 
			AND k.NOPEN = PNOPEN
	  ) a;
	  
	RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
