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
   DECLARE VNOMOR_TAGIHAN CHAR(10);
	DECLARE VNAMALENGKAP, VNAMAINSTANSI, VALAMAT, VKET, VPENGGUNA, VPEMBAYAR VARCHAR(250);
	DECLARE VTOTAL, VTOTALTAGIHAN, VTOTALDISKON, VTOTALEDC, VTOTALPENJAMINTAGIHAN DECIMAL(60,2);
	DECLARE VTOTALPIUTANG, VTOTALDEPOSIT, VTOTALSUBSIDI, VVTAGIHAN DECIMAL(60,2);
	DECLARE VTANGGAL, VTANGGALBAYAR DATETIME;
	DECLARE VNORM CHAR(14);
	DECLARE VNIP CHAR(30);
	DECLARE VTAGIHAN, VIDPPK INT;
	DECLARE VREF INT;
	
	SELECT kp.NOMOR 
	  INTO VNOMOR_KUITANSI
	  FROM cetakan.kwitansi_pembayaran kp 
	 WHERE kp.TAGIHAN = PTAGIHAN
	   AND kp.TUNAI = 1
       AND kp.JENIS_LAYANAN_ID = 1
	 ORDER BY kp.TANGGAL DESC
	 LIMIT 1;
	
	SELECT pt.NOMOR, t.ID, t.TANGGAL, t.TOTAL,
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
			 , t.PEMBULATAN
	  INTO VNOMOR_PEMBAYARAN, VNOMOR_TAGIHAN, VTANGGAL, VTOTAL, 
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
	
	SELECT VNOMOR_PEMBAYARAN NOMOR_PEMBAYARAN, VNOMOR_KUITANSI NOMOR_KUITANSI, VNOMOR_TAGIHAN NOMOR_TAGIHAN, VNOMOR_TAGIHAN ID, VTANGGAL TANGGAL, VTOTAL TOTAL, 
	  		 VTANGGALBAYAR TANGGALBAYAR, VNORM NORM, VNAMALENGKAP NAMALENGKAP,
	  		 VIDPPK IDPPK, VNAMAINSTANSI NAMAINSTANSI, VALAMAT ALAMAT, VKET KET,
	  		 VNIP NIP, VPENGGUNA PENGGUNA, VPEMBAYAR PEMBAYAR,
	 		 VTOTALTAGIHAN TOTALTAGIHAN, VTOTALDISKON TOTALDISKON, 
			 VTOTALEDC TOTALEDC, VTOTALPENJAMINTAGIHAN TOTALPENJAMINTAGIHAN, VTOTALPIUTANG TOTALPIUTANG,
	  		 VTOTALDEPOSIT TOTALDEPOSIT, VTOTALSUBSIDI TOTALSUBSIDI, VVTAGIHAN VTAGIHAN, VTAGIHAN `TAGIHAN`;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakRekapPasien
DROP PROCEDURE IF EXISTS `CetakRekapPasien`;
DELIMITER //
CREATE PROCEDURE `CetakRekapPasien`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT r.*, 
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP, pj.JENIS IDCARABAYAR, pj.NOMOR NOSEP, kap.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 pjt.NAIK_KELAS, pjt.NAIK_KELAS_VIP, pjt.NAIK_DIATAS_VIP,
			 @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN,
			 @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
			 @tedc:=pembayaran.getTotalEDC(t.ID) TOTALEDC, 
			 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
			 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
			 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
			 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
			 IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
			 /*IF(pj.JENIS=2,IF(pjt.NAIK_KELAS_VIP=1,
				IF(t.TOTAL < pjt.TOTAL,0,IF(((t.TOTAL - pjt.TARIF_INACBG_KELAS1) > (pjt.TARIF_INACBG_KELAS1 * 0.75)),(pjt.TARIF_INACBG_KELAS1 * 0.75) ,(t.TOTAL - pjt.TARIF_INACBG_KELAS1)))
				+ (pjt.TARIF_INACBG_KELAS1 - pjt.TOTAL)
			, IF(pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS - pjt.TOTAL)
			 , IF(pjt.NAIK_DIATAS_VIP=1, (t.TOTAL - IF(pjt.TOTAL > pjt.TOTAL_TAGIHAN_HAK,pjt.TOTAL, pjt.TOTAL_TAGIHAN_HAK))
			 , 0))),
			 (t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalEDC(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))+pembayaran.getTotalSubsidiTagihan(t.ID)))) JUMLAHBAYAR*/
			  , ppk.NAMA NAMAINSTANSI, ppk.ALAMAT ALAMATINSTANSI, ppk.TELEPON
			 , w.DESKRIPSI WILAYAH, t.PEMBULATAN
		  FROM (', pembayaran.getSkripRincianTagihan1(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS !=0
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.kartu_asuransi_pasien kap ON pd.NORM=kap.NORM AND kap.JENIS = 2
		  LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		  , aplikasi.properti_config pc
		WHERE r.STATUS = ', PSTATUS, '
		  AND ppk.ID = i.PPK
		  AND w.ID = ppk.WILAYAH
		  AND pc.ID = 9
		');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakRincianPasien
DROP PROCEDURE IF EXISTS `CetakRincianPasien`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPasien`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT r.*, 
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP, pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(d.NIP) DOKTER,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 pjt.NAIK_KELAS, pjt.NAIK_KELAS_VIP, pjt.NAIK_DIATAS_VIP,
			 @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN,
			 @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
			 @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC, 
			 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
			 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
			 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
			 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
			 IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
			 /*IF(pj.JENIS=2,IF(pjt.NAIK_KELAS_VIP=1,
				IF(t.TOTAL < pjt.TOTAL,0,IF(((t.TOTAL - pjt.TARIF_INACBG_KELAS1) > (pjt.TARIF_INACBG_KELAS1 * 0.75)),(pjt.TARIF_INACBG_KELAS1 * 0.75) ,(t.TOTAL - pjt.TARIF_INACBG_KELAS1)))
				+ (pjt.TARIF_INACBG_KELAS1 - pjt.TOTAL)
			, IF(pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS - pjt.TOTAL)
			 , IF(pjt.NAIK_DIATAS_VIP=1, (t.TOTAL - IF(pjt.TOTAL > pjt.TOTAL_TAGIHAN_HAK,pjt.TOTAL, pjt.TOTAL_TAGIHAN_HAK))
			 , 0))),
			 (t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalNonTunai(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))+pembayaran.getTotalSubsidiTagihan(t.ID)))) JUMLAHBAYAR*/
			  , ppk.NAMA NAMAINSTANSI, ppk.ALAMAT ALAMATINSTANSI, ppk.TELEPON
			 , w.DESKRIPSI WILAYAH
			 , pjt.PERSENTASE_TARIF_INACBG_KELAS1
			 , t.PEMBULATAN
		  FROM (', pembayaran.getSkripRincianTagihan(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS IN (1, 2)
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pd.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.dokter d ON tp.DOKTER=d.ID
		  LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		  , aplikasi.properti_config pc
		WHERE r.STATUS = ', PSTATUS, '
		  AND ppk.ID = i.PPK
		  AND w.ID = ppk.WILAYAH
		  AND pc.ID = 9
		');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakRincianPasienGroup
DROP PROCEDURE IF EXISTS `CetakRincianPasienGroup`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPasienGroup`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_HEADER_RINCIAN;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DETIL_RINCIAN;	

	CREATE TEMPORARY TABLE TEMP_HEADER_RINCIAN ENGINE=MEMORY
		SELECT i.PPK, t.ID NOMOR_TAGIHAN
				 , INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
				 , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGALREG
				 , `master`.getNamaLengkap(p.NORM) NAMALENGKAP
				 , pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR
				 , p.TANGGAL_LAHIR, CONCAT(CAST(rjk.DESKRIPSI AS CHAR(15)),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') UMUR 
				 , IF(pt.OLEH=0,pt.DESKRIPSI,master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA, t.ID IDTAGIHAN
				 , w.DESKRIPSI WILAYAH
				 , pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN
				 ,  @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN
				 , @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON 
				 , @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC 
				 ,  @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN 
				 ,  @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG
				 , @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT
				 , @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI
				 , IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
				 , IF((@tghn - @tj - @ts - @tp - @td - @tedc) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc)) TOTALJUMLAHBAYAR
				 , t.PEMBULATAN
			
		  FROM pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  		 LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  		 LEFT JOIN pembayaran.tagihan_pendaftaran tp ON tp.TAGIHAN = t.ID AND tp.UTAMA = 1 AND tp.`STATUS` = 1
		  		 LEFT JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = tp.PENDAFTARAN
		  		 LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		       LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS IN (1, 2)
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		       LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  		, aplikasi.instansi i
			   , master.ppk ppk
			   , master.wilayah w
		 WHERE t.ID = PTAGIHAN
		   AND t.JENIS = 1
		   AND t.`STATUS` IN (1, 2)
			AND ppk.ID = i.PPK
		   AND w.ID = ppk.WILAYAH;
	  
	CREATE TEMPORARY TABLE TEMP_DETIL_RINCIAN (
		`TAGIHAN` CHAR(10),
		`RUANGAN` VARCHAR(250),
		`LAYANAN` VARCHAR(100),
		`TANGGAL` DATETIME,
		`JUMLAH` DECIMAL(60,2),
		`TARIF` DECIMAL(60,2),
		`JENIS_KUNJUNGAN` TINYINT(4),
		`DESKRIPSI_KUNJUNGAN` VARCHAR(250),
		`JENIS_RINCIAN` VARCHAR(250)
	
	)
	ENGINE=MEMORY;
	
	INSERT INTO TEMP_DETIL_RINCIAN
		SELECT rt.TAGIHAN,
				 CONCAT(
				 	IF(r.JENIS_KUNJUNGAN = 3,
				 		CONCAT(r.DESKRIPSI,' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), 
						IF(NOT r1.DESKRIPSI IS NULL, r1.DESKRIPSI, r2.DESKRIPSI))
				 ) RUANGAN,
				 adm.NAMA LAYANAN,
				 IF(rt.JENIS = 1, 
				 	IF(tadm.ADMINISTRASI = 1, krtp.TANGGAL, 
					 	IF(tadm.ADMINISTRASI = 2, kp.TANGGAL, kj.KELUAR)
					 ), NULL) TANGGAL,
				 rt.JUMLAH, rt.TARIF
				 , IF(r.JENIS_KUNJUNGAN = 3, r.JENIS_KUNJUNGAN, r1.JENIS_KUNJUNGAN) JENIS_KUNJUNGAN
				 , IF(r.JENIS_KUNJUNGAN = 3, ref.DESKRIPSI, ref1.DESKRIPSI) DESKRIPSI_KUNJUNGAN
				 , jr.DESKRIPSI JENIS_RINCIAN
		  FROM pembayaran.rincian_tagihan rt
		  	    LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rt.REF_ID	
		  		 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rt.REF_ID AND rt.JENIS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN AND p.`STATUS`!=0
		  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
		  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
		  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
		  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
		  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
		  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
		  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
		  		 LEFT JOIN `master`.referensi ref1 ON r1.JENIS_KUNJUNGAN=ref1.ID AND ref1.`STATUS`!=0 AND ref1.JENIS = 15
		  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  		 LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
		  		 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
		  		 LEFT JOIN `master`.ruangan r2 ON r2.ID = kj.RUANGAN
		 WHERE rt.TAGIHAN = PTAGIHAN
		   AND rt.JENIS = 1 AND rt.STATUS = 1;
	
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			, ref.DESKRIPSI DESKRIPSI_KUNJUNGAN
			, jr.DESKRIPSI JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
	  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 5 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('(', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN,
			 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF - IF(rt.PERSENTASE_DISKON = 0, rt.DISKON, rt.TARIF * (rt.DISKON/100)) TARIF
			 , r.JENIS_KUNJUNGAN
			 , ref.DESKRIPSI DESKRIPSI_KUNJUNGAN
			 , IF(r.JENIS_KUNJUNGAN = 3,
			 		'Akomodasi', '') JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2 AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 2 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT * FROM (
	SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , ref.DESKRIPSI DESKRIPSI_KUNJUNGAN
			 , IF(INSTR(t.NAMA,'Visite') > 0 OR r.JENIS_KUNJUNGAN=6, t.NAMA,CONCAT(jr.DESKRIPSI,' ',ref.DESKRIPSI)) JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
		    LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NULL AND rt.STATUS = 1
	 UNION
	 
	 SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 'Tindakan Keperawatan' LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, SUM(rt.TARIF)
			 , r.JENIS_KUNJUNGAN
			 , ref.DESKRIPSI DESKRIPSI_KUNJUNGAN
			 , jr.DESKRIPSI JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
		    LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NOT NULL AND rt.STATUS = 1
	 GROUP BY RUANGAN,LAYANAN) ab
	 ORDER BY JENIS_KUNJUNGAN;
		  	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , ref.DESKRIPSI DESKRIPSI_KUNJUNGAN
			 , b.NAMA JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4 AND f.`STATUS`!=0
	  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 4 AND rt.STATUS = 1;
	   	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 ref.DESKRIPSI LAYANAN,
			 IF(rt.JENIS =  6, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
		    , ref1.DESKRIPSI DESKRIPSI_KUNJUNGAN
		    , ref.DESKRIPSI JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	  		 LEFT JOIN `master`.referensi ref1 ON r.JENIS_KUNJUNGAN=ref1.ID AND ref1.`STATUS`!=0 AND ref1.JENIS = 15
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 6 AND rt.STATUS = 1;
	
	SELECT thr.*, tdr.*, SUM(JUMLAH) JUMLAH, SUM(JUMLAH * TARIF) TOTAL
	  FROM TEMP_HEADER_RINCIAN thr
	       , TEMP_DETIL_RINCIAN tdr
	 WHERE tdr.TAGIHAN = thr.NOMOR_TAGIHAN
	 GROUP BY RUANGAN, JENIS_RINCIAN
	 ORDER BY JENIS_KUNJUNGAN, JENIS_RINCIAN
	 ;	
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakRincianPasienObat
DROP PROCEDURE IF EXISTS `CetakRincianPasienObat`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPasienObat`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT r.*, 
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP, pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(d.NIP) DOKTER,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 pjt.NAIK_KELAS, pjt.NAIK_KELAS_VIP, pjt.NAIK_DIATAS_VIP,
			 @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN,
			 @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
			 @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC, 
			 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
			 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
			 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
			 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
			IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
			 /*IF(pj.JENIS=2,IF(pjt.NAIK_KELAS_VIP=1,
				IF(t.TOTAL < pjt.TOTAL,0,IF(((t.TOTAL - pjt.TARIF_INACBG_KELAS1) > (pjt.TARIF_INACBG_KELAS1 * 0.75)),(pjt.TARIF_INACBG_KELAS1 * 0.75) ,(t.TOTAL - pjt.TARIF_INACBG_KELAS1)))
				+ (pjt.TARIF_INACBG_KELAS1 - pjt.TOTAL)
			, IF(pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS - pjt.TOTAL)
			 , IF(pjt.NAIK_DIATAS_VIP=1, (t.TOTAL - IF(pjt.TOTAL > pjt.TOTAL_TAGIHAN_HAK,pjt.TOTAL, pjt.TOTAL_TAGIHAN_HAK))
			 , 0))),
			 (t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalNonTunai(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))+pembayaran.getTotalSubsidiTagihan(t.ID)))) JUMLAHBAYAR*/
			  , ppk.NAMA NAMAINSTANSI, ppk.ALAMAT ALAMATINSTANSI, ppk.TELEPON
			 , w.DESKRIPSI WILAYAH
			 , pjt.PERSENTASE_TARIF_INACBG_KELAS1
			 , t.PEMBULATAN
		  FROM (', pembayaran.getSkripRincianTagihanObat(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS IN (1, 2)
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  LEFT JOIN pendaftaran.tujuan_pasien tp ON pd.NOMOR=tp.NOPEN AND tp.STATUS!=0
		  LEFT JOIN master.dokter d ON tp.DOKTER=d.ID
		  LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		  , aplikasi.properti_config pc
		WHERE r.STATUS = ', PSTATUS, '
		  AND ppk.ID = i.PPK
		  AND w.ID = ppk.WILAYAH
		  AND pc.ID = 9
		');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakRincianPasienPerDokter
DROP PROCEDURE IF EXISTS `CetakRincianPasienPerDokter`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPasienPerDokter`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	DROP TEMPORARY TABLE IF EXISTS TEMP_HEADER_RINCIAN;
	DROP TEMPORARY TABLE IF EXISTS TEMP_DETIL_RINCIAN;	

	CREATE TEMPORARY TABLE TEMP_HEADER_RINCIAN ENGINE=MEMORY
		SELECT t.ID NOMOR_TAGIHAN
				 , INSERT(INSERT(INSERT(LPAD(p.NORM,8,'0'),3,0,'-'),6,0,'-'),9,0,'-') NORM
				 , pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,'%d-%m-%Y %H:%i:%s') TANGGALREG
				 , `master`.getNamaLengkap(p.NORM) NAMALENGKAP
				 , pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR
				 , p.TANGGAL_LAHIR, CONCAT(CAST(rjk.DESKRIPSI AS CHAR(15)),' (',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),')') UMUR 
				 , IF(pt.OLEH=0,pt.DESKRIPSI,master.getNamaLengkapPegawai(mp.NIP)) PENGGUNA, t.ID IDTAGIHAN
				 , w.DESKRIPSI WILAYAH
				 , pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN
				 ,  @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN
				 , @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON 
				 , @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC 
				 ,  @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN 
				 ,  @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG
				 , @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT
				 , @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI
				 , IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
				 , t.PEMBULATAN
		  FROM pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  		 LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  		 LEFT JOIN pembayaran.tagihan_pendaftaran tp ON tp.TAGIHAN = t.ID AND tp.UTAMA = 1 AND tp.`STATUS` = 1
		  		 LEFT JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = tp.PENDAFTARAN
		  		 LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		       LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS IN (1, 2)
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		       LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  		, aplikasi.instansi i
			   , master.ppk ppk
			   , master.wilayah w
		 WHERE t.ID = PTAGIHAN
		   AND t.JENIS = 1
		   AND t.`STATUS` IN (1, 2)
			AND ppk.ID = i.PPK
		   AND w.ID = ppk.WILAYAH;
	  
	CREATE TEMPORARY TABLE TEMP_DETIL_RINCIAN (
		`TAGIHAN` CHAR(10),
		`RUANGAN` VARCHAR(250),
		`LAYANAN` VARCHAR(100),
		`TANGGAL` DATETIME,
		`JUMLAH` DECIMAL(60,2),
		`TARIF` DECIMAL(60,2),
		`JENIS_KUNJUNGAN` TINYINT(4),
		`DOKTER` VARCHAR(100),
		`DOKTERKEDUA` VARCHAR(100),
		`DOKTERANASTESI` VARCHAR(100),
		`ADMINISTRASI` DECIMAL(60,2),
		`SARANA` DECIMAL(60,2),
		`BHP` DECIMAL(60,2),
		`DOKTER_OPERATOR` DECIMAL(60,2),
		`DOKTER_ANASTESI` DECIMAL(60,2),
		`DOKTER_LAINNYA` DECIMAL(60,2),
		`PENATA_ANASTESI` DECIMAL(60,2),
		`PARAMEDIS` DECIMAL(60,2),
		`NON_MEDIS` DECIMAL(60,2),
		`STATUSTINDAKANRINCIAN` TINYINT(4),
		`LAYANAN1` VARCHAR(250),
		`LAYANAN_OK` VARCHAR(250),
		`TARIF_LAYANAN_OK` VARCHAR(250),
		`RP` VARCHAR(250)
	)
	ENGINE=MEMORY;
	
	INSERT INTO TEMP_DETIL_RINCIAN
		SELECT rt.TAGIHAN,
				 CONCAT(
				 	IF(r.JENIS_KUNJUNGAN = 3,
				 		CONCAT(r.DESKRIPSI,' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), 
						IF(NOT r1.DESKRIPSI IS NULL, r1.DESKRIPSI, r2.DESKRIPSI))
				 ) RUANGAN,
				 adm.NAMA LAYANAN,
				 IF(rt.JENIS = 1, 
				 	IF(tadm.ADMINISTRASI = 1, krtp.TANGGAL, 
					 	IF(tadm.ADMINISTRASI = 2, kp.TANGGAL, kj.KELUAR)
					 ), NULL) TANGGAL,
				 rt.JUMLAH, rt.TARIF
				 , IF(r.JENIS_KUNJUNGAN = 3, r.JENIS_KUNJUNGAN, r1.JENIS_KUNJUNGAN) JENIS_KUNJUNGAN
				 , '' DOKTER
			    , '' DOKTERKEDUA
			 	 , '' DOKTERANASTESI
				 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
				 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
				 , '' STATUSTINDAKANRINCIAN
				 , adm.NAMA LAYANAN1
				 , '' LAYANAN_OK
				 , '' TARIF_LAYANAN_OK
				 , '' RP
		  FROM pembayaran.rincian_tagihan rt
		  		 LEFT JOIN cetakan.kartu_pasien krtp ON krtp.ID = rt.REF_ID	

				 LEFT JOIN cetakan.karcis_pasien kp ON kp.ID = rt.REF_ID AND rt.JENIS = 1
		  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kp.NOPEN AND p.`STATUS`!=0
		  		 LEFT JOIN `master`.tarif_administrasi tadm ON tadm.ID = rt.TARIF_ID 
		  		 LEFT JOIN `master`.administrasi adm ON adm.ID = tadm.ADMINISTRASI
		  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
		  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
		  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
		  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
		  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
		  		 LEFT JOIN `master`.ruangan r1 ON r1.ID = tp.RUANGAN
		  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
		  		 
				 LEFT JOIN pendaftaran.kunjungan kj ON kj.NOMOR = rt.REF_ID AND rt.TARIF_ID IN (3,4)
		  		 LEFT JOIN `master`.ruangan r2 ON r2.ID = kj.RUANGAN
		 WHERE rt.TAGIHAN = PTAGIHAN
		   AND rt.JENIS = 1 AND rt.STATUS = 1;
	
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , pkt.NAMA LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
	  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 5 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN	   
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN,
			 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF - IF(rt.PERSENTASE_DISKON = 0, rt.DISKON, rt.TARIF * (rt.DISKON/100)) TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '') LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2 AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 2 AND rt.STATUS = 1;
		   
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT * FROM (
	SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTER
	   	, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERKEDUA
		   , @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERANASTESI
		, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
		, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS
		, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
		, CONCAT(t.NAMA,@dok1) LAYANAN1
		, CONCAT(t.NAMA,'\r',
				SPACE(3),'Jasa dr. Operator ',
				@dok1,'\r',
				SPACE(3),'Jasa dr. Anastesi ',
				@dok3,'\r',
				SPACE(3),'Jasa dr. Asisten ',
				@dok2,'\r',
				SPACE(3),'Jasa Penata Anastesi ','\r'
			) LAYANAN_OK
		, CONCAT(' ','\r',
				REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),',','.'),'\r'
			) TARIF_LAYANAN_OK
		, CONCAT(' ','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.'
			) RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NULL AND rt.STATUS = 1
	 UNION
	 
	 SELECT rt.TAGIHAN, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 'Tindakan Keperawatan' LAYANAN,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, SUM(rt.TARIF)
			 , r.JENIS_KUNJUNGAN
			 , @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTER
	   	, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERKEDUA
		   , @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1) IS NULL,'',
					CONCAT(' [',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
				FROM layanan.petugas_tindakan_medis ptm 
				     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
				     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
				     , pembayaran.rincian_tagihan rt1
				WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1 AND ptm.`STATUS`!=0
					AND ptm.TINDAKAN_MEDIS=rt1.REF_ID AND rt1.JENIS=3 AND rt1.TAGIHAN=rt.TAGIHAN LIMIT 1),']')) DOKTERANASTESI
		, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
		, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS
		, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
		, 'Tindakan Keperawatan' LAYANAN1
		, CONCAT(t.NAMA,'\r',
				SPACE(3),'Jasa dr. Operator ',
				@dok1,'\r',
				SPACE(3),'Jasa dr. Anastesi ',
				@dok3,'\r',
				SPACE(3),'Jasa dr. Asisten ',
				@dok2,'\r',
				SPACE(3),'Jasa Penata Anastesi ','\r'
			) LAYANAN_OK
		, CONCAT(' ','\r',
				REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),',','.'),'\r',
				REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),',','.'),'\r'
			) TARIF_LAYANAN_OK
		, CONCAT(' ','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.','\r',
				'Rp.'
			) RP
			
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3 AND tm.`STATUS`!=0
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
		    LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		    LEFT JOIN master.tindakan_keperawatan tk ON tm.TINDAKAN=tk.TINDAKAN AND tk.`STATUS`=1
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 3 AND tk.ID IS NOT NULL AND rt.STATUS = 1
	 GROUP BY RUANGAN,LAYANAN) ab
	 ORDER BY JENIS_KUNJUNGAN;
		  	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 b.NAMA LAYANAN,
			 IF(rt.JENIS =  4, f.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
			 , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , b.NAMA LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.farmasi f ON f.ID = rt.REF_ID AND rt.JENIS = 4 AND f.`STATUS`!=0
	  		 LEFT JOIN inventory.barang b ON b.ID = f.FARMASI
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = f.KUNJUNGAN AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 4 AND rt.STATUS = 1;
	   	
	INSERT INTO TEMP_DETIL_RINCIAN
	SELECT rt.TAGIHAN,
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')'), '')
			 ) RUANGAN,
			 ref.DESKRIPSI LAYANAN,
			 IF(rt.JENIS =  6, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF
			 , r.JENIS_KUNJUNGAN
		    , '' DOKTER
		    , '' DOKTERKEDUA
		 	 , '' DOKTERANASTESI
			 , 0 ADMINISTRASI, 0 SARANA, 0 BHP, 0 DOKTER_OPERATOR, 0 DOKTER_ANASTESI, 0 DOKTER_LAINNYA
			 , 0 PENATA_ANASTESI, 0 PARAMEDIS, 0 NON_MEDIS
			 , '' STATUSTINDAKANRINCIAN
			 , ref.DESKRIPSI LAYANAN1
			 , '' LAYANAN_OK
			 , '' TARIF_LAYANAN_OK
			 , '' RP
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	 WHERE rt.TAGIHAN = PTAGIHAN
	   AND rt.JENIS = 6 AND rt.STATUS = 1;
	
	SELECT *
	  FROM TEMP_HEADER_RINCIAN thr
	       , TEMP_DETIL_RINCIAN tdr
	 WHERE tdr.TAGIHAN = thr.NOMOR_TAGIHAN
	 ORDER BY JENIS_KUNJUNGAN, tdr.TANGGAL;	
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakSetoranKasir
DROP PROCEDURE IF EXISTS `CetakSetoranKasir`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasir`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
			 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
			 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, tg.PEMBULATAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
			 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=1 GROUP BY rt.TAGIHAN ) ADMINISTRASI, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=2 GROUP BY rt.TAGIHAN ) AKOMODASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=3 GROUP BY rt.TAGIHAN ) TINDAKAN, 
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=4 GROUP BY rt.TAGIHAN ) FARMASI,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=5 GROUP BY rt.TAGIHAN ) PAKET,
			 (SELECT IF(SUM(rt.TARIF * rt.JUMLAH) IS NULL,0,SUM(rt.TARIF * rt.JUMLAH)) FROM pembayaran.rincian_tagihan rt WHERE rt.TAGIHAN=pt.TAGIHAN AND rt.`STATUS` IN (1,2) AND rt.JENIS=6 GROUP BY rt.TAGIHAN ) O2
			
	 FROM pembayaran.transaksi_kasir tk
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
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	     , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	 WHERE tk.NOMOR = pt.REF AND pt.`STATUS` != 0 AND pt.JENIS = 1
	  AND tk.NOMOR IN (',PNOMOR,')
	  AND tk.KASIR = ',PKASIR ,'
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.CetakSetoranKasirNonTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirNonTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirNonTunai`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN, tg.PEMBULATAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalNonTunai(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
		 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
		 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
		 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 (SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
		 bk.DESKRIPSI BANK, kt.DESKRIPSI KARTUKREDIT, dc.NOMOR NOMORKARTU, dc.PEMILIK
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
	     LEFT JOIN master.ruangan r ON tp.RUANGAN=r.ID AND r.JENIS=5
	     LEFT JOIN master.referensi rf ON r.JENIS_KUNJUNGAN=rf.ID AND rf.JENIS=15
	     LEFT JOIN pembayaran.tagihan tg ON pt.TAGIHAN=tg.ID
	   , pembayaran.edc dc
	     LEFT JOIN master.referensi bk ON dc.BANK=bk.ID AND bk.JENIS=16
	     LEFT JOIN master.referensi kt ON dc.JENIS_KARTU=kt.ID AND kt.JENIS=17
	   , (SELECT p.NAMA NAMAINST, p.ALAMAT ALAMATINST
				FROM aplikasi.instansi ai
					, master.ppk p
				WHERE ai.PPK=p.ID) INST
	WHERE tk.NOMOR = pt.REF AND pt.`STATUS` != 0 AND pt.JENIS = 1
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS` = 2 AND pt.TAGIHAN = dc.TAGIHAN
	  AND tk.KASIR = ',PKASIR ,' AND dc.STATUS IN (1,2)
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.hitungPembulatan
DROP PROCEDURE IF EXISTS `hitungPembulatan`;
DELIMITER //
CREATE PROCEDURE `hitungPembulatan`(
	IN `PTAGIHAN` CHAR(10)
)
BEGIN
	DECLARE VTOTAL, VPEMBULATAN DECIMAL(60, 2);
		
	SELECT CAST(pc.VALUE AS SIGNED)
	  INTO VPEMBULATAN
	  FROM aplikasi.properti_config pc 
	 WHERE pc.ID = 56;
	 
	IF NOT VPEMBULATAN IS NULL THEN
		SET VTOTAL = pembayaran.getTotalTagihanPembayaran(PTAGIHAN);
		
		SET VPEMBULATAN = IF((VTOTAL % VPEMBULATAN) > 0, (VPEMBULATAN - (VTOTAL % VPEMBULATAN)), 0);
		
		UPDATE pembayaran.tagihan t
	   	SET t.PEMBULATAN = VPEMBULATAN
	 	 WHERE t.ID = PTAGIHAN; 
	END IF;
END//
DELIMITER ;

-- membuang struktur untuk procedure pembayaran.prosesDistribusiTarif
DROP PROCEDURE IF EXISTS `prosesDistribusiTarif`;
DELIMITER //
CREATE PROCEDURE `prosesDistribusiTarif`(
	IN `PTAGIHAN` CHAR(10),
	IN `PREF_ID` CHAR(19),
	IN `PJENIS` TINYINT,
	IN `PJUMLAH` DECIMAL(10,2),
	IN `PTOTAL` DECIMAL(60,2),
	IN `PINSERTED` TINYINT,
	IN `PKELAS` SMALLINT
)
BEGIN
	DECLARE VJENIS TINYINT;
	DECLARE VKATEGORI CHAR(3);
	
	IF PJENIS = 3 THEN
		SELECT t.JENIS INTO VJENIS
		  FROM layanan.tindakan_medis tm
		  		 , master.tindakan t
		 WHERE tm.ID = PREF_ID
		   AND tm.`STATUS` IN (1, 2)
		   AND t.ID = tm.TINDAKAN
		 LIMIT 1;
		   
		IF FOUND_ROWS() > 0 THEN
			UPDATE pembayaran.tagihan t
			   SET t.PROSEDUR_NON_BEDAH = t.PROSEDUR_NON_BEDAH + IF(VJENIS = 1, PTOTAL, 0)
			   	 , t.PROSEDUR_BEDAH = t.PROSEDUR_BEDAH + IF(VJENIS = 2, PTOTAL, 0)
			   	 , t.KONSULTASI = t.KONSULTASI + IF(VJENIS = 3, PTOTAL, 0)
			   	 , t.TENAGA_AHLI = t.TENAGA_AHLI + IF(VJENIS = 4, PTOTAL, 0)
			   	 , t.KEPERAWATAN = t.KEPERAWATAN + IF(VJENIS IN (5, 0), PTOTAL, 0)
			   	 , t.PENUNJANG = t.PENUNJANG + IF(VJENIS = 6, PTOTAL, 0)
			   	 , t.RADIOLOGI = t.RADIOLOGI + IF(VJENIS = 7, PTOTAL, 0)
			   	 , t.LABORATORIUM = t.LABORATORIUM + IF(VJENIS = 8, PTOTAL, 0)
			   	 , t.BANK_DARAH = t.BANK_DARAH + IF(VJENIS = 9, PTOTAL, 0)
			   	 , t.REHAB_MEDIK = t.REHAB_MEDIK + IF(VJENIS = 10, PTOTAL, 0)
			   	 , t.SEWA_ALAT = t.SEWA_ALAT + IF(VJENIS = 11, PTOTAL, 0)
			 WHERE t.ID = PTAGIHAN;
		END IF;
	END IF; 
	
	IF PJENIS = 2 THEN	
		SELECT r.REF_ID INTO VJENIS
		  FROM pendaftaran.kunjungan k
		  		 , master.ruangan r
		 WHERE k.NOMOR = PREF_ID
		   AND r.ID = k.RUANGAN
		   AND k.`STATUS` IN (1, 2)
		   AND k.RUANG_KAMAR_TIDUR > 0
		   AND r.JENIS_KUNJUNGAN = 3
		 LIMIT 1;
		
		IF FOUND_ROWS() > 0 THEN
			UPDATE pembayaran.tagihan t
			   SET t.AKOMODASI = t.AKOMODASI + IF(VJENIS = 0, PTOTAL, 0)
			   	 , t.AKOMODASI_INTENSIF = t.AKOMODASI_INTENSIF + IF(VJENIS = 1, PTOTAL, 0)
			   	 , t.RAWAT_INTENSIF = IF(VJENIS = 1, 1, 0)
			   	 , t.LAMA_RAWAT_INTENSIF = t.LAMA_RAWAT_INTENSIF + IF(VJENIS = 1, PJUMLAH, 0)
			 WHERE t.ID = PTAGIHAN;			 			 
		END IF;
	END IF;
	
	IF PJENIS = 1 THEN	
		UPDATE pembayaran.tagihan t
		   SET t.AKOMODASI = t.AKOMODASI + PTOTAL
		 WHERE t.ID = PTAGIHAN;
	END IF;
	
	IF PJENIS = 4 THEN
		SELECT LEFT(b.KATEGORI, 3) INTO VKATEGORI
		  FROM layanan.farmasi f
		  		 , inventory.barang b
		 WHERE f.ID = PREF_ID
		   AND b.ID = f.FARMASI
		 LIMIT 1;
		   
		IF FOUND_ROWS() > 0 THEN
			UPDATE pembayaran.tagihan t
			   SET t.OBAT = t.OBAT + IF(VKATEGORI = '101', PTOTAL, 0)
			   	 , t.ALKES = t.ALKES + IF(VKATEGORI = '102', PTOTAL, 0)
			   	 , t.BMHP = t.BMHP + IF(NOT VKATEGORI IN ('101', '102'), PTOTAL, 0)
			 WHERE t.ID = PTAGIHAN;
		END IF;
	END IF;
	
	IF PJENIS = 6 THEN
		UPDATE pembayaran.tagihan t
		   SET t.BMHP = t.BMHP + PTOTAL
		 WHERE t.ID = PTAGIHAN;
	END IF;
	
	CALL pembayaran.hitungPembulatan(PTAGIHAN);
END//
DELIMITER ;

-- membuang struktur untuk trigger pembayaran.onAfterInsertPembayaranTagihan
DROP TRIGGER IF EXISTS `onAfterInsertPembayaranTagihan`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `onAfterInsertPembayaranTagihan` AFTER INSERT ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.JENIS IN (1, 8) AND NEW.STATUS = 2 THEN 
		UPDATE pembayaran.tagihan
		   SET STATUS = 2
		 WHERE ID = NEW.TAGIHAN
		   AND STATUS = 1;
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

-- membuang struktur untuk trigger pembayaran.pembayaran_tagihan_after_update
DROP TRIGGER IF EXISTS `pembayaran_tagihan_after_update`;
SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `pembayaran_tagihan_after_update` AFTER UPDATE ON `pembayaran_tagihan` FOR EACH ROW BEGIN
	IF NEW.STATUS != OLD.STATUS AND NEW.STATUS = 2 THEN
	   IF NEW.JENIS IN (1, 8) THEN  
			UPDATE pembayaran.tagihan
			   SET STATUS = 2
			 WHERE ID = NEW.TAGIHAN
			   AND STATUS = 1;
		END IF;
	END IF;
	
	IF NOT NEW.JENIS IN (1, 8) THEN
		CALL pembayaran.hitungPembulatan(NEW.TAGIHAN);
	END IF;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
