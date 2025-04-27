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

-- membuang struktur untuk procedure aplikasi.killProcessSleep
DROP PROCEDURE IF EXISTS `killProcessSleep`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `killProcessSleep`(
	IN `PTIME` SMALLINT

)
BEGIN
	DECLARE VID INT;
	DECLARE VFOUND TINYINT DEFAULT FALSE;
	DECLARE DATA_NOT_FOUND INT DEFAULT FALSE;
	
	DECLARE CRDATA CURSOR FOR
		SELECT ID
		  FROM information_schema.`PROCESSLIST` pl 
		 WHERE pl.TIME > PTIME
		   AND pl.COMMAND = 'Sleep';
	
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET DATA_NOT_FOUND = TRUE;
		
	OPEN CRDATA;
		DATA_END: LOOP
			FETCH CRDATA INTO VID;
		
			IF DATA_NOT_FOUND THEN
				UPDATE temp.temp SET ID = 0 WHERE ID = 0;
				LEAVE DATA_END;
			END IF;	
			
			KILL VID;
			
		END LOOP;
	CLOSE CRDATA;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
