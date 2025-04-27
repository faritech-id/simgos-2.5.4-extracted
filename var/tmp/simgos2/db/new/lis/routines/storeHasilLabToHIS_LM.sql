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

-- membuang struktur untuk procedure lis.storeHasilLabToHIS_LM
DROP PROCEDURE IF EXISTS `storeHasilLabToHIS_LM`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeHasilLabToHIS_LM`(
	IN `PID` BIGINT
)
BEGIN
	DECLARE VID BIGINT;
	DECLARE VTINDAKAN_MEDIS CHAR(11);
	DECLARE VPARAMETER_TINDAKAN_LAB INT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VHASIL VARCHAR(250);
	DECLARE VTINDAKAN SMALLINT;
	DECLARE VDOKTER INT;
	DECLARE VOPERATOR SMALLINT;
	DECLARE VKUNJUNGAN CHAR(25);
	DECLARE VSTATUS TINYINT DEFAULT 2;
	DECLARE SUCCESS INT DEFAULT TRUE;	
	DECLARE DATA_NOT_FOUND INT DEFAULT FALSE;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	
	SELECT hl.HIS_NO_LAB, hl.ID, tm.no_tindakan TINDAKAN_MEDIS, mh.HIS_KODE_TEST, mh.PARAMETER_TINDAKAN_LAB, tm.iddokter, tm.iduser, hl.LIS_TANGGAL, hl.LIS_HASIL
	  INTO VKUNJUNGAN, VID, VTINDAKAN_MEDIS, VTINDAKAN, VPARAMETER_TINDAKAN_LAB, VDOKTER, VOPERATOR, VTANGGAL, VHASIL
	  FROM lis.hasil_log hl
	  		 , lis.mapping_hasil mh
	  		 , pcc_rsws.data_layanan tm
	  		 , pcc_rsws.tindakan t
	 WHERE mh.LIS_KODE_TEST = hl.LIS_KODE_TEST
	   AND mh.HIS_KODE_TEST = hl.HIS_KODE_TEST
	   AND mh.VENDOR_LIS = hl.VENDOR_LIS
	   AND tm.noreg = hl.HIS_NO_LAB
	   AND t.id_tindakan = tm.idtindakan
		AND t.no_tindakan = hl.HIS_KODE_TEST
		AND hl.STATUS = 1
		AND hl.ID = PID
	 LIMIT 1;
	
	IF FOUND_ROWS() > 0 THEN
		
		IF EXISTS(
			SELECT 1 
			  FROM pcc_rsws.data_hasil_lab hl 
			 WHERE hl.no_tindakan = VTINDAKAN_MEDIS 
			   AND hl.id_nilai_rujukan = VPARAMETER_TINDAKAN_LAB
			 LIMIT 1) THEN
			UPDATE pcc_rsws.data_hasil_lab
			   SET tanggal_hasil = VTANGGAL
			   	 , hasil = VHASIL
			 WHERE no_tindakan = VTINDAKAN_MEDIS 
			   AND id_nilai_rujukan = VPARAMETER_TINDAKAN_LAB;
		ELSE
			BEGIN
				DECLARE VNAMA_DOKTER TEXT;
				DECLARE VINDEX INT DEFAULT 0;
				
				
				SELECT d.nama_lengkap INTO VNAMA_DOKTER
				  FROM pcc_rsws.dokter d
				 WHERE d.iddokter = VDOKTER
				 LIMIT 1;
				
				IF FOUND_ROWS() = 0 THEN
					SET VNAMA_DOKTER = '';
				END IF;
				
				
				SELECT index_inr 
				  INTO VINDEX
				  FROM pcc_rsws.mapping_tindakan_rujukan mtr
				 WHERE mtr.id_nilai_rujukan = VPARAMETER_TINDAKAN_LAB
				   AND mtr.status_mapping = 1
				 LIMIT 1;
				 
				IF FOUND_ROWS() = 0 THEN 
					SET VINDEX = 0;
				END IF;
			
				BEGIN
					DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET SUCCESS = FALSE;
					
					INSERT INTO pcc_rsws.data_hasil_lab(no_tindakan, id_tindakan, id_nilai_rujukan, hasil, operator, dokter_lab, tanggal_hasil
									, noreg, status_publish, id_hasil_lab, index_inr)
						  VALUES (VTINDAKAN_MEDIS, VTINDAKAN, VPARAMETER_TINDAKAN_LAB, VHASIL, VOPERATOR, IF(VNAMA_DOKTER IS NULL, '', VNAMA_DOKTER), VTANGGAL
								   , VKUNJUNGAN, 1, CONCAT(VTINDAKAN_MEDIS, VPARAMETER_TINDAKAN_LAB), VINDEX);
				END;
			END;
			IF SUCCESS THEN
				
				UPDATE pcc_rsws.data_layanan 
				   SET otomatis = 1
				 WHERE no_tindakan = VTINDAKAN_MEDIS;
			END IF;
		END IF;		

		IF NOT SUCCESS THEN
			SET VSTATUS = 8;
		END IF;
		
		INSERT INTO aplikasi.automaticexecute(PERINTAH)
			VALUES(CONCAT("UPDATE lis.hasil_log SET STATUS = ", VSTATUS, " WHERE ID = ", VID));
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
