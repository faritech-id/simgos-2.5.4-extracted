-- --------------------------------------------------------
-- Host:                         192.168.23.129
-- Versi server:                 8.0.11 - MySQL Community Server - GPL
-- OS Server:                    Linux
-- HeidiSQL Versi:               12.1.0.6537
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
				 , pj.JENIS IDCARABAYAR, kap.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR
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
				 , IF(pt.TOTAL IS NULL, pembayaran.getTotalTagihanPembayaran(t.ID), pt.TOTAL) TOTALJUMLAHBAYAR
			    , (IF(pt.TOTAL IS NULL, pembayaran.getTotalTagihanPembayaran(t.ID), pt.TOTAL) - @tdp) JUMLAHBAYAR
			    , ROUND(t.PEMBULATAN) PEMBULATAN
				 , IF(INSTR(dm.DIAGNOSA, 'B20') > 1 OR  INSTR(dm.DIAGNOSA, 'HIV') > 1,'',dm.DIAGNOSA) DIAGNOSA
		       , (SELECT DATE_FORMAT(pl.TANGGAL,'%d-%m-%Y %H:%i:%s') FROM layanan.pasien_pulang pl WHERE pl.NOPEN=pd.NOMOR AND pl.`STATUS`!=0 LIMIT 1) TGLKELUAR
				 , pj.NOMOR NOSEP
		  FROM pembayaran.tagihan t
		  		 LEFT JOIN `master`.pasien p ON p.NORM = t.REF
		  		 LEFT JOIN master.referensi rjk ON p.JENIS_KELAMIN=rjk.ID AND rjk.JENIS=2
		  		 LEFT JOIN pembayaran.tagihan_pendaftaran tp ON tp.TAGIHAN = t.ID AND tp.UTAMA = 1 AND tp.`STATUS` = 1
		  		 LEFT JOIN pendaftaran.pendaftaran pd ON pd.NOMOR = tp.PENDAFTARAN
		  		 LEFT JOIN pendaftaran.penjamin pj ON pd.NOMOR=pj.NOPEN
		  		 LEFT JOIN `master`.kartu_asuransi_pasien kap ON kap.JENIS=2 AND kap.NORM=pd.NORM
		       LEFT JOIN master.referensi rf ON pj.JENIS=rf.ID AND rf.JENIS=10
		  		 LEFT JOIN pembayaran.pembayaran_tagihan pt ON pt.TAGIHAN = t.ID AND pt.JENIS = 1 AND pt.STATUS IN (1, 2)
		  		 LEFT JOIN pembayaran.penjamin_tagihan pjt ON t.ID=pjt.TAGIHAN AND pjt.KE=1
		  		 LEFT JOIN aplikasi.pengguna us ON us.ID = pt.OLEH
		       LEFT JOIN master.pegawai mp ON mp.NIP = us.NIP
		       LEFT JOIN `master`.diagnosa_masuk dm ON pd.DIAGNOSA_MASUK=dm.ID
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
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')', IF(kjgn.TITIPAN = 1, CONCAT(' Pasien Titipan ', kls1.DESKRIPSI), '')), '')
			 ) RUANGAN,
			 IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT(' (', rk.KAMAR, '/', rkt.TEMPAT_TIDUR, '/', kls.DESKRIPSI, ')', IF(kjgn.TITIPAN = 1, CONCAT(' Pasien Titipan ', kls1.DESKRIPSI), '')), '') LAYANAN,
			 IF(rt.JENIS = 2, kjgn.MASUK, NULL) TANGGAL, 
			 rt.JUMLAH, rt.TARIF - IF(rt.PERSENTASE_DISKON = 0, rt.DISKON, rt.TARIF * (rt.DISKON/100)) TARIF
			 , r.JENIS_KUNJUNGAN
			 , ref.DESKRIPSI DESKRIPSI_KUNJUNGAN
			 , IF(r.JENIS_KUNJUNGAN = 3,
			 		CONCAT('Akomodasi (',DATE_FORMAT(kjgn.MASUK,'%d-%m-%Y %H:%i:%s'),')'), '') JENIS_RINCIAN
	  FROM pembayaran.rincian_tagihan rt
	  		 LEFT JOIN pendaftaran.kunjungan kjgn ON kjgn.NOMOR = rt.REF_ID AND rt.JENIS = 2 AND kjgn.`STATUS`!=0
	  		 LEFT JOIN pendaftaran.pendaftaran p ON p.NOMOR = kjgn.NOPEN AND p.`STATUS`!=0
	  		 LEFT JOIN `master`.ruangan r ON r.ID = kjgn.RUANGAN
	  		 LEFT JOIN `master`.referensi ref ON r.JENIS_KUNJUNGAN=ref.ID AND ref.`STATUS`!=0 AND ref.JENIS = 15
	  		 LEFT JOIN `master`.ruang_kamar_tidur rkt ON rkt.ID = kjgn.RUANG_KAMAR_TIDUR
	  		 LEFT JOIN `master`.ruang_kamar rk ON rk.ID = rkt.RUANG_KAMAR
	  		 LEFT JOIN `master`.referensi kls ON kls.JENIS = 19 AND kls.ID = rk.KELAS
	  		 LEFT JOIN `master`.referensi jr ON rt.JENIS=jr.ID AND jr.`STATUS`!=0 AND jr.JENIS = 30
	  		 LEFT JOIN `master`.referensi kls1 ON kls1.JENIS = 19 AND kls1.ID = kjgn.TITIPAN_KELAS
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
	
	SELECT thr.*, tdr.*, SUM(IFNULL(JUMLAH, 0)) TOTAL_JUMLAH, SUM(JUMLAH * TARIF) TOTAL
	  FROM TEMP_HEADER_RINCIAN thr
	       , TEMP_DETIL_RINCIAN tdr
	 WHERE tdr.TAGIHAN = thr.NOMOR_TAGIHAN
	 GROUP BY RUANGAN, JENIS_RINCIAN
	 ORDER BY JENIS_KUNJUNGAN, JENIS_RINCIAN
	 ;	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
