-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.32 - MySQL Community Server - GPL
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


-- Membuang struktur basisdata untuk pendaftaran
USE `pendaftaran`;

-- membuang struktur untuk procedure pendaftaran.doProsesPaket
DROP PROCEDURE IF EXISTS `doProsesPaket`;
DELIMITER //
CREATE PROCEDURE `doProsesPaket`(
	IN `PKUNJUNGAN` CHAR(19)
)
BEGIN
	DECLARE VDPJP, VPAKET SMALLINT;
	DECLARE VRUANGAN, VTUJUAN CHAR(10);
	DECLARE VJENIS_KUNJUNGAN TINYINT;
	DECLARE VTANGGAL DATETIME;
	DECLARE VREF, VNOMOR CHAR(21);
	
	SET VTANGGAL = NOW();
	
	SELECT k.RUANGAN, k.DPJP, r.JENIS_KUNJUNGAN, p.PAKET, k.REF
	  INTO VRUANGAN, VDPJP, VJENIS_KUNJUNGAN, VPAKET, VREF
	  FROM pendaftaran.kunjungan k,
	  		 `master`.ruangan r,
	  		 pendaftaran.pendaftaran p
	 WHERE k.NOMOR = PKUNJUNGAN
		AND k.`STATUS` = 1
		AND r.ID = k.RUANGAN
		AND p.NOMOR = k.NOPEN
		AND NOT p.PAKET IS NULL;
		
	IF NOT VRUANGAN IS NULL AND NOT VPAKET IS NULL THEN
      
		IF VJENIS_KUNJUNGAN = 1 THEN
		BEGIN
			DECLARE VTINDAKAN SMALLINT;
			DECLARE TINDAKAN_PAKET_NOT_FOUND TINYINT DEFAULT FALSE;							
			DECLARE CR_TINDAKAN_PAKET CURSOR FOR
				SELECT pd.ITEM
				  FROM `master`.paket_detil pd
				 WHERE pd.PAKET = VPAKET
				   AND pd.JENIS = 1
				   AND pd.RUANGAN = VRUANGAN
				   AND pd.`STATUS` = 1;
			DECLARE CONTINUE HANDLER FOR NOT FOUND SET TINDAKAN_PAKET_NOT_FOUND = TRUE;
				
			OPEN CR_TINDAKAN_PAKET;
			TINDAKAN_PAKET_EOF: LOOP
				FETCH CR_TINDAKAN_PAKET INTO VTINDAKAN;
					
				IF TINDAKAN_PAKET_NOT_FOUND THEN
					UPDATE temp.temp SET ID = 0 WHERE ID = 0;
					LEAVE TINDAKAN_PAKET_EOF;
				END IF;
				
				IF NOT EXISTS(
					SELECT 1 
					  FROM layanan.tindakan_medis tm 
					 WHERE tm.KUNJUNGAN = PKUNJUNGAN
					   AND tm.TINDAKAN = VTINDAKAN
					   AND tm.`STATUS` = 1) THEN
					INSERT INTO layanan.tindakan_medis(ID, KUNJUNGAN, TINDAKAN, TANGGAL, OTOMATIS, STATUS)
					     VALUES (generator.generateIdTindakanMedis(VTANGGAL), PKUNJUNGAN, VTINDAKAN, VTANGGAL, 1, 1);
				END IF;
			END LOOP;
			CLOSE CR_TINDAKAN_PAKET;
		END;
		END IF;
		
		
		IF VREF IS NULL THEN
			BEGIN
				DECLARE KONSUL_NOT_FOUND TINYINT DEFAULT FALSE;
				DECLARE CR_KONSUL_PAKET CURSOR FOR
					SELECT DISTINCT pd.RUANGAN
					  FROM `master`.paket_detil pd,
					  		 `master`.ruangan_konsul rk
					 WHERE pd.PAKET = VPAKET
					   AND pd.JENIS = 1
					   AND NOT pd.RUANGAN = VRUANGAN
					   AND pd.`STATUS` = 1
					   AND rk.KONSUL = pd.RUANGAN
					   AND rk.`STATUS` = 1
						AND NOT EXISTS(
							 SELECT 1
							   FROM pendaftaran.konsul k
							  WHERE k.KUNJUNGAN = PKUNJUNGAN
							    AND k.TUJUAN = pd.RUANGAN
							    AND k.STATUS IN (1, 2)
						);
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET KONSUL_NOT_FOUND = TRUE;
					
				OPEN CR_KONSUL_PAKET;
				KONSUL_EOF: LOOP
					FETCH CR_KONSUL_PAKET INTO VTUJUAN;
						
					IF KONSUL_NOT_FOUND THEN
						UPDATE temp.temp SET ID = 0 WHERE ID = 0;
						LEAVE KONSUL_EOF;
					END IF;
					
					INSERT INTO pendaftaran.konsul(NOMOR, KUNJUNGAN, TANGGAL, DOKTER_ASAL, TUJUAN)
					     VALUES (generator.generateNoKonsul(VTUJUAN, VTANGGAL), PKUNJUNGAN, VTANGGAL, VDPJP, VTUJUAN);
				END LOOP;
				CLOSE CR_KONSUL_PAKET;
			END;
			
			BEGIN
				DECLARE ORDER_LAB_NOT_FOUND TINYINT DEFAULT FALSE;
				DECLARE CR_ORDER_LAB CURSOR FOR
					SELECT DISTINCT pd.RUANGAN
					  FROM `master`.paket_detil pd,
					  		 `master`.ruangan_laboratorium rl
					 WHERE pd.PAKET = VPAKET
					   AND pd.JENIS = 1
					   AND NOT pd.RUANGAN = VRUANGAN
					   AND pd.`STATUS` = 1
						AND rl.LABORATORIUM = pd.RUANGAN
						AND rl.`STATUS` = 1
						AND NOT EXISTS(
							 SELECT 1
							   FROM layanan.order_lab ol
							  WHERE ol.KUNJUNGAN = PKUNJUNGAN
							    AND ol.TUJUAN = pd.RUANGAN
							    AND ol.STATUS IN (1, 2)
						);
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET ORDER_LAB_NOT_FOUND = TRUE;
					
				OPEN CR_ORDER_LAB;
				ORDER_LAB_EOF: LOOP
					FETCH CR_ORDER_LAB INTO VTUJUAN;
						
					IF ORDER_LAB_NOT_FOUND THEN
						UPDATE temp.temp SET ID = 0 WHERE ID = 0;
						LEAVE ORDER_LAB_EOF;
					END IF;
					
					SET VNOMOR = generator.generateNoOrderLab(VTUJUAN, VTANGGAL);
					
					INSERT INTO layanan.order_lab(NOMOR, KUNJUNGAN, TANGGAL, DOKTER_ASAL, TUJUAN)
					     VALUES (VNOMOR, PKUNJUNGAN, VTANGGAL, VDPJP, VTUJUAN);
					     
					INSERT INTO layanan.order_detil_lab(ORDER_ID, TINDAKAN)
					SELECT VNOMOR, pd.ITEM
					  FROM `master`.paket_detil pd
					 WHERE pd.PAKET = VPAKET
					   AND pd.RUANGAN = VTUJUAN
					   AND pd.JENIS = 1
					   AND pd.`STATUS` = 1
					   AND NOT EXISTS(
					  		 SELECT 1
					  		   FROM layanan.order_detil_lab o
					  		  WHERE o.ORDER_ID = VNOMOR
					  		    AND o.TINDAKAN = pd.ITEM
					  	);
				END LOOP;
				CLOSE CR_ORDER_LAB;
			END;
			
			BEGIN
				DECLARE ORDER_RAD_NOT_FOUND TINYINT DEFAULT FALSE;
				DECLARE CR_ORDER_RAD CURSOR FOR
					SELECT DISTINCT pd.RUANGAN
					  FROM `master`.paket_detil pd,
					  		 `master`.ruangan_radiologi rr
					 WHERE pd.PAKET = VPAKET
					   AND pd.JENIS = 1
					   AND NOT pd.RUANGAN = VRUANGAN
					   AND pd.`STATUS` = 1
						AND rr.RADIOLOGI = pd.RUANGAN
						AND rr.`STATUS` = 1
						AND NOT EXISTS(
							 SELECT 1
							   FROM layanan.order_rad orad
							  WHERE orad.KUNJUNGAN = PKUNJUNGAN
							    AND orad.TUJUAN = pd.RUANGAN
							    AND orad.STATUS IN (1, 2)
						);
				DECLARE CONTINUE HANDLER FOR NOT FOUND SET ORDER_RAD_NOT_FOUND = TRUE;
					
				OPEN CR_ORDER_RAD;
				ORDER_RAD_EOF: LOOP
					FETCH CR_ORDER_RAD INTO VTUJUAN;
						
					IF ORDER_RAD_NOT_FOUND THEN
						UPDATE temp.temp SET ID = 0 WHERE ID = 0;
						LEAVE ORDER_RAD_EOF;
					END IF;
					
					SET VNOMOR = generator.generateNoOrderRad(VTUJUAN, VTANGGAL);
					
					INSERT INTO layanan.order_rad(NOMOR, KUNJUNGAN, TANGGAL, DOKTER_ASAL, TUJUAN)
					     VALUES (VNOMOR, PKUNJUNGAN, VTANGGAL, VDPJP, VTUJUAN);
					     
					INSERT INTO layanan.order_detil_rad(ORDER_ID, TINDAKAN)
					SELECT VNOMOR, pd.ITEM
					  FROM `master`.paket_detil pd
					 WHERE pd.PAKET = VPAKET
					   AND pd.RUANGAN = VTUJUAN
					   AND pd.JENIS = 1
					   AND pd.`STATUS` = 1
					   AND NOT EXISTS(
					  		 SELECT 1
					  		   FROM layanan.order_detil_rad o
					  		  WHERE o.ORDER_ID = VNOMOR
					  		    AND o.TINDAKAN = pd.ITEM
					  	);
				END LOOP;
				CLOSE CR_ORDER_RAD;
			END;
		END IF;
	END IF;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
