-- --------------------------------------------------------
-- Host:                         192.168.137.2
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- membuang struktur untuk procedure informasi.executeStatistikRujukan
DROP PROCEDURE IF EXISTS `executeStatistikRujukan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executeStatistikRujukan`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTGL_AWAL DATETIME;
   DECLARE VTGL_AKHIR DATETIME;
	
   SET VTGL_AWAL = CONCAT(PTGL_AWAL, ' 00:00:01');
   SET VTGL_AKHIR = CONCAT(PTGL_AKHIR, ' 23:59:59');
	BEGIN
		DECLARE VTANGGAL DATE;
	   DECLARE VMASUK SMALLINT;
		DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
		DECLARE CR_EXEC CURSOR FOR 
				SELECT DATE(pp.TANGGAL) tanggal, COUNT(*) jumlah_rujukan
				  FROM pendaftaran.pendaftaran pp
				  	  , pendaftaran.tujuan_pasien tp
				  	  , master.ruangan r
				 WHERE pp.RUJUKAN IS NOT NULL AND pp.`STATUS`!=0
				   AND pp.TANGGAL BETWEEN VTGL_AWAL AND VTGL_AKHIR
				   AND pp.NOMOR=tp.NOPEN AND tp.`STATUS`!=0 AND tp.RUANGAN=r.ID
				   AND r.JENIS_KUNJUNGAN IN (1,2)
			 GROUP BY DATE(pp.TANGGAL);
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
						
		OPEN CR_EXEC;
						
		EXIT_EXEC: LOOP
			FETCH CR_EXEC INTO VTANGGAL, VMASUK;
			
			IF EXEC_NOT_FOUND THEN
				UPDATE temp.temp t SET t.ID = 0 WHERE t.ID = 0;
				LEAVE EXIT_EXEC;
			END IF;
			
			IF EXISTS(SELECT 1 
					FROM informasi.statistik_rujukan sr
				  WHERE sr.TANGGAL = VTANGGAL) THEN
				UPDATE informasi.statistik_rujukan sr
				   SET sr.MASUK = VMASUK
				 WHERE sr.TANGGAL = VTANGGAL;
			ELSE
				REPLACE INTO informasi.statistik_rujukan(TANGGAL, MASUK)
					  VALUES (VTANGGAL, VMASUK);
			END IF;
		END LOOP;
		
		CLOSE CR_EXEC;
	END;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
