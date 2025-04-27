-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Membuang struktur basisdata untuk master
USE `master`;

-- membuang struktur untuk procedure master.storeJenisPeserta
DROP PROCEDURE IF EXISTS `storeJenisPeserta`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `storeJenisPeserta`(
	IN `PJENIS` SMALLINT,
	IN `PID` TINYINT,
	IN `PDESKRIPSI` VARCHAR(50)
)
BEGIN
	DECLARE VSUCCESS TINYINT DEFAULT TRUE;
		
	IF NOT EXISTS(SELECT 1 FROM `master`.jenis_peserta_penjamin j WHERE j.JENIS = PJENIS AND j.ID = PID) THEN
	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;
		
		INSERT INTO `master`.jenis_peserta_penjamin(JENIS, ID, DESKRIPSI)
		VALUES(PJENIS, PID, PDESKRIPSI);
	END;
	ELSE
	BEGIN
		DECLARE CONTINUE HANDLER FOR SQLEXCEPTION SET VSUCCESS = FALSE;
				
		UPDATE `master`.jenis_peserta_penjamin
		   SET DESKRIPSI = PDESKRIPSI
		 WHERE JENIS = PJENIS
		   AND ID = PID;
	END;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
