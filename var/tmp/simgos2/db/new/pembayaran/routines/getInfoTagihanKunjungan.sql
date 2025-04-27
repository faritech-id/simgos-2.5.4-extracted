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

-- membuang struktur untuk function pembayaran.getInfoTagihanKunjungan
DROP FUNCTION IF EXISTS `getInfoTagihanKunjungan`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `getInfoTagihanKunjungan`(`PTAGIHAN` CHAR(10)) RETURNS varchar(100) CHARSET latin1
    DETERMINISTIC
BEGIN
	DECLARE VKUNJUNGANS VARCHAR(100);
	
	SELECT GROUP_CONCAT(DISTINCT ref.DESKRIPSI) INTO VKUNJUNGANS
	  FROM pembayaran.tagihan_pendaftaran tp
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = tp.PENDAFTARAN
	  		 LEFT JOIN pendaftaran.tujuan_pasien tpsn ON tpsn.NOPEN = p.NOMOR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = tpsn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 15 AND ref.ID = r.JENIS_KUNJUNGAN
	 WHERE tp.STATUS = 1
	   AND tp.TAGIHAN = PTAGIHAN;
	
	IF FOUND_ROWS() = 0 THEN
		SET VKUNJUNGANS = '';
	END IF;
	   
	RETURN VKUNJUNGANS;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
