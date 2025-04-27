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

-- membuang struktur untuk function generator.generateNoSuratPenawaranHarga
DROP FUNCTION IF EXISTS `generateNoSuratPenawaranHarga`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` FUNCTION `generateNoSuratPenawaranHarga`(`PTANGGAL` DATE) RETURNS varchar(10) CHARSET latin1
    DETERMINISTIC
BEGIN
	INSERT INTO generator.no_surat_penawaran_harga(TANGGAL)
	VALUES(PTANGGAL);
		
	RETURN CONCAT(DATE_FORMAT(PTANGGAL, '%y%m%d'), LPAD(LAST_INSERT_ID(), 4, '0'));
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
