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

-- membuang struktur untuk procedure pembayaran.CetakKwitansi
DROP PROCEDURE IF EXISTS `CetakKwitansi`;
DELIMITER //
CREATE PROCEDURE `CetakKwitansi`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
)
BEGIN
   DECLARE VID CHAR(10);
	DECLARE VNAMALENGKAP, VNAMAINSTANSI, VALAMAT, VKET, VPENGGUNA, VPEMBAYAR VARCHAR(250);
	DECLARE VTOTAL, VTOTALTAGIHAN, VTOTALDISKON, VTOTALEDC, VTOTALPENJAMINTAGIHAN DECIMAL(60,2);
	DECLARE VTOTALPIUTANG, VTOTALDEPOSIT, VTOTALSUBSIDI, VVTAGIHAN DECIMAL(60,2);
	DECLARE VTANGGAL, VTANGGALBAYAR DATETIME;
	DECLARE VNORM CHAR(14);
	DECLARE VNIP CHAR(30);
	DECLARE VTAGIHAN, VIDPPK INT;
	DECLARE VREF INT;
	
	SELECT t.ID, t.TANGGAL, t.TOTAL,
			 pt.TANGGAL TANGGALBAYAR,
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 inst.PPK IDPPK, UPPER(inst.NAMA) NAMAINSTANSI, inst.ALAMAT,
			 CONCAT(pembayaran.getInfoTagihanKunjungan(t.ID),' ',inst.NAMA) KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, 
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 @tghn:=IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1 OR (pc.VALUE = 'TRUE' AND (pjt.NAIK_KELAS=1 OR pjt.NAIK_KELAS_VIP OR pjt.NAIK_DIATAS_VIP=1)),(pjt.TOTAL_NAIK_KELAS), IF(t.TOTAL < pjt.TOTAL,pjt.TARIF_INACBG_KELAS1,(t.TOTAL))) TOTALTAGIHAN, 
			 @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
			 @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC, 
			 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
			 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
			 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
			 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
			 @tot:=ROUND(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) VTAGIHAN,
			 IF(@tot < 0, 0, @tot) `TAGIHAN`,
			 t.REF
	  INTO VID, VTANGGAL, VTOTAL, 
	  		 VTANGGALBAYAR, VNORM, VNAMALENGKAP,
	  		 VIDPPK, VNAMAINSTANSI, VALAMAT, VKET,
	  		 VNIP, VPENGGUNA, VPEMBAYAR,
	  		 VTOTALTAGIHAN, VTOTALDISKON, VTOTALEDC, VTOTALPENJAMINTAGIHAN, VTOTALPIUTANG,
	  		 VTOTALDEPOSIT, VTOTALSUBSIDI, VVTAGIHAN, VTAGIHAN,
	  		 VREF
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
	  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.`STATUS` IN (1, 2)
	  		 LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		    LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		    LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		    LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
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
		
	IF PJENIS = 2 THEN # PIUTANG PASIEN
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
	
	SELECT VID ID, VTANGGAL TANGGAL, VTOTAL TOTAL, 
	  		 VTANGGALBAYAR TANGGALBAYAR, VNORM NORM, VNAMALENGKAP NAMALENGKAP,
	  		 VIDPPK IDPPK, VNAMAINSTANSI NAMAINSTANSI, VALAMAT ALAMAT, VKET KET,
	  		 VNIP NIP, VPENGGUNA PENGGUNA, VPEMBAYAR PEMBAYAR,
	 		 VTOTALTAGIHAN TOTALTAGIHAN, VTOTALDISKON TOTALDISKON, 
			 VTOTALEDC TOTALEDC, VTOTALPENJAMINTAGIHAN TOTALPENJAMINTAGIHAN, VTOTALPIUTANG TOTALPIUTANG,
	  		 VTOTALDEPOSIT TOTALDEPOSIT, VTOTALSUBSIDI TOTALSUBSIDI, VVTAGIHAN VTAGIHAN, VTAGIHAN `TAGIHAN`;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
