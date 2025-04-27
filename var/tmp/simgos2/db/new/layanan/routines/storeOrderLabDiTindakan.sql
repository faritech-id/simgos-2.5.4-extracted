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

-- membuang struktur untuk procedure layanan.storeOrderLabDiTindakan
DROP PROCEDURE IF EXISTS `storeOrderLabDiTindakan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `storeOrderLabDiTindakan`(IN `PID` CHAR(21), IN `POLEH` SMALLINT)
BEGIN
	DECLARE DATA_NOT_FOUND INT DEFAULT FALSE;
	DECLARE VIDTINDAKAN CHAR(11);
	DECLARE VKUNJUNGAN CHAR(19);
	DECLARE VTINDAKAN SMALLINT;
	
	DECLARE CRDATA CURSOR FOR
		SELECT c.NOMOR, b.TINDAKAN
		  FROM layanan.order_lab a,		  
		  	 	 layanan.order_detil_lab b,
		  	 	 pendaftaran.kunjungan c
		 WHERE a.NOMOR = PID
		   AND a.STATUS = 2
		   AND a.NOMOR = c.REF
		   AND a.NOMOR = b.ORDER_ID;
		   
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
	
	OPEN CRDATA;
		DATA_END: LOOP
			FETCH CRDATA INTO VKUNJUNGAN, VTINDAKAN;
		
			IF DATA_NOT_FOUND THEN
				UPDATE temp.temp SET ID = 0 WHERE ID = 0;
				LEAVE DATA_END;
			END IF;	
			
			BEGIN
				SET VIDTINDAKAN = generator.generateIdTindakanMedis(DATE(NOW()));
				
				INSERT INTO layanan.tindakan_medis(ID, KUNJUNGAN, TINDAKAN, TANGGAL, OLEH)
					VALUES(VIDTINDAKAN, VKUNJUNGAN, VTINDAKAN, NOW(), POLEH);
					
				UPDATE layanan.order_detil_lab
				   SET REF = VIDTINDAKAN
				 WHERE ORDER_ID = PID
				   AND TINDAKAN = VTINDAKAN
				   AND (REF IS NULL OR REF = '');
			END;
		END LOOP;
	CLOSE CRDATA;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
