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

-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.CetakKwitansiPenjualan
DROP PROCEDURE IF EXISTS `CetakKwitansiPenjualan`;
DELIMITER //
CREATE PROCEDURE `CetakKwitansiPenjualan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
)
BEGIN
	DECLARE VNOMOR_KUITANSI CHAR(12);
	DECLARE VNAMA VARCHAR(75);
	
	SELECT kp.NOMOR, kp.NAMA
	  INTO VNOMOR_KUITANSI, VNAMA
	  FROM cetakan.kwitansi_pembayaran kp 
	 WHERE kp.TAGIHAN = PTAGIHAN
	   AND kp.TUNAI = 1
       AND kp.JENIS_LAYANAN_ID = 1
	 ORDER BY kp.TANGGAL DESC
	 LIMIT 1;
	 
	SELECT pt.NOMOR NOMOR_PEMBAYARAN, VNOMOR_KUITANSI NOMOR_KUITANSI, t.ID, t.TANGGAL, t.TOTAL,
			 pt.TANGGAL TANGGALBAYAR,
			 IF(pp.PENGUNJUNG = '' OR pp.PENGUNJUNG IS NULL, VNAMA, pp.PENGUNJUNG) NAMALENGKAP,
			 inst.NAMA NAMAINSTANSI, inst.PPK IDPPK, inst.ALAMAT,
			 IF(pp.KETERANGAN = '' OR pp.KETERANGAN IS NULL, 'Pembelian Obat & Barang Lainnya', pp.KETERANGAN) KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, 
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 ROUND(t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalNonTunai(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))) + t.PEMBULATAN, 0) TAGIHAN
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID
	  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
			 LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP,
			 penjualan.penjualan pp,
			 (SELECT mp.NAMA,mp.ALAMAT, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	 WHERE t.ID = PTAGIHAN AND t.ID = pp.NOMOR
	   AND t.JENIS = PJENIS
	   AND pt.JENIS = 8 AND pt.`STATUS` IN (1, 2)
	   AND t.`STATUS` = 2;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakRincianPenjualan
DROP PROCEDURE IF EXISTS `CetakRincianPenjualan`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPenjualan`(
	IN `PNOMOR` CHAR(20)
)
BEGIN 
SET @sqlText = CONCAT('
		SELECT w.DESKRIPSI WILAYAH, mp.NAMA PENGGUNA, mp.NIP
			  , p.NOMOR,p.KETERANGAN,p.TANGGAL,p.PENGUNJUNG
			  , b.NAMA NAMAOBAT, pd.JUMLAH
			  , (hb.HARGA_JUAL  
			  		+ (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)) 
					+ ((hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100))) * IF(ppn.PPN IS NULL, 0, ppn.PPN / 100))
					)  HARGA_JUAL
			  , (pd.JUMLAH * 
			  		(hb.HARGA_JUAL  
			  		+ (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)) 
					+ ((hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100))) * IF(ppn.PPN IS NULL, 0, ppn.PPN / 100))
					)
			  	) TOTAL
			  ,  pt.TANGGAL TGLBYR
			  , r.DESKRIPSI RUANGANASAL
			  , t.PEMBULATAN
			  , pembayaran.getTotalNonTunai(t.ID) NON_TUNAI
		FROM pembayaran.tagihan t
		     LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 8 AND pt.STATUS IN (1, 2)
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

-- membuang struktur untuk procedure pembayaran.CetakSetoranKasirPenjualanTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirPenjualanTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirPenjualanTunai`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, ppj.PENGUNJUNG NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
		 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
		 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, tg.PEMBULATAN, 
		 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR
	from pembayaran.transaksi_kasir tk
	     LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		  LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	   , pembayaran.pembayaran_tagihan pt
	     LEFT JOIN master.referensi jb ON pt.JENIS=jb.ID AND jb.JENIS=50
	     LEFT JOIN pembayaran.tagihan_pendaftaran ptp ON pt.TAGIHAN=ptp.TAGIHAN AND ptp.`STATUS`=1 AND ptp.UTAMA = 1
	     LEFT JOIN pendaftaran.pendaftaran pp ON ptp.PENDAFTARAN=pp.NOMOR
	     LEFT JOIN pendaftaran.penjamin pj ON pp.NOMOR=pj.NOPEN
	     LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	     LEFT JOIN master.pasien p ON pp.NORM=p.NORM
	     LEFT JOIN pendaftaran.tujuan_pasien tp ON pp.NOMOR=tp.NOPEN
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	   , penjualan.penjualan ppj
	     LEFT JOIN master.ruangan r ON ppj.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	   , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE tk.NOMOR = pt.REF AND pt.`STATUS` != 0 AND pt.JENIS = 8 AND pt.TAGIHAN = ppj.NOMOR AND ppj.STATUS IN (1,2)
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS` = 2
	  AND tk.KASIR = ',PKASIR ,'
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.hitungTotalTagihanPenjualan
DROP PROCEDURE IF EXISTS `hitungTotalTagihanPenjualan`;
DELIMITER //
CREATE PROCEDURE `hitungTotalTagihanPenjualan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VTOTAL DECIMAL(60, 2);
	
	SELECT SUM(
		(pd.JUMLAH * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)))) +
			((pd.JUMLAH * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)))) * (pp.PPN / 100))
		) TOTAL
	  INTO VTOTAL
	  FROM penjualan.penjualan p
		    , penjualan.penjualan_detil pd
		    LEFT JOIN master.margin_penjamin_farmasi mpf ON mpf.ID = pd.MARGIN
		    LEFT JOIN penjualan.ppn_penjualan pp ON pp.ID = pd.PPN
			 , inventory.barang b
			 , inventory.harga_barang hb
	 WHERE b.ID = pd.BARANG
	   AND hb.ID = pd.HARGA_BARANG 
	   AND pd.PENJUALAN_ID = p.NOMOR
	   AND p.NOMOR = PTAGIHAN;
			 
	UPDATE tagihan t
	  SET t.TOTAL = IFNULL(VTOTAL, 0) 
	WHERE t.ID = PTAGIHAN;
	
	CALL pembayaran.hitungPembulatan(PTAGIHAN);
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
