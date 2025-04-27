USE `pembayaran`;
-- --------------------------------------------------------
-- Host:                         192.168.23.117
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               9.2.0.4947
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Dumping structure for procedure pembayaran.CetakRincianPenjualan
DROP PROCEDURE IF EXISTS `CetakRincianPenjualan`;
DELIMITER //
CREATE DEFINER=`root`@`127.0.0.1` PROCEDURE `CetakRincianPenjualan`(IN `PNOMOR` CHAR(20)
)
BEGIN 
SET @sqlText = CONCAT('
		SELECT w.DESKRIPSI WILAYAH, mp.NAMA PENGGUNA, mp.NIP
			  , p.NOMOR,p.KETERANGAN,p.TANGGAL,p.PENGUNJUNG
			  , b.NAMA NAMAOBAT, pd.JUMLAH
			  , (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)) +
			  	 (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)) * IF(ppn.PPN IS NULL, 0, ppn.PPN / 100)))  HARGA_JUAL
			  , (pd.JUMLAH * 
			  		(hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)) +
			  	 (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)) * IF(ppn.PPN IS NULL, 0, ppn.PPN / 100)))
			  		) TOTAL
			  ,  pt.TANGGAL TGLBYR
			  , r.DESKRIPSI RUANGANASAL
		FROM pembayaran.tagihan t
		     LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.STATUS IN (1, 2)
		     LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		     LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
			  , penjualan.penjualan p
			  LEFT JOIN master.ruangan r ON p.RUANGAN = r.ID
			  , penjualan.penjualan_detil pd
			  LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = pd.MARGIN
			  LEFT JOIN penjualan.ppn_penjualan ppn ON ppn.ID = pd.PPN
			  , inventory.barang b
			  , inventory.harga_barang hb
			  , aplikasi.instansi i
			  , master.ppk ppk
			  , master.wilayah w
		WHERE ppk.ID = i.PPK AND w.ID = ppk.WILAYAH AND b.ID = pd.BARANG
		  AND hb.ID = pd.HARGA_BARANG 
		  AND pd.PENJUALAN_ID = p.NOMOR AND p.NOMOR = t.ID 
		  AND t.ID = ''',PNOMOR,'''
		ORDER BY pd.ID');
   
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;