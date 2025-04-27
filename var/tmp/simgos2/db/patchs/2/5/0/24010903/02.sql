-- --------------------------------------------------------
-- Host:                         192.168.137.7
-- Server version:               8.0.34 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             12.5.0.6677
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for laporan
USE `laporan`;

-- Dumping structure for procedure laporan.LaporanPenjualanDetil
DROP PROCEDURE IF EXISTS `LaporanPenjualanDetil`;
DELIMITER //
CREATE PROCEDURE `LaporanPenjualanDetil`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT,
	IN `JENISINVENTORY` INT,
	IN `JENISKATEGORI` INT,
	IN `KATEGORIBARANG` INT,
	IN `JENISGENERIK` TINYINT,
	IN `JENISFORMULARIUM` INT,
	IN `PENGGOLONGAN` INT
)
BEGIN

	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
	DECLARE vJENISINVENTORY VARCHAR(11);
	DECLARE vKATEGORIBARANG VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   SET vJENISINVENTORY = CONCAT(JENISINVENTORY,'%');
   SET vKATEGORIBARANG = CONCAT(KATEGORIBARANG,'%');
   SET @HRG=0; 
   
	SET @sqlText = CONCAT('
		SELECT  pp.NOMOR, pp.PENGUNJUNG, pp.KETERANGAN, pp.TANGGAL,
				  ib.NAMA NAMAOBAT, IF(ref.DESKRIPSI IS NULL, ppd.ATURAN_PAKAI, ref.DESKRIPSI) ATURAN_PAKAI, SUM(ppd.JUMLAH) JUMLAH,
				  (SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG) RETUR,
				  (SUM(ppd.JUMLAH) - IF((SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG) IS NULL, 0,(SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG))) JMLJUAL,
				   (SUM(ppd.JUMLAH) - IF((SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG) IS NULL, 0,(SELECT SUM(JUMLAH) 
				  		FROM penjualan.retur_penjualan prp 
						WHERE prp.PENJUALAN_ID=ppd.PENJUALAN_ID 
							AND prp.BARANG=ppd.BARANG))) * inventory.getHargaJual(ppd.BARANG, ppd.HARGA_BARANG, ppd.MARGIN, ppd.PPN) TOTALJUAL
					, pt.TOTAL, @HRG:=inventory.getHargaJual(ppd.BARANG, ppd.HARGA_BARANG, ppd.MARGIN, ppd.PPN) HARGA_JUAL, (@HRG * 11 / 100) NILAI_PPN
					, IF(pp.`STATUS`=2,''Sudah Bayar'',IF(pp.`STATUS`=1,''Belum Bayar'',''Batal'')) KET,
					CONCAT(''LAPORAN PENJUALAN '',UPPER(jk.DESKRIPSI)) JENISLAPORAN, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST
					, IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER
			      , master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
	FROM penjualan.penjualan pp
	     LEFT JOIN master.ruangan rg ON pp.RUANGAN=rg.ID AND rg.JENIS=5
	     LEFT JOIN master.referensi jk ON rg.JENIS_KUNJUNGAN=jk.ID AND jk.JENIS=15
	     LEFT JOIN master.referensi crbyr ON crbyr.ID=1 AND crbyr.JENIS=10
		, penjualan.penjualan_detil ppd
		  LEFT JOIN master.referensi ref ON ref.ID LIKE LEFT(ppd.ATURAN_PAKAI,3) AND ref.JENIS=41
		  LEFT JOIN inventory.harga_barang hb ON ppd.HARGA_BARANG=hb.ID 
		  LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = ppd.MARGIN
		, inventory.barang ib
		  LEFT JOIN inventory.kategori ik ON ib.KATEGORI=ik.ID
		  ',IF(PENGGOLONGAN=0,'',CONCAT(' LEFT JOIN inventory.penggolongan_barang pb ON pb.BARANG=b.ID AND pb.CHECKED=1')),'
		, pembayaran.tagihan pt
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pp.NOMOR=ppd.PENJUALAN_ID AND pp.`STATUS` IN (1,2) AND ppd.`STATUS` IN (1,2) AND rg.JENIS_KUNJUNGAN=',LAPORAN,'
	  AND pp.NOMOR=pt.ID AND pt.JENIS=4 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
	  AND pp.RUANGAN LIKE ''',vRUANGAN,''' 
	  ',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
	  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
	  ',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
	  ',IF(JENISINVENTORY=0,'',CONCAT(' AND ik.ID LIKE ''',vJENISINVENTORY,'''')),'
	  ',IF(JENISKATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',vKATEGORI,'''')),'
	  ',IF(KATEGORIBARANG IN (0,10100),'',CONCAT(' AND ik.ID LIKE ''',vKATEGORIBARANG,'''')),'
	  ',IF(JENISGENERIK=0,'',CONCAT(' AND ib.JENIS_GENERIK=',JENISGENERIK)),'
	  ',IF(JENISFORMULARIUM=0,'',CONCAT(' AND ib.FORMULARIUM=',JENISFORMULARIUM)),'
	  ',IF(PENGGOLONGAN=0,'',CONCAT(' AND pb.PENGGOLONGAN=',PENGGOLONGAN)),'
	  AND ppd.BARANG=ib.ID
	GROUP BY pp.NOMOR, ppd.BARANG
	ORDER BY pp.TANGGAL
				
		
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
