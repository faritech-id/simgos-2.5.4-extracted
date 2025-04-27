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

-- membuang struktur untuk procedure pembayaran.CetakRincianPasienPaket
DROP PROCEDURE IF EXISTS `CetakRincianPasienPaket`;
DELIMITER //
CREATE PROCEDURE `CetakRincianPasienPaket`(
	IN `PTAGIHAN` CHAR(10),
	IN `PSTATUS` TINYINT
)
BEGIN
	
	DECLARE VPAKET SMALLINT;
	
	SELECT pd.PAKET INTO VPAKET
		FROM pembayaran.tagihan_pendaftaran tpd 
			, pendaftaran.pendaftaran pd
		WHERE tpd.TAGIHAN=PTAGIHAN AND tpd.UTAMA=1 AND tpd.`STATUS`!=0
		  AND tpd.PENDAFTARAN=pd.NOMOR AND pd.`STATUS`!=0
		  LIMIT 1;
	
	IF (FOUND_ROWS()=0 OR VPAKET IS NULL) THEN
	
		SET @sqlText = CONCAT('
			SELECT r.*, 
				 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
				 master.getNamaLengkap(p.NORM) NAMALENGKAP, pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR,
				 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
				 master.getNamaLengkapPegawai(d.NIP) DOKTER,
				 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
				 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
				 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
				 pjt.NAIK_KELAS, pjt.NAIK_KELAS_VIP, pjt.NAIK_DIATAS_VIP, t.TOTAL TOTALRS,
				 @tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN,
				 @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
				 @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC, 
				 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
				 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
				 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
				 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
				(IF(pt.TOTAL IS NULL, IF((ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN)) < 0 ,0,(ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN))), pt.TOTAL) ) TOTALJUMLAHBAYAR,
			   (IF(pt.TOTAL IS NULL, IF((ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN)) < 0 ,0,(ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN))), pt.TOTAL) - @tdp) JUMLAHBAYAR
				
				  , ppk.NAMA NAMAINSTANSI, ppk.ALAMAT ALAMATINSTANSI, ppk.TELEPON, i.PPK
				 , w.DESKRIPSI WILAYAH
				 , pjt.PERSENTASE_TARIF_INACBG_KELAS1
				 , ROUND(t.PEMBULATAN) PEMBULATAN
				, IF(INSTR(dm.DIAGNOSA, ''B20'') > 1 OR  INSTR(dm.DIAGNOSA, ''HIV'') > 1 OR pd.PAKET  > 0,'''',dm.DIAGNOSA) DIAGNOSA
					 , (SELECT DATE_FORMAT(pl.TANGGAL,''%d-%m-%Y %H:%i:%s'') FROM layanan.pasien_pulang pl WHERE pl.NOPEN=pd.NOMOR AND pl.`STATUS`!=0 LIMIT 1) TGLKELUAR
					 , pj.NOMOR NOSEP, IF(pd.PAKET IS NULL OR pd.PAKET=0,0,1) PAKET
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
			  LEFT JOIN `master`.diagnosa_masuk dm ON pd.DIAGNOSA_MASUK=dm.ID
			  , aplikasi.instansi i
			  , master.ppk ppk
			  , master.wilayah w
			  , aplikasi.properti_config pc
			WHERE r.STATUS = ', PSTATUS, '
			  AND ppk.ID = i.PPK
			  AND w.ID = ppk.WILAYAH
			  AND pc.ID = 9
			');

	ELSE 
		SET @sqlText = CONCAT('
				SELECT r.*, 
					 INSERT(INSERT(INSERT(LPAD(t.REF,8,''0''),3,0,''-''),6,0,''-''),9,0,''-'') NORM, pd.NOMOR NOPEN, DATE_FORMAT(pd.TANGGAL,''%d-%m-%Y %H:%i:%s'') TANGGALREG,
					 master.getNamaLengkap(p.NORM) NAMALENGKAP, pj.JENIS IDCARABAYAR, pj.NOMOR NOMORKARTU, rf.DESKRIPSI CARABAYAR,
					 p.TANGGAL_LAHIR, CONCAT(rjk.DESKRIPSI,'' ('',master.getCariUmur(pd.TANGGAL,p.TANGGAL_LAHIR),'')'') UMUR, 
					 master.getNamaLengkapPegawai(d.NIP) DOKTER,
					 master.getNamaLengkapPegawai(mp.NIP) PENGGUNA, t.ID IDTAGIHAN,
					 (SELECT NAMA FROM cetakan.kwitansi_pembayaran kp WHERE kp.TAGIHAN=t.ID ORDER BY kp.TANGGAL DESC LIMIT 1) PEMBAYAR,
					 pembayaran.getInfoTagihanKunjungan(t.ID) JENISKUNJUNGAN, IF(pt.TANGGAL IS NULL, SYSDATE(), pt.TANGGAL) TANGGALBAYAR, t.TANGGAL TANGGALTAGIHAN,
					 pjt.NAIK_KELAS, pjt.NAIK_KELAS_VIP, pjt.NAIK_DIATAS_VIP, t.TOTAL TOTALRS,
					@tghn:=(IF(pj.JENIS=2 AND pjt.NAIK_KELAS=1,(pjt.TOTAL_NAIK_KELAS), IF(pj.JENIS=2 AND pjt.NAIK_KELAS_VIP=1, pjt.TARIF_INACBG_KELAS1,t.TOTAL)) + IF(pjt.SELISIH_MINIMAL IS NULL,0,pjt.SELISIH_MINIMAL)) TOTALTAGIHAN,
					 @td:=(pembayaran.getTotalDiskon(t.ID)+ pembayaran.getTotalDiskonDokter(t.ID)) TOTALDISKON, 
					 @tedc:=pembayaran.getTotalNonTunai(t.ID) TOTALEDC, 
					 @tj:=pembayaran.getTotalPenjaminTagihan(t.ID) TOTALPENJAMINTAGIHAN, 
					 @tp:=(pembayaran.getTotalPiutangPasien(t.ID) + pembayaran.getTotalPiutangPerusahaan(t.ID)) TOTALPIUTANG,
					 @tdp:=(pembayaran.getTotalDeposit(t.ID) - pembayaran.getTotalPengembalianDeposit(t.ID)) TOTALDEPOSIT,
					 @ts:=pembayaran.getTotalSubsidiTagihan(t.ID) TOTALSUBSIDI,
					 (IF(pt.TOTAL IS NULL, IF((ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN)) < 0 ,0,(ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN))), pt.TOTAL) ) TOTALJUMLAHBAYAR,
			   (IF(pt.TOTAL IS NULL, IF((ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN)) < 0 ,0,(ROUND(pembayaran.getTotalTagihanPembayaran(t.ID)) + ROUND(t.PEMBULATAN))), pt.TOTAL) - @tdp) JUMLAHBAYAR
				
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
					  , ppk.NAMA NAMAINSTANSI, ppk.ALAMAT ALAMATINSTANSI, ppk.TELEPON, i.PPK
					 , w.DESKRIPSI WILAYAH
					 , pjt.PERSENTASE_TARIF_INACBG_KELAS1
					 , ROUND(t.PEMBULATAN) PEMBULATAN
					, IF(INSTR(dm.DIAGNOSA, ''B20'') > 1 OR  INSTR(dm.DIAGNOSA, ''HIV'') > 1 OR pd.PAKET  > 0,'''',dm.DIAGNOSA) DIAGNOSA
						 , (SELECT DATE_FORMAT(pl.TANGGAL,''%d-%m-%Y %H:%i:%s'') FROM layanan.pasien_pulang pl WHERE pl.NOPEN=pd.NOMOR AND pl.`STATUS`!=0 LIMIT 1) TGLKELUAR
						 , pj.NOMOR NOSEP, IF(pd.PAKET IS NULL OR pd.PAKET=0,0,1) PAKET
				  FROM (', pembayaran.getSkripRincianTagihanPaket(PTAGIHAN),'
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
				  LEFT JOIN `master`.diagnosa_masuk dm ON pd.DIAGNOSA_MASUK=dm.ID
				  , aplikasi.instansi i
				  , master.ppk ppk
				  , master.wilayah w
				  , aplikasi.properti_config pc
				WHERE r.STATUS = ', PSTATUS, '
				  AND ppk.ID = i.PPK
				  AND w.ID = ppk.WILAYAH
				  AND pc.ID = 9
				ORDER BY RUANGAN
				');
				
	END IF;
	
	PREPARE stmt FROM @sqlText;
	EXECUTE stmt;
	DEALLOCATE PREPARE stmt;
	
END//
DELIMITER ;

/*!40103 SET TIME_ZONE=IFNULL(@OLD_TIME_ZONE, 'system') */;
/*!40101 SET SQL_MODE=IFNULL(@OLD_SQL_MODE, '') */;
/*!40014 SET FOREIGN_KEY_CHECKS=IFNULL(@OLD_FOREIGN_KEY_CHECKS, 1) */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40111 SET SQL_NOTES=IFNULL(@OLD_SQL_NOTES, 1) */;
