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

-- membuang struktur untuk procedure pembayaran.CetakKwitansi
DROP PROCEDURE IF EXISTS `CetakKwitansi`;
DELIMITER //
CREATE PROCEDURE `CetakKwitansi`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
)
BEGIN
	DECLARE VNOMOR_PEMBAYARAN CHAR(11);
	DECLARE VNOMOR_KUITANSI CHAR(12);
	DECLARE VPEMBAYAR VARCHAR(75);
   DECLARE VNOMOR_TAGIHAN CHAR(10);
	DECLARE VNAMALENGKAP, VNAMAINSTANSI, VALAMAT, VKET, VPENGGUNA VARCHAR(250);
	DECLARE VTANGGAL, VTANGGALBAYAR DATETIME;
	DECLARE VNORM CHAR(14);
	DECLARE VNIP CHAR(30);
	DECLARE VTAGIHAN, VIDPPK INT;
	DECLARE VREF INT;
	
	SELECT kp.NOMOR, kp.NAMA
	  INTO VNOMOR_KUITANSI, VPEMBAYAR
	  FROM cetakan.kwitansi_pembayaran kp 
	 WHERE kp.TAGIHAN = PTAGIHAN
	   AND kp.TUNAI = 1
       AND kp.JENIS_LAYANAN_ID = 1
	 ORDER BY kp.TANGGAL DESC
	 LIMIT 1;
	
	SELECT pt.NOMOR, t.ID, t.TANGGAL,
			 pt.TANGGAL TANGGALBAYAR,
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT,
			 CONCAT(pembayaran.getInfoTagihanKunjungan(t.ID),' ',inst.NAMA) KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA,
			 IF(pt.TOTAL < 0, 0, pt.TOTAL) `TAGIHAN`,
			 t.REF
	  INTO VNOMOR_PEMBAYARAN, VNOMOR_TAGIHAN, VTANGGAL,
	  		 VTANGGALBAYAR, VNORM, VNAMALENGKAP,
	  		 VIDPPK, VNAMAINSTANSI, VALAMAT, VKET,
	  		 VNIP, VPENGGUNA, 
	  		 VTAGIHAN,
	  		 VREF
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
	  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.`STATUS` IN (1, 2)
			 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
			 LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP,
			 (SELECT mpp.NAMA, mpp.ALAMAT, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mpp
				WHERE ai.PPK=mpp.ID) inst
			 , aplikasi.properti_config pc
	 WHERE t.ID = PTAGIHAN
	   AND t.JENIS = PJENIS
	   AND t.`STATUS` = 2
		AND pc.ID = 9;
		
	IF PJENIS = 2 THEN 
		SELECT INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
			    master.getNamaLengkap(p.NORM) NAMALENGKAP,
			    CONCAT('Piutang ', pembayaran.getInfoTagihanKunjungan(t.ID),' ',VNAMAINSTANSI) KET
		  INTO VNORM, VNAMALENGKAP, VKET
		  FROM pembayaran.pelunasan_piutang_pasien ppp
		  		 , pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		 WHERE ppp.ID = VREF
		   AND t.ID = ppp.TAGIHAN_PIUTANG;
	END IF;
	
	SELECT VNOMOR_PEMBAYARAN NOMOR_PEMBAYARAN, VNOMOR_KUITANSI NOMOR_KUITANSI, VNOMOR_TAGIHAN NOMOR_TAGIHAN, VNOMOR_TAGIHAN ID, VTANGGAL TANGGAL,
	  		 VTANGGALBAYAR TANGGALBAYAR, VNORM NORM, VNAMALENGKAP NAMALENGKAP,
	  		 VIDPPK IDPPK, VNAMAINSTANSI NAMAINSTANSI, VALAMAT ALAMAT, VKET KET,
	  		 VNIP NIP, VPENGGUNA PENGGUNA, VPEMBAYAR PEMBAYAR,
	 		 VTAGIHAN `TAGIHAN`;
END//
DELIMITER ;

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
	 
	SELECT pt.NOMOR NOMOR_PEMBAYARAN, VNOMOR_KUITANSI NOMOR_KUITANSI, t.ID, t.TANGGAL, 
			 pt.TANGGAL TANGGALBAYAR,
			 IF(pp.PENGUNJUNG = '' OR pp.PENGUNJUNG IS NULL, VNAMA, pp.PENGUNJUNG) NAMALENGKAP,
			 inst.NAMA NAMAINSTANSI, inst.PPK IDPPK, inst.ALAMAT,
			 IF(pp.KETERANGAN = '' OR pp.KETERANGAN IS NULL, 'Pembelian Obat & Barang Lainnya', pp.KETERANGAN) KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA,
			 IF(pt.TOTAL < 0, 0, pt.TOTAL) TAGIHAN
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

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
