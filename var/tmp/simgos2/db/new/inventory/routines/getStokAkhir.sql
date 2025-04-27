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

-- membuang struktur untuk function inventory.getStokAkhir
DROP FUNCTION IF EXISTS `getStokAkhir`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` FUNCTION `getStokAkhir`(`PBARANG_RUANGAN` INT, `PTANGGAL` DATE) RETURNS decimal(60,2)
    DETERMINISTIC
BEGIN
	DECLARE VTANGGAL DATETIME;
	DECLARE VSTOK DECIMAL(60, 2);
	
	SET VTANGGAL = CONCAT(PTANGGAL, ' 23:59:59');
	
	SELECT STOK INTO VSTOK
	  FROM inventory.transaksi_stok_ruangan tsr
	 WHERE tsr.BARANG_RUANGAN = PBARANG_RUANGAN
	   AND tsr.TANGGAL <= VTANGGAL
	 ORDER BY TANGGAL DESC LIMIT 1;
	 
	IF FOUND_ROWS() = 0 THEN
		SET VSTOK = 0;
	END IF;
	
	RETURN VSTOK;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
