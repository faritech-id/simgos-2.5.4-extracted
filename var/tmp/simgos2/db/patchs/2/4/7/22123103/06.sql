USE `penjualan`;
-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure penjualan.CetakFakturPenjualan
DROP PROCEDURE IF EXISTS `CetakFakturPenjualan`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakFakturPenjualan`(IN `PTAGIHAN` CHAR(10), IN `PJENIS` TINYINT
)
BEGIN
	SELECT dat.*, (dat.JUMLAH - dat.RETUR) QTY, ((dat.JUMLAH - dat.RETUR) * dat.HARGA_JUAL) TOTAL 
	  FROM (
		SELECT inst.PPK, inst.NAMA INSTASI, inst.ALAMAT ALAMATINSTANSI
			 	 , pp.NOMOR, IFNULL(pp.PENGUNJUNG, '-') PENGUNJUNG, pp.KETERANGAN, pp.TANGGAL
			 	 , ib.NAMA NAMAOBAT
				 , master.getAturanPakai(ppd.ATURAN_PAKAI) ATURAN_PAKAI
			 	 , usr.NAMA PETUGAS
			 	 , SUM(ppd.JUMLAH) JUMLAH
			 	 , IFNULL((SELECT SUM(JUMLAH)
			 			FROM penjualan.retur_penjualan prp 
				  	  WHERE prp.PENJUALAN_ID = ppd.PENJUALAN_ID
						 AND prp.PENJUALAN_DETIL_ID = ppd.ID 
				       AND prp.BARANG = ppd.BARANG), 0
				 ) RETUR
			  	 , ROUND((
					(hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL,0,mpf.MARGIN / 100))) + 
						((hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL,0,mpf.MARGIN / 100))) * IF(ppn.PPN IS NULL,0,ppn.PPN / 100))
					),0) HARGA_JUAL
			  	 , r.DESKRIPSI RUANGANASAL
	     FROM penjualan.penjualan pp
	  		    LEFT JOIN master.ruangan r ON r.ID = pp.RUANGAN
		       LEFT JOIN aplikasi.pengguna usr ON usr.ID = pp.OLEH
			  	 , penjualan.penjualan_detil ppd
			  	 LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = ppd.MARGIN
			  	 LEFT JOIN penjualan.ppn_penjualan ppn ON ppn.ID = ppd.PPN
			  	 LEFT JOIN master.referensi ref ON ref.ID LIKE LEFT(ppd.ATURAN_PAKAI,3) AND ref.JENIS = 41
			  	 , inventory.barang ib
			  	 , pembayaran.tagihan pt
			  	 , inventory.harga_barang hb
			  	 , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
						FROM aplikasi.instansi ai
							  , master.ppk mp
					  WHERE ai.PPK = mp.ID
				 ) inst
		 WHERE pp.NOMOR = ppd.PENJUALAN_ID 
		   AND pp.NOMOR = PTAGIHAN
		   AND pp.`STATUS` IN (1,2) 
		   AND ppd.`STATUS` IN (1,2)
		   AND pp.NOMOR = pt.ID  
		   AND pt.JENIS = PJENIS
		   AND ppd.BARANG = ib.ID
		   AND hb.ID = ppd.HARGA_BARANG
	 GROUP BY ppd.ID
   ) dat;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;