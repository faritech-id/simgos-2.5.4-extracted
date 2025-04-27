-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.0.0.6468
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk penjualan
CREATE DATABASE IF NOT EXISTS `penjualan`;
USE `penjualan`;

-- membuang struktur untuk procedure penjualan.CetakEtiket
DROP PROCEDURE IF EXISTS `CetakEtiket`;
DELIMITER //
CREATE PROCEDURE `CetakEtiket`(
	IN `PPENJUALAN` VARCHAR(50)
)
BEGIN
	SELECT inst.NAMA NAMAINSTANSI, inst.ALAMAT ALAMATINSTANSI
		    , apoteker.NAMA NAMAAPOTEKER, apoteker.SIPA SIPAAPOTEKER, p.PENGUNJUNG, p.TANGGAL,p.NOMOR, br.NAMA NAMAOBAT, pd.JUMLAH
			 , master.getAturanPakai(pd.ATURAN_PAKAI) DESKRIPSI 
		    , jp.DESKRIPSI JENISPENGGUNAAN
	  FROM penjualan.penjualan p
	       LEFT JOIN penjualan.penjualan_detil pd ON pd.PENJUALAN_ID = p.NOMOR
	       LEFT JOIN inventory.barang br ON br.ID = pd.BARANG
	       LEFT JOIN master.referensi ref ON ref.ID = pd.ATURAN_PAKAI AND ref.JENIS = 41
	       LEFT JOIN master.referensi jp ON br.JENIS_PENGGUNAAN_OBAT = jp.ID AND jp.JENIS = 55
	       , (SELECT mp.NAMA, ai.PPK, mp.ALAMAT
			 	   FROM aplikasi.instansi ai
			 		    , master.ppk mp
				  WHERE ai.PPK = mp.ID
			 ) inst
			 , (SELECT ap.NAMA, ap.SIPA
				   FROM master.apoteker ap
				  WHERE ap.`STATUS` = 1
			 ) apoteker
	 WHERE p.NOMOR = PPENJUALAN;
END//
DELIMITER ;

-- membuang struktur untuk procedure penjualan.CetakFakturPenjualan
DROP PROCEDURE IF EXISTS `CetakFakturPenjualan`;
DELIMITER //
CREATE PROCEDURE `CetakFakturPenjualan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
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
			  	 , (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL,0,mpf.MARGIN / 100))) HARGA_JUAL
			  	 , r.DESKRIPSI RUANGANASAL
	     FROM penjualan.penjualan pp
	  		    LEFT JOIN master.ruangan r ON r.ID = pp.RUANGAN
		       LEFT JOIN aplikasi.pengguna usr ON usr.ID = pp.OLEH
			  	 , penjualan.penjualan_detil ppd
			  	 LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = ppd.MARGIN
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

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
