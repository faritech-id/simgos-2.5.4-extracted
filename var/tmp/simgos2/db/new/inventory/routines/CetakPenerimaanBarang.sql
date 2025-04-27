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

-- membuang struktur untuk procedure inventory.CetakPenerimaanBarang
DROP PROCEDURE IF EXISTS `CetakPenerimaanBarang`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakPenerimaanBarang`(
	IN `PID` INT

)
BEGIN
	
	SELECT inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, py.NAMA NAMAREKANAN, py.ALAMAT ALAMATREKANAN, py.TELEPON TLPREKANAN, pb.FAKTUR NOFAKTUR, pb.TANGGAL TGLFAKTUR, pb.TANGGAL_DIBUAT
	  , ib.NAMA NAMABARANG, pbd.JUMLAH, s.NAMA NAMASATUAN, pbd.HARGA, pbd.DISKON,  ((pbd.JUMLAH * pbd.HARGA) - pbd.DISKON) TOTAL, IF(pb.PPN='Tidak',0.1,0) PPN
	FROM inventory.penerimaan_barang pb
	     LEFT JOIN inventory.penyedia py ON pb.REKANAN=py.ID
	     LEFT JOIN master.ruangan r ON pb.RUANGAN=r.ID
		, inventory.penerimaan_barang_detil pbd
		  LEFT JOIN inventory.barang ib ON pbd.BARANG=ib.ID
		  LEFT JOIN inventory.satuan s ON ib.SATUAN=s.ID
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pb.ID=pbd.PENERIMAAN AND pb.ID=PID;
	
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
