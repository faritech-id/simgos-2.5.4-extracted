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

-- membuang struktur untuk function inventory.getHargaSph
DROP FUNCTION IF EXISTS `getHargaSph`;
DELIMITER //
CREATE DEFINER=`root`@`%` FUNCTION `getHargaSph`(
	`PBARANG` INT,
	`PSUPPLIER` INT

) RETURNS decimal(20,2)
    DETERMINISTIC
BEGIN
	DECLARE VHRG DECIMAL(20,2);
	SELECT (b.HARGA - b.DISKON_RUPIAH) INTO VHRG FROM surat_penawaran_harga a,surat_penawaran_harga_detil b
	WHERE b.ID_PENAWARAN=a.NOMOR AND b.BARANG = PBARANG AND b.STATUS = 1 AND a.SUPPLIER=PSUPPLIER LIMIT 1;
	IF FOUND_ROWS() > 0 THEN
		RETURN VHRG;
	ELSE
		RETURN 0;
	END IF;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
