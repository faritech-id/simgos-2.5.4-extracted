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

-- membuang struktur untuk procedure informasi.executeStatistik10BesarPenyakitRujukan
DROP PROCEDURE IF EXISTS `executeStatistik10BesarPenyakitRujukan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executeStatistik10BesarPenyakitRujukan`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTAHUN SMALLINT;
	DECLARE VBULAN TINYINT;
	DECLARE VJENIS_PELAYANAN TINYINT;
	DECLARE VKONTEN TEXT;
	
	DECLARE VAWAL, VAKHIR DATETIME;
	DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
	DECLARE CR_EXEC CURSOR FOR 
		SELECT DATE_FORMAT(TANGGAL,'%Y-%m-01 00:00:00'), CONCAT(LAST_DAY(TANGGAL),' 23:59:59')
		  FROM master.tanggal
		 WHERE TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR
		 GROUP BY DATE_FORMAT(TANGGAL,'%Y-%m');
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
					
	OPEN CR_EXEC;
					
	EXIT_EXEC: LOOP
		FETCH CR_EXEC INTO VAWAL, VAKHIR;
		
		IF EXEC_NOT_FOUND THEN
			UPDATE temp.temp t SET t.ID = 0 WHERE t.ID = 0;
			LEAVE EXIT_EXEC;
		END IF;
		
		BEGIN
			DECLARE EXEC_NOT_FOUND_RI TINYINT DEFAULT FALSE;		
			DECLARE CR_EXEC_RI CURSOR FOR 
				SELECT TAHUN, BULAN, GROUP_CONCAT(konten) KONTEN
				  FROM (
							SELECT YEAR(pp.TANGGAL) TAHUN, MONTH(pp.TANGGAL) BULAN
								  , CONCAT('{"kode_icd_10":"',dm.ICD,'","jumlah":"',COUNT(*),'"}') konten
								  , COUNT(*) JUMLAH_KASUS
							  FROM pendaftaran.pendaftaran pp
							  	  , pendaftaran.tujuan_pasien tp
							  	  , master.ruangan r
							  	  , master.diagnosa_masuk dm
							 WHERE pp.RUJUKAN IS NOT NULL AND pp.`STATUS`!=0
							   AND pp.TANGGAL BETWEEN VAWAL AND VAKHIR
							   AND pp.NOMOR=tp.NOPEN AND tp.`STATUS`!=0 AND tp.RUANGAN=r.ID
							   AND r.JENIS_KUNJUNGAN IN (1,2) AND pp.DIAGNOSA_MASUK=dm.ID
							GROUP BY YEAR(pp.TANGGAL), MONTH(pp.TANGGAL), dm.ICD
							ORDER BY JUMLAH_KASUS DESC LIMIT 10
							) ab
					GROUP BY TAHUN, BULAN;
				
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND_RI = TRUE;
							
			OPEN CR_EXEC_RI;
							
			EXIT_EXEC_RI: LOOP
				FETCH CR_EXEC_RI INTO VTAHUN, VBULAN, VKONTEN;
				
				IF EXEC_NOT_FOUND_RI THEN
					UPDATE temp.temp t SET t.ID = 0 WHERE t.ID = 0;
					LEAVE EXIT_EXEC_RI;
				END IF;
				
				IF EXISTS(SELECT 1 
						FROM informasi.statistik_10_besar_diagnosa_rujukan bp 
					  WHERE bp.TAHUN = VTAHUN
					    AND bp.BULAN = VBULAN
						 AND bp.JENIS_RUJUKAN = 2) THEN
					UPDATE informasi.statistik_10_besar_diagnosa_rujukan bp
					   SET bp.KONTEN = VKONTEN
					 WHERE bp.TAHUN = VTAHUN
					   AND bp.BULAN = VBULAN
						AND bp.JENIS_RUJUKAN = 2;
				ELSE
					REPLACE INTO informasi.statistik_10_besar_diagnosa_rujukan(TAHUN, BULAN, JENIS_RUJUKAN, KONTEN)
					VALUES (VTAHUN, VBULAN, 2, VKONTEN);
				END IF;
			END LOOP;
			CLOSE CR_EXEC_RI;
		END;
	
	END LOOP;
	CLOSE CR_EXEC;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
