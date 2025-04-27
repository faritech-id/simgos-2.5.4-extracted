-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               11.0.0.5919
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk bpjs
USE `bpjs`;

-- membuang struktur untuk procedure bpjs.executeTempatTidur
DROP PROCEDURE IF EXISTS `executeTempatTidur`;
DELIMITER //
CREATE PROCEDURE `executeTempatTidur`()
BEGIN
	DECLARE vkodekelas CHAR(3);
	DECLARE vkoderuang SMALLINT;
	DECLARE vnamaruang VARCHAR(100);
	DECLARE vkapasitas, vtersedia, vtersediapria, vtersediawanita, vtersediapriawanita SMALLINT;
	
	DECLARE EXEC_NOT_FOUND TINYINT DEFAULT FALSE;		
	DECLARE CR_EXEC CURSOR FOR
		SELECT k.kelas kodekelas
			 , t.IDKAMAR koderuang
			 , CONCAT(t.SUBUNIT, ' - ', t.KAMAR) namaruang
			 , (t.TTLAKI + t.TTPEREMPUAN) kapasitas
			 , (t.TTLAKI + t.TTPEREMPUAN) - (t.JMLLAKI + t.JMLPEREMPUAN) tersedia
			 , IF(t.JMLLAKI > 0 AND t.JMLPEREMPUAN = 0, t.TTLAKI - t.JMLLAKI, 0) tersediapria
			 , IF(t.JMLPEREMPUAN > 0 AND t.JMLLAKI = 0, t.TTPEREMPUAN - t.JMLPEREMPUAN, 0) tersediawanita
			 , IF(t.JMLLAKI > 0 AND t.JMLPEREMPUAN > 0,  (t.TTLAKI + t.TTPEREMPUAN) - (t.JMLLAKI + t.JMLPEREMPUAN), 0) tersediapriawanita
	  FROM informasi.tempat_tidur_kemkes t,
	  		 bpjs.map_kelas k
	 WHERE k.kelas_rs = t.IDKELAS
	   AND NOT t.INSTALASI IS NULL;
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET EXEC_NOT_FOUND = TRUE;
						
	OPEN CR_EXEC;
					
	EXIT_EXEC: LOOP
		FETCH CR_EXEC INTO vkodekelas, vkoderuang, vnamaruang, vkapasitas, vtersedia, vtersediapria, vtersediawanita, vtersediapriawanita;
						
		IF EXEC_NOT_FOUND THEN
			LEAVE EXIT_EXEC;
		END IF;

		SET Vtersedia = IF(vtersedia < 0, 0, vtersedia);
		SET vtersediapriawanita = IF(vtersediapriawanita < 0, 0, vtersediapriawanita);
		
		IF EXISTS(SELECT 1 
				FROM bpjs.tempat_tidur tt
			  WHERE tt.kodekelas = vkodekelas
			    AND tt.koderuang = vkoderuang) THEN
			UPDATE bpjs.tempat_tidur
			   SET namaruang = vnamaruang
			   	 , kapasitas = vkapasitas
					 , tersedia = vtersedia
					 , tersediapria = vtersediapria
					 , tersediawanita = vtersediawanita
					 , tersediapriawanita = vtersediapriawanita
					 , kirim = 1
			  WHERE kodekelas = vkodekelas
			    AND koderuang = vkoderuang;
		ELSE
			INSERT INTO bpjs.tempat_tidur(kodekelas, koderuang, namaruang, kapasitas, tersedia, tersediapria, tersediawanita, tersediapriawanita)
				  VALUES (vkodekelas, vkoderuang, vnamaruang, vkapasitas, vtersedia, vtersediapria, vtersediawanita, vtersediapriawanita);
		END IF;
	END LOOP;
	
	CLOSE CR_EXEC;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
