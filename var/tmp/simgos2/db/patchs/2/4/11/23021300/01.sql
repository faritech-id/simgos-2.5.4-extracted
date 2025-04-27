-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
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

-- Membuang struktur basisdata untuk aplikasi
USE `aplikasi`;

-- membuang struktur untuk function aplikasi.isPenggunaAksesRuangan
DROP FUNCTION IF EXISTS `isPenggunaAksesRuangan`;
DELIMITER //
CREATE FUNCTION `isPenggunaAksesRuangan`(
	`PPENGGUNA` SMALLINT,
	`PRUANGAN` CHAR(10)
) RETURNS tinyint
    DETERMINISTIC
BEGIN
	DECLARE VID MEDIUMINT;
	DECLARE VJENIS_KUNJUNGAN, VPROFESI SMALLINT;
	DECLARE VPROFESI_DESKRIPSI VARCHAR(50);
	
	SELECT par.ID
	  INTO VID
	  FROM aplikasi.pengguna_akses_ruangan par
	 WHERE par.RUANGAN = PRUANGAN
	   AND par.PENGGUNA = PPENGGUNA
	   AND par.`STATUS` = 1
	  LIMIT 1;
	
	IF VID IS NULL THEN
		SELECT r.JENIS_KUNJUNGAN
		  INTO VJENIS_KUNJUNGAN
		  FROM `master`.ruangan r
		 WHERE r.ID = PRUANGAN;
		
		IF NOT VJENIS_KUNJUNGAN IS NULL THEN
			IF VJENIS_KUNJUNGAN IN (2, 3) THEN ## IGD dan RI
				SELECT pg.PROFESI, ref.DESKRIPSI
				  INTO VPROFESI, VPROFESI_DESKRIPSI
				  FROM aplikasi.pengguna p,
				  		 `master`.pegawai pg,
				  		 `master`.referensi ref
				 WHERE p.ID = PPENGGUNA
				   AND pg.NIP = p.NIP
				   AND ref.ID = pg.PROFESI
				   AND ref.JENIS = 36
				 LIMIT 1;
				 
				IF NOT VPROFESI IS NULL THEN
					IF VPROFESI = 4 THEN ## DOKTER
						RETURN 1;
					END IF;
					
					IF INSTR(VPROFESI_DESKRIPSI, 'PPDS') > 0 THEN
						RETURN 1;
					END IF;
				END IF;
			END IF;
		END IF;
		 
		RETURN 0;
	END IF;

	RETURN 1;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
