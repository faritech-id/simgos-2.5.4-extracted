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

-- membuang struktur untuk procedure informasi.executeStatistiKunjungan
DROP PROCEDURE IF EXISTS `executeStatistiKunjungan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `executeStatistiKunjungan`(
	IN `PTGL_AWAL` DATE,
	IN `PTGL_AKHIR` DATE
)
BEGIN
	DECLARE VTANGGAL DATE;
	DECLARE VRJ INT;
	DECLARE VRD INT;
	DECLARE VRI INT;
	DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
	DECLARE CR_EXEC CURSOR FOR 
		SELECT tanggal, SUM(kunjungan_rj) kunjungan_rj, SUM(kunjungan_igd) kunjungan_igd, SUM(pasien_ri) pasien_ri
		  FROM (
			SELECT k.TANGGAL tanggal, SUM(k.VALUE) kunjungan_rj, 0 kunjungan_igd, 0 pasien_ri
			  FROM informasi.kunjungan k 
			  	    , master.tanggal t
			 WHERE k.ID=1 AND k.TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR
			   AND k.TANGGAL=t.TANGGAL
			 GROUP BY k.TANGGAL
			UNION
			SELECT p.TANGGAL tanggal, 0 kunjungan_rj, SUM(p.VALUE) kunjungan_igd, 0 pasien_ri
			  FROM informasi.pengunjung p
				    , master.tanggal t
			 WHERE p.ID=2 AND p.TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR
				AND p.TANGGAL=t.TANGGAL 
			 GROUP BY p.TANGGAL
			UNION
			SELECT i.TANGGAL tanggal, 0 kunjungan_rj, 0 kunjungan_igd, SUM(i.HP)  pasien_ri
			  FROM informasi.indikator_rs i
			  	    , master.tanggal t
			 WHERE i.TANGGAL BETWEEN PTGL_AWAL AND PTGL_AKHIR
				AND i.TANGGAL=t.TANGGAL 
			 GROUP BY i.TANGGAL
			) ab
	   GROUP BY tanggal;
		
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
					
	OPEN CR_EXEC;
					
	EXIT_EXEC: LOOP
		FETCH CR_EXEC INTO VTANGGAL, VRJ, VRD, VRI;
		
		IF EXEC_NOT_FOUND THEN
			UPDATE temp.temp t SET t.ID = 0 WHERE t.ID = 0;
			LEAVE EXIT_EXEC;
		END IF;
		
		SET VRJ = IFNULL(VRJ, 0);
		SET VRD = IFNULL(VRD, 0);
		SET VRI = IFNULL(VRI, 0);
		
		IF EXISTS(SELECT 1 
				FROM informasi.statistik_kunjungan sk 
			  WHERE sk.TANGGAL = VTANGGAL) THEN
			UPDATE informasi.statistik_kunjungan sk
			   SET sk.RJ = VRJ, sk.RD = VRD, sk.RI = VRI
			 WHERE TANGGAL = VTANGGAL;
		ELSE
			REPLACE INTO informasi.statistik_kunjungan(TANGGAL, RJ, RD, RI)
				  VALUES (VTANGGAL, VRJ, VRD, VRI);
		END IF;
	END LOOP;
	
	CLOSE CR_EXEC;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
