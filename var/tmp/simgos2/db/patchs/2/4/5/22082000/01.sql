-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Versi server:                 8.0.26 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Membuang struktur basisdata untuk pembayaran
USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.CetakEDC
DROP PROCEDURE IF EXISTS `CetakEDC`;
DELIMITER //
CREATE PROCEDURE `CetakEDC`(
	IN `PNOMOR` CHAR(11)
)
BEGIN
	DECLARE VNOMOR CHAR(11);
	DECLARE VTAGIHAN CHAR(10);
	DECLARE VNAMA_BANK, VNAMA_KARTU, VPEMILIK, 
			  VNAMA_LENGKAP, VNAMA_INSTANSI, VKET, VPENGGUNA VARCHAR(250);
	DECLARE VNOMOR_KARTU CHAR(25);
	DECLARE VTOTAL DECIMAL(60,2);
	DECLARE VAPRV_CODE CHAR(20);
	DECLARE VTGL_EDC DATETIME;
	DECLARE VNORM CHAR(14);
	DECLARE VNIP CHAR(30);
	DECLARE VTAGIHAN_JENIS TINYINT;
	DECLARE VTAGIHAN_REF INT;
	
	SELECT dp.NOMOR, dp.TAGIHAN, bnk.DESKRIPSI NAMA_BANK, nkartu.DESKRIPSI NAMA_KARTU, 
			 dp.NO_ID NOMOR_KARTU ,dp.TOTAL, dp.NAMA PEMILIK, dp.REF APRV_CODE, dp.TANGGAL TGL_EDC,
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
			 master.getNamaLengkap(p.NORM) NAMA_LENGKAP,
			 inst.NAMA NAMA_INSTANSI,
			 CONCAT(pembayaran.getInfoTagihanKunjungan(t.ID),' ',inst.NAMA) KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA,
			 t.JENIS, t.REF
	  INTO VNOMOR, VTAGIHAN, VNAMA_BANK, VNAMA_KARTU,
	  	    VNOMOR_KARTU, VTOTAL, VPEMILIK, VAPRV_CODE, VTGL_EDC,
	  	    VNORM, VNAMA_LENGKAP, VNAMA_INSTANSI, VKET, VNIP, VPENGGUNA,
	  	    VTAGIHAN_JENIS, VTAGIHAN_REF
	  FROM pembayaran.tagihan t
	       LEFT JOIN `master`.pasien p ON p.NORM = t.REF,
			 pembayaran.pembayaran_tagihan dp
			 LEFT JOIN aplikasi.pengguna us ON us.ID = dp.OLEH
			 LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
			 LEFT JOIN master.referensi bnk ON dp.BANK_ID = bnk.ID AND bnk.JENIS = 16
			 LEFT JOIN master.referensi nkartu ON dp.JENIS_KARTU_ID = nkartu.ID AND nkartu.JENIS = 17,
			 (SELECT mp.NAMA 
				 FROM aplikasi.instansi ai
						, master.ppk mp
				WHERE ai.PPK = mp.ID) inst
	WHERE dp.NOMOR = PNOMOR
	AND dp.TAGIHAN = t.ID
	AND dp.JENIS_LAYANAN_ID = 2
	AND NOT dp.`STATUS` = 0;
	
	IF VTAGIHAN_JENIS = 2 THEN # PIUTANG PASIEN
		SELECT INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
			    master.getNamaLengkap(p.NORM) NAMA_LENGKAP,
			    CONCAT('Piutang ', pembayaran.getInfoTagihanKunjungan(t.ID),' ',VNAMA_INSTANSI) KET
		  INTO VNORM, VNAMA_LENGKAP, VKET
		  FROM pembayaran.pelunasan_piutang_pasien ppp
		  		 , pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		 WHERE ppp.ID = VTAGIHAN_REF
		   AND t.ID = ppp.TAGIHAN_PIUTANG;
	END IF;
	
	SELECT VNOMOR NOMOR, VTAGIHAN TAGIHAN, VNAMA_BANK NAMA_BANK, VNAMA_KARTU NAMA_KARTU,
	  	    VNOMOR_KARTU NOMOR_KARTU, VTOTAL TOTAL, VPEMILIK PEMILIK, VAPRV_CODE APRV_CODE, VTGL_EDC TGL_EDC,
	  	    VNORM NORM, VNAMA_LENGKAP NAMA_LENGKAP, VNAMA_INSTANSI NAMA_INSTANSI, VKET KET, VNIP NIP, VPENGGUNA PENGGUNA;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
