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

-- membuang struktur untuk procedure laporan.LaporanPenjualanDetil
DROP PROCEDURE IF EXISTS `LaporanPenjualanDetil`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `LaporanPenjualanDetil`(
	IN `TGLAWAL` DATETIME,
	IN `TGLAKHIR` DATETIME,
	IN `RUANGAN` CHAR(10),
	IN `LAPORAN` INT,
	IN `CARABAYAR` INT,
	IN `KATEGORI` INT,
	IN `BARANG` INT
)
BEGIN

	DECLARE vRUANGAN VARCHAR(11);
	DECLARE vKATEGORI VARCHAR(11);
      
   SET vRUANGAN = CONCAT(RUANGAN,'%');
   SET vKATEGORI = CONCAT(KATEGORI,'%');
   
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
							AND prp.BARANG=ppd.BARANG))) * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL,0,mpf.MARGIN / 100))) TOTALJUAL, pt.TOTAL, (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL,0,mpf.MARGIN / 100))) HARGA_JUAL,
					IF(pp.`STATUS`=2,''Sudah Bayar'',IF(pp.`STATUS`=1,''Belum Bayar'',''Batal'')) KET,
					CONCAT(''LAPORAN PENJUALAN '',UPPER(jk.DESKRIPSI)) JENISLAPORAN, inst.NAMA NAMAINST, inst.ALAMAT ALAMATINST,
					IF(',CARABAYAR,'=0,''Semua'',(SELECT ref.DESKRIPSI FROM master.referensi ref WHERE ref.ID=',CARABAYAR,' AND ref.JENIS=10)) CARABAYARHEADER,
			      master.getHeaderLaporan(''',RUANGAN,''') INSTALASI
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
		, pembayaran.tagihan pt
		, (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
					FROM aplikasi.instansi ai
						, master.ppk mp
					WHERE ai.PPK=mp.ID) inst
	WHERE pp.NOMOR=ppd.PENJUALAN_ID AND pp.`STATUS` IN (1,2) AND ppd.`STATUS` IN (1,2) AND rg.JENIS_KUNJUNGAN=',LAPORAN,'
	  AND pp.NOMOR=pt.ID AND pt.JENIS=4 AND pp.TANGGAL BETWEEN ''',TGLAWAL,''' AND ''',TGLAKHIR,'''
	  AND pp.RUANGAN LIKE ''',vRUANGAN,''' 
	  ',IF(KATEGORI=0,'',CONCAT(' AND ik.ID LIKE ''',VKATEGORI,'''')),'
		',IF(BARANG=0,'',CONCAT(' AND ib.ID=',BARANG)),'
		',IF(CARABAYAR IN (0,1),'',CONCAT(' AND crbyr.ID=',CARABAYAR )),'
	  AND ppd.BARANG=ib.ID
	GROUP BY pp.NOMOR, ppd.BARANG
				
		
			');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;

END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
