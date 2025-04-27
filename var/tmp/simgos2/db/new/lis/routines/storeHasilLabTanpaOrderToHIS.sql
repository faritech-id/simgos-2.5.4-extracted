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

-- membuang struktur untuk procedure lis.storeHasilLabTanpaOrderToHIS
DROP PROCEDURE IF EXISTS `storeHasilLabTanpaOrderToHIS`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeHasilLabTanpaOrderToHIS`(IN `PID` BIGINT)
BEGIN		
	DECLARE VTANGGAL DATETIME;
	DECLARE VTINDAKAN INT;
	DECLARE VDOKTER INT;
	DECLARE VOPERATOR SMALLINT;
	DECLARE VKUNJUNGAN CHAR(25);
	DECLARE VRUANGAN INT DEFAULT 951001;
	DECLARE VRUANGAN_TINDAKAN INT DEFAULT 301100;
	DECLARE VPARAMEDIS INT DEFAULT 1489;
	DECLARE DATA_NOT_FOUND INT DEFAULT FALSE;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	
	SELECT hl.HIS_NO_LAB, mh.HIS_KODE_TEST, hl.LIS_USER, hl.LIS_TANGGAL
	  INTO VKUNJUNGAN, VTINDAKAN, VOPERATOR, VTANGGAL
	  FROM lis.hasil_log hl
	  		 , lis.mapping_hasil mh
	 WHERE mh.LIS_KODE_TEST = hl.LIS_KODE_TEST
	   AND mh.HIS_KODE_TEST = hl.HIS_KODE_TEST
	   AND mh.VENDOR_LIS = hl.VENDOR_LIS
		AND hl.STATUS = 1
		AND hl.ID = PID
	 LIMIT 1;
	
	IF FOUND_ROWS() > 0 THEN
		
		SELECT a.iddokter
		  INTO VDOKTER
		  FROM pcc_rsws.jadwal_dokter_lab a 
		       LEFT JOIN pcc_rsws.dokter_konsulen_lab b ON a.iddokter = b.in_dokter_konsulen_lab
		 WHERE a.tgl_jaga = DATE(VTANGGAL)
		 LIMIT 1;			
		
		IF FOUND_ROWS() = 0 THEN 
			SET VDOKTER = 0;
		END IF;
	
		IF NOT EXISTS(SELECT 1
			FROM pcc_rsws.data_layanan dl
		  WHERE dl.noreg = VKUNJUNGAN
		    AND dl.idtindakan = CONCAT(VRUANGAN_TINDAKAN, VTINDAKAN)
		    AND dl.tgl_tindakan1 = VTANGGAL
		    AND dl.status_tindakan = 1
			 LIMIT 1) THEN
			INSERT INTO pcc_rsws.data_layanan(noreg, idtindakan, tgl_tindakan, idanastesi, idparamedis, iddokter, iduser
						, status_tindakan, id_unit, tgl_tindakan1, iddokter2, iddokter3, otomatis)
			  VALUES (VKUNJUNGAN, CONCAT(VRUANGAN_TINDAKAN, VTINDAKAN), DATE_FORMAT(VTANGGAL, '%d-%m-%Y %H:%i:%s'), 0, VPARAMEDIS, VDOKTER, VOPERATOR
			  			, 1, VRUANGAN, VTANGGAL, 0, 0, 1);
					
			UPDATE pcc_rsws.register SET status_layanan = 1 WHERE id_reg_lengkap = VKUNJUNGAN;	
		END IF;
		
		CALL lis.storeHasilLabToHIS(PID);
	END IF;	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
