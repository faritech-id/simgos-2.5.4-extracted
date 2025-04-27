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

-- membuang struktur untuk procedure laporan.LaporanPenerimaanBarangExternal
DROP PROCEDURE IF EXISTS `LaporanPenerimaanBarangExternal`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPenerimaanBarangExternal`(IN `TGLAWAL` DATETIME, IN `TGLAKHIR` DATETIME, IN `RUANGAN` CHAR(10), IN `LAPORAN` INT, IN `CARABAYAR` INT, IN `KATEGORI` INT, IN `BARANG` INT)
BEGIN

	
	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   
	SET @sqlText = CONCAT('
			SELECT inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST, py.NAMA NAMAREKANAN, py.ALAMAT ALAMATREKANAN, py.TELEPON TLPREKANAN, pb.FAKTUR NOFAKTUR, pb.TANGGAL TGLFAKTUR, pb.TANGGAL_DIBUAT
				  , ib.NAMA NAMABARANG, pbd.JUMLAH, s.NAMA NAMASATUAN, pbd.HARGA, pbd.DISKON, ((pbd.JUMLAH * pbd.HARGA) - pbd.DISKON) TOTAL
				  , master.getHeaderKategoriBarang(''',KATEGORI,''') KATEGORI
				  , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
				  , IF(',BARANG,'=0,''Semua'',(SELECT br.NAMA FROM inventory.barang br WHERE br.ID=',BARANG,')) BARANGHEADER
				FROM inventory.penerimaan_barang pb
				     LEFT JOIN inventory.penyedia py ON pb.REKANAN=py.ID
				     LEFT JOIN master.ruangan r ON pb.RUANGAN=r.ID
					, inventory.penerimaan_barang_detil pbd
					  LEFT JOIN inventory.barang ib ON pbd.BARANG=ib.ID
					  LEFT JOIN inventory.satuan s ON ib.SATUAN=s.ID
					  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
					, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
								FROM aplikasi.instansi ai
									, master.ppk mp
								WHERE ai.PPK=mp.ID) inst
				WHERE pb.ID=pbd.PENERIMAAN AND pb.TANGGAL_DIBUAT BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
				  AND pb.RUANGAN LIKE ''',vRUANGAN,''' AND pb.STATUS=2 AND pbd.STATUS=2
				  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
					',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'		
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
