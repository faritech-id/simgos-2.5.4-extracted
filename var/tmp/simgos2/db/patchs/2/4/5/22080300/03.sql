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
CREATE DATABASE IF NOT EXISTS `aplikasi`;
USE `aplikasi`;

-- membuang struktur untuk procedure aplikasi.grantAksesRekamMedis
DROP PROCEDURE IF EXISTS `grantAksesRekamMedis`;
DELIMITER //
CREATE PROCEDURE `grantAksesRekamMedis`()
BEGIN
	DECLARE VGROUP_USER_ID INT;
	
	-- cek group rekam medis
	SELECT r.ID
	  INTO VGROUP_USER_ID
	  FROM `master`.referensi r 
	 WHERE r.JENIS = 43
	   AND TRIM(UPPER(r.DESKRIPSI)) = 'REKAM MEDIS';
	
	IF VGROUP_USER_ID IS NULL THEN
		INSERT INTO `master`.referensi(JENIS, DESKRIPSI)
		VALUES(43, 'Rekam Medis');
		
		SET VGROUP_USER_ID = LAST_INSERT_ID();
	END IF;
	
	BEGIN
		-- insert module ke group pengguna akses module
		INSERT INTO aplikasi.group_pengguna_akses_module(GROUP_PENGGUNA, MODUL, STATUS)
		SELECT VGROUP_USER_ID, m.ID, 1
		  FROM aplikasi.modules m
		 WHERE m.ID LIKE '13%'
		   AND NOT m.ID LIKE '1301%'
			AND NOT EXISTS(
				SELECT 1 
				  FROM aplikasi.group_pengguna_akses_module gpam
				  WHERE gpam.GROUP_PENGGUNA = VGROUP_USER_ID
				    AND gpam.MODUL = m.ID
				LIMIT 1
			);
			
		-- insert group pengguna akses modul dan pengguna ke pengguna akses jika belum ada
		INSERT INTO aplikasi.pengguna_akses(PENGGUNA, GROUP_PENGGUNA_AKSES_MODULE, STATUS)
		SELECT p2.ID, gp.ID, 1
		  FROM `master`.pegawai p,
		       aplikasi.pengguna p2,
		       aplikasi.group_pengguna_akses_module gp
		 WHERE p.`STATUS` = 1
		   AND p.PROFESI IN (4, 6)
			AND p2.NIP = p.NIP
			AND gp.GROUP_PENGGUNA = VGROUP_USER_ID
            AND gp.MODUL LIKE '13%'
			AND NOT EXISTS(
				SELECT 1
				  FROM aplikasi.pengguna_akses pa
				WHERE pa.PENGGUNA = p2.ID
				  AND pa.GROUP_PENGGUNA_AKSES_MODULE = gp.ID
			);
	END;
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
