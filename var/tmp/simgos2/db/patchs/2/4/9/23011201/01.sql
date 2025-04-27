
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


-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk function master.getDPJP
DROP FUNCTION IF EXISTS `getDPJP`;
DELIMITER //
CREATE FUNCTION `getDPJP`(
	`PNOPEN` CHAR(10),
	`PJENIS` TINYINT
) RETURNS varchar(75) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL VARCHAR(75);
   
	SELECT IF(PJENIS=1, d.NIP, `master`.getNamaLengkapPegawai(d.NIP)) INTO HASIL 
		FROM pendaftaran.kunjungan k 
			, master.dokter d 
			, `master`.ruangan r
		WHERE k.NOPEN=PNOPEN AND k.DPJP!=0 AND k.DPJP=d.ID AND k.RUANGAN=r.ID AND r.JENIS_KUNJUNGAN=3
		ORDER BY k.MASUK  DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
