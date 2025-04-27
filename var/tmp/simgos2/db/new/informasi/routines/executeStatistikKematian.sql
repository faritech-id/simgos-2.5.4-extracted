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

-- membuang struktur untuk procedure informasi.executeStatistikKematian
DROP PROCEDURE IF EXISTS `executeStatistikKematian`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executeStatistikKematian`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTGL_AWAL DATETIME;
   DECLARE VTGL_AKHIR DATETIME;
	
   SET VTGL_AWAL = CONCAT(PTGL_AWAL, ' 00:00:01');
   SET VTGL_AKHIR = CONCAT(PTGL_AKHIR, ' 23:59:59');
	BEGIN
		DECLARE VTAHUN SMALLINT;
	   DECLARE VBULAN SMALLINT;
		DECLARE VKONTEN TEXT;
		DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
		DECLARE CR_EXEC CURSOR FOR 
				SELECT tahun, bulan, GROUP_CONCAT(konten) konten
				  FROM (
							SELECT YEAR(pm.TANGGAL) tahun, MONTH(pm.TANGGAL) bulan
									, CONCAT('{"kode_ruang":"',k.IDKEMKES,'","jumlah":"',COUNT(*),'"}') konten
							  FROM layanan.pasien_meninggal pm
							  	  , pendaftaran.kunjungan pk
							  	  , master.kemkes_kematian_dashboard k
							  	WHERE pm.KUNJUNGAN=pk.NOMOR AND pm.`STATUS`!=0 AND pk.`STATUS`!=0
							  	  AND pm.TANGGAL BETWEEN VTGL_AWAL AND VTGL_AKHIR
							  	  AND pk.RUANGAN=k.RUANG
							  	GROUP BY YEAR(pm.TANGGAL), MONTH(pm.TANGGAL), k.IDKEMKES
							) ab
				  GROUP BY tahun, bulan
			  	  ORDER BY tahun, bulan;
			
		DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
						
		OPEN CR_EXEC;
						
		EXIT_EXEC: LOOP
			FETCH CR_EXEC INTO VTAHUN, VBULAN, VKONTEN;
			
			IF EXEC_NOT_FOUND THEN
				UPDATE temp.temp t SET t.ID = 0 WHERE t.ID = 0;
				LEAVE EXIT_EXEC;
			END IF;
			
			IF EXISTS(SELECT 1 
					FROM informasi.statistik_jumlah_kematian sk 
				  WHERE sk.TAHUN = VTAHUN AND sk.BULAN=VBULAN) THEN
				UPDATE informasi.statistik_jumlah_kematian sk
				   SET sk.KONTEN = VKONTEN
				 WHERE sk.TAHUN = VTAHUN AND sk.BULAN=VBULAN;
			ELSE
				REPLACE INTO informasi.statistik_jumlah_kematian(TAHUN, BULAN, KONTEN)
					  VALUES (VTAHUN, VBULAN, VKONTEN);
			END IF;
		END LOOP;
		
		CLOSE CR_EXEC;
	END;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
