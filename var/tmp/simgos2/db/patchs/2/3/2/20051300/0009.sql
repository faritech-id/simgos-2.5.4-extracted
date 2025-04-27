-- --------------------------------------------------------
-- Host:                         127.0.0.1
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Win64
-- HeidiSQL Versi:               10.2.0.5599
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

USE `pembayaran`;

-- membuang struktur untuk procedure pembayaran.CetakKwitansi
DROP PROCEDURE IF EXISTS `CetakKwitansi`;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `CetakKwitansi`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
)
BEGIN
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
			 @tedc:=pembayaran.getTotalEDC(t.ID) TOTALEDC, 
			 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
			 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
			 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
			 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
			 @tot:=ROUND(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) VTAGIHAN,
			 IF(@tot < 0, 0, @tot) TAGIHAN
			 
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
	  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.`STATUS` = 1
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
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IF(@OLD_FOREIGN_KEY_CHECKS IS NULL, 1, @OLD_FOREIGN_KEY_CHECKS) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
