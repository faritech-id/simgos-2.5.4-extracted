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

-- membuang struktur untuk function master.getNopenIRD
DROP FUNCTION IF EXISTS `getNopenIRD`;
DELIMITER //
CREATE FUNCTION `getNopenIRD`(
	`PNORM` INT,
	`PTANGGAL` DATETIME
) RETURNS char(10) CHARSET latin1
    DETERMINISTIC
BEGIN
   DECLARE HASIL CHAR(10);
   
	SELECT pr.NOMOR INTO HASIL	
		FROM pendaftaran.pendaftaran pr
			, pendaftaran.tujuan_pasien tpr
			, master.ruangan rpr
			, pendaftaran.kunjungan kpr
			  LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kpr.RUANG_KAMAR_TIDUR
		  	  LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  	  LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		WHERE pr.NORM=PNORM AND pr.TANGGAL < PTANGGAL AND HOUR(TIMEDIFF(PTANGGAL, pr.TANGGAL)) <= 24 AND pr.`STATUS`!=0 AND pr.NOMOR=tpr.NOPEN
		  AND tpr.RUANGAN=rpr.ID AND rpr.JENIS_KUNJUNGAN=2		  
		  AND pr.NOMOR=kpr.NOPEN AND kpr.REF IS NULL AND kpr.`STATUS`!=0
		ORDER BY pr.TANGGAL DESC
		LIMIT 1;
 
  RETURN HASIL;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
