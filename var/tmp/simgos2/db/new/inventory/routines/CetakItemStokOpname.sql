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

-- membuang struktur untuk procedure inventory.CetakItemStokOpname
DROP PROCEDURE IF EXISTS `CetakItemStokOpname`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakItemStokOpname`(IN `PSTOKOPNAME` INT)
BEGIN
	
	SELECT inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, ib.NAMA NAMAOBAT, master.getHeaderLaporan(br.RUANGAN) INSTALASI
	FROM inventory.stok_opname_detil sod
	   , inventory.barang_ruangan br
	   , inventory.barang ib
	   , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE sod.BARANG_RUANGAN=br.ID AND br.BARANG=ib.ID
	  AND sod.STOK_OPNAME=PSTOKOPNAME
	;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
