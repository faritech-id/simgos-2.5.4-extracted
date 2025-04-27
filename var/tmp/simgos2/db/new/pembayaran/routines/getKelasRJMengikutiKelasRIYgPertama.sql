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

-- membuang struktur untuk function pembayaran.getKelasRJMengikutiKelasRIYgPertama
DROP FUNCTION IF EXISTS `getKelasRJMengikutiKelasRIYgPertama`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getKelasRJMengikutiKelasRIYgPertama`(
	`PTAGIHAN` CHAR(10),
	`PKUNJUNGAN` CHAR(19)) RETURNS smallint(6)
    DETERMINISTIC
BEGIN
	DECLARE VKELAS SMALLINT;
	
	
	
	
					
	IF EXISTS(SELECT 1
		  FROM aplikasi.properti_config pc
		 WHERE pc.ID = 8
		   AND VALUE = 'TRUE') THEN				
		IF EXISTS(
				SELECT 1
				  FROM pendaftaran.kunjungan k
				 WHERE k.NOMOR = PKUNJUNGAN
				   AND k.RUANG_KAMAR_TIDUR = 0
					AND NOT k.`STATUS` = 0
		   	) THEN
			SELECT IF(rk.KELAS IS NULL, 0, rk.KELAS) KELAS
			  INTO VKELAS
			  FROM pembayaran.tagihan_pendaftaran tp,
			  		 pendaftaran.kunjungan k
			  		 LEFT JOIN master.ruang_kamar_tidur rkt ON rkt.ID = k.RUANG_KAMAR_TIDUR
					 LEFT JOIN master.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR 
			 WHERE tp.TAGIHAN = PTAGIHAN
			   
			   AND tp.STATUS = 1
			   AND k.NOPEN = tp.PENDAFTARAN
				AND k.RUANG_KAMAR_TIDUR > 0
				AND k.REF IS NULL
				AND NOT k.`STATUS` = 0
			 LIMIT 1;
				
			IF FOUND_ROWS() > 0 THEN
				RETURN VKELAS;
			END IF;
		END IF;
	END IF;
	
	RETURN -1;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
