-- --------------------------------------------------------
-- Host:                         192.168.137.8
-- Server version:               8.0.25 - MySQL Community Server - GPL
-- Server OS:                    Linux
-- HeidiSQL Version:             11.3.0.6295
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8 */;
/*!50503 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;


-- Dumping database structure for pembayaran
CREATE DATABASE IF NOT EXISTS `pembayaran`;
USE `pembayaran`;

-- Dumping structure for procedure pembayaran.CetakJasaDokterKasir
DROP PROCEDURE IF EXISTS `CetakJasaDokterKasir`;
DELIMITER //
CREATE PROCEDURE `CetakJasaDokterKasir`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 t.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 3, tm.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`,
			 master.getNamaLengkapPegawai(mp.NIP) KASIR,
			 master.getNamaLengkapPegawai(mpdok.NIP) PETUGASMEDIS,
			 INSERT(INSERT(INSERT(LPAD(ps.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM,
			 master.getNamaLengkap(ps.NORM) NAMAPASIEN,kjgn.NOPEN,crbyr.DESKRIPSI CARABAYAR, DATE_FORMAT(p.TANGGAL,''%d-%m-%Y %H:%i:%s'') TGLREG,
			 SUM(mtt.DOKTER_OPERATOR) DOKTER_OPERATOR, tm.KUNJUNGAN,
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 	(SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN layanan.tindakan_medis tm ON tm.ID = rt.REF_ID AND rt.JENIS = 3
	  		 LEFT JOIN `master`.tindakan t ON t.ID = tm.TINDAKAN
	  		 LEFT JOIN layanan.petugas_tindakan_medis ptm ON tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS=1 AND KE=1
			 LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
			 LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = tm.KUNJUNGAN
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN
	  		 LEFT JOIN pendaftaran.penjamin pj ON p.NOMOR=pj.NOPEN
	       LEFT JOIN master.referensi crbyr ON pj.JENIS=crbyr.ID AND crbyr.JENIS=10
	  		 LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
	  		 LEFT JOIN master.tarif_tindakan mtt ON rt.TARIF_ID=mtt.ID
	  	  , pembayaran.pembayaran_tagihan pt
	  		, pembayaran.transaksi_kasir tk
	  		  LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		     LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	 WHERE rt.JENIS = 3 AND rt.TAGIHAN=pt.TAGIHAN AND tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.JENIS IN (1,2)
	  AND tk.`STATUS`=2 AND tk.NOMOR IN (',PNOMOR,') 
	  AND tk.KASIR=',PKASIR ,'
	GROUP BY ptm.MEDIS, kjgn.RUANGAN, p.NOMOR, tm.TINDAKAN');

   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakJasaDokterKasirPaket
DROP PROCEDURE IF EXISTS `CetakJasaDokterKasirPaket`;
DELIMITER //
CREATE PROCEDURE `CetakJasaDokterKasirPaket`(
	IN `PNOMOR` VARCHAR(50),
	IN `PKASIR` SMALLINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT RAND() QID, rt.TAGIHAN, rt.REF_ID, 
			 CONCAT(r.DESKRIPSI,
			 	IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('' ('', rk.KAMAR, ''/'', rkt.TEMPAT_TIDUR, ''/'', kls.DESKRIPSI, '')''), '''')
			 ) RUANGAN,
			 pkt.NAMA LAYANAN,
			 rt.JENIS, ref.DESKRIPSI JENIS_RINCIAN,
			 rt.TARIF_ID,
			 IF(rt.JENIS = 5, p.TANGGAL, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF, rt.`STATUS`,
			 dtp.DOKTER_OPERATOR, dtp.DOKTER_ANASTESI, dtp.DOKTER_LAINNYA,
			 INSERT(INSERT(INSERT(LPAD(ps.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM,
			 master.getNamaLengkap(ps.NORM) NAMAPASIEN, p.TANGGAL TGLREG, master.getNamaLengkapPegawai(mp.NIP) KASIR,
			 CONCAT(''PERIODE : '',(SELECT DATE_FORMAT(ts.BUKA,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.BUKA ASC LIMIT 1),'' s/d '',
		 	(SELECT DATE_FORMAT(ts.TUTUP,''%d-%m-%Y %H:%i:%s'') FROM pembayaran.transaksi_kasir ts WHERE ts.NOMOR IN (',PNOMOR,') ORDER BY ts.TUTUP DESC LIMIT 1)) TUTUPKASIR,
			 (SELECT GROUP_CONCAT(DISTINCT(master.getNamaLengkapPegawai(mpdok.NIP)),''\r'') 
					FROM pendaftaran.kunjungan pk
						, layanan.tindakan_medis tm
						, layanan.petugas_tindakan_medis ptm
						  LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
						  LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
						, pembayaran.pembayaran_tagihan pt
						, pembayaran.tagihan_pendaftaran ptp
				   	, pembayaran.rincian_tagihan_paket rtp
						, master.paket_detil pdt
					WHERE pt.TAGIHAN=rt.TAGIHAN AND pk.NOMOR=tm.KUNJUNGAN AND tm.`STATUS` IN (1,2)
						AND tm.ID=ptm.TINDAKAN_MEDIS AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0 AND pt.`STATUS` IN (1,2)
						AND pt.TAGIHAN=ptp.TAGIHAN AND pk.NOPEN=ptp.PENDAFTARAN
						AND pt.TAGIHAN=rtp.TAGIHAN AND rtp.PAKET_DETIL=pdt.ID AND tm.TINDAKAN=pdt.ITEM) DOKTER
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.pendaftaran p ON rt.JENIS = 5 AND p.NOMOR = rt.REF_ID
	  		 LEFT JOIN master.pasien ps ON p.NORM=ps.NORM
	  		 LEFT JOIN `master`.paket pkt ON pkt.ID = p.PAKET
	  		 LEFT JOIN `master`.distribusi_tarif_paket dtp ON dtp.PAKET = pkt.ID AND dtp.STATUS = 1
	  		 LEFT JOIN pendaftaran.tujuan_pasien tp ON tp.NOPEN = p.NOMOR
	  		 LEFT JOIN pendaftaran.reservasi res ON res.NOMOR = tp.RESERVASI
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = res.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.ruangan r ON r.ID = rk.RUANGAN
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi ref ON ref.JENIS = 30 AND ref.ID = rt.JENIS
			, pembayaran.pembayaran_tagihan pt
	  		, pembayaran.transaksi_kasir tk
	  		  LEFT JOIN aplikasi.pengguna us ON tk.KASIR=us.ID
		     LEFT JOIN master.pegawai mp ON us.NIP=mp.NIP
	 WHERE rt.JENIS = 5 AND rt.TAGIHAN=pt.TAGIHAN AND tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND AND pt.JENIS IN (1,2)
	  AND tk.`STATUS`=2 AND tk.NOMOR IN (',PNOMOR,') 
	  AND tk.KASIR=',PKASIR ,'
	  ');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakKwitansi
DROP PROCEDURE IF EXISTS `CetakKwitansi`;
DELIMITER //
CREATE PROCEDURE `CetakKwitansi`(
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
			 @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC, 
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

-- Dumping structure for procedure pembayaran.CetakKwitansiPenjualan
DROP PROCEDURE IF EXISTS `CetakKwitansiPenjualan`;
DELIMITER //
CREATE PROCEDURE `CetakKwitansiPenjualan`(
	IN `PTAGIHAN` CHAR(10),
	IN `PJENIS` TINYINT
)
BEGIN
	SELECT t.ID, t.TANGGAL, t.TOTAL,
			 pt.TANGGAL TANGGALBAYAR,
			 pp.PENGUNJUNG NAMALENGKAP,
			 inst.NAMA NAMAINSTANSI, inst.PPK IDPPK, inst.ALAMAT,
			 pp.KETERANGAN KET,
			 mp.NIP,
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, 
			 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
			 ROUND(t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalEDC(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))), 0) TAGIHAN
	  FROM pembayaran.tagihan t
	  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 8 AND pt.STATUS IN (1, 2)
	  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
			 LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP,
			 penjualan.penjualan pp,
			 (SELECT mp.NAMA,mp.ALAMAT, ai.PPK
				FROM aplikasi.instansi ai
					, master.ppk mp
				WHERE ai.PPK=mp.ID) inst
	 WHERE t.ID = PTAGIHAN AND t.ID = pp.NOMOR
	   AND t.JENIS = PJENIS
	   AND t.`STATUS` = 2;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakRekapPasien
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
			 , w.DESKRIPSI WILAYAH
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

-- Dumping structure for procedure pembayaran.CetakRincianKegiatanPasien
DROP PROCEDURE IF EXISTS `CetakRincianKegiatanPasien`;
DELIMITER //
CREATE PROCEDURE `CetakRincianKegiatanPasien`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT * FROM (
		SELECT 2 IDPAKET, ''LUAR PAKET'' PAKET, r.QID,r.TAGIHAN, r.REF_ID, r.RUANGAN, r.LAYANAN, r.JENIS, r.JENIS_RINCIAN, r.TANGGAL, r.JUMLAH, r.TARIF, 
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, pt.TANGGAL TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 w.DESKRIPSI WILAYAH,
			 (SELECT GROUP_CONCAT(master.getNamaLengkapPegawai(mpdok.NIP))
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN) PETUGASMEDIS
		  FROM (', pembayaran.getSkripRincianTagihan(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS !=0
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		WHERE r.STATUS = ', PSTATUS, ' AND r.JENIS !=5
		  AND ppk.ID = i.PPK 
		  AND w.ID = ppk.WILAYAH
		UNION
		SELECT 1 IDPAKET, ''PAKET'' PAKET, RAND() QID, rt.TAGIHAN, rt.REF_ID, rt.RUANGAN, rt.LAYANAN, rt.JENIS, rt.JENIS_RINCIAN, rt.TANGGAL, rt.JUMLAH,rt.TARIF, 
	       INSERT(INSERT(INSERT(LPAD(tg.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, tg.ID IDTAGIHAN,
			 pembayaran.getInfoTagihanKunjungan(tg.ID) JENISKUNJUNGAN, DATE_FORMAT(pt.TANGGAL,''%d-%m-%Y'') TANGGALBAYAR, tg.TANGGAL TANGGALTAGIHAN,
			 w.DESKRIPSI WILAYAH,
			 (SELECT GROUP_CONCAT(master.getNamaLengkapPegawai(mpdok.NIP))
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan_paket rtp
					     , master.paket_detil mpd
					WHERE ptm.TINDAKAN_MEDIS=rt.REF_ID AND ptm.JENIS IN (1,2) AND ptm.MEDIS!=0
						AND ptm.TINDAKAN_MEDIS=rtp.REF_ID  AND rtp.PAKET_DETIL=mpd.ID AND mpd.JENIS=1 AND rtp.TAGIHAN=rt.TAGIHAN) PETUGASMEDIS
	FROM (', pembayaran.getSkripRincianTagihanPaket(PTAGIHAN),'
		)  rt 
	     LEFT JOIN pembayaran.tagihan tg ON rt.TAGIHAN=tg.ID AND tg.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = tg.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = tg.ID AND pt.JENIS = 1 AND pt.STATUS = 1
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON tg.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
	WHERE rt.STATUS = ', PSTATUS, ' AND rt.JENIS !=5
		  AND ppk.ID = i.PPK 
		  AND w.ID = ppk.WILAYAH
	  ) a ORDER BY IDPAKET ASC, RUANGAN DESC
		');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakRincianPasien
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
			 , w.DESKRIPSI WILAYAH
			 , pjt.PERSENTASE_TARIF_INACBG_KELAS1
		  FROM (', pembayaran.getSkripRincianTagihan(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS !=0
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

-- Dumping structure for procedure pembayaran.CetakRincianPasienObat
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
			 , w.DESKRIPSI WILAYAH
			 , pjt.PERSENTASE_TARIF_INACBG_KELAS1
		  FROM (', pembayaran.getSkripRincianTagihanObat(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS !=0
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

-- Dumping structure for procedure pembayaran.CetakRincianPasienPerDokter
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
				 , @tedc:=pembayaran.getTotalEDC(t.ID) TOTALEDC 
				 ,  @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN 
				 ,  @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG
				 , @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT
				 , @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI
				 , IF((@tghn - @tj - @ts - @tp - @td - @tedc - @tdp) <=0, 0,(@tghn - @tj - @ts - @tp - @td - @tedc - @tdp)) JUMLAHBAYAR
			
		  FROM pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  		 LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  		 LEFT JOIN pembayaran.tagihan_pendaftaran tp ON tp.TAGIHAN = t.ID AND tp.UTAMA = 1 AND tp.`STATUS` = 1
		  		 LEFT JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = tp.PENDAFTARAN
		  		 LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		       LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS !=0
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

-- Dumping structure for procedure pembayaran.CetakRincianPasienPerDokter_lama
DROP PROCEDURE IF EXISTS `CetakRincianPasienPerDokter_lama`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPasienPerDokter_lama`(IN `PTAGIHAN` CHAR(10), IN `PSTATUS` TINYINT
)
BEGIN
	SET @sqlText = CONCAT('
		SELECT r.*,  
			 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
			 master.getNamaLengkap(p.NORM) NAMALENGKAP, pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR,
			 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
			 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
			 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
			 t.TOTAL TOTALTAGIHAN, (pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
			 pembayaran.getTotalEDC(t.ID) TOTALEDC, pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
			 (pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
			 pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
			 (t.TOTAL - (pembayaran.getTotalDiskon(t.ID) + pembayaran.getTotalDiskonDokter(t.ID) + 
			 pembayaran.getTotalEDC(t.ID) + pembayaran.getTotalPenjaminTagihan(t.ID) + 
			 pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID) +
			 (pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID))+pembayaran.getTotalSubsidiTagihan(t.ID))) JUMLAHBAYAR
			 , w.DESKRIPSI WILAYAH
			, @dok1:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN LIMIT 1) IS NULL,'''',
						CONCAT('' ['',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=1
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN LIMIT 1),'']'')) DOKTER
			, @dok2:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN LIMIT 1) IS NULL,'''',
						CONCAT('' ['',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS=1 AND ptm.MEDIS!=0 AND ptm.KE=2
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN LIMIT 1),'']'')) DOKTERKEDUA
			, @dok3:=IF((SELECT master.getNamaLengkapPegawai(mpdok.NIP)
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN LIMIT 1) IS NULL,'''',
						CONCAT('' ['',(SELECT master.getNamaLengkapPegawai(mpdok.NIP)
					FROM layanan.petugas_tindakan_medis ptm 
					     LEFT JOIN master.dokter dok ON ptm.MEDIS=dok.ID
					     LEFT JOIN master.pegawai mpdok ON dok.NIP=mpdok.NIP
					     , pembayaran.rincian_tagihan rt
					WHERE ptm.TINDAKAN_MEDIS=r.REF_ID AND ptm.JENIS=2 AND ptm.MEDIS!=0 AND ptm.KE=1
						AND ptm.TINDAKAN_MEDIS=rt.REF_ID AND rt.JENIS=3 AND rt.TAGIHAN=r.TAGIHAN LIMIT 1),'']'')) DOKTERANASTESI
			, mtt.ADMINISTRASI, mtt.SARANA, mtt.BHP, mtt.DOKTER_OPERATOR, mtt.DOKTER_ANASTESI, mtt.DOKTER_LAINNYA
			, mtt.PENATA_ANASTESI, mtt.PARAMEDIS, mtt.NON_MEDIS, mtt.ID
			, IF((SELECT ru.JENIS_KUNJUNGAN
					FROM layanan.tindakan_medis tm
					      , pembayaran.rincian_tagihan rt
					      , pendaftaran.kunjungan pk
					      , master.ruangan ru
					WHERE tm.ID=rt.REF_ID AND rt.JENIS=3 
						AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
						AND rt.TAGIHAN=r.TAGIHAN AND tm.ID=r.REF_ID
						AND pk.RUANGAN=ru.ID
					LIMIT 1
				) IS NULL, 0, (SELECT ru.JENIS_KUNJUNGAN
					FROM layanan.tindakan_medis tm
					      , pembayaran.rincian_tagihan rt
					      , pendaftaran.kunjungan pk
					      , master.ruangan ru
					WHERE tm.ID=rt.REF_ID AND rt.JENIS=3 
						AND tm.KUNJUNGAN=pk.NOMOR AND pk.`STATUS`!=0
						AND rt.TAGIHAN=r.TAGIHAN AND tm.ID=r.REF_ID
						AND pk.RUANGAN=ru.ID
					LIMIT 1
					)) JENIS_KUNJUNGAN
			, IF(tr.ID IS NULL,0,1) STATUSTINDAKANRINCIAN
			, CONCAT(LAYANAN,@dok1) LAYANAN1
			, CONCAT(LAYANAN,''\r'',
					SPACE(3),''Sewa '',RUANGAN,''\r'',
					SPACE(3),''Jasa dr. Operator '',
					@dok1,''\r'',
					SPACE(3),''Jasa dr. Anastesi '',
					@dok3,''\r'',
					SPACE(3),''Jasa dr. Asisten '',
					@dok2,''\r'',
					SPACE(3),''Jasa Penata Anastesi '',''\r''
				) LAYANAN_OK
			, CONCAT('' '',''\r'',
					REPLACE(FORMAT(mtt.SARANA,0),'','',''.''),''\r'',
					REPLACE(FORMAT(mtt.DOKTER_OPERATOR,0),'','',''.''),''\r'',
					REPLACE(FORMAT(mtt.DOKTER_ANASTESI,0),'','',''.''),''\r'',
					REPLACE(FORMAT(mtt.DOKTER_LAINNYA,0),'','',''.''),''\r'',
					REPLACE(FORMAT(mtt.PENATA_ANASTESI,0),'','',''.''),''\r''
				) TARIF_LAYANAN_OK
			, CONCAT('' '',''\r'',
					''Rp.'',''\r'',
					''Rp.'',''\r'',
					''Rp.'',''\r'',
					''Rp.'',''\r'',
					''Rp.''
				) RP
		  FROM (', pembayaran.getSkripRincianTagihan(PTAGIHAN),'
		) r
		  LEFT JOIN pembayaran.tagihan t ON r.TAGIHAN=t.ID AND t.STATUS IN (1,2)
		  LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
  		  LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS = 1
  		  LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		  LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		  LEFT JOIN pembayaran.tagihan_pendaftaran tpd ON t.ID=tpd.TAGIHAN AND tpd.STATUS=1 AND tpd.UTAMA = 1
		  LEFT JOIN pendaftaran.pendaftaran pd ON tpd.PENDAFTARAN=pd.NOMOR AND pd.STATUS IN (1,2)
		  LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  LEFT JOIN master.tarif_tindakan mtt ON r.TARIF_ID=mtt.ID
		  LEFT JOIN master.tindakan_rincian tr ON mtt.TINDAKAN=tr.TINDAKAN AND tr.STATUS=1
		  , aplikasi.instansi i
		  , master.ppk ppk
		  , master.wilayah w
		WHERE r.STATUS = ', PSTATUS, '
		  AND ppk.ID = i.PPK
		  AND w.ID = ppk.WILAYAH
		ORDER BY r.JENIS_KUNJUNGAN
		');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakRincianPenjualan
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
			  , hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100))  HARGA_JUAL
			  , (pd.JUMLAH * (hb.HARGA_JUAL + (hb.HARGA_JUAL * IF(mpf.MARGIN IS NULL, 0, mpf.MARGIN / 100)))) TOTAL
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

-- Dumping structure for procedure pembayaran.CetakSetoranKasir
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
			 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
			 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
			 pembayaran.getTotalEDC(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
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
	 WHERE tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.STATUS IN (1, 2)
	  AND tk.NOMOR IN (',PNOMOR,')
	  AND tk.KASIR=',PKASIR ,'
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasirNonTunai
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
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalEDC(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
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
	WHERE tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.STATUS IN (1, 2)
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS`=2 AND pt.TAGIHAN=dc.TAGIHAN
	  AND tk.KASIR=',PKASIR ,' AND dc.STATUS IN (1,2)
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasirPenjualanNonTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirPenjualanNonTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirPenjualanNonTunai`(IN `PNOMOR` VARCHAR(50), IN `PKASIR` SMALLINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, master.getNamaLengkap(p.NORM) NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalEDC(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
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
	WHERE tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.JENIS=8
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS`=2 AND pt.TAGIHAN=dc.TAGIHAN
	  AND tk.KASIR=',PKASIR ,' AND dc.STATUS IN (1,2)
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

-- Dumping structure for procedure pembayaran.CetakSetoranKasirPenjualanTunai
DROP PROCEDURE IF EXISTS `CetakSetoranKasirPenjualanTunai`;
DELIMITER //
CREATE PROCEDURE `CetakSetoranKasirPenjualanTunai`(IN `PNOMOR` VARCHAR(50), IN `PKASIR` SMALLINT)
BEGIN
	SET @sqlText = CONCAT('
		SELECT INST.NAMAINST, INST.ALAMATINST, master.getNamaLengkapPegawai(mp.NIP) KASIR, tk.BUKA, tk.TUTUP, tk.`STATUS`,
		 INSERT(INSERT(INSERT(LPAD(p.NORM,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, ppj.PENGUNJUNG NAMAPASIEN, pp.NOMOR NOPEN, pt.TAGIHAN, DATE(pt.TANGGAL) TGLBAYAR,
		 pt.JENIS, jb.DESKRIPSI JENISBAYAR, rf.ID IDJENISKUNJUNGAN, rf.DESKRIPSI JENISKUNJUNGAN,
		 crbyr.DESKRIPSI CARABAYAR, pt.TANGGAL, tg.TOTAL TOTALTAGIHAN,
		 (pembayaran.getTotalDiskon(pt.TAGIHAN)+ pembayaran.getTotalDiskonDokter(pt.TAGIHAN)) TOTALDISKON, 
		 pembayaran.getTotalEDC(pt.TAGIHAN) TOTALEDC, pembayaran.getTotalPenjaminTagihan(pt.TAGIHAN) TOTALPENJAMINTAGIHAN, 
		 (pembayaran.getTotalPiutangPasien(pt.TAGIHAN) + pembayaran.getTotalPiutangPerusahaan(pt.TAGIHAN)) TOTALPIUTANG,
		 (pembayaran.getTotalDeposit(pt.TAGIHAN) - pembayaran.getTotalPengembalianDeposit(pt.TAGIHAN)) TOTALDEPOSIT, pt.TOTAL PENERIMAAN, 
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
	WHERE tk.NOMOR=pt.REF AND pt.`STATUS` !=0 AND pt.JENIS=8 AND pt.TAGIHAN=ppj.NOMOR AND ppj.STATUS IN (1,2)
	  AND tk.NOMOR IN (',PNOMOR,') AND tk.`STATUS`=2
	  AND tk.KASIR=',PKASIR ,'
      ORDER BY rf.ID,DATE(pt.TANGGAL),pj.JENIS');
   

	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
END//
DELIMITER ;

/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
